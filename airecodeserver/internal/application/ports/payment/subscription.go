package payment

import (
	"context"
)

type Subscription interface {
	CreateProduct(ctx context.Context, req *CreateProductReq) (*CreateProductRsp, error)
	CreatePlan(ctx context.Context, req *CreatePlanReq) (*CreatePlanRsp, error)
	CreateSubscription(ctx context.Context, req *CreateSubscriptionReq) (*CreateSubscriptionRsp, error)
	GetSubscription(ctx context.Context, subscriptionId string) (*SubscriptionDetail, error)
}
