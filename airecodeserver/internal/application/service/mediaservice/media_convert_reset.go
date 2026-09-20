package mediaservice

import (
	"context"

	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"trpc.group/trpc-go/trpc-go/errs"
)

func NewMediaConvertReset(
	transMgr repository.RepoTransMgr, userId int64,
) *MediaConvertReset {
	return &MediaConvertReset{
		transMgr: transMgr,
		userId:   userId,
	}
}

type MediaConvertReset struct {
	transMgr repository.RepoTransMgr
	userId   int64
}

func (m *MediaConvertReset) MediaConvertReset(
	ctx context.Context, req *protocol.MediaConvertResetReq,
) (*protocol.MediaConvertResetRsp, error) {
	if err := m.transMgr.DoTransaction(ctx, func(ctx context.Context, repo repository.AiRecordRepo) error {
		// 锁用户记录
		if _, err := repo.UserRepo().LockUserInfo(ctx, m.userId); err != nil {
			return err
		}

		// 查询音频信息&校验
		mediaInfo, err := m.transMgr.GetRepository().MediaRepo().GetMediaInfo(ctx, req.MediaId)
		if err != nil {
			return err
		}

		if mediaInfo.UserId != m.userId {
			return errs.Newf(errorcode.ErrRecordNotExisted, "media not found")
		}

		// 检查音频状态，转写成功或转写中2小时以上的音频才允许重置
		if mediaInfo.State != entity.MediaStateSuccess {
			return errs.Newf(errorcode.ErrMediaRecNotNeedReset, "media rec not support reset")
		}

		// 重置音频信息状态
		mediaInfo.State = entity.MediaStateFailed
		mediaInfo.Description = "reset media convert state"
		if err := repo.MediaRepo().UpdateMediaInfo(ctx, mediaInfo); err != nil {
			return err
		}

		// 重置音频转写记录状态
		mediaRec, err := m.transMgr.GetRepository().MediaRepo().GetMediaRec(ctx, mediaInfo.MediaId)
		if err != nil {
			return err
		}

		mediaRec.State = entity.MediaRecStateFailed
		mediaRec.Memo = "reset media convert state"
		if err := repo.MediaRepo().UpdateMediaRec(ctx, mediaRec); err != nil {
			return err
		}

		// 重置音频总结记录状态
		mediaSummary, err := m.transMgr.GetRepository().MediaRepo().GetMediaSummary(ctx, mediaInfo.MediaId)
		if err == nil {
			mediaSummary.State = entity.MediaSummaryStateFailed
			mediaSummary.Memo = "reset media convert state"
			if err := repo.MediaRepo().UpdateMediaSummary(ctx, mediaSummary); err != nil {
				return err
			}
		}

		return nil
	}); err != nil {
		return nil, err
	}

	return &protocol.MediaConvertResetRsp{}, nil
}
