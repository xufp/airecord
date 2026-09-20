package orderservice

import (
	"context"

	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	"github.com/smartox/ai_record_server/internal/infrastructure/adapters/paypal"
	"github.com/smartox/ai_record_server/internal/infrastructure/config"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"trpc.group/trpc-go/trpc-go/errs"
	"trpc.group/trpc-go/trpc-go/log"
)

func NewPaypalSubscriptionCancel(
	transMgr repository.RepoTransMgr,
) *PaypalSubscriptionCancel {
	return &PaypalSubscriptionCancel{
		transMgr: transMgr,
	}
}

type PaypalSubscriptionCancel struct {
	transMgr repository.RepoTransMgr
}

func (m *PaypalSubscriptionCancel) PaypalSubscriptionCancel(
	ctx context.Context, req *protocol.PaypalSubscriptionCancelReq,
) (
	*protocol.PaypalSubscriptionCancelRsp, error,
) {
	log.InfoContextf(ctx, "PaypalSubscriptionCancel req: %+v", req)

	// 查询订单信息
	order, err := m.transMgr.GetRepository().ServiceRepo().GetOrderByPaymentId(ctx, req.PaymentId)
	if err != nil {
		return nil, err
	}

	// 查询支付订阅信息
	p, err := paypal.NewSubscription(ctx, config.GetServerConfig().Payment.PayPal)
	if err != nil {
		return nil, err
	}

	// 查询订阅结果
	sub, err := p.GetSubscription(ctx, order.PaymentId)
	if err != nil {
		return nil, err
	}
	log.DebugContextf(ctx, "GetSubscription: %+v", sub)

	// 订单信息检查
	if sub.CustomId != order.OrderId {
		return nil, errs.Newf(errorcode.ErrOrderDealFailed, "subscription order_id is invalid.")
	}

	// 仅 Pending 状态的订单才标记为失败
	if order.State == entity.OrderStatePending {
		order.State = entity.OrderStateFailed
		order.Memo = "user cancelled subscription"
		if err := m.transMgr.DoTransaction(ctx, func(ctx context.Context, repo repository.AiRecordRepo) error {
			if _, err := repo.UserRepo().LockUserInfo(ctx, order.UserId); err != nil {
				return err
			}
			if err := repo.ServiceRepo().UpdateOrder(ctx, order); err != nil {
				return err
			}
			return nil
		}); err != nil {
			log.ErrorContextf(ctx, "PaypalSubscriptionCancel update order failed. err: %+v", err)
			return nil, err
		}
	}

	return &protocol.PaypalSubscriptionCancelRsp{
		OrderId: order.OrderId,
		State:   order.State,
		Memo:    "subscription status: " + sub.Status,
	}, nil
}
