package oauth

import "context"

type OAuth interface {
	AccessToken(ctx context.Context, code string) (*AccessTokenResponse, error)
	UserInfo(ctx context.Context, accessToken string, openid string) (*UserInfoResponse, error)
}
