package entity

import "time"

// SubscriptionPlan 支付订阅计划表
type SubscriptionPlan struct {
	PlanId         string    `gorm:"column:plan_id;primary_key"`                        // 订阅ID
	PackageId      int32     `gorm:"column:package_id;NOT NULL"`                        // 套餐ID
	ProductId      string    `gorm:"column:product_id;NOT NULL"`                        // 产品ID
	PlanName       string    `gorm:"column:plan_name;NOT NULL"`                         // 订阅名称
	Description    string    `gorm:"column:description;NOT NULL"`                       // 订阅描述
	Amount         int64     `gorm:"column:amount;NOT NULL"`                            // 金额
	Currency       string    `gorm:"column:currency;NOT NULL"`                          // 币种(CNY/USD/HKD...)
	Interval       int32     `gorm:"column:interval;NOT NULL"`                          // 订阅计费间隔天数
	CreateTime     time.Time `gorm:"column:create_time;default:CURRENT_TIMESTAMP"`      // 记录创建时间
	LastUpdateTime time.Time `gorm:"column:last_update_time;default:CURRENT_TIMESTAMP"` // 最后修改时间
}

func (m *SubscriptionPlan) TableName() string {
	return "ai_record_db.t_subscription_plan"
}
