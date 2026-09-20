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

func NewAuthRegister(repo repository.UserRepo) *AuthRegister {
	return &AuthRegister{
		repo: repo,
	}
}

type AuthRegister struct {
	repo     repository.UserRepo
	userInfo *entity.UserInfo
}

func (u *AuthRegister) AuthRegister(ctx context.Context, req *protocol.AuthRegisterReq) (
	*protocol.AuthRegisterRsp, error,
) {
	if !config.GetServerConfig().Auth.Email.Enable {
		return nil, errs.Newf(errorcode.ErrServiceNotSupport, "not support email login.")
	}

	// registerCheck
	if err := u.registerCheck(ctx, req); err != nil {
		return nil, err
	}

	// 执行注册
	if err := u.userRegister(ctx, req); err != nil {
		return nil, err
	}

	// 发送验证码
	if err := u.sendVerifyCode(ctx, req.Email); err != nil {
		return nil, err
	}

	return &protocol.AuthRegisterRsp{
		State: u.userInfo.State,
	}, nil
}

func (u *AuthRegister) registerCheck(ctx context.Context, req *protocol.AuthRegisterReq) error {
	// 查询用户
	_, err := u.repo.GetUserInfoByEmail(ctx, req.Email)
	if err != nil {
		// 查询用户不存在,返回成功，其他返回错误
		if errs.Code(err) == errorcode.ErrUserNotFound {
			return nil
		}

		return err
	}

	return errs.Newf(errorcode.ErrUserIsExisted, "register failed. user is existed.")
}

func (u *AuthRegister) userRegister(ctx context.Context, req *protocol.AuthRegisterReq) error {
	// 首次注册，插入默认商户信息
	userInfoNew, err := service.NewUserAuth(u.repo).CreateEmailUser(ctx, req.Email, req.Password,
		entity.UserStateWaitVerifyCode)
	if err != nil {
		return err
	}

	u.userInfo = userInfoNew

	return nil
}

func (u *AuthRegister) sendVerifyCode(ctx context.Context, email string) error {
	// 生成邮箱验证码
	code, err := service.NewUserAuth(u.repo).GenVerifyCode(ctx, entity.VerifyCodeSceneLogin, email,
		config.GetServerConfig().Auth.Email.Expire)
	if err != nil {
		return err
	}

	// 通过邮箱发送验证码
	if err := smtp.NewVerifyCode(config.GetServerConfig().Auth.Email, entity.VerifyCodeSceneLogin).SendCode(email,
		code); err != nil {
		return errs.Newf(errorcode.ErrVerifyCodeSendFailed, err.Error())
	}

	return nil
}
