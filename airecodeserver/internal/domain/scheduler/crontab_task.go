package scheduler

import (
	"context"
)

// CrontabTask 定时任务接口
type CrontabTask interface {
	// Execute 执行任务
	Execute(ctx context.Context) error
	// GetSchedule 获取执行计划（crontab格式）
	GetSchedule() string
}
