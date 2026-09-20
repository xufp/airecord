package wechat

import (
	"context"
	"fmt"
	"net/http"

	"github.com/smartox/ai_record_server/internal/application/ports/oauth"
	"github.com/smartox/ai_record_server/internal/infrastructure/config"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"trpc.group/trpc-go/trpc-go/client"
	"trpc.group/trpc-go/trpc-go/codec"
	"trpc.group/trpc-go/trpc-go/errs"
	thttp "trpc.group/trpc-go/trpc-go/http"
	"trpc.group/trpc-go/trpc-go/log"
)

func NewWechatOAuth(cfg config.WechatCfg) oauth.OAuth {
	httpCli := thttp.NewClientProxy("api.weixin.qq.com", client.WithSerializationType(codec.SerializationTypeJSON))
	api := OAuthImpl{
		cfg: cfg,
		Cli: httpCli,
	}
	return &api
}

type OAuthImpl struct {
	cfg config.WechatCfg
	Cli thttp.Client
}

func (i *OAuthImpl) AccessToken(ctx context.Context, code string) (*oauth.AccessTokenResponse, error) {
	reqHeader := &thttp.ClientReqHeader{}

	rspHead := &thttp.ClientRspHeader{}
	rsp := &oauth.AccessTokenResponse{}

	path := fmt.Sprintf("/sns/oauth2/access_token?appid=%s&secret=%s&code=%s&grant_type=authorization_code",
		i.cfg.AppId, i.cfg.AppSecret, code)

	log.InfoContextf(ctx, "req Get uri: %s", path)

	if err := i.Cli.Get(ctx, path, rsp, client.WithReqHead(reqHeader), client.WithRspHead(rspHead)); err != nil {
		return nil, err
	}

	log.InfoContextf(ctx, "rsp: %+v", rspHead.Response)
	log.InfoContextf(ctx, "rsp body: %+v", rsp)

	if rspHead.Response.StatusCode != http.StatusOK || len(rsp.Openid) == 0 {
		return nil, errs.New(errorcode.ErrRemoteCallFail, rspHead.Response.Status)
	}

	return &oauth.AccessTokenResponse{}, nil
}

func (i *OAuthImpl) UserInfo(ctx context.Context, accessToken string, openid string) (
	*oauth.UserInfoResponse, error,
) {
	reqHeader := &thttp.ClientReqHeader{}

	rspHead := &thttp.ClientRspHeader{}
	rsp := &oauth.UserInfoResponse{}

	path := fmt.Sprintf("/sns/oauth2/userinfo?access_token=%s&openid=%s", accessToken, openid)

	log.InfoContextf(ctx, "req Get uri: %s", path)

	if err := i.Cli.Get(ctx, path, rsp, client.WithReqHead(reqHeader), client.WithRspHead(rspHead)); err != nil {
		return nil, err
	}

	log.InfoContextf(ctx, "rsp: %+v", rspHead.Response)
	log.InfoContextf(ctx, "rsp body: %+v", rsp)

	if rspHead.Response.StatusCode != http.StatusOK || len(rsp.Openid) == 0 {
		return nil, errs.New(errorcode.ErrRemoteCallFail, rspHead.Response.Status)
	}

	return rsp, nil
}
