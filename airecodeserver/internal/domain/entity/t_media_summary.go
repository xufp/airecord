package entity

import (
	"time"
)

// MediaSummary 音频总结记录表
type MediaSummary struct {
	SummaryId      int64     `gorm:"column:summary_id;primary_key;AUTO_INCREMENT"`      // 总结记录ID
	MediaId        int64     `gorm:"column:media_id;NOT NULL"`                          // 音频ID
	Engine         string    `gorm:"column:engine;NOT NULL"`                            // 大模型引擎(hunyuan, openai, ...)
	Prompt         string    `gorm:"column:prompt;NOT NULL"`                            // 总结Prompt
	State          int32     `gorm:"column:state;default:0;NOT NULL"`                   // 0： 初始化，1: 总结中，2：已成功， 3：总结失败
	Memo           string    `gorm:"column:memo;NOT NULL"`                              // 备注信息
	ContentType    int32     `gorm:"column:content_type;default:0;NOT NULL"`            // 总结内容类型 1-引擎生成内容，2-用户修改内容
	Content        string    `gorm:"column:content;NOT NULL"`                           // 总结内容
	CreateTime     time.Time `gorm:"column:create_time;default:CURRENT_TIMESTAMP"`      // 记录创建时间
	LastUpdateTime time.Time `gorm:"column:last_update_time;default:CURRENT_TIMESTAMP"` // 最后修改时间
}

func (m *MediaSummary) TableName() string {
	return "ai_record_db.t_media_summary"
}

const (
	MediaSummaryContentTypeEngine = 1 // 引擎生成
	MediaSummaryContentTypeCustom = 2 // 用户修改
)

const (
	MediaSummaryStateWaiting = 0 // 任务等待
	MediaSummaryStateDoing   = 1 // 任务执行中
	MediaSummaryStateSuccess = 2 // 任务成功
	MediaSummaryStateFailed  = 3 // 任务失败
)

const (
	GptEngineHunYuan = "hunyuan"
	GptEngineOpenAI  = "openai"
)
