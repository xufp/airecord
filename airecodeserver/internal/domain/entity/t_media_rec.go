package entity

import (
	"time"
)

// MediaRec 音频语音识别表
type MediaRec struct {
	MediaId        int64     `gorm:"column:media_id;primary_key"`                       // 音频ID
	RecForm        int32     `gorm:"column:rec_form;NOT NULL"`                          // Asr服务形式 1：录音文件极速识别，2：实时语音识别，3：录音文件识别
	EngineType     string    `gorm:"column:engine_type;NOT NULL"`                       // 引擎模型类型(16k_zh：中文通用；16k_en：英语；)
	Format         string    `gorm:"column:format;NOT NULL"`                            // 音频编码格式 wav, mp3, acc ...
	ObjectName     string    `gorm:"column:object_name;NOT NULL"`                       // 音频文件对象名称（路径）
	State          int32     `gorm:"column:state;default:0;NOT NULL"`                   // 0： 等待中，1: 识别中，2：已完成， 3：识别失败
	Memo           string    `gorm:"column:memo;NOT NULL"`                              // 备注信息(失败错误信息等)
	TaskId         string    `gorm:"column:task_id;NOT NULL"`                           // 识别请求任务ID
	RequestId      string    `gorm:"column:request_id;NOT NULL"`                        // 请求ID，用于tcloud日志查询
	Duration       int64     `gorm:"column:duration;default:0;NOT NULL"`                // 识别音频的时长：毫秒
	Text           string    `gorm:"column:text;NOT NULL"`                              // 已识别完整文本
	SentenceDetail string    `gorm:"column:sentence_detail;NOT NULL"`                   // 识别结果段落级别明细
	CreateTime     time.Time `gorm:"column:create_time;default:CURRENT_TIMESTAMP"`      // 记录创建时间
	LastUpdateTime time.Time `gorm:"column:last_update_time;default:CURRENT_TIMESTAMP"` // 最后修改时间
}

func (m *MediaRec) TableName() string {
	return "ai_record_db.t_media_rec"
}

const (
	MediaRecFormFlash  = 1 // 极速识别
	MediaRecFormSpeech = 2 // 实时语音识别
	MediaRecFormAudio  = 3 // 录音文件识别
)

const (
	MediaRecStateNotConvert = -1 // 任务未创建
	MediaRecStateWaiting    = 0  // 任务等待
	MediaRecStateDoing      = 1  // 任务执行中
	MediaRecStateSuccess    = 2  // 任务成功
	MediaRecStateFailed     = 3  // 任务失败
)

const (
	MediaRecEngine16kZh = "16k_zh"
	MediaRecEngine16kEn = "16k_en"
)
