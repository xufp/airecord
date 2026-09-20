package paypal

import (
	"context"

	vpaypal "github.com/plutov/paypal/v4"
	"github.com/smartox/ai_record_server/internal/application/ports/payment"
	"github.com/smartox/ai_record_server/internal/infrastructure/config"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"trpc.group/trpc-go/trpc-go/errs"
	"trpc.group/trpc-go/trpc-go/log"
)

type PaymentImpl struct {
	*BaseClient
}

func NewPayment(ctx context.Context, cfg config.PayPalCfg) (payment.Payment, error) {
	base, err := NewBaseClient(ctx, cfg)
	if err != nil {
		return nil, err
	}

	return &PaymentImpl{
		BaseClient: base,
	}, nil
}

func (p *PaymentImpl) CreateOrder(ctx context.Context, req *payment.CreateOrderReq) (*payment.CreateOrderRsp, error) {
	pus := []vpaypal.PurchaseUnitRequest{
		{
			CustomID: req.OrderId,
			Amount: &vpaypal.PurchaseUnitAmount{
				Currency: req.Currency,
				Value:    req.Amount,
			},
		},
	}

	ps := &vpaypal.PaymentSource{
		Paypal: &vpaypal.PaymentSourcePaypal{
			ExperienceContext: vpaypal.PaymentSourcePaypalExperienceContext{
				PaymentMethodPreference: "UNRESTRICTED",
				LandingPage:             "NO_PREFERENCE",
				BrandName:               "gopay",
				Locale:                  "en-US",
				ShippingPreference:      "NO_SHIPPING",
				UserAction:              "PAY_NOW",
				ReturnURL:               p.cfg.ReturnUrl,
				CancelURL:               p.cfg.CancelUrl,
			},
		},
	}

	order, err := p.client.CreateOrder(ctx, "CAPTURE", pus, ps, nil)
	if err != nil {
		return nil, errs.Newf(errorcode.ErrOrderCreateFailed, "create paypal order failed. err: %s", err.Error())
	}

	log.DebugContextf(ctx, "create order: %+v", order)

	rsp := &payment.CreateOrderRsp{
		PaymentId: order.ID,
		Status:    order.Status,
	}

	for _, link := range order.Links {
		if link.Rel == "payer-action" {
			rsp.ApprovalURL = link.Href
		}
	}

	if rsp.ApprovalURL == "" {
		return nil, errs.Newf(errorcode.ErrOrderCreateFailed, "create paypal order failed. approval url is empty")
	}

	return rsp, nil
}

func (p *PaymentImpl) CaptureOrder(ctx context.Context, paymentId string) error {
	ctor := vpaypal.CaptureOrderRequest{}
	// Capture Orders example
	ppRsp, err := p.client.CaptureOrder(ctx, paymentId, ctor)
	if err != nil {
		return errs.Newf(errorcode.ErrOrderCaptureFailed, "capture paypal order failed. err: %s", err.Error())
	}

	if ppRsp.Status != vpaypal.OrderStatusCompleted {
		return errs.Newf(errorcode.ErrOrderCaptureFailed, "PayPal order capture failed. status: %s", ppRsp.Status)
	}

	log.DebugContextf(ctx, "PayPal order captured successfully, paymentId: %s, rsp: %+v", paymentId, ppRsp)

	return nil
}

func (p *PaymentImpl) GetOrder(ctx context.Context, paymentId string) (*payment.OrderDetail, error) {
	// Order Details example
	order, err := p.client.GetOrder(ctx, paymentId)
	if err != nil {
		return nil, errs.Newf(errorcode.ErrOrderDetailGetFailed, "get paypal order failed. err: %s", err.Error())
	}

	log.DebugContextf(ctx, "PayPal order details: %+v", order)

	return &payment.OrderDetail{
		PaymentId: order.ID,
		Status:    order.Status,
	}, nil
}
