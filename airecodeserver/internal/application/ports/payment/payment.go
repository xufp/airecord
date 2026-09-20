package payment

import "context"

type Payment interface {
	CreateOrder(ctx context.Context, req *CreateOrderReq) (*CreateOrderRsp, error)
	CaptureOrder(ctx context.Context, paymentId string) error
	GetOrder(ctx context.Context, paymentId string) (*OrderDetail, error)
}
