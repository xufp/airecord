package paypal

import (
	"context"
	"fmt"
	"net/http"
	"time"

	vpaypal "github.com/plutov/paypal/v4"
	"github.com/smartox/ai_record_server/internal/infrastructure/config"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"trpc.group/trpc-go/trpc-go/errs"
	"trpc.group/trpc-go/trpc-go/log"
)

// BaseClient 基础客户端
type BaseClient struct {
	cfg    config.PayPalCfg
	client *vpaypal.Client
}

func NewBaseClient(ctx context.Context, cfg config.PayPalCfg) (*BaseClient, error) {
	baseAPI := vpaypal.APIBaseLive
	if cfg.IsSandbox {
		baseAPI = vpaypal.APIBaseSandBox
	}

	client, err := vpaypal.NewClient(cfg.ClientId, cfg.Secret, baseAPI)
	if err != nil {
		return nil, fmt.Errorf("PayPal初始化失败: %w", err)
	}

	client.SetHTTPClient(&http.Client{
		Timeout: 5 * time.Second,
	})

	token, err := client.GetAccessToken(ctx)
	if err != nil {
		return nil, errs.Newf(errorcode.ErrOrderPaypalInitFailed, "get paypal access token failed. err: %s", err.Error())
	}

	log.DebugContextf(ctx, "PayPal client initialized successfully, token: %s", token.Token)

	return &BaseClient{
		cfg:    cfg,
		client: client,
	}, nil
}
