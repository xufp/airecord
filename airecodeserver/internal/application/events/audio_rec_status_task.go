package events

import (
	"context"
	"strconv"

	"github.com/smartox/ai_record_server/internal/application/ports/recognizer"
	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	"github.com/smartox/ai_record_server/internal/domain/scheduler"
	"trpc.group/trpc-go/trpc-go/log"
)

type AudioRecStatusTask struct {
	schedule string
	transMgr repository.RepoTransMgr
}

func NewAudioRecStatusTask(schedule string, transMgr repository.RepoTransMgr) scheduler.CrontabTask {
	return &AudioRecStatusTask{
		schedule: schedule,
		transMgr: transMgr,
	}
}

// Execute 获取录音识别结果任务执行逻辑
func (t *AudioRecStatusTask) Execute(ctx context.Context) error {
	// 获取处理中的任务记录
	tasks, err := t.transMgr.GetRepository().MediaRepo().FindProcessingMediaRec(ctx,
		[]int32{entity.MediaRecStateWaiting, entity.MediaRecStateDoing})
	if err != nil {
		return err
	}

	for _, task := range tasks {
		if err := t.describeTaskStatus(ctx, task); err != nil {
			log.ErrorContextf(ctx, "describe task status failed: %v", err)
			continue
		}
	}

	return nil
}

// describeTaskStatus 获取录音识别结果
func (t *AudioRecStatusTask) describeTaskStatus(ctx context.Context, mediaRec *entity.MediaRec) error {
	taskId, err := strconv.ParseInt(mediaRec.TaskId, 10, 64)
	if err != nil {
		log.ErrorContextf(ctx, "taskId parse failed. %+v", err)
		return err
	}

	mediaInfo, err := t.transMgr.GetRepository().MediaRepo().GetMediaInfo(ctx, mediaRec.MediaId)
	if err != nil {
		return err
	}

	task := recognizer.RecTask{
		TaskId: uint64(taskId),
	}

	NewAudioRecognizer(t.transMgr, mediaInfo.UserId).DescribeTaskStatus(context.Background(), &task, mediaRec, 1)

	return nil
}

func (t *AudioRecStatusTask) GetSchedule() string {
	return t.schedule
}
