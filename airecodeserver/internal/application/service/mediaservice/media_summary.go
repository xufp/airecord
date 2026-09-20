package mediaservice

import (
	"context"

	"github.com/smartox/ai_record_server/internal/application/events"
	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	"github.com/smartox/ai_record_server/internal/domain/service"
	"github.com/smartox/ai_record_server/internal/infrastructure/config"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"trpc.group/trpc-go/trpc-go/errs"
	"trpc.group/trpc-go/trpc-go/log"
)

func NewMediaSummary(transMgr repository.RepoTransMgr, userId int64) *MediaSummary {
	return &MediaSummary{
		transMgr: transMgr,
		userId:   userId,
	}
}

type MediaSummary struct {
	transMgr     repository.RepoTransMgr
	userId       int64
	prompt       string
	mediaRec     *entity.MediaRec
	mediaSummary *entity.MediaSummary
}

func (m *MediaSummary) MediaSummary(ctx context.Context, req *protocol.MediaSummaryReq) (
	*protocol.MediaSummaryRsp, error,
) {
	if err := m.checkParams(ctx, req); err != nil {
		return nil, err
	}

	if err := m.generateSummary(ctx, req.MediaId, req.Engine); err != nil {
		return nil, err
	}

	return &protocol.MediaSummaryRsp{
		MediaId: req.MediaId,
		State:   m.mediaSummary.State,
		Content: m.mediaSummary.Content,
	}, nil
}

func (m *MediaSummary) checkParams(ctx context.Context, req *protocol.MediaSummaryReq) error {
	// 默认引擎
	if len(req.Engine) == 0 {
		req.Engine = config.GetServerConfig().Gpt.Default
	}

	// 当前仅支持混元大模型
	if req.Engine != entity.GptEngineHunYuan && req.Engine != entity.GptEngineOpenAI {
		return errs.Newf(errorcode.ErrEngineNotSupport, "not support gpt engine")
	}

	if len(req.PromptId) != 0 {
		// 校验promptId合法性
		PromptCfg, err := m.transMgr.GetRepository().UserRepo().GetAppConfig(ctx, entity.AppConfigTypePromptTemplate,
			req.PromptId)
		if err != nil {
			return err
		}
		m.prompt = PromptCfg.ConfigValue
	} else {
		m.prompt = req.Prompt
	}

	// 查询音频信息
	mediaInfo, err := m.transMgr.GetRepository().MediaRepo().GetMediaInfo(ctx, req.MediaId)
	if err != nil {
		return err
	}

	if mediaInfo.UserId != m.userId {
		return errs.Newf(errorcode.ErrParamsInvalid, "media not found")
	}

	// 查询音频转写记录
	m.mediaRec, err = m.transMgr.GetRepository().MediaRepo().GetMediaRec(ctx, req.MediaId)
	if err != nil {
		return err
	}

	if m.mediaRec.State != entity.MediaRecStateSuccess {
		return errs.Newf(errorcode.ErrMediaNotConvert, "media not convert success")
	}

	// 生成总结前校验
	if len(m.mediaRec.Text) < config.GetServerConfig().Gpt.TextLimit {
		return errs.Newf(errorcode.ErrTextTooShortSummary, "text is too short to summarize")
	}

	return nil
}

func (m *MediaSummary) generateSummary(ctx context.Context, mediaId int64, engine string) error {
	// 创建总结记录
	if err := m.transMgr.DoTransaction(ctx, func(ctx context.Context, repo repository.AiRecordRepo) error {
		// 锁用户记录
		if _, err := repo.UserRepo().LockUserInfo(ctx, m.userId); err != nil {
			return err
		}

		// 创建转写记录
		mediaSummary, err := service.NewUserMedia(repo.MediaRepo(), m.userId).CreateMediaSummary(ctx, mediaId, engine,
			m.prompt)
		if err != nil {
			return err
		}
		m.mediaSummary = mediaSummary

		return nil
	}); err != nil {
		return err
	}

	// 总结生成处理中或已成功，不重新生成总结
	if m.mediaSummary.State == entity.MediaSummaryStateSuccess || m.mediaSummary.State == entity.MediaSummaryStateDoing {
		return nil
	}

	// 执行生成总结
	if err := events.NewGptSummary(m.transMgr, m.userId).GptSummary(ctx, m.mediaRec, m.mediaSummary); err != nil {
		// 错误返回，更新失败信息
		m.mediaSummary.State = entity.MediaSummaryStateFailed
		m.mediaSummary.Memo = err.Error()
		// 错误信息截断
		if len(m.mediaSummary.Memo) > 256 {
			m.mediaSummary.Memo = m.mediaSummary.Memo[:256]
		}

		// 更新结果
		if err := m.transMgr.DoTransaction(ctx, func(ctx context.Context, repo repository.AiRecordRepo) error {
			// 锁用户记录
			if _, err := repo.UserRepo().LockUserInfo(ctx, m.userId); err != nil {
				return err
			}

			// 更新总结结果
			if err := repo.MediaRepo().UpdateMediaSummary(ctx, m.mediaSummary); err != nil {
				return err
			}

			return nil
		}); err != nil {
			log.ErrorContextf(ctx, "hunYuanSummary update media summary err: %+v", err)
			return err
		}

		return err
	}

	return nil
}
