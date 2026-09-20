package entity

import (
	"time"
)

// ThirdAuth 第三方授权信息表
type ThirdAuth struct {
	Id             int64     `gorm:"column:id;primary_key;AUTO_INCREMENT"`              // 自增ID
	Channel        int32     `gorm:"column:channel;NOT NULL"`                           // 授权渠道 1: wechat --当前仅支持微信第三方登录
	UserId         int64     `gorm:"column:user_id;primary_key"`                        // 用户ID
	UnionId        string    `gorm:"column:union_id;NOT NULL"`                          // 用户统一标识。针对一个微信开放平台账号下的应用，同一用户的 union_id 是唯一的. App已获取用户信息授权时才有值
	Openid         string    `gorm:"column:openid;NOT NULL"`                            // 授权用户唯一标识
	AccessToken    string    `gorm:"column:access_token;NOT NULL"`                      // 接口调用凭证（有效期2小时）
	CreateTime     time.Time `gorm:"column:create_time;default:CURRENT_TIMESTAMP"`      // 记录创建时间
	LastUpdateTime time.Time `gorm:"column:last_update_time;default:CURRENT_TIMESTAMP"` // 最后修改时间
}

func (m *ThirdAuth) TableName() string {
	return "ai_record_db.t_third_auth"
}

const (
	AuthTypeWechat = 1
)
