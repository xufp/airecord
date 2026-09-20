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

func NewUserAgreement(repo repository.UserRepo) *UserAgreement {
	return &UserAgreement{
		repo: repo,
	}
}

type UserAgreement struct {
	repo repository.UserRepo
}

func (u *UserAgreement) UserAgreement(ctx context.Context, req *protocol.UserAgreementReq) (
	*protocol.UserAgreementRsp, error,
) {
	// 设置默认语言
	lang := "zh"
	if len(req.Lang) != 0 {
		if req.Lang != "zh" && req.Lang != "en" {
			return nil, errs.Newf(errorcode.ErrParamsInvalid, "params out of range lang = %v", req.Lang)
		}
		lang = req.Lang
	}

	// 查询用户协议
	agreement, err := u.repo.GetAppConfig(ctx, entity.AppConfigTypeAppProtocol, "user_agreement_"+lang)
	if err != nil {
		return nil, err
	}

	return &protocol.UserAgreementRsp{
		Content:    agreement.ConfigValue,
		UpdateTime: agreement.LastUpdateTime.Format(time.DateTime),
	}, nil
}
