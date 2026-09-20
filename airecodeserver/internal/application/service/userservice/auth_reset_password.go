package userservice

import (
	"context"

	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	"github.com/smartox/ai_record_server/internal/domain/service"
	"github.com/smartox/ai_record_server/internal/infrastructure/adapters/smtp"
	"github.com/smartox/ai_record_server/internal/infrastructure/config"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"trpc.group/trpc-go/trpc-go/errs"
)

func NewAuthResetPassword(repo repository.UserRepo) *AuthResetPassword {
	return &AuthResetPassword{
		repo: repo,
	}
}

type AuthResetPassword struct {
	repo repository.UserRepo
}

func (u *AuthResetPassword) AuthResetPassword(
	ctx context.Context, req *protocol.AuthResetPasswordReq,
) (*protocol.AuthResetPasswordRsp, error) {
	if len(req.Code) == 0 && len(req.NewPassword) == 0 {
		// 未传入验证码
		_, err := u.repo.GetUserInfoByEmail(ctx, req.Email)
		if err != nil {
			return nil, err
		}

		// 发送验证码
		if err := u.sendVerifyCode(ctx, req.Email); err != nil {
			return nil, nil
		}
	} else {
		// 密码重置
		if err := service.NewUserAuth(u.repo).ResetPassword(ctx, req.Email, req.Code, req.NewPassword); err != nil {
			return nil, err
		}
	}

	return &protocol.AuthResetPasswordRsp{}, nil
}

func (u *AuthResetPassword) sendVerifyCode(ctx context.Context, email string) error {
	// 生成邮箱验证码
	code, err := service.NewUserAuth(u.repo).GenVerifyCode(ctx, entity.VerifyCodeSceneResetPassword, email,
		config.GetServerConfig().Auth.Email.Expire)
	if err != nil {
		return err
	}

	// 通过邮箱发送验证码
	if err := smtp.NewVerifyCode(config.GetServerConfig().Auth.Email, entity.VerifyCodeSceneResetPassword).SendCode(email,
		code); err != nil {
		return errs.Newf(errorcode.ErrVerifyCodeSendFailed, err.Error())
	}

	return nil
}
