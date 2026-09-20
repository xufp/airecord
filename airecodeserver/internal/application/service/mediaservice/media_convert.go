package mediaservice

import (
	"context"
	"strings"

	"github.com/smartox/ai_record_server/internal/application/events"
	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	domainservice "github.com/smartox/ai_record_server/internal/domain/service"
	"github.com/smartox/ai_record_server/internal/infrastructure/config"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"trpc.group/trpc-go/trpc-go/errs"
	"trpc.group/trpc-go/trpc-go/log"
)

func NewMediaConvert(transMgr repository.RepoTransMgr, userId int64) *MediaConvert {
	return &MediaConvert{
		userId:    userId,
		transMgr:  transMgr,
		isReentry: false,
	}
}

type MediaConvert struct {
	userId    int64
	transMgr  repository.RepoTransMgr
	mediaInfo *entity.MediaInfo
	mediaRec  *entity.MediaRec
	isReentry bool
}

func (m *MediaConvert) MediaConvert(ctx context.Context, req *protocol.MediaConvertReq) (
	*protocol.MediaConvertRsp, error,
) {
	// media检查
	if err := m.checkMediaInfo(ctx, req); err != nil {
		return nil, err
	}

	// 执行转写
	if err := m.execMediaRec(ctx, req); err != nil {
		return nil, err
	}

	return m.buildResponse(ctx)
}

func (m *MediaConvert) checkMediaInfo(ctx context.Context, req *protocol.MediaConvertReq) error {
	mediaInfo, err := m.transMgr.GetRepository().MediaRepo().GetMediaInfo(ctx, req.MediaId)
	if err != nil {
		return err
	}
	if mediaInfo.UserId != m.userId {
		return errs.Newf(errorcode.ErrRecordNotExisted, "media not found")
	}
	m.mediaInfo = mediaInfo

	// 校验音频状态是否需要转写
	if mediaInfo.State == entity.MediaStateSuccess || mediaInfo.State == entity.MediaStateProcessing {
		log.InfoContextf(ctx, "media not need to convert. state: %d", mediaInfo.State)
		m.isReentry = true
		return nil
	}

	// 校验音频类型是否支持转写
	if mediaInfo.State != entity.MediaStateFailed && mediaInfo.MediaType != entity.MediaTypeRecorderFile {
		return errs.Newf(errorcode.ErrMediaNotSupportConvert, "media not support convert")
	}

	if mediaInfo.State == entity.MediaStateInit {
		return errs.Newf(errorcode.ErrMediaFileNotExisted, "media file not upload ack")
	}

	// 套餐余量校验
	usage, err := domainservice.NewUserService(m.transMgr.GetRepository().ServiceRepo(),
		m.userId).GetUserServiceUsage(ctx,
		entity.ServiceTypeConvert)
	if err != nil {
		return err
	}

	if err := usage.CheckBalance(mediaInfo.Duration); err != nil {
		return err
	}

	return nil
}

// execMediaRec 执行音频识别
func (m *MediaConvert) execMediaRec(ctx context.Context, req *protocol.MediaConvertReq) error {
	if m.isReentry {
		return nil
	}

	// 生成RecForm
	recForm := entity.MediaRecFormFlash
	if strings.HasPrefix(m.mediaInfo.MediaUrl, config.StorageModeCosPrefix) {
		recForm = entity.MediaRecFormAudio
	}

	// 创建识别任务，执行转写
	switch recForm {
	case entity.MediaRecFormFlash:
		if err := m.createFlashRecognizer(ctx, int32(recForm), req.EngineType); err != nil {
			return err
		}
	case entity.MediaRecFormAudio:
		if err := m.createAudioRecognizer(ctx, int32(recForm), req.EngineType); err != nil {
			return err
		}
	}

	return nil
}

func (m *MediaConvert) createFlashRecognizer(ctx context.Context, recForm int32, engine string) error {
	// 创建转写任务记录，启用转写
	if err := m.transMgr.DoTransaction(ctx, func(ctx context.Context, repo repository.AiRecordRepo) error {
		// 锁用户记录
		if _, err := repo.UserRepo().LockUserInfo(ctx, m.userId); err != nil {
			return err
		}

		// 创建转写记录
		mediaRec, err := domainservice.NewUserMedia(repo.MediaRepo(), m.userId).CreateMediaConvert(ctx, m.mediaInfo.MediaId,
			recForm, engine)
		if err != nil {
			return err
		}
		m.mediaRec = mediaRec

		return nil
	}); err != nil {
		return err
	}

	// 执行转写任务
	if err := events.NewFlashRecognizer(m.transMgr, m.userId).FlashRecognizer(ctx, m.mediaRec); err != nil {
		return err
	}

	return nil
}

func (m *MediaConvert) createAudioRecognizer(ctx context.Context, recForm int32, engine string) error {
	// 创建转写任务记录，启用转写
	if err := m.transMgr.DoTransaction(ctx, func(ctx context.Context, repo repository.AiRecordRepo) error {
		// 锁用户记录
		if _, err := repo.UserRepo().LockUserInfo(ctx, m.userId); err != nil {
			return err
		}

		// 创建转写记录
		mediaRec, err := domainservice.NewUserMedia(repo.MediaRepo(), m.userId).CreateMediaConvert(ctx, m.mediaInfo.MediaId,
			recForm, engine)
		if err != nil {
			return err
		}
		m.mediaRec = mediaRec

		return nil
	}); err != nil {
		return err
	}

	// 执行转写
	if err := events.NewAudioRecognizer(m.transMgr, m.userId).AudioRecognizer(ctx, m.mediaRec); err != nil {
		m.mediaRec.State = entity.MediaRecStateFailed
		m.mediaRec.Memo = err.Error()
		// 错误信息截断
		if len(m.mediaRec.Memo) > 256 {
			m.mediaRec.Memo = m.mediaRec.Memo[:256]
		}
	}

	// 更新转写进度
	if err := m.transMgr.DoTransaction(ctx, func(ctx context.Context, repo repository.AiRecordRepo) error {
		// 锁用户记录
		if _, err := repo.UserRepo().LockUserInfo(ctx, m.userId); err != nil {
			return err
		}

		// 更新转写记录
		if err := domainservice.NewUserMedia(repo.MediaRepo(), m.userId).UpdateMediaRec(ctx, m.mediaRec); err != nil {
			return err
		}

		return nil
	}); err != nil {
		return err
	}

	return nil
}

func (m *MediaConvert) buildResponse(ctx context.Context) (*protocol.MediaConvertRsp, error) {
	if m.isReentry {
		rec, err := m.transMgr.GetRepository().MediaRepo().GetMediaRec(ctx, m.mediaInfo.MediaId)
		if err == nil {
			m.mediaRec = rec
		}
	}

	return &protocol.MediaConvertRsp{
		MediaId: m.mediaRec.MediaId,
		State:   m.mediaRec.State,
		Memo:    m.mediaRec.Memo,
		Text:    m.mediaRec.Text,
	}, nil
}
