package gpt

type Message struct {
	Role    string `json:"role"`    // 角色，可选值包括 system、user、assistant、 tool。
	Content string `json:"content"` // 文本内容
}

const (
	RoleSystem    = "system"
	RoleUser      = "user"
	RoleAssistant = "assistant"
)

type TokensUsage struct {
	Prompt     int64 `json:"prompt"`     // 输入Token数量
	Completion int64 `json:"completion"` // 输出Token数量
	Total      int64 `json:"total"`      // 总Token数量
}

type ChatCompletionsRequest struct {
	Messages []Message `json:"messages"` // 聊天上下文信息, 属组最大长度40
}

type ChatCompletionsResponse struct {
	RequestId string      `json:"request_id"` // 本次请求的RequestId
	Messages  []Message   `json:"messages"`   // 回复内容
	Usage     TokensUsage `json:"usage"`      // Token 统计信息
}
