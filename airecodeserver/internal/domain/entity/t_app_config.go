package entity

import (
	"time"
)

// AppConfig 应用配置表
type AppConfig struct {
	Id             int32     `gorm:"column:id;primary_key;AUTO_INCREMENT"`              // 自增ID
	ConfigType     int32     `gorm:"column:config_type;NOT NULL"`                       // 配置类型 ...
	ConfigKey      string    `gorm:"column:config_key;NOT NULL"`                        // 配置项key
	ConfigValue    string    `gorm:"column:config_value;NOT NULL"`                      // 配置项值
	ConfigDesc     string    `gorm:"column:config_desc;NOT NULL"`                       // 配置描述
	ConfigName     string    `gorm:"column:config_name;NOT NULL"`                       // 配置类型名称 --
	Lstate         int32     `gorm:"column:lstate;default:0;NOT NULL"`                  // 逻辑状态(判断当前记录是否逻辑删除) 1: active, 2: deleted
	CreateTime     time.Time `gorm:"column:create_time;default:CURRENT_TIMESTAMP"`      // 记录创建时间
	LastUpdateTime time.Time `gorm:"column:last_update_time;default:CURRENT_TIMESTAMP"` // 最后修改时间
}

func (m *AppConfig) TableName() string {
	return "ai_record_db.t_app_config"
}

const (
	AppConfigTypeAppProtocol       = 1 // 应用协议
	AppConfigTypeHelpManual        = 2 // 帮助手册
	AppConfigTypeIosAppVersion     = 3 // IOS应用版本信息
	AppConfigTypeAndroidAppVersion = 4 // Android应用版本信息
	AppConfigTypeAsrEngineModel    = 5 // Asr引擎模型
	AppConfigTypePromptTemplate    = 6 // Prompt模板
	AppConfigTypeBleDevice         = 7 // 蓝牙设备
	AppConfigTypePackageI18n       = 8 // 套餐多语言配置
)

const (
	AppConfigLstateActive  = 1 // 有效
	AppConfigLstateDeleted = 2 // 删除
)
