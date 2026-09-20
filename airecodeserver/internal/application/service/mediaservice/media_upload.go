package mediaservice

import (
	"context"
	"crypto/sha256"
	"encoding/json"
	"fmt"
	"io"
	"mime/multipart"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"

	"github.com/faiface/beep"
	"github.com/faiface/beep/mp3"
	"github.com/faiface/beep/wav"
	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	"github.com/smartox/ai_record_server/internal/infrastructure/adapters/cos"
	"github.com/smartox/ai_record_server/internal/infrastructure/config"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"github.com/smartox/ai_record_server/internal/infrastructure/utils"
	"trpc.group/trpc-go/trpc-go/errs"
	"trpc.group/trpc-go/trpc-go/log"
)

func NewMediaUpload(transMgr repository.RepoTransMgr, userId int64) *MediaUpload {
	return &MediaUpload{
		transMgr: transMgr,
		userId:   userId,
		cfg:      config.GetServerConfig().Media.Storage.Cos,
	}
}

type MediaUpload struct {
	userId     int64
	transMgr   repository.RepoTransMgr
	cfg        config.CosCfg
	meta       *protocol.MediaMeta
	mediaInfo  *entity.MediaInfo
	filePath   string
	fileSign   string
	objectName string
}

func (m *MediaUpload) MediaUpload(ctx context.Context, req *protocol.MediaUploadReq) (
	*protocol.MediaUploadRsp, error,
) {
	// 解析请求参数
	if err := m.parseRequestParams(ctx, req); err != nil {
		return nil, err
	}

	// 构造音频&用量信息
	if err := m.genMediaInfo(ctx); err != nil {
		return nil, err
	}

	// 音频信息校验
	if err := m.checkMediaInfo(ctx); err != nil {
		// 重入，按成功返回
		if errs.Code(err) == errorcode.ErrMediaRepeatUpload {
			return &protocol.MediaUploadRsp{
				MediaId: m.mediaInfo.MediaId,
			}, nil
		}
		return nil, err
	}

	// 音频信息保存
	if err := m.saveMediaInfo(ctx); err != nil {
		return nil, err
	}

	return &protocol.MediaUploadRsp{
		MediaId: m.mediaInfo.MediaId,
	}, nil
}

func (m *MediaUpload) parseRequestParams(ctx context.Context, req *protocol.MediaUploadReq) error {
	// 限制上传文件的大小（这里限制为10MB）
	if err := req.Req.ParseMultipartForm(10 << 20); err != nil {
		return err
	}

	// 获取文件元信息
	metadata := req.Req.FormValue("meta")
	if len(metadata) == 0 {
		return errs.Newf(errorcode.ErrParamsInvalid, "meta is miss")
	}

	var meta protocol.MediaMeta
	if err := json.Unmarshal([]byte(metadata), &meta); err != nil {
		return errs.Newf(errorcode.ErrParamsInvalid, "invalid meta format")
	}
	m.meta = &meta

	// 元数据校验
	if err := utils.ValidateStruct(m.meta); err != nil {
		return err
	}

	// 获取上传的文件
	file, handler, err := req.Req.FormFile("file")
	if err != nil {
		log.ErrorContextf(ctx, "got formFile err %s", err.Error())
		return errs.Newf(errorcode.ErrParamsInvalid, "error retrieving the file")
	}
	defer func(file multipart.File) {
		err := file.Close()
		if err != nil {
			log.ErrorContextf(ctx, "formFile close err %s", err.Error())
		}
	}(file)

	log.InfoContextf(ctx, "upload file name: %s", handler.Filename)

	// Generate a unique filename
	ext := filepath.Ext(handler.Filename)
	name := strings.TrimSuffix(handler.Filename, ext)
	newFileName := fmt.Sprintf("%s_%s%s", name, time.Now().Format("20060102150405"), ext)
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
	dst, err := os.Create(filePath)
	if err != nil {
		return errs.Newf(errorcode.ErrParamsInvalid, "error saving the file")
	}
	defer func(dst *os.File) {
		err := dst.Close()
		if err != nil {
			log.ErrorContextf(ctx, "saveFile close err %s", err.Error())
		}
	}(dst)

	// 将上传的文件内容复制到目标文件
	if _, err := io.Copy(dst, file); err != nil {
		return errs.Newf(errorcode.ErrParamsInvalid, "error writing the file")
	}

	m.filePath = filePath

	return nil
}

func (m *MediaUpload) genMediaInfo(ctx context.Context) error {
	// 生成MediaInfo
	m.mediaInfo = &entity.MediaInfo{
		UserId:         m.userId,
		MediaName:      m.meta.MediaName,
		FileFormat:     "",
		FileSize:       0,
		FileSign:       m.meta.FileSign,
		RecordAddress:  m.meta.RecordAddress,
		Duration:       0,
		MediaUrl:       "",
		State:          entity.MediaStateUploaded,
		Summary:        "",
		Description:    "",
		MediaType:      entity.MediaTypeRecorderFile,
		DeviceId:       m.meta.DeviceId,
		Lstate:         entity.LStateActive,
		CreateTime:     time.Now(),
		LastUpdateTime: time.Now(),
	}

	// 获取音频文件元数据
	if err := m.getMediaMetaInfo(ctx); err != nil {
		return err
	}

	// RecordTime
	rt, err := time.Parse("2006-01-02 15:04:05", m.meta.RecordTime)
	if err != nil {
		return err
	}
	m.mediaInfo.RecordTime = rt

	// MediaUrl
	fileName := m.mediaInfo.MediaName
	if !strings.HasSuffix(m.mediaInfo.MediaName, "."+m.mediaInfo.FileFormat) {
		fileName = fmt.Sprintf("%s.%s", m.mediaInfo.MediaName, m.mediaInfo.FileFormat)
	}
	m.objectName = fmt.Sprintf("%s/%d/%s", m.cfg.Path, m.userId, fileName)
	m.mediaInfo.MediaUrl = config.StorageModeCosPrefix + m.objectName

	log.InfoContextf(ctx, "genMediaInfo: %+v", m.mediaInfo)
	return nil
}

func (m *MediaUpload) checkMediaInfo(ctx context.Context) error {
	// 文件格式校验
	ext := strings.ToLower(filepath.Ext(m.filePath))
	if ext != ".mp3" && ext != ".wav" {
		return errs.Newf(errorcode.ErrParamsInvalid, "not support file format.")
	}

	// 文件签名校验
	if m.mediaInfo.FileSign != m.fileSign {
		return errs.Newf(errorcode.ErrParamsInvalid, "file sign check failed.")
	}

	// 文件重复上传校验
	media, err := m.transMgr.GetRepository().MediaRepo().GetMediaInfoByName(ctx, m.userId, m.mediaInfo.MediaName)
	if err == nil {
		// 文件已存在
		if media.FileSign == m.mediaInfo.FileSign {
			m.mediaInfo = media
			return errs.Newf(errorcode.ErrMediaRepeatUpload, "media repeat upload")
		} else {
			return errs.Newf(errorcode.ErrMediaNameExisted, "media name is existed")
		}
	}

	return nil
}

func (m *MediaUpload) saveMediaInfo(ctx context.Context) error {
	// 音频文件上传云存储
	if err := cos.NewObjectStorage(m.cfg).PutObject(ctx, m.filePath, m.objectName); err != nil {
		return err
	}

	// 音频信息入库
	if err := m.transMgr.DoTransaction(ctx, func(ctx context.Context, repo repository.AiRecordRepo) error {
		// 锁用户信息
		if _, err := repo.UserRepo().LockUserInfo(ctx, m.userId); err != nil {
			return err
		}

		// 保存音频信息
		if err := repo.MediaRepo().SaveMediaInfo(ctx, m.mediaInfo); err != nil {
			return err
		}

		return nil
	}); err != nil {
		return err
	}

	return nil
}

// getMediaMetaInfo 获取音频文件元信息
func (m *MediaUpload) getMediaMetaInfo(ctx context.Context) error {
	file, err := os.Open(m.filePath)
	if err != nil {
		return errs.Newf(errorcode.ErrFileOperatorFailed, "error opening file: %v", err)
	}

	defer func(file *os.File) {
		err := file.Close()
		if err != nil {
			log.DebugContextf(ctx, "error close file: %v", err)
		}
	}(file)

	// Get file info -> file size
	fileInfo, err := file.Stat()
	if err != nil {
		return err
	}
	m.mediaInfo.FileSize = fileInfo.Size()

	if _, err := file.Seek(0, io.SeekStart); err != nil {
		return err
	}

	// Calculate SHA-256
	signer := sha256.New()
	if _, err := io.Copy(signer, file); err != nil {
		return err
	}
	m.fileSign = fmt.Sprintf("%x", signer.Sum(nil))

	if _, err := file.Seek(0, io.SeekStart); err != nil {
		return err
	}

	// file format
	ext := strings.ToLower(filepath.Ext(m.filePath))

	var streamer beep.StreamSeekCloser
	var format beep.Format

	// Determine the file format based on extension and decode
	switch ext {
	case ".mp3":
		m.mediaInfo.FileFormat = "mp3"
		streamer, format, err = mp3.Decode(file)
	case ".wav":
		m.mediaInfo.FileFormat = "wav"
		streamer, format, err = wav.Decode(file)
	default:
		return errs.Newf(errorcode.ErrMediaFormatNotSupport, "unsupported media format: %s", ext)
	}

	if err != nil {
		return err
	}

	defer func(streamer beep.StreamSeekCloser) {
		err := streamer.Close()
		if err != nil {
			log.ErrorContextf(ctx, "beep streamer close err. %+v", err)
		}
	}(streamer)

	// Calculate the duration
	duration := streamer.Len() / format.SampleRate.N(time.Millisecond)
	m.mediaInfo.Duration = int64(duration)

	return nil
}
