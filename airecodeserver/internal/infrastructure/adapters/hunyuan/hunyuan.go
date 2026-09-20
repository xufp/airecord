package hunyuan

import (
	"context"

	"github.com/smartox/ai_record_server/internal/application/ports/gpt"
	"github.com/smartox/ai_record_server/internal/infrastructure/config"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"github.com/tencentcloud/tencentcloud-sdk-go/tencentcloud/common"
	"github.com/tencentcloud/tencentcloud-sdk-go/tencentcloud/common/profile"
	"github.com/tencentcloud/tencentcloud-sdk-go/tencentcloud/common/regions"
	thunyuan "github.com/tencentcloud/tencentcloud-sdk-go/tencentcloud/hunyuan/v20230901"
	"trpc.group/trpc-go/trpc-go/errs"
)

const (
	ModelHunYuanLite         = "hunyuan-lite"
	ModelHunYuanStandard     = "hunyuan-standard"
	ModelHunYuanStandard256k = "hunyuan-standard-256K"
)

func NewGptImpl(cfg config.HunYuanCfg, model string) gpt.Gpt {
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
	cfg   config.HunYuanCfg
	model string
}

func (g *GptImpl) newClient() (*thunyuan.Client, error) {
	cpf := profile.NewClientProfile()

	credential := common.NewCredential(g.cfg.SecretId, g.cfg.SecretKey)

	return thunyuan.NewClient(credential, regions.Guangzhou, cpf)
}

func (g *GptImpl) ChatCompletions(ctx context.Context, request *gpt.ChatCompletionsRequest) (
	*gpt.ChatCompletionsResponse, error,
) {
	// 创建客户端
	client, err := g.newClient()
	if err != nil {
		return nil, err
	}

	treq := thunyuan.NewChatCompletionsRequest()

	for _, msg := range request.Messages {
		tmsg := &thunyuan.Message{
			Role:    common.StringPtr(msg.Role),
			Content: common.StringPtr(msg.Content),
		}

		treq.Messages = append(treq.Messages, tmsg)
	}

	// ChatCompletions 同时支持 stream 和非 stream 的情况
	treq.Stream = common.BoolPtr(false)
	treq.Model = common.StringPtr(g.model)

	trsp, err := client.ChatCompletions(treq)
	if err != nil {
		return nil, errs.Newf(errorcode.ErrRemoteCallFail, "hunyuan call ChatCompletions error. %+v", err)
	}

	response := gpt.ChatCompletionsResponse{
		RequestId: *trsp.Response.RequestId,
		Usage: gpt.TokensUsage{
			Prompt:     *trsp.Response.Usage.PromptTokens,
			Completion: *trsp.Response.Usage.CompletionTokens,
			Total:      *trsp.Response.Usage.TotalTokens,
		},
		Messages: request.Messages,
	}

	for _, c := range trsp.Response.Choices {
		rmsg := gpt.Message{
			Role:    *c.Message.Role,
			Content: *c.Message.Content,
		}

		response.Messages = append(response.Messages, rmsg)
	}

	return &response, nil
}
