package gpt

import "context"

type Gpt interface {
	ChatCompletions(ctx context.Context, request *ChatCompletionsRequest) (*ChatCompletionsResponse, error)
}
