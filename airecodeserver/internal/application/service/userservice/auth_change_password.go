package userservice

import (
	"context"

	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	"github.com/smartox/ai_record_server/internal/domain/service"
)

func NewAuthChangePassword(repo repository.UserRepo, userId int64) *AuthChangePassword {
	return &AuthChangePassword{
		repo:   repo,
		userId: userId,
	}
}

type AuthChangePassword struct {
	repo   repository.UserRepo
	userId int64
}

func (u *AuthChangePassword) AuthChangePassword(ctx context.Context, req *protocol.AuthChangePasswordReq) (
	*protocol.AuthChangePasswordRsp, error,
) {
	// 用户信息查询
	if err := service.NewUserAuth(u.repo).ChangePassword(ctx, u.userId, req.CurrentPassword,
		req.NewPassword); err != nil {
		return nil, err
	}

	// 打包返回信息
	return &protocol.AuthChangePasswordRsp{}, nil
}
