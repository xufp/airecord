package entity

import (
	"time"
)

// MediaInfo 音频信息表
type MediaInfo struct {
	MediaId        int64      `gorm:"column:media_id;primary_key;AUTO_INCREMENT"`        // 音频ID
	UserId         int64      `gorm:"column:user_id;NOT NULL"`                           // 用户ID
	MediaName      string     `gorm:"column:media_name;NOT NULL"`                        // 音频名称（可修改）
	FileFormat     string     `gorm:"column:file_format;NOT NULL"`                       // 音频文件格式 wav, mp3 ...
	FileSize       int64      `gorm:"column:file_size;default:0;NOT NULL"`               // 文件大小(单位：byte)
	FileSign       string     `gorm:"column:file_sign;NOT NULL"`                         // 文件签名(sha256)
	RecordTime     time.Time  `gorm:"column:record_time;default:CURRENT_TIMESTAMP"`      // 文件创建时间/录音时间
	RecordAddress  string     `gorm:"column:record_address;NOT NULL"`                    // 记录地址
	Duration       int64      `gorm:"column:duration;default:0;NOT NULL"`                // 音频时长(单位：毫秒)
	MediaUrl       string     `gorm:"column:media_url;NOT NULL"`                         // 音频文件url地址 (file:,cos:)
	State          int32      `gorm:"column:state;default:0;NOT NULL"`                   // 音频状态：0: 初始状态(未上传),1:已上传, 2: 转写中，3：已转写， 4：转写失败
	RecTime        *time.Time `gorm:"column:rec_time"`                                   // 音频识别成功时间
	Summary        string     `gorm:"column:summary;NOT NULL"`                           // 文件摘要(已转写文本内容摘要)
	Description    string     `gorm:"column:description;NOT NULL"`                       // 描述信息
	MediaType      int32      `gorm:"column:media_type;default:0;NOT NULL"`              // 音频类型 1：常规录音文件；2：速记录音文件
	DeviceId       string     `gorm:"column:device_id;NOT NULL"`                         // 设备ID
	Lstate         int32      `gorm:"column:lstate;default:0;NOT NULL"`                  // 逻辑状态(判断当前记录是否逻辑删除) 1: active, 2: deleted
	CreateTime     time.Time  `gorm:"column:create_time;default:CURRENT_TIMESTAMP"`      // 创建时间
	LastUpdateTime time.Time  `gorm:"column:last_update_time;default:CURRENT_TIMESTAMP"` // 最后修改时间
}

func (m *MediaInfo) TableName() string {
	return "ai_record_db.t_media_info"
}

const (
	LStateActive  = 1 // 逻辑状态：有效
	LStateDeleted = 2 // 逻辑状态：已删除
)

const (
	MediaTypeRecorderFile = 1 // 常规录音文件
	MediaTypeSpeechFile   = 2 // 速记录音文件
)

const (
	MediaStateInit       = 0 // 初始,文件未上传
	MediaStateUploaded   = 1 // 文件已上传
	MediaStateProcessing = 2 // 转写中
	MediaStateSuccess    = 3 // 已转写成功
	MediaStateFailed     = 4 // 转写失败
)

const (
	MediaFileFormatPcm  = "pcm"
	MediaFileFormatWav  = "wav"
	MediaFileFormatMp3  = "mp3"
	MediaFileFormatM4a  = "m4a"
	MediaFileFormatOpus = "opus"
)

// const (
// 	MediaFileUploadNotAck = 0 // 0-上传未确认
// 	MediaFileUploadAck    = 1 // 1-上传已确认
// )
