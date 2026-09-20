package mediaservice

import (
	"context"
	"fmt"
	"strings"
	"time"

	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	"github.com/smartox/ai_record_server/internal/infrastructure/adapters/cos"
	"github.com/smartox/ai_record_server/internal/infrastructure/config"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"github.com/smartox/ai_record_server/internal/infrastructure/utils"
	"trpc.group/trpc-go/trpc-go/errs"
)

func NewMediaUploadCredential(
	transMgr repository.RepoTransMgr, userId int64,
) *MediaUploadCredential {
	return &MediaUploadCredential{
		cfg:      config.GetServerConfig(),
		transMgr: transMgr,
		userId:   userId,
	}
}

type MediaUploadCredential struct {
	userId     int64
	transMgr   repository.RepoTransMgr
	cfg        *config.ServerConfig
	mediaInfo  *entity.MediaInfo
	objectName string
}

func (m *MediaUploadCredential) MediaUploadCredential(
	ctx context.Context, req *protocol.MediaUploadCredentialReq,
) (*protocol.MediaUploadCredentialRsp, error) {
	// gen mediaInfo
	if err := m.genMediaInfo(req); err != nil {
		return nil, err
	}

	// check media info
	if err := m.checkMediaInfo(ctx); err != nil {
		// 重入，按成功返回
		if errs.Code(err) == errorcode.ErrMediaRepeatUpload {
			return m.packResponse(ctx)
		}
		return nil, err
	}

	// save
	if err := m.saveMediaInfo(ctx); err != nil {
		return nil, err
	}

	return m.packResponse(ctx)
}

func (m *MediaUploadCredential) genMediaInfo(req *protocol.MediaUploadCredentialReq) error {
	// 生成MediaInfo
	m.mediaInfo = &entity.MediaInfo{
		UserId:         m.userId,
		MediaName:      req.MediaName,
		FileFormat:     req.FileFormat,
		FileSize:       req.FileSize,
		FileSign:       "",
		RecordAddress:  req.RecordAddress,
		Duration:       req.Duration,
		MediaUrl:       "",
		State:          entity.MediaStateInit,
		Summary:        "",
		Description:    "",
		MediaType:      entity.MediaTypeRecorderFile,
		DeviceId:       req.DeviceId,
		Lstate:         entity.LStateActive,
		CreateTime:     time.Now(),
		LastUpdateTime: time.Now(),
	}

	// 生成media url
	fileName := m.mediaInfo.MediaName
	if !strings.HasSuffix(m.mediaInfo.MediaName, "."+m.mediaInfo.FileFormat) {
		fileName = fmt.Sprintf("%s.%s", m.mediaInfo.MediaName, m.mediaInfo.FileFormat)
	}
	m.objectName = fmt.Sprintf("%s/%d/%s", m.cfg.Media.Storage.Cos.Path, m.userId, fileName)

	m.mediaInfo.MediaUrl = config.StorageModeCosPrefix + m.objectName

	return nil
}

func (m *MediaUploadCredential) checkMediaInfo(ctx context.Context) error {
	// 文件格式校验
	if !utils.Contains(m.cfg.Media.SupportFormat, m.mediaInfo.FileFormat) {
		return errs.Newf(errorcode.ErrParamsInvalid, "not support file format.")
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

func (m *MediaUploadCredential) saveMediaInfo(ctx context.Context) error {
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

// packResponse 构造返回包
func (m *MediaUploadCredential) packResponse(ctx context.Context) (*protocol.MediaUploadCredentialRsp, error) {
	// 生成临时秘钥
	storage := cos.NewObjectStorage(m.cfg.Media.Storage.Cos)
	credential, err := storage.GetCredential(ctx, m.objectName)
	if err != nil {
		return nil, err
	}

	// 打包返回参数
	rsp := &protocol.MediaUploadCredentialRsp{
		MediaId: m.mediaInfo.MediaId,
		State:   m.mediaInfo.State,
		Credential: protocol.Credential{
			TmpSecretId:  credential.TmpSecretID,
			TmpSecretKey: credential.TmpSecretKey,
			SessionToken: credential.SessionToken,
			StartTime:    int32(credential.StartTime),
			ExpiredTime:  int32(credential.ExpiredTime),
			ObjectName:   credential.ObjectName,
			Region:       m.cfg.Media.Storage.Cos.Region,
			Bucket:       m.cfg.Media.Storage.Cos.Bucket,
		},
	}

	return rsp, nil
}
