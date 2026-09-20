package events

import (
	"context"
	"fmt"
	"time"

	"github.com/smartox/ai_record_server/internal/application/ports/recognizer"
	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	domainservice "github.com/smartox/ai_record_server/internal/domain/service"
	"github.com/smartox/ai_record_server/internal/infrastructure/adapters/asrv3"
	"github.com/smartox/ai_record_server/internal/infrastructure/adapters/cos"
	"github.com/smartox/ai_record_server/internal/infrastructure/config"
	"trpc.group/trpc-go/trpc-go/log"
)

const DefaultRetryTimes = 5

type AudioRecognizer interface {
	AudioRecognizer(ctx context.Context, mediaRec *entity.MediaRec) error

	DescribeTaskStatus(ctx context.Context, task *recognizer.RecTask, mediaRec *entity.MediaRec, times int)
}

func NewAudioRecognizer(transMgr repository.RepoTransMgr, userId int64) AudioRecognizer {
	return &AudioRecognizerImpl{
		transMgr:   transMgr,
		userId:     userId,
		recognizer: asrv3.NewAudioRecognizer(config.GetServerConfig().Media.Asr),
	}
}

type AudioRecognizerImpl struct {
	transMgr   repository.RepoTransMgr
	userId     int64
	recognizer recognizer.AudioRecognizer
}

func (i *AudioRecognizerImpl) AudioRecognizer(ctx context.Context, mediaRec *entity.MediaRec) error {
	// 创建识别任务
	request := recognizer.NewRecTaskRequest(mediaRec.EngineType)

	// 获取media url
	storage := cos.NewObjectStorage(config.GetServerConfig().Media.Storage.Cos)
	url, err := storage.GetObjectUrl(ctx, mediaRec.ObjectName)
	if err != nil {
		return err
	}
	request.Url = url

	task, err := i.recognizer.CreateRecTask(ctx, request)
	if err != nil {
		return err
	}

	mediaRec.TaskId = fmt.Sprintf("%d", task.TaskId)

	// 启动异步查询任务
	go i.DescribeTaskStatus(context.Background(), task, mediaRec, DefaultRetryTimes)

	return nil
}

// DescribeTaskStatus 识别状态查询
func (i *AudioRecognizerImpl) DescribeTaskStatus(
	ctx context.Context, task *recognizer.RecTask, mediaRec *entity.MediaRec, times int,
) {
	interval := 2 // 设置初始sleep时间间隔，单位秒

	for idx := 0; idx < times; idx++ {
		recTaskStatus, err := i.recognizer.DescribeTaskStatus(ctx, task)
		if err != nil {
			mediaRec.State = entity.MediaRecStateFailed
			mediaRec.Memo = err.Error()
			break
		}

		if recTaskStatus.Status == recognizer.TaskStatusFailed {
			mediaRec.State = entity.MediaRecStateFailed
			mediaRec.Memo = recTaskStatus.ErrorMsg
			break
		} else if recTaskStatus.Status == recognizer.TaskStatusSuccess {
			mediaRec.State = entity.MediaRecStateSuccess
			mediaRec.Memo = "success"
			mediaRec.Duration = recTaskStatus.Duration
			mediaRec.Text = recTaskStatus.Text

			sentenceDetail := entity.SentenceDetail{}
			for _, v := range recTaskStatus.SentenceList {
				sentence := entity.Sentence{
					Index:     v.Index,
					StartTime: v.StartTime,
					EndTime:   v.EndTime,
					Text:      v.Text,
					SpeakId:   v.SpeakId,
				}

				sentenceDetail.SentenceList = append(sentenceDetail.SentenceList, sentence)
			}

			mediaRec.SentenceDetail = sentenceDetail.Marshal()
			break
		}

		time.Sleep(time.Second * time.Duration(interval))
		if idx > times {
			mediaRec.State = entity.MediaRecStateFailed
			mediaRec.Memo = fmt.Sprintf("DescribeTaskStatus times out of range %d.", times)
		} else {
			interval = interval * 2
		}
	}

	// 识别结果更新
	if err := i.transMgr.DoTransaction(ctx, func(ctx context.Context, repo repository.AiRecordRepo) error {
		// 锁用户记录
		if _, err := repo.UserRepo().LockUserInfo(ctx, i.userId); err != nil {
			return err
		}

		// 更新音频识别结果
		if err := domainservice.NewUserMedia(repo.MediaRepo(), i.userId).UpdateMediaRec(ctx, mediaRec); err != nil {
			return err
		}

		// 用户转写服务消费
		if mediaRec.State == entity.MediaRecStateSuccess {
			if err := domainservice.NewUserService(repo.ServiceRepo(), i.userId).UserConvertServiceCost(ctx, mediaRec.MediaId,
				mediaRec.Duration, false); err != nil {
				return err
			}
		}

		return nil
	}); err != nil {
		log.ErrorContextf(ctx, "AudioRecognizer update rec result err: %+v", err)
		return
	}
}
