package constservice

import (
	"context"
	"encoding/json"

	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	"trpc.group/trpc-go/trpc-go/log"
)

func NewPromptTemplates(repo repository.UserRepo) *PromptTemplates {
	return &PromptTemplates{
		repo: repo,
	}
}

type PromptTemplates struct {
	repo repository.UserRepo
}

func (u *PromptTemplates) PromptTemplates(ctx context.Context, req *protocol.PromptTemplatesReq) (
	*protocol.PromptTemplatesRsp, error,
) {
	// 查询全部帮助手册
	manuals, err := u.repo.FindAppConfig(ctx, []int32{entity.AppConfigTypePromptTemplate})
	if err != nil {
		return nil, err
	}

	rsp := &protocol.PromptTemplatesRsp{}
	for _, manual := range manuals {
		// desc解析
		desc := ""
		var descMap map[string]string
		if err := json.Unmarshal([]byte(manual.ConfigDesc), &descMap); err != nil {
			log.ErrorContextf(ctx, "unmarshal config_desc err: %+v", err)
		} else {
			if descStr, exists := descMap[req.Lang]; exists {
				desc = descStr
			} else if defaultDesc, exists := descMap["default"]; exists {
				desc = defaultDesc
			}
		}

		m := protocol.PromptTemplate{
			PromptId:   manual.ConfigKey,
			PromptDesc: desc,
		}
		rsp.Data = append(rsp.Data, m)
	}

	return rsp, nil
}
