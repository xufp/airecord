package mediaservice

import (
	"context"

	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"trpc.group/trpc-go/trpc-go/errs"
)

func NewMediaRemove(transMgr repository.RepoTransMgr, userId int64) *MediaRemove {
	return &MediaRemove{
		transMgr: transMgr,
		userId:   userId,
	}
}

type MediaRemove struct {
	transMgr repository.RepoTransMgr
	userId   int64
	req      *protocol.MediaRemoveReq
}

func (m *MediaRemove) MediaRemove(ctx context.Context, req *protocol.MediaRemoveReq) (
	*protocol.MediaRemoveRsp, error,
) {
	m.req = req

	if err := m.transMgr.DoTransaction(ctx, m.DoTransaction); err != nil {
		return nil, err
	}

	return &protocol.MediaRemoveRsp{}, nil
}

func (m *MediaRemove) DoTransaction(ctx context.Context, repo repository.AiRecordRepo) error {
	userInfo, err := repo.UserRepo().LockUserInfo(ctx, m.userId)
	if err != nil {
		return err
	}

	mediaInfo, err := repo.MediaRepo().GetMediaInfo(ctx, m.req.MediaId)
	if err != nil {
		return err
	}

	if mediaInfo.UserId != userInfo.UserId {
		return errs.Newf(errorcode.ErrParamsInvalid, "media not found")
	}

	if err := repo.MediaRepo().RemoveMediaInfo(ctx, mediaInfo.MediaId, mediaInfo.MediaName); err != nil {
		return err
	}

	return nil
}
