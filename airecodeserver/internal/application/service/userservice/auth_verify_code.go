package userservice

import (
	"context"
	"strings"

	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	"github.com/smartox/ai_record_server/internal/domain/service"
	"github.com/smartox/ai_record_server/internal/infrastructure/config"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"trpc.group/trpc-go/trpc-go/errs"
)

func NewAuthVerifyCode(repo repository.UserRepo, userId int64) *AuthVerifyCode {
	return &AuthVerifyCode{
		repo:   repo,
		userId: userId,
	}
}

type AuthVerifyCode struct {
	repo            repository.UserRepo
	loginMethod     int32
	loginIdentifier string
	userId          int64
	token           string
}

func (u *AuthVerifyCode) AuthVerifyCode(ctx context.Context, req *protocol.AuthVerifyCodeReq) (
	*protocol.AuthVerifyCodeRsp, error,
) {
	// 业务参数检查
	if err := u.checkParams(req); err != nil {
		return nil, err
	}

	// 用户登录验证
	if err := u.verifyUserLogin(ctx, req); err != nil {
		return nil, err
	}

	// 生成token信息
	if err := u.genUserToken(ctx); err != nil {
		return nil, err
	}

	// 打包返回信息
	return &protocol.AuthVerifyCodeRsp{
		State:       entity.UserStateRegisterSuccess,
		AccessToken: u.token,
	}, nil
}

// checkParams 业务参数检查
func (u *AuthVerifyCode) checkParams(req *protocol.AuthVerifyCodeReq) error {
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

func (u *AuthVerifyCode) verifyUserLogin(ctx context.Context, req *protocol.AuthVerifyCodeReq) error {
	// 登录验证
	userInfo, err := service.NewUserAuth(u.repo).VerifyUserLogin(ctx, u.loginMethod, u.loginIdentifier, req.Code)
	if err != nil {
		if u.loginMethod != entity.LoginMethodPhone || errs.Code(err) != errorcode.ErrUserNotFound {
			return err
		}

		// 手机号码登录时，用户不存在，请求参数传入userId，用于绑定手机号码
		if u.userId != 0 {
			// 请求参数传入userId，用于绑定手机号码
			if err := service.NewUserAuth(u.repo).BindUserPhone(ctx, u.userId, u.loginIdentifier); err != nil {
				return err
			}
		} else {
			// 首次注册，创建用户
			userInfoNew, err := service.NewUserAuth(u.repo).CreatePhoneUser(ctx, u.loginIdentifier,
				entity.UserStateRegisterSuccess)
			if err != nil {
				return err
			}

			userInfo = userInfoNew
		}
	}

	u.userId = userInfo.UserId

	return nil
}

// genUserToken 生成用户token
func (u *AuthVerifyCode) genUserToken(ctx context.Context) error {
	// 生成用户token信息
	token, err := service.NewUserAuth(u.repo).GenUserToken(ctx, u.userId, config.GetServerConfig().Auth.Token.Expire)
	if err != nil {
		return err
	}

	u.token = token

	return nil
}
