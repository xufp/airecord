package payment

type CreateOrderReq struct {
	OrderId     string `json:"order_id"`    // 业务订单号
	Amount      string `json:"amount"`      // 订单金额
	Currency    string `json:"currency"`    // 币种
	Description string `json:"description"` // 订单描述
}

type CreateOrderRsp struct {
	PaymentId   string `json:"payment_id"`   // 支付单号
	ApprovalURL string `json:"approval_url"` // 支付链接
	Status      string `json:"status"`       // 支付状态
}

type OrderDetail struct {
	PaymentId string `json:"payment_id"` // 支付单号
	Status    string `json:"status"`     // 支付状态
}

const (
	OrderStatusCreated   string = "CREATED"
	OrderStatusSaved     string = "SAVED"
	OrderStatusApproved  string = "APPROVED"
	OrderStatusVoided    string = "VOIDED"
	OrderStatusCompleted string = "COMPLETED"
)

type CreateProductReq struct {
	ProductName string `json:"product_name"`
	Description string `json:"description"`
}

type CreateProductRsp struct {
	ProductId string `json:"product_id"`
}

type CreatePlanReq struct {
	ProductId   string `json:"product_id"`
	PlanName    string `json:"plan_name"`
	Description string `json:"description"`
	Amount      string `json:"amount"`
	Currency    string `json:"currency"`
	Interval    int32  `json:"interval"` // 订阅计费间隔天数
}

type CreatePlanRsp struct {
	PlanId string `json:"plan_id"`
}

type CreateSubscriptionReq struct {
	PlanId   string `json:"plan_id"`   // 计划ID
	CustomId string `json:"custom_id"` // 业务系统关联ID
	Interval int32  `json:"interval"`  // 订阅计费间隔天数
}

type CreateSubscriptionRsp struct {
	SubscriptionId string `json:"subscription_id"` // 订阅ID
	ApprovalURL    string `json:"approval_url"`    // 订阅支付链接
}

type SubscriptionDetail struct {
	SubscriptionId  string `json:"subscription_id"`   // 订阅ID
	CustomId        string `json:"custom_id"`         // 业务系统关联ID
	Status          string `json:"status"`            // 订阅状态
	NextBillingTime string `json:"next_billing_time"` // 下一次计费时间
}

const (
	SubscriptionStatusApprovalPending = "APPROVAL_PENDING"
	SubscriptionStatusApproved        = "APPROVED"
	SubscriptionStatusActive          = "ACTIVE"
	SubscriptionStatusSuspended       = "SUSPENDED"
	SubscriptionStatusCancelled       = "CANCELLED"
	SubscriptionStatusExpired         = "EXPIRED"
)
