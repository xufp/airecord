package openai

import (
	"context"

	"github.com/sashabaranov/go-openai"
	"github.com/smartox/ai_record_server/internal/application/ports/gpt"
	"github.com/smartox/ai_record_server/internal/infrastructure/config"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"trpc.group/trpc-go/trpc-go/errs"
	"trpc.group/trpc-go/trpc-go/log"
)

const (
	ModelGPT3Dot5Turbo = openai.GPT3Dot5Turbo
	ModelGPT4oMini     = openai.GPT4oMini
	ModelGPT4o         = openai.GPT4o
)

func NewGptImpl(cfg config.OpenAiCfg, model string) gpt.Gpt {
	// 默认使用配置文件中的模型
	if len(model) == 0 {
		model = cfg.Model
	}
	return &GptImpl{
		cfg:   cfg,
		model: model,
	}
}

type GptImpl struct {
	cfg   config.OpenAiCfg
	model string
}

func (g *GptImpl) ChatCompletions(ctx context.Context, request *gpt.ChatCompletionsRequest) (
	*gpt.ChatCompletionsResponse, error,
) {
	log.InfoContextf(ctx, "ChatCompletions cfg: %+v, model: %s", g.cfg, g.model)

	var client *openai.Client
	if g.cfg.ApiType == config.OpenAiApiTypeAzure {
		cfg := openai.DefaultAzureConfig(g.cfg.SecretKey, g.cfg.BaseUrl)
		cfg.APIVersion = g.cfg.ApiVersion
		client = openai.NewClientWithConfig(cfg)
	} else {
		client = openai.NewClient(g.cfg.SecretKey)
	}

	var gptMsgs []openai.ChatCompletionMessage
	for _, msg := range request.Messages {
		gptMsg := openai.ChatCompletionMessage{
			Role:    msg.Role,
			Content: msg.Content,
		}

		gptMsgs = append(gptMsgs, gptMsg)
	}

	resp, err := client.CreateChatCompletion(
		context.Background(),
		openai.ChatCompletionRequest{
			Model:    g.model,
			Messages: gptMsgs,
		},
	)

	if err != nil {
		return nil, errs.Newf(errorcode.ErrRemoteCallFail, "openai call ChatCompletions error. %+v", err)
	}

	response := gpt.ChatCompletionsResponse{
		RequestId: resp.ID,
		Usage: gpt.TokensUsage{
			Prompt:     int64(resp.Usage.PromptTokens),
			Completion: int64(resp.Usage.CompletionTokens),
			Total:      int64(resp.Usage.TotalTokens),
		},
		Messages: request.Messages,
	}

	for _, c := range resp.Choices {
		rmsg := gpt.Message{
			Role:    c.Message.Role,
			Content: c.Message.Content,
		}

		response.Messages = append(response.Messages, rmsg)
	}

	return &response, nil
}
