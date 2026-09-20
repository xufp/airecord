package scheduler

import (
	"context"

	"github.com/robfig/cron/v3"
	"trpc.group/trpc-go/trpc-go/log"
)

// NewTaskScheduler 创建任务调度器
func NewTaskScheduler() *TaskScheduler {
	return &TaskScheduler{}
}

// TaskScheduler 任务调度器
// 实现了CrontabTask接口，用于执行定时任务
// 支持秒级精度
type TaskScheduler struct{}

// Run 启动任务调度器
func (t *TaskScheduler) Run(ctx context.Context, tasks ...CrontabTask) error {
	if len(tasks) == 0 {
		log.ErrorContextf(ctx, "no tasks provided")
		return nil
	}

	// 创建cron调度器
	c := cron.New(cron.WithSeconds()) // 支持秒级精度
	defer c.Stop()

	// 为每个任务注册cron表达式
	for _, task := range tasks {
		t := task // 创建闭包变量
		_, err := c.AddFunc(task.GetSchedule(), func() {
			// 异步执行任务
			go func() {
				if err := t.Execute(ctx); err != nil {
					log.ErrorContextf(ctx, "task failed: %T, error: %v", t, err)
				}
			}()
		})
		if err != nil {
			log.ErrorContextf(ctx, "register task failed: %T, error: %v", task, err)
			return err
		}
		log.InfoContextf(ctx, "register task success: %T, schedule: %s", task, task.GetSchedule())
	}

	// 启动cron调度器
	c.Start()
	log.InfoContextf(ctx, "task scheduler started")

	// 等待上下文取消
	<-ctx.Done()
	log.InfoContextf(ctx, "task scheduler stopped")

	return nil
}
