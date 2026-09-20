package userservice

import (
	"context"

	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	domainservice "github.com/smartox/ai_record_server/internal/domain/service"
	"github.com/smartox/ai_record_server/internal/infrastructure/utils"
)

func NewCardActivate(
	transMgr repository.RepoTransMgr, userId int64,
) *CardActivate {
	return &CardActivate{
		transMgr: transMgr,
		userId:   userId,
	}
}

type CardActivate struct {
	userId   int64
	transMgr repository.RepoTransMgr
}

func (c *CardActivate) CardActivate(ctx context.Context, req *protocol.CardActivateReq) (
	*protocol.CardActivateRsp, error,
) {
	activateCard := utils.NewActivateCard()
	if err := activateCard.Decode(req.CardCode); err != nil {
		return nil, err
	}

	// 卡激活执行
	if err := c.transMgr.DoTransaction(ctx, func(ctx context.Context, repo repository.AiRecordRepo) error {
		// 锁用户记录
		if _, err := repo.UserRepo().LockUserInfo(ctx, c.userId); err != nil {
			return err
		}

		// 卡激活
		if err := domainservice.NewUserService(repo.ServiceRepo(), c.userId).ActiveCard(ctx, activateCard.CardNo,
			activateCard.CardPwd); err != nil {
			return err
		}
		return nil
	}); err != nil {
		return nil, err
	}

	return &protocol.CardActivateRsp{}, nil
}
