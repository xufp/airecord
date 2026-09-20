package entity

import (
	"time"
)

// UserPackage 用户套餐表
type UserPackage struct {
	UserPackageId  int64     `gorm:"column:user_package_id;AUTO_INCREMENT;NOT NULL"`    // 自增ID
	UserId         int64     `gorm:"column:user_id;NOT NULL"`                           // 用户ID
	PackageId      int32     `gorm:"column:package_id;NOT NULL"`                        // 套餐ID
	ServiceType    int32     `gorm:"column:service_type;NOT NULL"`                      // 服务类型
	BeginDate      time.Time `gorm:"column:begin_date;NOT NULL"`                        // 服务开始日期
	EndDate        time.Time `gorm:"column:end_date;NOT NULL"`                          // 服务结束日期
	Quantity       int64     `gorm:"column:quantity;NOT NULL"`                          // 服务量（时长：单位分钟/容量：单位MB）
	OrderId        string    `gorm:"column:order_id;NOT NULL"`                          // 订单号
	CreateTime     time.Time `gorm:"column:create_time;default:CURRENT_TIMESTAMP"`      // 记录创建时间
	LastUpdateTime time.Time `gorm:"column:last_update_time;default:CURRENT_TIMESTAMP"` // 最后修改时间
}

func (m *UserPackage) TableName() string {
	return "ai_record_db.t_user_package"
}
