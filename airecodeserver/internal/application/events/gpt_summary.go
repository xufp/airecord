package events

import (
  "context"
  "strings"

  "github.com/smartox/ai_record_server/internal/application/ports/gpt"
  "github.com/smartox/ai_record_server/internal/domain/entity"
  "github.com/smartox/ai_record_server/internal/domain/repository"
  "github.com/smartox/ai_record_server/internal/infrastructure/adapters/hunyuan"
  "github.com/smartox/ai_record_server/internal/infrastructure/adapters/openai"
  "github.com/smartox/ai_record_server/internal/infrastructure/config"
  "github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
  "trpc.group/trpc-go/trpc-go/errs"
  "trpc.group/trpc-go/trpc-go/log"
)

type GptSummary interface {
  GptSummary(ctx context.Context, mediaRec *entity.MediaRec, mediaSummary *entity.MediaSummary) error
}

func NewGptSummary(transMgr repository.RepoTransMgr, userId int64) GptSummary {
  return &GptSummaryImpl{
    transMgr: transMgr,
    userId:   userId,
  }
}

type GptSummaryImpl struct {
  transMgr repository.RepoTransMgr
  userId   int64
}

func (s *GptSummaryImpl) GptSummary(
    ctx context.Context, mediaRec *entity.MediaRec, mediaSummary *entity.MediaSummary,
) error {
  // 构造请求消息
  prompt := mediaSummary.Prompt
  if len(prompt) == 0 {
    prompt = "请为以下内容生成总结，输出时请使用与内容相同的语言。内容如下："
  }

  var content string
  // 检查prompt内容，存在{transcribed_text}, 则替换为实际的文本内容
  if strings.Count(prompt, "{transcribed_text}") > 0 {
    content = strings.ReplaceAll(prompt, "{transcribed_text}", mediaRec.Text)
  } else {
    content = prompt + mediaRec.Text
  }

  msg := gpt.Message{
    Role:    gpt.RoleUser,
    Content: content,
  }

  switch mediaSummary.Engine {
  case entity.GptEngineHunYuan:
    go s.hunYuanSummary(context.Background(), msg, mediaSummary)
  case entity.GptEngineOpenAI:
    go s.openAiSummary(context.Background(), msg, mediaSummary)
  default:
    return errs.Newf(errorcode.ErrEngineNotSupport, "not support engine")
  }

  return nil
}

func (s *GptSummaryImpl) hunYuanSummary(
    ctx context.Context, msg gpt.Message, mediaSummary *entity.MediaSummary,
) {
  // 更新状态为执行中
  mediaSummary.State = entity.MediaSummaryStateDoing
  if err := s.transMgr.DoTransaction(ctx, func(ctx context.Context, repo repository.AiRecordRepo) error {
    // 锁用户记录
    if _, err := repo.UserRepo().LockUserInfo(ctx, s.userId); err != nil {
      return err
    }

    // 更新总结结果
    if err := repo.MediaRepo().UpdateMediaSummary(ctx, mediaSummary); err != nil {
      return err
    }

    return nil
  }); err != nil {
    log.ErrorContextf(ctx, "hunYuanSummary update media summary state = 1 failed. err: %+v", err)
  }

  // 执行总结
  req := &gpt.ChatCompletionsRequest{}
  req.Messages = append(req.Messages, msg)

  h := hunyuan.NewGptImpl(config.GetServerConfig().Gpt.HunYuan, "")
  rsp, err := h.ChatCompletions(ctx, req)
  if err != nil {
    mediaSummary.State = entity.MediaSummaryStateFailed
    mediaSummary.Memo = err.Error()
  } else {
    log.InfoContextf(ctx, "summary: %+v", rsp)

    mediaSummary.State = entity.MediaSummaryStateSuccess
    if len(rsp.Messages) > 0 {
      mediaSummary.Content = rsp.Messages[len(rsp.Messages)-1].Content
    }
  }

  // 更新结果
  if err := s.transMgr.DoTransaction(ctx, func(ctx context.Context, repo repository.AiRecordRepo) error {
    // 锁用户记录
    if _, err := repo.UserRepo().LockUserInfo(ctx, s.userId); err != nil {
      return err
    }

    // 更新总结结果
    if err := repo.MediaRepo().UpdateMediaSummary(ctx, mediaSummary); err != nil {
      return err
    }

    return nil
  }); err != nil {
    log.ErrorContextf(ctx, "hunYuanSummary update media summary err: %+v", err)
    return
  }
}

func (s *GptSummaryImpl) openAiSummary(
    ctx context.Context, msg gpt.Message, mediaSummary *entity.MediaSummary,
) {
  // 更新状态为执行中
  mediaSummary.State = entity.MediaSummaryStateDoing
  if err := s.transMgr.DoTransaction(ctx, func(ctx context.Context, repo repository.AiRecordRepo) error {
    // 锁用户记录
    if _, err := repo.UserRepo().LockUserInfo(ctx, s.userId); err != nil {
      return err
    }

    // 更新总结结果
    if err := repo.MediaRepo().UpdateMediaSummary(ctx, mediaSummary); err != nil {
      return err
    }

    return nil
  }); err != nil {
    log.ErrorContextf(ctx, "openAiSummary update media summary state = 1 failed. err: %+v", err)
  }

  // 执行总结
  req := &gpt.ChatCompletionsRequest{}
  req.Messages = append(req.Messages, msg)

  h := openai.NewGptImpl(config.GetServerConfig().Gpt.OpenAi, "")
  rsp, err := h.ChatCompletions(ctx, req)
  if err != nil {
    mediaSummary.State = entity.MediaSummaryStateFailed
    mediaSummary.Memo = err.Error()
  } else {
    log.InfoContextf(ctx, "summary: %+v", rsp)

    mediaSummary.State = entity.MediaSummaryStateSuccess
    if len(rsp.Messages) > 0 {
      mediaSummary.Content = rsp.Messages[len(rsp.Messages)-1].Content
    }
  }

  // 更新结果
  if err := s.transMgr.DoTransaction(ctx, func(ctx context.Context, repo repository.AiRecordRepo) error {
    // 锁用户记录
    if _, err := repo.UserRepo().LockUserInfo(ctx, s.userId); err != nil {
      return err
    }

    // 更新总结结果
    if err := repo.MediaRepo().UpdateMediaSummary(ctx, mediaSummary); err != nil {
      return err
    }

    return nil
  }); err != nil {
    log.ErrorContextf(ctx, "openAiSummary update media summary err: %+v", err)
    return
  }
}
