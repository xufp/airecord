package mediaservice

import (
	"context"
	"encoding/binary"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"

	"github.com/smartox/ai_record_server/internal/application/ports/recognizer"
	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	domainservice "github.com/smartox/ai_record_server/internal/domain/service"
	"github.com/smartox/ai_record_server/internal/infrastructure/adapters/asrv2"
	"github.com/smartox/ai_record_server/internal/infrastructure/adapters/cos"
	"github.com/smartox/ai_record_server/internal/infrastructure/config"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"trpc.group/trpc-go/trpc-go/errs"
	"trpc.group/trpc-go/trpc-go/log"
)

func NewMediaSpeech(transMgr repository.RepoTransMgr, userId int64) *MediaSpeech {
	return &MediaSpeech{
		transMgr: transMgr,
		userId:   userId,
	}
}

type MediaSpeech struct {
	transMgr       repository.RepoTransMgr
	userId         int64
	mediaInfo      *entity.MediaInfo
	mediaRec       *entity.MediaRec
	filePath       string
	convertUsage   *entity.ServiceUsage
	file           *os.File
	recognizer     recognizer.SpeechRecognizer
	fileSize       int64
	duration       int64
	sentenceDetail entity.SentenceDetail
	index          int32  // 记录暂停恢复时最后一个片段的index
	endTime        uint32 // 记录暂停恢复时最后一个片段的结束时间
}

func (m *MediaSpeech) MediaSpeech(ctx context.Context, req *protocol.MediaSpeechReq) error {
	if err := m.checkMediaInfo(ctx, req); err != nil {
		return err
	}

	if err := m.genMediaInfo(ctx, req); err != nil {
		return err
	}

	if err := m.saveMediaInfo(ctx); err != nil {
		return err
	}

	return nil
}

func (m *MediaSpeech) MediaCreate(
	ctx context.Context, mediaStream chan protocol.MediaSpeechData, asrStream chan protocol.MediaSpeechRsp,
) error {
	file, err := os.OpenFile(m.filePath, os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		return err
	}
	m.file = file

	// 创建转写服务
	m.recognizer = asrv2.NewSpeechRecognizer(config.GetServerConfig().Media.Asr)
	if err := m.recognizer.SpeechRecognition(ctx, m.mediaRec, mediaStream, asrStream); err != nil {
		return err
	}

	// 更新音频状态
	m.mediaInfo.State = entity.MediaStateProcessing

	if err := m.transMgr.DoTransaction(ctx, func(ctx context.Context, repo repository.AiRecordRepo) error {
		// 锁用户
		if _, err := repo.UserRepo().LockUserInfo(ctx, m.userId); err != nil {
			return err
		}

		// 保存音频信息
		if err := repo.MediaRepo().UpdateMediaInfo(ctx, m.mediaInfo); err != nil {
			return err
		}

		return nil
	}); err != nil {
		return err
	}

	return nil
}

func (m *MediaSpeech) MediaResume(
	ctx context.Context, mediaStream chan protocol.MediaSpeechData, asrStream chan protocol.MediaSpeechRsp,
) error {
	// 恢复转写服务
	if err := m.recognizer.SpeechRecognition(ctx, m.mediaRec, mediaStream, asrStream); err != nil {
		return err
	}

	// 恢复时计算最后片段的index和结束时间
	if len(m.sentenceDetail.SentenceList) > 0 {
		lastSentence := m.sentenceDetail.SentenceList[len(m.sentenceDetail.SentenceList)-1]
		m.index = lastSentence.Index + 1
		m.endTime = lastSentence.EndTime
	}

	return nil
}

func (m *MediaSpeech) MediaWrite(ctx context.Context, data []byte) error {
	// 存储文件大小计算
	m.fileSize += int64(len(data))

	// 写入文件内容
	if _, err := m.file.Write(data); err != nil {
		return err
	}

	return nil
}

func (m *MediaSpeech) MediaConvertRspFix(rsp protocol.MediaSpeechRsp) protocol.MediaSpeechRsp {
	// 暂停恢复时，转写结果数据修复
	rsp.Result.Index = rsp.Result.Index + m.index
	rsp.Result.StartTime = rsp.Result.StartTime + m.endTime
	rsp.Result.EndTime = rsp.Result.EndTime + m.endTime
	return rsp
}

func (m *MediaSpeech) MediaConvert(ctx context.Context, rsp protocol.MediaSpeechRsp) error {
	m.duration += int64(rsp.Result.EndTime - rsp.Result.StartTime)
	m.mediaRec.Text += rsp.Result.Text

	// 写入识别结果明细
	s := entity.Sentence{
		Index:     rsp.Result.Index,
		StartTime: rsp.Result.StartTime,
		EndTime:   rsp.Result.EndTime,
		Text:      rsp.Result.Text,
	}

	m.sentenceDetail.SentenceList = append(m.sentenceDetail.SentenceList, s)

	return nil
}

// 修复WAV文件头的方法
func fixWavHeader(filePath string) error {
	// 打开WAV文件
	file, err := os.OpenFile(filePath, os.O_RDWR, 0644)
	if err != nil {
		return fmt.Errorf("error opening file: %v", err)
	}

	defer func(file *os.File) {
		err := file.Close()
		if err != nil {
			log.ErrorContextf(context.Background(), "fixWavHeader file close err %s", err.Error())
		}
	}(file)

	// 读取WAV文件头（44字节）
	header := make([]byte, 44)
	_, err = file.Read(header)
	if err != nil && err != io.EOF {
		return fmt.Errorf("error reading file header: %v", err)
	}

	// 读取音频数据
	// 通过跳过文件头的44字节来读取数据部分
	audioData, err := io.ReadAll(file)
	if err != nil {
		return fmt.Errorf("error reading audio data: %v", err)
	}

	// 获取音频数据大小
	audioDataSize := len(audioData)

	// 计算新的文件大小
	newFileSize := 36 + audioDataSize

	// 更新数据大小字段（40-43字节）和文件大小字段（4-7字节）
	binary.LittleEndian.PutUint32(header[40:44], uint32(audioDataSize)) // 更新数据块大小
	binary.LittleEndian.PutUint32(header[4:8], uint32(newFileSize))     // 更新文件总大小

	// 将文件指针重新定位到文件的开头
	_, err = file.Seek(0, io.SeekStart)
	if err != nil {
		return fmt.Errorf("error seeking to file start: %v", err)
	}

	// 写入更新后的头部
	_, err = file.Write(header)
	if err != nil {
		return fmt.Errorf("error writing header: %v", err)
	}

	// 写入音频数据
	_, err = file.Write(audioData)
	if err != nil {
		return fmt.Errorf("error writing audio data: %v", err)
	}

	return nil
}

func (m *MediaSpeech) MediaClose(ctx context.Context, asrErr error) error {
	defer func() {
		// delete file
		if err := os.Remove(m.filePath); err != nil {
			log.ErrorContextf(ctx, "remove file err %s", err.Error())
		}
	}()

	// 关闭文件，保存音频信息
	err := m.file.Close()
	if err != nil {
		log.ErrorContextf(ctx, "saveFile close err %s", err.Error())
	}

	// 修复WAV文件头
	if m.mediaInfo.FileFormat == entity.MediaFileFormatWav {
		if err := fixWavHeader(m.filePath); err != nil {
			log.ErrorContextf(ctx, "fixWavHeader err %s", err.Error())
		}
	}

	// 已有成功转写内容，过程中发生错误关闭时，按成功保存信息
	if len(m.mediaRec.Text) != 0 {
		asrErr = nil
	}

	if asrErr == nil {
		// 上传音频文件
		err := m.mediaUpload(ctx)
		if err != nil {
			log.ErrorContextf(ctx, "media upload fail. %+v", err)
		}
	}

	if err := m.transMgr.DoTransaction(ctx, func(ctx context.Context, repo repository.AiRecordRepo) error {
		// 锁用户
		if _, err := repo.UserRepo().LockUserInfo(ctx, m.userId); err != nil {
			return err
		}

		// 获取已存在记录
		saved, err := repo.MediaRepo().GetMediaInfo(ctx, m.MediaId())
		if err != nil {
			return err
		}

		if saved.State == entity.MediaStateSuccess {
			return nil
		}

		// 音频信息保存
		if asrErr != nil {
			m.mediaInfo.State = entity.MediaStateFailed
			m.mediaInfo.MediaUrl = ""

			m.mediaRec.State = entity.MediaRecStateFailed
			m.mediaRec.Memo = asrErr.Error()
		} else {
			// 音频文件处理
			log.InfoContextf(ctx, "media close. duration: %d ", m.duration)
			m.mediaInfo.FileSize = m.fileSize
			m.mediaInfo.Duration = m.duration
			m.mediaInfo.State = entity.MediaStateSuccess
			// m.mediaInfo.Summary = utils.TruncateString(m.mediaRec.Text, 64)
			recTime := time.Now()
			m.mediaInfo.RecTime = &recTime

			m.mediaRec.State = entity.MediaRecStateSuccess
			m.mediaRec.Memo = "success"
			m.mediaRec.SentenceDetail = m.sentenceDetail.Marshal()
			m.mediaRec.Duration = m.duration
		}

		if err := repo.MediaRepo().UpdateMediaInfo(ctx, m.mediaInfo); err != nil {
			return err
		}

		if err := repo.MediaRepo().UpdateMediaRec(ctx, m.mediaRec); err != nil {
			return err
		}

		// 服务费用扣除
		if asrErr == nil {
			// 转写服务消费
			if err := domainservice.NewUserService(repo.ServiceRepo(), m.userId).UserConvertServiceCost(ctx, m.MediaId(),
				m.mediaRec.Duration, true); err != nil {
				return err
			}
		}

		return nil
	}); err != nil {
		return err
	}

	return nil
}

func (m *MediaSpeech) genMediaInfo(ctx context.Context, req *protocol.MediaSpeechReq) error {
	// 生成MediaInfo
	m.mediaInfo = &entity.MediaInfo{
		UserId:         m.userId,
		MediaName:      req.MediaName,
		FileFormat:     req.FileFormat,
		FileSize:       0,
		FileSign:       "",
		RecordTime:     time.Now(),
		RecordAddress:  req.RecordAddress,
		Duration:       0,
		MediaUrl:       "",
		State:          entity.MediaStateInit,
		Summary:        "",
		Description:    "",
		MediaType:      entity.MediaTypeSpeechFile,
		DeviceId:       req.DeviceId,
		Lstate:         entity.LStateActive,
		CreateTime:     time.Now(),
		LastUpdateTime: time.Now(),
	}

	// Generate a unique filename
	ext := filepath.Ext(req.MediaName)
	name := strings.TrimSuffix(req.MediaName, ext)
	newFileName := fmt.Sprintf("%s_%s%s", name, time.Now().Format("20060102150405"), ext)
	if !strings.HasSuffix(req.MediaName, "."+req.FileFormat) {
		newFileName = fmt.Sprintf("%s.%s", req.MediaName, req.FileFormat)
	}
	// newFileName := fmt.Sprintf("%s_%s.%s", req.MediaName, time.Now().Format("20060102150405"), req.FileFormat)
	log.InfoContextf(ctx, "upload file name new: %s", newFileName)

	// 创建上传文件的目录
	dirPath := filepath.Join(config.GetServerConfig().Media.Storage.Path, strconv.FormatInt(m.userId, 10))
	if err := os.MkdirAll(dirPath, 0755); err != nil {
		fmt.Printf("Failed to create upload directory: %v\n", err)
		return err
	}
	// 创建保存文件的路径
	filePath := filepath.Join(dirPath, newFileName)

	// 创建目标文件
	file, err := os.Create(filePath)
	if err != nil {
		return errs.Newf(errorcode.ErrParamsInvalid, "error saving the file")
	}
	defer func(dst *os.File) {
		err := dst.Close()
		if err != nil {
			log.ErrorContextf(ctx, "saveFile close err %s", err.Error())
		}
	}(file)

	// MediaUrl 先记录本地文件地址
	m.mediaInfo.MediaUrl = config.StorageModeFilePrefix + filePath
	m.filePath = filePath

	log.InfoContextf(ctx, "genMediaInfo: %+v", m.mediaInfo)

	m.mediaRec = &entity.MediaRec{
		MediaId:        m.mediaInfo.MediaId,
		RecForm:        entity.MediaRecFormSpeech,
		EngineType:     req.EngineType,
		Format:         req.FileFormat,
		ObjectName:     "",
		State:          entity.MediaRecStateWaiting,
		Memo:           "waiting",
		CreateTime:     time.Now(),
		LastUpdateTime: time.Now(),
	}

	return nil
}

func (m *MediaSpeech) checkMediaInfo(ctx context.Context, req *protocol.MediaSpeechReq) error {
	// 文件格式校验
	if req.FileFormat != "mp3" && req.FileFormat != "wav" && req.FileFormat != "pcm" && req.FileFormat != "opus" {
		return errs.Newf(errorcode.ErrParamsInvalid, "not support file format.")
	}

	// 文件重复上传校验
	if _, err := m.transMgr.GetRepository().MediaRepo().GetMediaInfoByName(ctx, m.userId, req.MediaName); err == nil {
		return errs.Newf(errorcode.ErrMediaNameExisted, "media name is existed")
	}

	// 速记功能启用校验
	// mediaList, err := m.repo.MediaRepo().FindUserLiveRecMedia(ctx, m.userId)
	// if err != nil {
	// 	return err
	// }
	// if len(mediaList) != 0 {
	// 	return errs.Newf(errorcode.ErrRecServiceNotAllow, "media asrv2 logic not allow")
	// }

	convertUsage, err := domainservice.NewUserService(m.transMgr.GetRepository().ServiceRepo(),
		m.userId).GetUserServiceUsage(ctx,
		entity.ServiceTypeConvert)
	if err != nil {
		return err
	}
	if convertUsage.Total-convertUsage.Used <= 0 {
		return errs.Newf(errorcode.ErrBalanceInsufficient, "insufficient user convert times")
	}
	m.convertUsage = convertUsage

	return nil
}

func (m *MediaSpeech) saveMediaInfo(ctx context.Context) error {
	if err := m.transMgr.DoTransaction(ctx, func(ctx context.Context, repo repository.AiRecordRepo) error {
		// 锁用户
		if _, err := repo.UserRepo().LockUserInfo(ctx, m.userId); err != nil {
			return err
		}

		// 保存音频信息
		if err := repo.MediaRepo().SaveMediaInfo(ctx, m.mediaInfo); err != nil {
			return err
		}
		m.mediaRec.MediaId = m.mediaInfo.MediaId

		// 保存音频转写信息
		if err := repo.MediaRepo().SaveMediaRec(ctx, m.mediaRec); err != nil {
			return err
		}

		return nil
	}); err != nil {
		return err
	}

	return nil
}

func (m *MediaSpeech) MediaId() int64 {
	if m.mediaInfo != nil {
		return m.mediaInfo.MediaId
	}
	return 0
}

func (m *MediaSpeech) mediaUpload(ctx context.Context) error {
	log.DebugContextf(ctx, "upload media to cos")
	cfg := config.GetServerConfig().Media.Storage.Cos
	// MediaUrl
	fileName := m.mediaInfo.MediaName
	if !strings.HasSuffix(m.mediaInfo.MediaName, "."+m.mediaInfo.FileFormat) {
		fileName = fmt.Sprintf("%s.%s", m.mediaInfo.MediaName, m.mediaInfo.FileFormat)
	}
	objectName := fmt.Sprintf("%s/%d/%s", cfg.Path, m.userId, fileName)
	mediaUrl := config.StorageModeCosPrefix + objectName

	// 音频文件上传云存储
	if err := cos.NewObjectStorage(cfg).PutObject(ctx, m.filePath, objectName); err != nil {
		return err
	}

	m.mediaInfo.MediaUrl = mediaUrl
	m.mediaRec.ObjectName = objectName

	return nil
}
