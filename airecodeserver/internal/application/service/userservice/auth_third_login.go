package userservice

import (
	"context"
	"time"

	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	"github.com/smartox/ai_record_server/internal/infrastructure/adapters/wechat"
	"github.com/smartox/ai_record_server/internal/infrastructure/config"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"github.com/smartox/ai_record_server/internal/infrastructure/utils"
	"trpc.group/trpc-go/trpc-go/errs"
)

func NewAuthThirdLogin(repo repository.UserRepo) *AuthThirdLogin {
	return &AuthThirdLogin{
		repo: repo,
	}
}

type AuthThirdLogin struct {
	repo repository.UserRepo
}

func (u *AuthThirdLogin) AuthThirdLogin(ctx context.Context, req *protocol.AuthThirdLoginReq) (
	*protocol.AuthThirdLoginRsp, error,
) {
	// 获取access_token
	wechatOAuth := wechat.NewWechatOAuth(config.GetServerConfig().Auth.ThirdOAuth.Wechat)
	oAuthToken, err := wechatOAuth.AccessToken(ctx, req.Code)
	if err != nil {
		return nil, err
	}

	userInfo := &entity.UserInfo{}
	// 查询是否已存在用户
	thirdAuth, err := u.repo.GetThirdAuth(ctx, req.Channel, oAuthToken.Openid)
	if err != nil {
		if errs.Code(err) != errorcode.ErrRecordNotExisted {
			return nil, err
		}
		// 不存在授权记录，新增用户信息
		if len(oAuthToken.UnionId) != 0 {
			oAuthUserInfo, err := wechatOAuth.UserInfo(ctx, oAuthToken.AccessToken, oAuthToken.Openid)
			if err != nil {
				return nil, err
			}
			userInfo.NickName = oAuthUserInfo.NickName
			userInfo.Sex = oAuthUserInfo.Sex
			userInfo.Province = oAuthUserInfo.Province
			userInfo.City = oAuthUserInfo.City
			userInfo.Country = oAuthUserInfo.Country
			userInfo.HeadImgUrl = oAuthUserInfo.HeadImgUrl
		} else {
			userInfo.NickName = "user_" + utils.GenerateMD5Hash(oAuthToken.Openid)
		}
		userInfo.State = entity.UserStateWaitVerifyCode

		if err := u.repo.SaveUserInfo(ctx, userInfo); err != nil {
			return nil, err
		}

		// 更新第三方登录信息
		thirdAuth := &entity.ThirdAuth{
			Channel:     req.Channel,
			UserId:      userInfo.UserId,
			UnionId:     oAuthToken.UnionId,
			Openid:      oAuthToken.Openid,
			AccessToken: oAuthToken.AccessToken,
		}
		if err := u.repo.SaveThirdAuth(ctx, thirdAuth); err != nil {
			return nil, err
		}
	} else {
		// 已存在授权，查询用户信息
		userInfo, err = u.repo.GetUserInfoByUserId(ctx, thirdAuth.UserId)
		if err != nil {
			return nil, err
		}

		// 已注销用户，不支持登录
		if userInfo.State == entity.UserStateDeactivated {
			return nil, errs.Newf(errorcode.ErrUserDeactivated, "Login failed, the user has been deactivated.")
		}
	}

	// 生成用户token信息
	userToken := &entity.UserToken{
		UserId: userInfo.UserId,
		Token:  utils.GenerateUUID(),
	}

	if userInfo.State != entity.UserStateRegisterSuccess {
		userToken.ExpireTime = time.Now().Add(time.Duration(config.GetServerConfig().Auth.Token.TempExpire) * time.Second)
	} else {
		userToken.ExpireTime = time.Now().Add(time.Duration(config.GetServerConfig().Auth.Token.Expire) * time.Second)
	}

	if err := u.repo.SaveUserToken(ctx, userToken); err != nil {
		return nil, err
	}

	// 打包返回信息
	rsp := &protocol.AuthThirdLoginRsp{
		AccessToken: userToken.Token,
		State:       userInfo.State,
	}

	return rsp, nil
}
