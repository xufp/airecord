package entity

import (
	"time"
)

// UserCost 用户使用记录表
type UserCost struct {
	Id               int64     `gorm:"column:id;primary_key;AUTO_INCREMENT"`              // 自增ID
	UserId           int64     `gorm:"column:user_id;NOT NULL"`                           // 用户ID
	ServiceType      int       `gorm:"column:service_type;NOT NULL"`                      // 服务类型
	UserPackageId    int64     `gorm:"column:user_package_id;NOT NULL"`                   // 用户套餐ID
	QuantityUsed     int64     `gorm:"column:quantity_used;NOT NULL"`                     // 已使用量（时长：单位分钟/容量：单位MB）
	QuantityCanceled int64     `gorm:"column:quantity_canceled;NOT NULL"`                 // 已退回量[容量删除]（时长：单位分钟/容量：单位MB）
	CostDate         string    `gorm:"column:cost_date"`                                  // 使用日期
	Description      string    `gorm:"column:description;NOT NULL"`                       // 使用情况描述
	MediaId          int64     `gorm:"column:media_id;NOT NULL"`                          // 关联-音频ID
	CreateTime       time.Time `gorm:"column:create_time;default:CURRENT_TIMESTAMP"`      // 记录创建时间
	LastUpdateTime   time.Time `gorm:"column:last_update_time;default:CURRENT_TIMESTAMP"` // 最后修改时间
}

func (m *UserCost) TableName() string {
	return "ai_record_db.t_user_cost"
}
