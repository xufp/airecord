package recognizer

import (
	"context"
)

//go:generate mockgen -source audio_recognizer.go -destination audio_recognizer.go -package recognizer

// AudioRecognizer 音频识别接口
type AudioRecognizer interface {
	// CreateRecTask 创建语音识别任务(录音文件识别)
	CreateRecTask(ctx context.Context, request *RecTaskRequest) (*RecTask, error)
	// DescribeTaskStatus  语音识别任务状态查询(录音文件识别)
	DescribeTaskStatus(ctx context.Context, task *RecTask) (*RecTaskStatus, error)
}
