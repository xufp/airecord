package entity

import "time"

// SubscriptionProduct 支付订阅产品表
type SubscriptionProduct struct {
	ProductId      string    `gorm:"column:product_id;primary_key"`                     // 产品ID
	ProductName    string    `gorm:"column:product_name;NOT NULL"`                      // 产品名称
	ProductDesc    string    `gorm:"column:product_desc;NOT NULL"`                      // 产品描述
	CreateTime     time.Time `gorm:"column:create_time;default:CURRENT_TIMESTAMP"`      // 记录创建时间
	LastUpdateTime time.Time `gorm:"column:last_update_time;default:CURRENT_TIMESTAMP"` // 最后修改时间
}

func (m *SubscriptionProduct) TableName() string {
	return "ai_record_db.t_subscription_product"
}

const (
	ProductAiRecordProUser = "AiRecordProVip" // 产品名称-AiRecord专业版Vip
)
