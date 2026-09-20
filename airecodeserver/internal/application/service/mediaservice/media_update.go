package mediaservice

import (
	"context"

	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"trpc.group/trpc-go/trpc-go/errs"
)

func NewMediaUpdate(transMgr repository.RepoTransMgr, userId int64) *MediaUpdate {
	return &MediaUpdate{
		transMgr: transMgr,
		userId:   userId,
	}
}

type MediaUpdate struct {
	transMgr repository.RepoTransMgr
	userId   int64
}

func (m *MediaUpdate) MediaUpdate(ctx context.Context, req *protocol.MediaUpdateReq) (
	*protocol.MediaUpdateRsp, error,
) {
	// 执行更新
	if err := m.transMgr.DoTransaction(ctx, func(ctx context.Context, repo repository.AiRecordRepo) error {
		// 锁用户信息
		if _, err := repo.UserRepo().LockUserInfo(ctx, m.userId); err != nil {
			return err
		}

		// 修改后名称不能与其他音频名称重复，必须唯一
		if media, err := repo.MediaRepo().GetMediaInfoByName(ctx, m.userId,
			req.MediaName); err == nil {
			if media.MediaId != req.MediaId {
				return errs.Newf(errorcode.ErrMediaNameExisted, "media name is existed")
			} else {
				// 不修改名称，直接返回
				return nil
			}
		}

		// 查询音频信息&校验
		mediaInfo, err := repo.MediaRepo().GetMediaInfo(ctx, req.MediaId)
		if err != nil {
			return err
		}

		if mediaInfo.UserId != m.userId {
			return errs.Newf(errorcode.ErrRecordNotExisted, "media not found")
		}

		mediaInfo.MediaName = req.MediaName

		// 保存音频信息
		if err := repo.MediaRepo().UpdateMediaInfo(ctx, mediaInfo); err != nil {
			return err
		}

		return nil
	}); err != nil {
		return nil, err
	}

	return &protocol.MediaUpdateRsp{}, nil
}
