package events

import (
	"context"

	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	domainservice "github.com/smartox/ai_record_server/internal/domain/service"
	"github.com/smartox/ai_record_server/internal/infrastructure/adapters/asrv2"
	"github.com/smartox/ai_record_server/internal/infrastructure/config"
	"github.com/smartox/ai_record_server/internal/infrastructure/utils"
	"trpc.group/trpc-go/trpc-go/log"
)

type FlashRecognizer interface {
	FlashRecognizer(ctx context.Context, mediaRec *entity.MediaRec) error
}

func NewFlashRecognizer(transMgr repository.RepoTransMgr, userId int64) FlashRecognizer {
	return &FlashRecognizerImpl{
		transMgr: transMgr,
		userId:   userId,
	}
}

type FlashRecognizerImpl struct {
	transMgr repository.RepoTransMgr
	userId   int64
}

// FlashRecognizer 极速识别
func (f *FlashRecognizerImpl) FlashRecognizer(ctx context.Context, mediaRec *entity.MediaRec) error {
	// 执行转写，超过2分钟的音频，异步执行
	if utils.OccupiedTime(mediaRec.Duration, utils.BlockMillisecond) == 2 {
		log.DebugContextf(ctx, "FlashRecognizer exec.")
		f.executeFlashRecognizer(ctx, mediaRec)
	} else {
		log.DebugContextf(ctx, "FlashRecognizer exec for go")
		go f.executeFlashRecognizer(context.Background(), mediaRec)
	}

	return nil
}

func (f *FlashRecognizerImpl) executeFlashRecognizer(ctx context.Context, mediaRec *entity.MediaRec) {
	// 执行识别
	if err := asrv2.NewSpeechRecognizer(config.GetServerConfig().Media.Asr).FlashRecognizer(ctx, mediaRec); err != nil {
		log.ErrorContextf(ctx, "FlashRecognizer err: %+v", err)
		mediaRec.State = entity.MediaStateFailed
		mediaRec.Memo = err.Error()
	}

	log.DebugContextf(ctx, "FlashRecognizer DoTransaction for update recognizer result")

	// 识别结果更新
	if err := f.transMgr.DoTransaction(ctx, func(ctx context.Context, repo repository.AiRecordRepo) error {
		// 锁用户记录
		if _, err := repo.UserRepo().LockUserInfo(ctx, f.userId); err != nil {
			return err
		}

		// 更新音频识别结果
		if err := domainservice.NewUserMedia(repo.MediaRepo(), f.userId).UpdateMediaRec(ctx, mediaRec); err != nil {
			return err
		}

		// 用户转写服务消费
		if mediaRec.State == entity.MediaRecStateSuccess {
			if err := domainservice.NewUserService(repo.ServiceRepo(), f.userId).UserConvertServiceCost(ctx, mediaRec.MediaId,
				mediaRec.Duration, false); err != nil {
				return err
			}
		}

		return nil
	}); err != nil {
		log.ErrorContextf(ctx, "FlashRecognizer update asrv2 err: %+v", err)
		return
	}
}
