package mediaservice

import (
	"context"
	"strings"

	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	"github.com/smartox/ai_record_server/internal/infrastructure/adapters/cos"
	"github.com/smartox/ai_record_server/internal/infrastructure/config"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"trpc.group/trpc-go/trpc-go/errs"
)

func NewMediaUrl(repo repository.MediaRepo, userId int64) *MediaUrl {
	return &MediaUrl{
		repo:   repo,
		userId: userId,
		cfg:    config.GetServerConfig().Media.Storage.Cos,
	}
}

type MediaUrl struct {
	repo   repository.MediaRepo
	userId int64
	cfg    config.CosCfg
}

func (m *MediaUrl) MediaUrl(ctx context.Context, req *protocol.MediaUrlReq) (
	*protocol.MediaUrlRsp, error,
) {
	// 音频信息查询&校验
	mediaInfo, err := m.repo.GetMediaInfo(ctx, req.MediaId)
	if err != nil {
		return nil, err
	}

	if mediaInfo.UserId != m.userId {
		return nil, errs.Newf(errorcode.ErrRecordNotExisted, "media not found")
	}

	if mediaInfo.State == entity.MediaStateInit {
		return nil, errs.Newf(errorcode.ErrMediaFileNotExisted, "media file not upload ack")
	}

	// 获取media url
	if !strings.HasPrefix(mediaInfo.MediaUrl, config.StorageModeCosPrefix) {
		return nil, errs.Newf(errorcode.ErrParamsInvalid, "media file not support get url.")
	}

	url, err := cos.NewObjectStorage(m.cfg).GetObjectUrl(ctx,
		strings.TrimPrefix(mediaInfo.MediaUrl, config.StorageModeCosPrefix))
	if err != nil {
		return nil, err
	}

	// 构造参数返回
	return &protocol.MediaUrlRsp{
		MediaId: mediaInfo.MediaId,
		Url:     url,
	}, nil
}
