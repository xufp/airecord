package entity

import (
	"time"
)

// Service 服务信息表
type Service struct {
	ServiceId      int32     `gorm:"column:service_id;primary_key"`                     // 服务ID
	ServiceType    int32     `gorm:"column:service_type;NOT NULL"`                      // 服务类型 1：语音转写，
	ServiceName    string    `gorm:"column:service_name;NOT NULL"`                      // 服务名称
	Description    string    `gorm:"column:description;NOT NULL"`                       // 服务描述
	Quantity       int64     `gorm:"column:quantity;default:0;NOT NULL"`                // 服务量（时长：单位秒）
	Price          int64     `gorm:"column:price;default:0;NOT NULL"`                   // 价格（单位：分）
	Currency       string    `gorm:"column:currency;NOT NULL"`                          // 币种(CNY/USD/HKD...)
	ValidityDays   int32     `gorm:"column:validity_days;default:0;NOT NULL"`           // 服务有效期天数
	CreateTime     time.Time `gorm:"column:create_time;default:CURRENT_TIMESTAMP"`      // 记录创建时间
	LastUpdateTime time.Time `gorm:"column:last_update_time;default:CURRENT_TIMESTAMP"` // 最后修改时间
}

func (m *Service) TableName() string {
	return "ai_record_db.t_service"
}

const (
	ServiceTypeConvert = 1 // 语音转写
)
