package mediaservice

import (
	"context"

	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"trpc.group/trpc-go/trpc-go/errs"
	"trpc.group/trpc-go/trpc-go/log"
)

func NewMediaSummaryUpdate(
	transMgr repository.RepoTransMgr, userId int64,
) *MediaSummaryUpdate {
	return &MediaSummaryUpdate{
		transMgr: transMgr,
		userId:   userId,
	}
}

type MediaSummaryUpdate struct {
	transMgr repository.RepoTransMgr
	userId   int64
}

func (m *MediaSummaryUpdate) MediaSummaryUpdate(ctx context.Context, req *protocol.MediaSummaryUpdateReq) (
	*protocol.MediaSummaryUpdateRsp, error,
) {
	// 查询音频信息&校验
	mediaInfo, err := m.transMgr.GetRepository().MediaRepo().GetMediaInfo(ctx, req.MediaId)
	if err != nil {
		return nil, err
	}

	if mediaInfo.UserId != m.userId {
		return nil, errs.Newf(errorcode.ErrRecordNotExisted, "media not found")
	}

	// 总结内容更新
	if err := m.updateSummary(ctx, req); err != nil {
		return nil, err
	}

	return &protocol.MediaSummaryUpdateRsp{}, nil
}

func (m *MediaSummaryUpdate) updateSummary(ctx context.Context, req *protocol.MediaSummaryUpdateReq) error {
	// 修改内容更新
	if err := m.transMgr.DoTransaction(ctx, func(ctx context.Context, repo repository.AiRecordRepo) error {
		// 锁用户记录
		if _, err := repo.UserRepo().LockUserInfo(ctx, m.userId); err != nil {
			return err
		}

		// 查询总结
		mediaSummary, err := m.transMgr.GetRepository().MediaRepo().GetMediaSummary(ctx, req.MediaId)
		if err != nil {
			return err
		}

		mediaSummary.ContentType = entity.MediaSummaryContentTypeCustom
		mediaSummary.Content = req.Content

		// 更新总结结果
		if err := repo.MediaRepo().UpdateMediaSummary(ctx, mediaSummary); err != nil {
			return err
		}

		return nil
	}); err != nil {
		log.ErrorContextf(ctx, "MediaSummaryUpdate update media summary err: %+v", err)
		return err
	}

	return nil
}
