package entity

import (
	"time"
)

// VerifyCode 短信验证码表
type VerifyCode struct {
	Id             int64     `gorm:"column:id;primary_key;AUTO_INCREMENT"`              // 自增ID
	Scene          int32     `gorm:"column:scene;NOT NULL"`                             // 验证码使用场景 1-用户登录，2-密码重置
	UniKey         string    `gorm:"column:uni_key;NOT NULL"`                           // 电话号码/email地址
	Code           string    `gorm:"column:code;NOT NULL"`                              // 验证码
	ExpireTime     time.Time `gorm:"column:expire_time;default:CURRENT_TIMESTAMP"`      // 过期时间
	CreateTime     time.Time `gorm:"column:create_time;default:CURRENT_TIMESTAMP"`      // 记录创建时间
	LastUpdateTime time.Time `gorm:"column:last_update_time;default:CURRENT_TIMESTAMP"` // 最后修改时间
	State          int32     `gorm:"column:state;default:0;NOT NULL"`                   // 状态 0: 未使用，1：已使用
}

func (m *VerifyCode) TableName() string {
	return "ai_record_db.t_verify_code"
}

const (
	VerifyCodeSceneLogin         = 1 // 用户登录
	VerifyCodeSceneResetPassword = 2 // 密码重置...
)

const (
	VerifyCodeStateUnUsed = 0 // 验证码未使用
	VerifyCodeStateIsUsed = 1 // 验证码已使用
)
