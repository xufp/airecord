package orderservice

import (
	"context"
	"strconv"

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

func NewOrderCreate(transMgr repository.RepoTransMgr, userId int64) *OrderCreate {
	return &OrderCreate{
		transMgr: transMgr,
		userId:   userId,
	}
}

type OrderCreate struct {
	transMgr repository.RepoTransMgr
	userId   int64
	pkg      *entity.Package
}

func (s *OrderCreate) OrderCreate(ctx context.Context, req *protocol.OrderCreateReq) (
	*protocol.OrderCreateRsp, error,
) {
	// 参数检查
	if err := s.CheckParam(ctx, req); err != nil {
		return nil, err
	}

	// 创建系统内订单
	order, err := domainservice.NewUserService(s.transMgr.GetRepository().ServiceRepo(), s.userId).CreateOrder(ctx, s.pkg,
		req.PayChannel)
	if err != nil {
		return nil, err
	}

	// 订单支付处理
	if err := s.OrderPayment(ctx, order); err != nil {
		order.State = entity.OrderStateFailed
		order.Memo = err.Error()
	} else {
		order.State = entity.OrderStatePending
	}

	// 更新订单状态
	if err := s.transMgr.GetRepository().ServiceRepo().UpdateOrder(ctx, order); err != nil {
		return nil, err
	}

	return &protocol.OrderCreateRsp{
		OrderId: order.OrderId,
		State:   order.State,
		Link: protocol.Link{
			Method: "GET",
			Href:   order.PaymentDesc,
		},
	}, nil
}

// CheckParam 请求参数检查
func (s *OrderCreate) CheckParam(ctx context.Context, req *protocol.OrderCreateReq) error {
	// 检查支付渠道
	if req.PayChannel != entity.OrderPayChannelPaypal {
		return errs.Newf(errorcode.ErrNotSupportPayChannel, "payment channel not support")
	}

	// 获取套餐信息
	pkg, err := s.transMgr.GetRepository().ServiceRepo().GetPackage(ctx, req.PackageId)
	if err != nil {
		return err
	}

	// 套餐有效期判断
	if !pkg.IsValid() {
		return errs.New(errorcode.ErrRecordNotExisted, "the package is not valid")
	}

	// 支付下单支持套餐类型检查
	if pkg.PackageType != entity.PackageTypePurchase && pkg.PackageType != entity.PackageTypeSubscription {
		return errs.Newf(errorcode.ErrPackageNotSupport, "this package not support payment")
	}

	s.pkg = pkg
	return nil
}

// OrderPayment 订单支付处理
func (s *OrderCreate) OrderPayment(ctx context.Context, order *entity.Order) error {
	// 支付渠道订单创建
	if order.PayChannel == entity.OrderPayChannelPaypal {
		switch order.PaymentType {
		case entity.OrderPaymentTypeOnce:
			// 创建paypal支付订单
			if err := s.PaypalCreateOrder(ctx, order); err != nil {
				return err
			}
		case entity.OrderPaymentTypeSubscription:
			// 创建paypal订阅订单
			if err := s.PaypalSubscription(ctx, order); err != nil {
				return err
			}
		}
	}

	return nil
}

func (s *OrderCreate) PaypalCreateOrder(ctx context.Context, order *entity.Order) error {
	orderReq := &payment.CreateOrderReq{
		Amount:      strconv.FormatFloat(float64(order.Amount)/100, 'f', 2, 64),
		Currency:    order.Currency,
		Description: order.PackageName,
		OrderId:     order.OrderId,
	}

	p, err := paypal.NewPayment(ctx, config.GetServerConfig().Payment.PayPal)
	if err != nil {
		return err
	}

	rsp, err := p.CreateOrder(ctx, orderReq)
	if err != nil {
		log.ErrorContextf(ctx, "CreateOrder err: %v", err)
		return err
	}

	log.InfoContextf(ctx, "paypal order: %v", order)

	order.PaymentId = rsp.PaymentId
	order.PaymentDesc = rsp.ApprovalURL
	return nil
}

func (s *OrderCreate) PaypalSubscription(ctx context.Context, order *entity.Order) error {
	ps, err := paypal.NewSubscription(ctx, config.GetServerConfig().Payment.PayPal)
	if err != nil {
		return err
	}

	// 获取订阅计划
	plan, err := s.GenSubscriptionPlan(ctx, ps, order)

	req := &payment.CreateSubscriptionReq{
		PlanId:   plan.PlanId,
		CustomId: order.OrderId,
		Interval: plan.Interval,
	}

	rsp, err := ps.CreateSubscription(ctx, req)
	if err != nil {
		log.ErrorContextf(ctx, "CreateSubscription err: %v", err)
		return err
	}

	log.InfoContextf(ctx, "paypal subscription: %v", rsp)

	order.PaymentId = rsp.SubscriptionId
	order.PaymentDesc = rsp.ApprovalURL

	return nil
}

func (s *OrderCreate) GenSubscriptionPlan(
	ctx context.Context, ps payment.Subscription, order *entity.Order,
) (*entity.SubscriptionPlan, error) {
	// 查询订阅计划
	plan, err := s.transMgr.GetRepository().ServiceRepo().GetSubscriptionPlan(ctx, order.PackageId)
	if err == nil {
		return plan, nil
	}
	// 非“订阅计划不存在”错误，则直接返回错误
	if errs.Code(err) != errorcode.ErrRecordNotExisted {
		return nil, err
	}

	// 查询订阅计划不存在，创建新的订阅计划
	// 获取订阅计划对应的产品
	newCreateProduct := false
	product, err := s.transMgr.GetRepository().ServiceRepo().GetSubscriptionProduct(ctx, entity.ProductAiRecordProUser)
	if err != nil {
		// 非“产品不存在”错误，则直接返回错误
		if errs.Code(err) != errorcode.ErrRecordNotExisted {
			return nil, err
		}
		// 查询产品不存在，创建新的产品
		productReq := &payment.CreateProductReq{
			ProductName: entity.ProductAiRecordProUser,
			Description: "AI Record Pro会员",
		}

		productRsp, err := ps.CreateProduct(ctx, productReq)
		if err != nil {
			return nil, err
		}

		product = &entity.SubscriptionProduct{
			ProductId:   productRsp.ProductId,
			ProductName: productReq.ProductName,
			ProductDesc: productReq.Description,
		}
		newCreateProduct = true
	}

	// 创建订阅计划
	planReq := &payment.CreatePlanReq{
		ProductId:   product.ProductId,
		PlanName:    order.PackageName,
		Description: order.PackageName,
		Amount:      strconv.FormatFloat(float64(order.Amount)/100, 'f', 2, 64),
		Currency:    order.Currency,
		Interval:    0,
	}
	planReq.Interval, err = domainservice.NewUserService(s.transMgr.GetRepository().ServiceRepo(),
		s.userId).GetPackageServiceValidityDays(ctx, order.PackageId)
	if err != nil {
		return nil, err
	}

	planRsp, err := ps.CreatePlan(ctx, planReq)
	if err != nil {
		return nil, err
	}

	plan = &entity.SubscriptionPlan{
		PlanId:      planRsp.PlanId,
		PackageId:   order.PackageId,
		ProductId:   product.ProductId,
		PlanName:    planReq.PlanName,
		Description: planReq.Description,
		Amount:      order.Amount,
		Currency:    planReq.Currency,
		Interval:    planReq.Interval,
	}

	// 保存订阅计划，启动事务
	if err := s.transMgr.DoTransaction(ctx, func(ctx context.Context, repo repository.AiRecordRepo) error {
		// 保存产品信息
		if newCreateProduct {
			if err := repo.ServiceRepo().SaveSubscriptionProduct(ctx, product); err != nil {
				return err
			}
		}

		// 保存订阅计划
		if err := repo.ServiceRepo().SaveSubscriptionPlan(ctx, plan); err != nil {
			return err
		}

		return nil
	}); err != nil {
		return nil, err
	}

	return plan, nil
}
