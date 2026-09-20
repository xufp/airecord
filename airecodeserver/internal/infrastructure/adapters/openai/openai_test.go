package openai

import (
	"context"
	"testing"

	"github.com/smartox/ai_record_server/internal/application/ports/gpt"
	"github.com/smartox/ai_record_server/internal/infrastructure/config"
)

func TestGptImpl_ChatCompletions(t *testing.T) {
	cfg := config.OpenAiCfg{
		ApiType:    config.OpenAiApiTypeAzure,
		SecretKey:  "YOUR_AZURE_OPENAI_KEY",
		Model:      "gpt-4o",
		BaseUrl:    "https://your-resource.cognitiveservices.azure.com",
		ApiVersion: "2024-08-01-preview",
	}

	tests := []struct {
		name    string
		cfg     config.OpenAiCfg
		model   string
		request *gpt.ChatCompletionsRequest
		wantErr bool
	}{
		{
			name:  "AzureOpenAi模型对话",
			cfg:   cfg,
			model: "gpt-4o",
			request: func() *gpt.ChatCompletionsRequest {
				msg := gpt.Message{
					Role:    gpt.RoleUser,
					Content: "你好！请介绍一下自己",
				}
				req := gpt.ChatCompletionsRequest{}
				req.Messages = append(req.Messages, msg)
				return &req
			}(),
			wantErr: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			h := NewGptImpl(tt.cfg, tt.model)
			got, err := h.ChatCompletions(context.Background(), tt.request)
			if (err != nil) != tt.wantErr {
				t.Errorf("ChatCompletions() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
			t.Logf("got: %+v", got)
			//
			// req2 := gpt.ChatCompletionsRequest{
			//   Messages: got.Messages,
			// }
			// msg := gpt.Message{
			//   Role:    gpt.RoleUser,
			//   Content: "你能帮我干什么",
			// }
			// req2.Messages = append(req2.Messages, msg)
			// got2, err := h.ChatCompletions(context.Background(), &req2)
			// if (err != nil) != tt.wantErr {
			//   t.Errorf("ChatCompletions() error = %v, wantErr %v", err, tt.wantErr)
			//   return
			// }
			// t.Logf("got2: %+v", got2)
		})
	}
}
