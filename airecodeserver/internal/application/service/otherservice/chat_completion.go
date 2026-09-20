package otherservice

import (
	"github.com/smartox/ai_record_server/internal/application/ports/gpt"
	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	domainservice "github.com/smartox/ai_record_server/internal/domain/service"
	"github.com/smartox/ai_record_server/internal/infrastructure/adapters/hunyuan"
	"github.com/smartox/ai_record_server/internal/infrastructure/adapters/openai"
	"github.com/smartox/ai_record_server/internal/infrastructure/config"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"golang.org/x/net/context"
	"trpc.group/trpc-go/trpc-go/errs"
)

func NewChatCompletion(repo repository.ServiceRepo, userId int64) *ChatCompletion {
	return &ChatCompletion{
		repo:   repo,
		userId: userId,
	}
}

type ChatCompletion struct {
	repo   repository.ServiceRepo
	userId int64
}

func (c *ChatCompletion) ChatCompletion(
	ctx context.Context, req *protocol.ChatCompletionReq,
) (*protocol.ChatCompletionRsp, error) {
	if len(req.Messages) > 20 {
		return nil, errs.Newf(errorcode.ErrParamsInvalid, "params out of range messages size.")
	}

	// 会员权限检查
	membership, err := domainservice.NewUserService(c.repo, c.userId).GetMembership(ctx)
	if err != nil {
		return nil, err
	}

	// todo: 需调整为会员等级2以上方可使用
	if membership.Level < entity.MembershipLevel1 {
		return nil, errs.Newf(errorcode.ErrPackageNotSupport, "user package not support.")
	}

	// 构造请求消息
	chatReq := &gpt.ChatCompletionsRequest{}
	for _, msg := range req.Messages {
		chatReq.Messages = append(chatReq.Messages, gpt.Message{
			Role:    msg.Role,
			Content: msg.Content,
		})
	}

	// 选择gpt引擎
	var g gpt.Gpt
	switch config.GetServerConfig().Gpt.Default {
	case entity.GptEngineOpenAI:
		g = openai.NewGptImpl(config.GetServerConfig().Gpt.OpenAi, "")
	case entity.GptEngineHunYuan:
		g = hunyuan.NewGptImpl(config.GetServerConfig().Gpt.HunYuan, "")
	default:
		g = openai.NewGptImpl(config.GetServerConfig().Gpt.OpenAi, "")
	}

	// 调用gpt接口
	chatRsp, err := g.ChatCompletions(ctx, chatReq)
	if err != nil {
		return nil, err
	}

	// 构造返回消息
	rsp := &protocol.ChatCompletionRsp{}
	for _, msg := range chatRsp.Messages {
		rsp.Messages = append(rsp.Messages, protocol.Message{
			Role:    msg.Role,
			Content: msg.Content,
		})
	}

	return rsp, nil
}
