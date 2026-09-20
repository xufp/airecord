package entity

import (
	"time"
)

// Membership 会员表
type Membership struct {
	Id             int64     `gorm:"column:id;primary_key;AUTO_INCREMENT"`              // 自增ID
	UserId         int64     `gorm:"column:user_id;NOT NULL"`                           // 用户ID
	Level          int32     `gorm:"column:level;NOT NULL"`                             // 会员等级 0->2
	ExpireTime     time.Time `gorm:"column:expire_time;default:CURRENT_TIMESTAMP"`      // 过期时间
	State          int32     `gorm:"column:state;NOT NULL"`                             // 状态 1：有效，2：无效(冻结)
	CreateTime     time.Time `gorm:"column:create_time;default:CURRENT_TIMESTAMP"`      // 记录创建时间
	LastUpdateTime time.Time `gorm:"column:last_update_time;default:CURRENT_TIMESTAMP"` // 最后修改时间
}

func (m *Membership) TableName() string {
	return "ai_record_db.t_membership"
}

const (
	MembershipLevel0     = 0
	MembershipLevel1     = 1
	MembershipLevel2     = 2
	MembershipLevelAdmin = 99
)

const (
	MembershipStateActive   = 1
	MembershipStateInactive = 2
)
