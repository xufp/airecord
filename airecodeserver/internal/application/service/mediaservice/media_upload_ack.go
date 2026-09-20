package mediaservice

import (
	"context"

	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"trpc.group/trpc-go/trpc-go/errs"
)

func NewMediaUploadAck(transMgr repository.RepoTransMgr, userId int64) *MediaUploadAck {
	return &MediaUploadAck{
		transMgr: transMgr,
		userId:   userId,
	}
}

type MediaUploadAck struct {
	transMgr repository.RepoTransMgr
	userId   int64
}

func (m *MediaUploadAck) MediaUploadAck(
	ctx context.Context, req *protocol.MediaUploadAckReq,
) (*protocol.MediaUploadAckRsp, error) {
	// 查询音频信息&校验
	mediaInfo, err := m.transMgr.GetRepository().MediaRepo().GetMediaInfo(ctx, req.MediaId)
	if err != nil {
		return nil, err
	}

	if mediaInfo.UserId != m.userId {
		return nil, errs.Newf(errorcode.ErrRecordNotExisted, "media not found")
	}

	// 已上传，直接返回
	if mediaInfo.State != entity.MediaStateInit {
		return &protocol.MediaUploadAckRsp{}, nil
	}

	// 更新上传状态确认
	mediaInfo.State = entity.MediaStateUploaded

	// 查询识别记录
	if err := m.updateMediaInfo(ctx, mediaInfo); err != nil {
		return nil, err
	}

	return &protocol.MediaUploadAckRsp{}, nil
}

func (m *MediaUploadAck) updateMediaInfo(ctx context.Context, mediaInfo *entity.MediaInfo) error {
	if err := m.transMgr.DoTransaction(ctx, func(ctx context.Context, repo repository.AiRecordRepo) error {
		// 锁用户信息
		if _, err := repo.UserRepo().LockUserInfo(ctx, m.userId); err != nil {
			return err
		}

		// 保存音频信息
		if err := repo.MediaRepo().UpdateMediaInfo(ctx, mediaInfo); err != nil {
			return err
		}

		return nil
	}); err != nil {
		return err
	}

	return nil
}
