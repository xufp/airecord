package paypal

import (
	"context"
	"time"

	vpaypal "github.com/plutov/paypal/v4"
	"github.com/smartox/ai_record_server/internal/application/ports/payment"
	"github.com/smartox/ai_record_server/internal/infrastructure/config"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"trpc.group/trpc-go/trpc-go/errs"
	"trpc.group/trpc-go/trpc-go/log"
)

type SubscriptionImpl struct {
	*BaseClient
}

func NewSubscription(ctx context.Context, cfg config.PayPalCfg) (payment.Subscription, error) {
	base, err := NewBaseClient(ctx, cfg)
	if err != nil {
		return nil, err
	}
	return &SubscriptionImpl{
		BaseClient: base,
	}, nil
}

// CreateProduct 创建产品
func (s *SubscriptionImpl) CreateProduct(ctx context.Context, req *payment.CreateProductReq) (
	*payment.CreateProductRsp, error,
) {
	product, err := s.client.CreateProduct(ctx, vpaypal.Product{
		Name:        req.ProductName,
		Description: req.Description,
		Type:        vpaypal.ProductTypeService,
		Category:    vpaypal.ProductCategorySoftware,
	})

	if err != nil {
		return nil, errs.Newf(errorcode.ErrCreatePaymentProductFailed, "create payment product failed. err: %v", err)
	}

	log.DebugContextf(ctx, "PayPal create product successfully, product_id: %s, product: %+v", product.ID, product)

	return &payment.CreateProductRsp{
		ProductId: product.ID,
	}, nil
}

func (s *SubscriptionImpl) CreatePlan(ctx context.Context, req *payment.CreatePlanReq) (*payment.CreatePlanRsp, error) {
	plan := vpaypal.SubscriptionPlan{
		ProductId:   req.ProductId,
		Name:        req.PlanName,
		Description: req.Description,
		Status:      "ACTIVE",
		BillingCycles: []vpaypal.BillingCycle{
			{
				Frequency: vpaypal.Frequency{
					IntervalUnit:  vpaypal.IntervalUnitDay,
					IntervalCount: int(req.Interval),
				},
				TenureType:  "REGULAR",
				Sequence:    1,
				TotalCycles: 0,
				PricingScheme: vpaypal.PricingScheme{
					FixedPrice: vpaypal.Money{
						Currency: req.Currency,
						Value:    req.Amount,
					},
				},
			},
		},
		PaymentPreferences: &vpaypal.PaymentPreferences{
			AutoBillOutstanding: true,
			// SetupFee 初次安装费用
			SetupFee: &vpaypal.Money{
				Currency: req.Currency,
				Value:    req.Amount,
			},
		},
	}

	p, err := s.client.CreateSubscriptionPlan(ctx, plan)
	if err != nil {
		return nil, errs.Newf(errorcode.ErrCreatePaymentPlanFailed, "create payment plan failed. err: %v", err)
	}

	log.DebugContextf(ctx, "PayPal create plan successfully, plan_id: %s, plan: %+v", p.ID, p)

	return &payment.CreatePlanRsp{
		PlanId: p.ID,
	}, nil
}

func (s *SubscriptionImpl) CreateSubscription(ctx context.Context, req *payment.CreateSubscriptionReq) (
	*payment.CreateSubscriptionRsp, error,
) {
	startTime := vpaypal.JSONTime(time.Now().AddDate(0, 0, int(req.Interval)))
	subscription := vpaypal.SubscriptionBase{
		PlanID:    req.PlanId,
		Quantity:  "1",
		StartTime: &startTime,
		CustomID:  req.CustomId,
		ApplicationContext: &vpaypal.ApplicationContext{
			ReturnURL: s.cfg.SubscriptionReturnUrl,
			CancelURL: s.cfg.SubscriptionCancelUrl,
		},
	}

	sub, err := s.client.CreateSubscription(context.Background(), subscription)
	if err != nil {
		return nil, errs.Newf(errorcode.ErrCreatePaymentSubscriptionFailed, "create payment subscription failed. err: %v",
			err)
	}

	log.DebugContextf(ctx, "PayPal create subscription successfully, plan_id: %s, subscription: %+v", req.PlanId, sub)

	// 提取审批链接
	var approvalURL string
	for _, link := range sub.Links {
		if link.Rel == "approve" {
			approvalURL = link.Href
			break
		}
	}

	return &payment.CreateSubscriptionRsp{
		SubscriptionId: sub.ID,
		ApprovalURL:    approvalURL,
	}, nil
}

func (s *SubscriptionImpl) GetSubscription(ctx context.Context, subscriptionId string) (
	*payment.SubscriptionDetail, error,
) {
	sub, err := s.client.GetSubscriptionDetails(ctx, subscriptionId)
	if err != nil {
		return nil, errs.Newf(errorcode.ErrGetPaymentSubscriptionFailed, "get payment subscription failed. err: %v", err)
	}

	log.DebugContextf(ctx, "GetSubscription successfully, subscription_id: %s, subscription: %+v", subscriptionId, sub)

	return &payment.SubscriptionDetail{
		SubscriptionId:  sub.ID,
		CustomId:        sub.CustomID,
		Status:          string(sub.SubscriptionStatus),
		NextBillingTime: sub.BillingInfo.NextBillingTime.Format(time.DateTime),
	}, nil
}
