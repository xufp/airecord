package userservice

import (
	"context"
	"strings"

	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	"github.com/smartox/ai_record_server/internal/domain/service"
	"github.com/smartox/ai_record_server/internal/infrastructure/adapters/sms"
	"github.com/smartox/ai_record_server/internal/infrastructure/adapters/smtp"
	"github.com/smartox/ai_record_server/internal/infrastructure/config"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"trpc.group/trpc-go/trpc-go/errs"
)

func NewAuthGetCode(repo repository.UserRepo) *AuthGetCode {
	return &AuthGetCode{
		repo: repo,
	}
}

type AuthGetCode struct {
	repo            repository.UserRepo
	loginMethod     int32
	loginIdentifier string
}

func (u *AuthGetCode) AuthGetCode(ctx context.Context, req *protocol.AuthGetCodeReq) (*protocol.AuthGetCodeRsp, error) {
	// 业务参数检查
	if err := u.checkParams(ctx, req); err != nil {
		return nil, err
	}

	// 验证码投递
	if err := u.sendVerifyCode(ctx); err != nil {
		return nil, err
	}

	return &protocol.AuthGetCodeRsp{}, nil
}

func (u *AuthGetCode) checkParams(ctx context.Context, req *protocol.AuthGetCodeReq) error {
	if strings.TrimSpace(req.Phone) == "" && strings.TrimSpace(req.Email) == "" {
		return errs.Newf(errorcode.ErrParamsInvalid, "either phone or email must be provided")
	}

	if strings.TrimSpace(req.Phone) != "" && strings.TrimSpace(req.Email) != "" {
		return errs.Newf(errorcode.ErrParamsInvalid, "only one of phone or email can be provided")
	}

	if strings.TrimSpace(req.Phone) != "" {
		u.loginMethod = entity.LoginMethodPhone
		u.loginIdentifier = req.Phone
	} else if strings.TrimSpace(req.Email) != "" {
		u.loginMethod = entity.LoginMethodEmail
		u.loginIdentifier = req.Email
	}

	return nil
}

func (u *AuthGetCode) sendVerifyCode(ctx context.Context) error {
	switch u.loginMethod {
	case entity.LoginMethodPhone:
		if err := u.sendSmsCode(ctx, u.loginIdentifier); err != nil {
			return err
		}
	case entity.LoginMethodEmail:
		if err := u.sendEmailCode(ctx, u.loginIdentifier); err != nil {
			return err
		}
	}

	return nil
}

// sendSmsCode 短信验证码投递
func (u *AuthGetCode) sendSmsCode(ctx context.Context, phone string) error {
	if !config.GetServerConfig().Auth.SmsCode.Enable {
		return errs.Newf(errorcode.ErrServiceNotSupport, "not support sms code login.")
	}

	// 生成验证码
	code, err := service.NewUserAuth(u.repo).GenVerifyCode(ctx, entity.VerifyCodeSceneLogin, phone,
		config.GetServerConfig().Auth.SmsCode.Expire)
	if err != nil {
		return err
	}

	// 发送验证码
	// phone number adds +86
	if !strings.HasPrefix(phone, "+86") {
		phone = "+86" + phone
	}

	// 判断是否启用sms短信推送(测试时不启用)
	if !config.GetServerConfig().Auth.SmsCode.IsTest {
		return nil
	}

	// 腾讯云sms平台发送短信验证码
	if err := sms.NewVerifyCode(config.GetServerConfig().Auth.SmsCode).SendCode(phone, code); err != nil {
		return errs.Newf(errorcode.ErrVerifyCodeSendFailed, err.Error())
	}

	return nil
}

// sendEmailCode 邮箱验证码投递
func (u *AuthGetCode) sendEmailCode(ctx context.Context, email string) error {
	if !config.GetServerConfig().Auth.Email.Enable {
		return errs.Newf(errorcode.ErrServiceNotSupport, "not support email login.")
	}

	// 生成邮箱验证码
	code, err := service.NewUserAuth(u.repo).GenVerifyCode(ctx, entity.VerifyCodeSceneLogin, email,
		config.GetServerConfig().Auth.SmsCode.Expire)
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
