package paypal

import (
	"context"
	"testing"
	"time"

	"github.com/smartox/ai_record_server/internal/application/ports/payment"
	"github.com/smartox/ai_record_server/internal/infrastructure/config"
	"github.com/smartox/ai_record_server/internal/infrastructure/utils"
)

func TestPaymentImpl_CreateOrder(t *testing.T) {
	// 初始化配置
	cfg := config.PayPalCfg{
		ClientId:  "YOUR_PAYPAL_CLIENT_ID",
		Secret:    "YOUR_PAYPAL_SECRET",
		IsSandbox: true,
		ReturnUrl: "https://your-domain.com/v1/order/paypal/return",
		CancelUrl: "https://your-domain.com/v1/order/paypal/cancel",
	}

	paymentId := "9GU424288E6840842"

	// 初始化客户端
	ctx := context.Background()
	cli, err := NewPayment(ctx, cfg)
	if err != nil {
		t.Fatal(err)
	}

	if len(paymentId) == 0 {
		// 创建订单
		order, err := cli.CreateOrder(ctx, &payment.CreateOrderReq{
			OrderId:     utils.GetRandomString(16),
			Amount:      "0.01",
			Currency:    "USD",
			Description: "test order",
		})
		if err != nil {
			t.Fatal(err)
		}
		t.Logf("order: %+v", order)
		paymentId = order.PaymentId
	}

	if err := cli.CaptureOrder(ctx, paymentId); err != nil {
		t.Fatal(err)
	}

	// 获取订单
	for i := 0; i < 10; i++ {
		order, err := cli.GetOrder(ctx, paymentId)
		if err != nil {
			t.Fatal(err)
		}
		t.Logf("order: %+v", order)

		time.Sleep(6 * time.Second)
	}

}
