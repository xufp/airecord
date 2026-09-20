package userservice

import (
	"context"
	"time"

	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/domain/repository"
)

func NewUserFeedback(transMgr repository.RepoTransMgr, userId int64) *UserFeedback {
	return &UserFeedback{
		transMgr: transMgr,
		userId:   userId,
	}
}

type UserFeedback struct {
	transMgr repository.RepoTransMgr
	userId   int64
}

func (u *UserFeedback) UserFeedback(ctx context.Context, req *protocol.UserFeedbackReq) (
	*protocol.UserFeedbackRsp, error,
) {
	// 生成用户反馈结构
	feedback := &entity.UserFeedback{
		UserId:         u.userId,
		Content:        req.Content,
		Contract:       req.Contract,
		State:          entity.FeedbackStateUnprocessed,
		CreateTime:     time.Now(),
		LastUpdateTime: time.Now(),
	}

	// 用户反馈更新入库
	if err := u.transMgr.DoTransaction(ctx, func(ctx context.Context, repo repository.AiRecordRepo) error {
		if err := repo.UserRepo().SaveUserFeedback(ctx, feedback); err != nil {
			return err
		}
		return nil
	}); err != nil {
		return nil, err
	}

	return &protocol.UserFeedbackRsp{}, nil
}
