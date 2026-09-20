package entity

import (
	"time"
)

// UserFeedback 用户反馈表
type UserFeedback struct {
	Id             int64     `gorm:"column:id;primary_key;AUTO_INCREMENT"`              // 自增ID
	UserId         int64     `gorm:"column:user_id;NOT NULL"`                           // 用户ID
	Content        string    `gorm:"column:content;NOT NULL"`                           // 反馈内容
	Contract       string    `gorm:"column:contract;NOT NULL"`                          // 联系方式
	State          int32     `gorm:"column:state;NOT NULL"`                             // 处理状态 1：未处理，2：已处理
	Description    string    `gorm:"column:description;NOT NULL"`                       // 描述信息
	CreateTime     time.Time `gorm:"column:create_time;default:CURRENT_TIMESTAMP"`      // 记录创建时间
	LastUpdateTime time.Time `gorm:"column:last_update_time;default:CURRENT_TIMESTAMP"` // 最后修改时间
}

func (m *UserFeedback) TableName() string {
	return "ai_record_db.t_user_feedback"
}

const (
	FeedbackStateUnprocessed = 1 // 未处理
	FeedbackStateProcessed   = 2 // 已处理
)
