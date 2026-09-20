package entity

import (
	"time"
)

// UserInfo 用户信息表
type UserInfo struct {
	UserId         int64     `gorm:"column:user_id;primary_key;AUTO_INCREMENT"` // 用户ID
	NickName       string    `gorm:"column:nick_name;NOT NULL"`                 // 用户名称
	Sex            int32     `gorm:"column:sex;default:0;NOT NULL"`             // 普通用户性别，1 为男性，2 为女性
	Province       string    `gorm:"column:province;NOT NULL"`                  // 普通用户个人资料填写的省份
	City           string    `gorm:"column:city;NOT NULL"`                      // 普通用户个人资料填写的城市
	Country        string    `gorm:"column:country;NOT NULL"`                   // 国家，如中国为 CN
	HeadImgUrl     string    `gorm:"column:head_img_url;NOT NULL"`              // 用户头像，最后一个数值代表正方形头像大小（有 0、46、64、96、132 数值可选，0 代表 640*640 正方形头像），用户没有头像时该项为空
	Phone          *string   `gorm:"column:phone"`                              // 电话号码
	Email          *string   `gorm:"column:email"`                              // smtp
	Password       string    `gorm:"column:password;NOT NULL"`                  // 密码
	State          int32     `gorm:"column:state;default:0;NOT NULL"`           // 用户注册状态 1: 待绑定手机号，2：注册成功，3：用户已注销
	CreateTime     time.Time `gorm:"column:create_time;"`                       // 记录创建时间
	LastUpdateTime time.Time `gorm:"column:last_update_time;"`                  // 最后修改时间
}

func (m *UserInfo) TableName() string {
	return "ai_record_db.t_user_info"
}

const (
	UserStateWaitVerifyCode  = 1 // 待注册验证（绑定手机号/邮箱验证）
	UserStateRegisterSuccess = 2 // 注册成功
	UserStateDeactivated     = 3 // 用户已注销
)

const (
	LoginMethodPhone = 1
	LoginMethodEmail = 2
)
