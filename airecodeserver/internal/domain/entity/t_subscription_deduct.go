package entity

import "time"

// SubscriptionDeduct 支付订阅扣款记录表
type SubscriptionDeduct struct {
	DeductId       string    `gorm:"column:deduct_id;primaryKey"`                       // 扣款ID
	SubscriptionId string    `gorm:"column:subscription_id;not null"`                   // 订阅ID
	UserId         int64     `gorm:"column:user_id;not null"`                           // 用户ID
	Description    string    `gorm:"column:description;not null"`                       // 扣款描述
	State          int32     `gorm:"column:state;not null"`                             // 扣款状态
	CreateTime     time.Time `gorm:"column:create_time;default:CURRENT_TIMESTAMP"`      // 记录创建时间
	LastUpdateTime time.Time `gorm:"column:last_update_time;default:CURRENT_TIMESTAMP"` // 最后修改时间
}

func (m *SubscriptionDeduct) TableName() string {
	return "ai_record_db.t_subscription_deduct"
}

const (
	SubscriptionDeductStateCompleted = 1 // 扣款完成
	SubscriptionDeductStateFailed    = 2 // 扣款失败
)

// SubscriptionDescription 订阅描述
type SubscriptionDescription struct {
	OrderId string `json:"order_id"`
	State   string `json:"state"`
	Amount  struct {
		Total    string `json:"total"`
		Currency string `json:"currency"`
	} `json:"amount"`
	NextBillingTime string `json:"next_billing_time"`
}
