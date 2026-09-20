package orderservice

import (
	"context"

	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	"trpc.group/trpc-go/trpc-go/log"
)

func NewPaypalCancel(transMgr repository.RepoTransMgr) *PaypalCancel {
	return &PaypalCancel{
		transMgr: transMgr,
	}
}

type PaypalCancel struct {
	transMgr repository.RepoTransMgr
}

func (m *PaypalCancel) PaypalCancel(ctx context.Context, req *protocol.PaypalCancelReq) (
	*protocol.PaypalCancelRsp, error,
) {
	log.InfoContextf(ctx, "PaypalCancel req: %+v", req)

	// 查询订单信息
	order, err := m.transMgr.GetRepository().ServiceRepo().GetOrderByPaymentId(ctx, req.PaymentId)
	if err != nil {
		return nil, err
	}

	// 仅 Pending 状态的订单才标记为失败（避免误改已成功的订单）
	if order.State == entity.OrderStatePending {
		order.State = entity.OrderStateFailed
		order.Memo = "user cancelled payment"
		if err := m.transMgr.DoTransaction(ctx, func(ctx context.Context, repo repository.AiRecordRepo) error {
			// 锁用户记录
			if _, err := repo.UserRepo().LockUserInfo(ctx, order.UserId); err != nil {
				return err
			}
			// 更新订单信息
			if err := repo.ServiceRepo().UpdateOrder(ctx, order); err != nil {
				return err
			}
			return nil
		}); err != nil {
			log.ErrorContextf(ctx, "PaypalCancel update order failed. err: %+v", err)
			return nil, err
		}
	}

	return &protocol.PaypalCancelRsp{
		OrderId: order.OrderId,
		State:   order.State,
		Memo:    order.Memo,
	}, nil
}
