package entity

import (
	"time"
)

// ActivationCard 激活卡表
type ActivationCard struct {
	CardNo           string     `gorm:"column:card_no;primary_key"`                        // 激活卡号
	CardPwd          string     `gorm:"column:card_pwd;NOT NULL"`                          // 激活卡密码
	CardState        int32      `gorm:"column:card_state;NOT NULL"`                        // 激活卡状态 1：未激活，2：已激活
	CardOrderId      string     `gorm:"column:card_order_id;NOT NULL"`                     // 激活卡订单号
	CardExpireTime   time.Time  `gorm:"column:card_expire_time;default:CURRENT_TIMESTAMP"` // 激活卡过期时间
	ActivationUserId int64      `gorm:"column:activation_user_id;NOT NULL"`                // 激活用户ID
	ActivationTime   *time.Time `gorm:"column:activation_time;"`                           // 激活时间
	PackageId        int32      `gorm:"column:package_id;NOT NULL"`                        // 套餐ID
	CreateTime       time.Time  `gorm:"column:create_time;default:CURRENT_TIMESTAMP"`      // 记录创建时间
	LastUpdateTime   time.Time  `gorm:"column:last_update_time;default:CURRENT_TIMESTAMP"` // 最后修改时间
}

func (m *ActivationCard) TableName() string {
	return "ai_record_db.t_activation_card"
}

const (
	ActivationCardStateDeactivated = 1 // 未激活
	ActivationCardStateActivated   = 2 // 已激活
	ActivationCardStateDeleted     = 3 // 已作废
)
