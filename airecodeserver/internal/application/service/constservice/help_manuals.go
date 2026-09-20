package constservice

import (
	"context"

	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"trpc.group/trpc-go/trpc-go/errs"
)

func NewHelpManuals(repo repository.UserRepo) *HelpManuals {
	return &HelpManuals{
		repo: repo,
	}
}

type HelpManuals struct {
	repo repository.UserRepo
}

func (u *HelpManuals) HelpManuals(ctx context.Context, req *protocol.HelpManualsReq) (
	*protocol.HelpManualsRsp, error,
) {
	// 设置默认语言
	lang := "zh"
	if len(req.Lang) != 0 {
		if req.Lang != "zh" && req.Lang != "en" {
			return nil, errs.Newf(errorcode.ErrParamsInvalid, "params out of range lang = %v", req.Lang)
		}
		lang = req.Lang
	}

	// 查询全部帮助手册
	manuals, err := u.repo.FindAppConfig(ctx, []int32{entity.AppConfigTypeHelpManual})
	if err != nil {
		return nil, err
	}

	rsp := &protocol.HelpManualsRsp{}
	for _, manual := range manuals {
		// 按语言筛选
		if manual.ConfigDesc == lang {
			m := protocol.HelpManual{
				Question: manual.ConfigKey,
				Answer:   manual.ConfigValue,
			}
			rsp.Data = append(rsp.Data, m)
		}
	}

	return rsp, nil
}
