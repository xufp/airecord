package service

import (
	"context"

	"github.com/smartox/ai_record_server/internal/admin/protocol"
	appprotocol "github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/application/service/userservice"
	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"trpc.group/trpc-go/trpc-go/errs"
)

type AuthLogin struct {
	repo repository.AiRecordRepo
}

func NewAuthLogin(repo repository.AiRecordRepo) *AuthLogin {
	return &AuthLogin{
		repo: repo,
	}
}

func (u *AuthLogin) AuthLogin(ctx context.Context, req *protocol.LoginRequest) (*protocol.LoginResponse, error) {
	// 登录验证
	rsp, err := userservice.NewAuthLogin(u.repo.UserRepo()).AuthLogin(ctx, &appprotocol.AuthLoginReq{
		Email:    req.Email,
		Password: req.Password,
		Register: false,
	})
	if err != nil {
		return nil, err
	}

	// 获取token信息
	userToken, err := u.repo.UserRepo().GetUserToken(ctx, rsp.AccessToken)
	if err != nil {
		return nil, err
	}

	// 查询管理员权限
	if _, err := u.repo.ServiceRepo().GetMembership(ctx, userToken.UserId, entity.MembershipLevelAdmin); err != nil {
		return nil, errs.Newf(errorcode.ErrUserAuthInvalid, "user auth invalid.")
	}

	// 登录成功，返回token
	return &protocol.LoginResponse{
		Msg:         "登录成功",
		AccessToken: rsp.AccessToken,
	}, nil
}
