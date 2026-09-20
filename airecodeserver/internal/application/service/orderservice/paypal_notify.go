package orderservice

import (
	"context"
	"encoding/json"
	"fmt"
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

func NewPaypalNotify(transMgr repository.RepoTransMgr) *PaypalNotify {
	return &PaypalNotify{
		transMgr: transMgr,
	}
}

type PaypalNotify struct {
	transMgr repository.RepoTransMgr
}

func (m *PaypalNotify) PaypalNotify(ctx context.Context, req *protocol.PaypalNotifyReq) (
	*protocol.PaypalNotifyRsp, error,
) {
	log.DebugContextf(ctx, "PaypalNotify req: %+v", req)
	switch req.EventType {
	// case "CHECKOUT.ORDER.APPROVED":
	// 	err := m.OrderShip(ctx, req.Resource.Id)
	// 	if err != nil {
	// 		return nil, err
	// 	}
	case "PAYMENT.CAPTURE.COMPLETED":
		err := m.OrderShip(ctx, req.Resource.SupplementaryData.RelatedIds.OrderId)
		if err != nil {
			return nil, err
		}
	case "BILLING.SUBSCRIPTION.ACTIVATED":
		err := m.SubscriptionActivate(ctx, req.Resource.Id, req.Resource.CustomId)
		if err != nil {
			return nil, err
		}
	case "PAYMENT.SALE.COMPLETED":
		if err := m.SubscriptionDeduct(ctx, req.Resource.Id, req.Resource.BillingAgreementId, req.Resource); err != nil {
			return nil, err
		}
	case "BILLING.SUBSCRIPTION.CANCELLED":
		if err := m.SubscriptionCancelled(ctx, req.Resource.Id, req.Resource.CustomId); err != nil {
			return nil, err
		}
	default:
		log.ErrorContextf(ctx, "PaypalNotify unknown event type: %s", req.EventType)
	}

	return &protocol.PaypalNotifyRsp{}, nil
}

// OrderShip 订单发货处理
func (m *PaypalNotify) OrderShip(ctx context.Context, paymentId string) error {
	// 查询订单信息
	order, err := m.transMgr.GetRepository().ServiceRepo().GetOrderByPaymentId(ctx, paymentId)
	if err != nil {
		return err
	}

	// 订单状态检查
	if order.State == entity.OrderStateCompleted {
		return nil
	}

	// 执行订单支付
	p, err := paypal.NewPayment(ctx, config.GetServerConfig().Payment.PayPal)
	if err != nil {
		return err
	}

	// 订单状态查询
	po, err := p.GetOrder(ctx, order.PaymentId)
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
	} else {
		log.ErrorContextf(ctx, "OrderShip failed status: %s", po.Status)
	}

	return nil
}

// SubscriptionActivate 订阅激活处理
func (m *PaypalNotify) SubscriptionActivate(ctx context.Context, paymentId string, orderId string) error {
	// 查询订单信息
	order, err := m.transMgr.GetRepository().ServiceRepo().GetOrderByPaymentId(ctx, paymentId)
	if err != nil {
		return err
	}

	// todo: ..
	if order.OrderId != orderId {
		return errs.Newf(errorcode.ErrOrderDealFailed, "subscription order_id is invalid.")
	}

	// 订单状态检查
	if order.State == entity.OrderStateCompleted {
		return nil
	}

	// 创建订阅支付
	p, err := paypal.NewSubscription(ctx, config.GetServerConfig().Payment.PayPal)
	if err != nil {
		return err
	}

	// 查询订阅结果
	sub, err := p.GetSubscription(ctx, order.PaymentId)
	if err != nil {
		return err
	}

	// todo: ...
	if sub.CustomId != order.OrderId {
		return errs.Newf(errorcode.ErrOrderDealFailed, "subscription order_id is invalid.")
	}

	// 订阅已激活，更新订单状态至已完成
	if sub.Status == payment.SubscriptionStatusActive {
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

			return nil
		}); err != nil {
			return err
		}

	} else {
		log.ErrorContextf(ctx, "SubscriptionActivate failed status: %s", sub.Status)
	}

	return nil
}

// SubscriptionDeduct 订阅扣款处理（更新扣款记录&发货）
func (m *PaypalNotify) SubscriptionDeduct(
	ctx context.Context, deductId string, paymentId string, resource protocol.Resource,
) error {
	// 查询订单信息
	order, err := m.transMgr.GetRepository().ServiceRepo().GetOrderByPaymentId(ctx, paymentId)
	if err != nil {
		return err
	}

	// todo: ..
	if order.OrderId != resource.Custom {
		return errs.Newf(errorcode.ErrOrderDealFailed, "subscription order_id is invalid.")
	}

	// 订单状态检查
	if order.State != entity.OrderStateCompleted && order.State != entity.OrderStateSuccess {
		return errs.Newf(errorcode.ErrOrderDealFailed, "subscription order state is invalid.")
	}

	// 创建订阅支付
	p, err := paypal.NewSubscription(ctx, config.GetServerConfig().Payment.PayPal)
	if err != nil {
		return err
	}

	// 查询订阅结果
	sub, err := p.GetSubscription(ctx, order.PaymentId)
	if err != nil {
		return err
	}

	if sub.Status != payment.SubscriptionStatusActive {
		log.ErrorContextf(ctx, "SubscriptionDeduct failed status: %s", sub.Status)
		return errs.Newf(errorcode.ErrOrderDealFailed, "subscription status is invalid.")
	}

	// 扣款记录处理。 todo:
	deduct, err := m.transMgr.GetRepository().ServiceRepo().GetSubscriptionDeduct(ctx, deductId)
	if err != nil {
		if errs.Code(err) != errorcode.ErrRecordNotExisted {
			return err
		}
	} else {
		// 扣款记录已存在，检查订单状态
		log.WarnContextf(ctx, "SubscriptionDeduct already exists, deduct_id: %s", deductId)
		return nil
	}

	// 扣款记录不存在，创建扣款记录
	deduct = &entity.SubscriptionDeduct{
		DeductId:       deductId,
		SubscriptionId: paymentId,
		UserId:         order.UserId,
		CreateTime:     time.Now(),
		LastUpdateTime: time.Now(),
	}
	if resource.State == "completed" {
		deduct.State = entity.SubscriptionDeductStateCompleted
	} else {
		deduct.State = entity.SubscriptionDeductStateFailed
	}
	subDesc := &entity.SubscriptionDescription{
		OrderId:         resource.Id,
		State:           resource.State,
		NextBillingTime: sub.NextBillingTime,
	}
	subDesc.Amount.Total = resource.Amount.Total
	subDesc.Amount.Currency = resource.Amount.Currency

	desc, err := json.Marshal(&subDesc)
	if err != nil {
		return err
	}
	deduct.Description = string(desc)

	if err := m.transMgr.DoTransaction(ctx, func(ctx context.Context, repo repository.AiRecordRepo) error {
		// 锁用户记录
		if _, err := repo.UserRepo().LockUserInfo(ctx, order.UserId); err != nil {
			return err
		}

		// 保存扣款记录
		if err := repo.ServiceRepo().SaveSubscriptionDeduct(ctx, deduct); err != nil {
			return err
		}

		// 订单发货处理
		if deduct.State == entity.SubscriptionDeductStateCompleted {
			service := domainservice.NewUserService(repo.ServiceRepo(), order.UserId)
			// 会员激活
			if err := service.ActiveMembership(ctx, order.PackageId); err != nil {
				return err
			}

			// 套餐领取
			if _, err := service.GivePackage(ctx, order.PackageId,
				fmt.Sprintf("%v-%v", order.OrderId, deduct.DeductId)); err != nil {
				return err
			}
		}

		return nil
	}); err != nil {
		return err
	}

	return nil
}

// SubscriptionCancelled 订阅取消处理
func (m *PaypalNotify) SubscriptionCancelled(ctx context.Context, paymentId string, orderId string) error {
	// 查询订单信息
	order, err := m.transMgr.GetRepository().ServiceRepo().GetOrderByPaymentId(ctx, paymentId)
	if err != nil {
		return err
	}

	if order.OrderId != orderId {
		return errs.Newf(errorcode.ErrOrderDealFailed, "subscription order_id is invalid.")
	}

	// 订单状态检查
	if order.State == entity.OrderStateCancelled {
		return nil
	}

	// 创建订阅支付
	p, err := paypal.NewSubscription(ctx, config.GetServerConfig().Payment.PayPal)
	if err != nil {
		return err
	}

	// 查询订阅结果
	sub, err := p.GetSubscription(ctx, order.PaymentId)
	if err != nil {
		return err
	}

	if sub.CustomId != order.OrderId {
		return errs.Newf(errorcode.ErrOrderDealFailed, "subscription order_id is invalid.")
	}

	// 订阅已激活，更新订单状态至已完成
	if sub.Status == payment.SubscriptionStatusCancelled {
		// 更新订单状态
		order.State = entity.OrderStateCancelled
		order.Memo = "subscription cancelled"
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
			return err
		}
	} else {
		log.ErrorContextf(ctx, "SubscriptionCancelled failed status: %s", sub.Status)
	}

	return nil
}
