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
	"github.com/smartox/ai_record_server/internal/infrastructure/utils"
	"trpc.group/trpc-go/trpc-go/errs"
)

func NewAuthLogin(repo repository.UserRepo) *AuthLogin {
	return &AuthLogin{
		repo: repo,
	}
}

type AuthLogin struct {
	repo     repository.UserRepo
	userInfo *entity.UserInfo
	token    string
}

func (u *AuthLogin) AuthLogin(ctx context.Context, req *protocol.AuthLoginReq) (*protocol.AuthLoginRsp, error) {
	if !config.GetServerConfig().Auth.Email.Enable {
		return nil, errs.Newf(errorcode.ErrServiceNotSupport, "not support email login.")
	}

	// loginCheck
	if err := u.loginCheck(ctx, req); err != nil {
		return nil, err
	}

	// 生成token
	if err := u.genUserToken(ctx); err != nil {
		return nil, err
	}

	return &protocol.AuthLoginRsp{
		State:       u.userInfo.State,
		AccessToken: u.token,
	}, nil
}

func (u *AuthLogin) loginCheck(ctx context.Context, req *protocol.AuthLoginReq) error {
	// 查询用户
	userInfo, err := u.repo.GetUserInfoByEmail(ctx, req.Email)
	if err != nil {
		// 查询用户不存在,判断是否需要注册
		if errs.Code(err) == errorcode.ErrUserNotFound && req.Register {
			return u.userRegister(ctx, req)
		}

		return err
	}

	u.userInfo = userInfo

	// 登录密码验证
	if u.userInfo.Password != utils.GenerateSha256(req.Password) {
		return errs.Newf(errorcode.ErrInvalidPassword, "Login failed, incorrect password.")
	}

	// 已注销用户，不支持登录
	if userInfo.State == entity.UserStateDeactivated {
		return errs.Newf(errorcode.ErrUserDeactivated, "Login failed, the user has been deactivated.")
	} else if userInfo.State == entity.UserStateWaitVerifyCode {
		// 未验证，重新发送验证码
		if err := u.sendVerifyCode(ctx, req.Email); err != nil {
			return err
		}
	}

	return nil
}

func (u *AuthLogin) userRegister(ctx context.Context, req *protocol.AuthLoginReq) error {
	// 首次注册，插入默认商户信息
	userInfoNew, err := service.NewUserAuth(u.repo).CreateEmailUser(ctx, req.Email, req.Password,
		entity.UserStateWaitVerifyCode)
	if err != nil {
		return err
	}

	u.userInfo = userInfoNew

	// 发送验证码
	if err := u.sendVerifyCode(ctx, req.Email); err != nil {
		return err
	}

	return nil
}

func (u *AuthLogin) sendVerifyCode(ctx context.Context, email string) error {
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

// genUserToken 生成用户token
func (u *AuthLogin) genUserToken(ctx context.Context) error {
	// 未注册成功，不返回token
	if u.userInfo.State == entity.UserStateWaitVerifyCode {
		return nil
	}

	// 设置token过期时间
	expireTime := config.GetServerConfig().Auth.Token.Expire
	// if u.userInfo.State == entity.UserStateWaitVerifyCode {
	// 	// 未注册成功，返回临时token
	// 	expireTime = config.GetServerConfig().Auth.Token.TempExpire
	// }

	// 生成用户token信息
	token, err := service.NewUserAuth(u.repo).GenUserToken(ctx, u.userInfo.UserId, expireTime)
	if err != nil {
		return err
	}

	u.token = token

	return nil
}
