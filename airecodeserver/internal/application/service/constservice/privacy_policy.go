package constservice

import (
	"context"
	"time"

	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"trpc.group/trpc-go/trpc-go/errs"
)

func NewPrivacyPolicy(repo repository.UserRepo) *PrivacyPolicy {
	return &PrivacyPolicy{
		repo: repo,
	}
}

type PrivacyPolicy struct {
	repo repository.UserRepo
}

func (u *PrivacyPolicy) PrivacyPolicy(ctx context.Context, req *protocol.PrivacyPolicyReq) (
	*protocol.PrivacyPolicyRsp, error,
) {
	// 设置默认语言
	lang := "zh"
	if len(req.Lang) != 0 {
		if req.Lang != "zh" && req.Lang != "en" {
			return nil, errs.Newf(errorcode.ErrParamsInvalid, "params out of range lang = %v", req.Lang)
		}
		lang = req.Lang
	}

	// 查询隐私政策
	privacy, err := u.repo.GetAppConfig(ctx, entity.AppConfigTypeAppProtocol, "privacy_policy_"+lang)
	if err != nil {
		return nil, err
	}

	return &protocol.PrivacyPolicyRsp{
		Content:    privacy.ConfigValue,
		UpdateTime: privacy.LastUpdateTime.Format(time.DateTime),
	}, nil
}
