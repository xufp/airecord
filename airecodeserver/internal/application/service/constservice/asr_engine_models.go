package constservice

import (
	"context"
	"encoding/json"

	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	"trpc.group/trpc-go/trpc-go/log"
)

func NewAsrEngineModels(repo repository.UserRepo) *AsrEngineModels {
	return &AsrEngineModels{
		repo: repo,
	}
}

type AsrEngineModels struct {
	repo repository.UserRepo
}

func (u *AsrEngineModels) AsrEngineModels(ctx context.Context, req *protocol.AsrEngineModelsReq) (
	*protocol.AsrEngineModelsRsp, error,
) {
	// 查询全部帮助手册
	manuals, err := u.repo.FindAppConfig(ctx, []int32{entity.AppConfigTypeAsrEngineModel})
	if err != nil {
		return nil, err
	}

	rsp := &protocol.AsrEngineModelsRsp{}
	for _, manual := range manuals {
		// 解析desc
		desc := manual.ConfigDesc
		var descMap map[string]string
		if err := json.Unmarshal([]byte(manual.ConfigValue), &descMap); err != nil {
			log.ErrorContextf(ctx, "unmarshal config_value err: %+v", err)
		} else if descStr, exists := descMap[req.Lang]; exists {
			desc = descStr
		}

		m := protocol.EngineModel{
			EngineType: manual.ConfigKey,
			EngineDesc: desc,
		}
		rsp.Data = append(rsp.Data, m)
	}

	return rsp, nil
}
