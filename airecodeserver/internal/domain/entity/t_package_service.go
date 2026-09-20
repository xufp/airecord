package entity

import (
	"time"
)

// PackageService 套餐服务配置表
type PackageService struct {
	PackageId      int32     `gorm:"column:package_id;primary_key"`                     // 服务ID
	ServiceId      int32     `gorm:"column:service_id;NOT NULL"`                        // 服务ID
	CreateTime     time.Time `gorm:"column:create_time;default:CURRENT_TIMESTAMP"`      // 记录创建时间
	LastUpdateTime time.Time `gorm:"column:last_update_time;default:CURRENT_TIMESTAMP"` // 最后修改时间
}

func (m *PackageService) TableName() string {
	return "ai_record_db.t_package_service"
}
