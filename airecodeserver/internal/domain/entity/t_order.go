package entity

import (
	"time"
)

// Order 订单表
type Order struct {
	OrderId        string     `gorm:"column:order_id;primary_key"`                       // 订单号
	UserId         int64      `gorm:"column:user_id;NOT NULL"`                           // 用户ID
	PackageId      int32      `gorm:"column:package_id;NOT NULL"`                        // 套餐ID
	PackageName    string     `gorm:"column:package_name;NOT NULL"`                      // 套餐名称
	State          int32      `gorm:"column:state;NOT NULL"`                             // 订单状态 0：初始化，1：待支付，2：已支付成功，3：支付失败/撤销, 4: 已完成(执行发货)...
	Amount         int64      `gorm:"column:amount;NOT NULL"`                            // 价格
	Currency       string     `gorm:"column:currency;NOT NULL"`                          // 币种(CNY/USD/HKD...)
	PayTime        *time.Time `gorm:"column:pay_time;NOT NULL"`                          // 支付时间
	PayChannel     int32      `gorm:"column:pay_channel;default:0;NOT NULL"`             // 支付渠道 1-paypal, 2-apple pay, 3-alipay, 4-wechat pay
	PaymentType    int32      `gorm:"column:payment_type;default:0;NOT NULL"`            // 支付类型 1-一次性支付, 2-订阅支付
	PaymentId      string     `gorm:"column:payment_id;NOT NULL"`                        // 支付ID（支付类型 1-支付订单ID，2-订阅ID）
	PaymentDesc    string     `gorm:"column:payment_desc;NOT NULL"`                      // 支付描述信息
	Memo           string     `gorm:"column:memo;NOT NULL"`                              // 备注信息
	Lstate         int32      `gorm:"column:lstate;default:0;NOT NULL"`                  // 逻辑状态(判断当前记录是否逻辑删除) 1: active, 2: deleted
	CreateTime     time.Time  `gorm:"column:create_time;default:CURRENT_TIMESTAMP"`      // 记录创建时间
	LastUpdateTime time.Time  `gorm:"column:last_update_time;default:CURRENT_TIMESTAMP"` // 最后修改时间
}

func (m *Order) TableName() string {
	return "ai_record_db.t_order"
}

const (
	OrderLStateActive  = 1 // 逻辑状态：有效
	OrderLStateDeleted = 2 // 逻辑状态：已删除
)

const (
	OrderStateInit      = 0 // 订单状态：初始化
	OrderStatePending   = 1 // 订单状态：待支付
	OrderStateSuccess   = 2 // 订单状态：已支付成功
	OrderStateFailed    = 3 // 订单状态：支付失败(撤销)
	OrderStateCompleted = 4 // 订单状态：已完成(执行发货)
	OrderStateCancelled = 5 // 订单状态：订阅取消
)

const (
	OrderPayChannelPaypal   = 1 // 支付渠道：paypal
	OrderPayChannelApplePay = 2 // 支付渠道：apple pay
	OrderPayChannelAlipay   = 3 // 支付渠道：alipay
	OrderPayChannelWechat   = 4 // 支付渠道：wechat pay
)

const (
	OrderPaymentTypeOnce         = 1 // 支付类型：一次性支付
	OrderPaymentTypeSubscription = 2 // 支付类型：订阅支付
)
