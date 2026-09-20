package orderservice

import (
	"context"
	"time"

	"github.com/smartox/ai_record_server/internal/application/ports/payment"
	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	domainservice "github.com/smartox/ai_record_server/internal/domain/service"
	"github.com/smartox/ai_record_server/internal/infrastructure/adapters/paypal"
	"github.com/smartox/ai_record_server/internal/infrastructure/config"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"trpc.group/trpc-go/trpc-go/errs"
	"trpc.group/trpc-go/trpc-go/log"
)

func NewPaypalReturn(transMgr repository.RepoTransMgr) *PaypalReturn {
	return &PaypalReturn{
		transMgr: transMgr,
	}
}

type PaypalReturn struct {
	transMgr repository.RepoTransMgr
	client   payment.Payment
}

func (m *PaypalReturn) PaypalReturn(ctx context.Context, req *protocol.PaypalReturnReq) (
	*protocol.PaypalReturnRsp, error,
) {
	// 查询订单信息
	order, err := m.transMgr.GetRepository().ServiceRepo().GetOrderByPaymentId(ctx, req.PaymentId)
	if err != nil {
		return nil, err
	}

	// 订单状态检查
	if order.State == entity.OrderStateSuccess {
		return &protocol.PaypalReturnRsp{
			OrderId: order.OrderId,
			State:   order.State,
		}, nil
	}

	if order.State != entity.OrderStatePending {
		return nil, errs.Newf(errorcode.ErrOrderDealFailed, "order status is invalid.")
	}

	// 执行订单支付
	p, err := paypal.NewPayment(ctx, config.GetServerConfig().Payment.PayPal)
	if err != nil {
		return nil, err
	}
	m.client = p

	// 执行订单支付
	if err := p.CaptureOrder(ctx, req.PaymentId); err != nil {
		return nil, err
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

	// 同步尝试发货（双重保障：即使 Webhook 延迟也能及时生效）
	if err := m.OrderShip(ctx, order); err != nil {
		// 发货失败不阻塞 return，Webhook 会再次触发
		log.ErrorContextf(ctx, "PaypalReturn OrderShip failed (will retry via webhook). err: %+v", err)
	}

	return &protocol.PaypalReturnRsp{
		OrderId: order.OrderId,
		State:   order.State,
	}, nil
}

// OrderShip 订单发货处理
func (m *PaypalReturn) OrderShip(ctx context.Context, order *entity.Order) error {
	log.InfoContextf(ctx, "OrderShip deal... %s", order.OrderId)
	if order.State == entity.OrderStateCompleted {
		return nil
	}

	// 订单状态查询
	po, err := m.client.GetOrder(ctx, order.PaymentId)
	if err != nil {
		return err
	}

	if po.Status == payment.OrderStatusCompleted {
		// 更新订单状态
		order.State = entity.OrderStateCompleted

		if err := m.transMgr.DoTransaction(ctx, func(ctx context.Context, repo repository.AiRecordRepo) error {
			// 锁用户记录
			if _, err := repo.UserRepo().LockUserInfo(ctx, order.UserId); err != nil {
				return err
			}

			// 更新订单信息
			if err := repo.ServiceRepo().UpdateOrder(ctx, order); err != nil {
				return err
			}

			// 订单发货处理
			if _, err := domainservice.NewUserService(repo.ServiceRepo(), order.UserId).GivePackage(ctx,
				order.PackageId, order.OrderId); err != nil {
				return err
			}

			return nil
		}); err != nil {
			return err
		}
	}

	return nil
}
