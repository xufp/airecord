package entity

import (
	"time"
)

// UserToken 用户token信息表
type UserToken struct {
	Token          string    `gorm:"column:token;NOT NULL"`                             // 用户token id
	UserId         int64     `gorm:"column:user_id;NOT NULL"`                           // 用户ID
	ExpireTime     time.Time `gorm:"column:expire_time;default:CURRENT_TIMESTAMP"`      // 过期时间
	CreateTime     time.Time `gorm:"column:create_time;default:CURRENT_TIMESTAMP"`      // 记录创建时间
	LastUpdateTime time.Time `gorm:"column:last_update_time;default:CURRENT_TIMESTAMP"` // 最后修改时间
}

func (m *UserToken) TableName() string {
	return "ai_record_db.t_user_token"
}
