package entity

import (
	"time"
)

// Package 套餐信息表
type Package struct {
	PackageId      int32     `gorm:"column:package_id;primary_key"`                     // 套餐ID
	PackageType    int32     `gorm:"column:package_type;NOT NULL"`                      // 套餐类型 1：免费体验类（每个用户限领一次）, 2：付费购买套餐， 3: 订阅计划， 4：激活卡类
	PackageName    string    `gorm:"column:package_name;NOT NULL"`                      // 套餐名称（默认语言）
	Description    string    `gorm:"column:description;NOT NULL"`                       // 套餐描述（默认语言）
	Price          int64     `gorm:"column:price;default:0;NOT NULL"`                   // 套餐总价（单位：分）
	Rates          int64     `gorm:"column:rates;default:0;NOT NULL"`                   // 套餐折扣率(%)
	Currency       string    `gorm:"column:currency;NOT NULL"`                          // 币种(CNY/USD/HKD...)
	BeginDate      time.Time `gorm:"column:begin_date;NOT NULL"`                        // 套餐有效期-开始
	EndDate        time.Time `gorm:"column:end_date;NOT NULL"`                          // 套餐有效期-结束
	CreateTime     time.Time `gorm:"column:create_time;default:CURRENT_TIMESTAMP"`      // 记录创建时间
	LastUpdateTime time.Time `gorm:"column:last_update_time;default:CURRENT_TIMESTAMP"` // 最后修改时间
}

// GetAmount 计算单套餐的购买金额
func (m *Package) GetAmount() int64 {
	return m.Price * m.Rates / 100
}

// IsValid 判断套餐是否有效
func (m *Package) IsValid() bool {
	now := time.Now()
	return now.After(m.BeginDate) && now.Before(m.EndDate)
}

// TableName 表名
func (m *Package) TableName() string {
	return "ai_record_db.t_package"
}

const (
	PackageTypeFreeGive       = 1 // 可免费领取类（每个用户限领一次）
	PackageTypePurchase       = 2 // 可付费购买套餐
	PackageTypeSubscription   = 3 // 可订阅套餐
	PackageTypeActivationCard = 4 // 激活卡类
)
