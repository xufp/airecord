package orderservice

import (
	"context"
	"time"

	"github.com/smartox/ai_record_server/internal/application/ports/payment"
	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	"github.com/smartox/ai_record_server/internal/infrastructure/adapters/paypal"
	"github.com/smartox/ai_record_server/internal/infrastructure/config"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"trpc.group/trpc-go/trpc-go/errs"
	"trpc.group/trpc-go/trpc-go/log"
)

func NewPaypalSubscriptionReturn(
	transMgr repository.RepoTransMgr,
) *PaypalSubscriptionReturn {
	return &PaypalSubscriptionReturn{
		transMgr: transMgr,
	}
}

type PaypalSubscriptionReturn struct {
	transMgr repository.RepoTransMgr
	client   payment.Subscription
}

func (m *PaypalSubscriptionReturn) PaypalSubscriptionReturn(
	ctx context.Context, req *protocol.PaypalSubscriptionReturnReq,
) (
	*protocol.PaypalSubscriptionReturnRsp, error,
) {
	log.InfoContextf(ctx, "PaypalSubscriptionCancel req: %+v", req)
	// 查询订单信息
	order, err := m.transMgr.GetRepository().ServiceRepo().GetOrderByPaymentId(ctx, req.PaymentId)
	if err != nil {
		return nil, err
	}

	// 订单状态检查
	if order.State == entity.OrderStateSuccess {
		return &protocol.PaypalSubscriptionReturnRsp{
			OrderId: order.OrderId,
			State:   order.State,
		}, nil
	}

	if order.State != entity.OrderStatePending {
		return nil, errs.Newf(errorcode.ErrOrderDealFailed, "order status is invalid.")
	}

	// 查询支付订阅信息
	p, err := paypal.NewSubscription(ctx, config.GetServerConfig().Payment.PayPal)
	if err != nil {
		return nil, err
	}
	m.client = p

	// 查询订阅结果
	sub, err := m.client.GetSubscription(ctx, order.PaymentId)
	if err != nil {
		return nil, err
	}
	log.DebugContextf(ctx, "GetSubscription: %+v", sub)

	// 订单信息检查
	if sub.CustomId != order.OrderId {
		return nil, errs.Newf(errorcode.ErrOrderDealFailed, "subscription order_id is invalid.")
	}

	// 订阅状态检查
	if sub.Status != payment.SubscriptionStatusActive && sub.Status != payment.SubscriptionStatusApproved {
		return nil, errs.Newf(errorcode.ErrOrderDealFailed, "subscription status is invalid.")
	}

	// 订单状态更新
	order.State = entity.OrderStateSuccess
	order.PaymentDesc = ""
	payTime := time.Now()
	order.PayTime = &payTime
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
		log.ErrorContextf(ctx, "PaypalReturn update order failed. err: %+v", err)
		return nil, err
	}

	return &protocol.PaypalSubscriptionReturnRsp{
		OrderId: order.OrderId,
		State:   order.State,
	}, nil
}
