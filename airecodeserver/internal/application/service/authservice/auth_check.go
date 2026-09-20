package authservice

import (
	"context"
	"net/http"
	"strings"

	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"github.com/smartox/ai_record_server/internal/infrastructure/utils"
	"trpc.group/trpc-go/trpc-go/errs"
	"trpc.group/trpc-go/trpc-go/log"
)

func NewAuthCheck(transMgr repository.RepoTransMgr) *AuthCheck {
	return &AuthCheck{
		transMgr: transMgr,
	}
}

type AuthCheck struct {
	transMgr repository.RepoTransMgr
}

func (a *AuthCheck) Authorization(ctx context.Context, r *http.Request, force bool) (int64, error) {
	log.DebugContextf(r.Context(), "%s %s header: %+v", r.RequestURI, r.Method, r.Header)
	// 非强校验时，请求参数未传则不校验
	if !force {
		return 0, nil
	}

	// 解析http头
	authHeader := r.Header.Get("Authorization")
	if len(authHeader) == 0 {
		return 0, errs.Newf(errorcode.ErrParamsInvalid, "Authorization header missing")
	}

	// 检查 Authorization 头格式
	parts := strings.Split(authHeader, " ")
	if len(parts) != 2 || (parts[0] != "Bearer" && parts[0] != "token") {
		return 0, errs.Newf(errorcode.ErrParamsInvalid, "Invalid Authorization header format")
	}

	// 提取token值
	token := parts[1]

	log.WithContextFields(ctx, "TOKEN", utils.GenerateMD5Hash(token))

	// 验证token是否有效
	userToken, err := a.transMgr.GetRepository().UserRepo().GetUserToken(ctx, token)
	if err != nil {
		return 0, err
	}

	if force {
		// 用户状态校验
		userInfo, err := a.transMgr.GetRepository().UserRepo().GetUserInfoByUserId(ctx, userToken.UserId)
		if err != nil || userInfo.State != entity.UserStateRegisterSuccess {
			return 0, errs.Newf(errorcode.ErrUserAuthInvalid, "user auth invalid.")
		}
	}

	return userToken.UserId, nil
}
