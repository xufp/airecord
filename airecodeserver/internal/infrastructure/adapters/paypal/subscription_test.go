package paypal

import (
	"context"
	"testing"
	"time"

	"github.com/smartox/ai_record_server/internal/application/ports/payment"
	"github.com/smartox/ai_record_server/internal/infrastructure/config"
	"github.com/smartox/ai_record_server/internal/infrastructure/utils"
)

func TestSubscriptionImpl_CreateSubscription(t *testing.T) {
	// 初始化配置
	cfg := config.PayPalCfg{
		ClientId:  "YOUR_PAYPAL_CLIENT_ID",
		Secret:    "YOUR_PAYPAL_SECRET",
		IsSandbox: true,
		ReturnUrl: "https://your-domain.com/v1/order/paypal/return",
		CancelUrl: "https://your-domain.com/v1/order/paypal/cancel",
	}

	planId := "P-4GE24089WF502915NM66JKQQ"
	subscriptionId := "I-8JXM4AT55SFP"
	// subscriptionId := "BA-6MC0171449844181A"

	// 初始化客户端
	ctx := context.Background()
	cli, err := NewSubscription(ctx, cfg)
	if err != nil {
		t.Fatal(err)
	}

	if len(planId) == 0 {
		// 创建产品
		product, err := cli.CreateProduct(ctx, &payment.CreateProductReq{
			ProductName: "ai_record_service_month",
			Description: "ai record service month subscription",
		})
		if err != nil {
			t.Fatal(err)
		}
		t.Logf("product: %+v", product)

		// 创建计划
		plan, err := cli.CreatePlan(ctx, &payment.CreatePlanReq{
			ProductId:   product.ProductId,
			PlanName:    "month plan 01",
			Description: "ai record service month plan",
			Amount:      "0.01",
			Currency:    "USD",
			Interval:    5,
		})

		if err != nil {
			t.Fatal(err)
		}
		t.Logf("plan: %+v", plan)

		planId = plan.PlanId
	}

	// 创建订阅
	if len(subscriptionId) == 0 {
		sub, err := cli.CreateSubscription(ctx, &payment.CreateSubscriptionReq{
			PlanId:   planId,
			CustomId: utils.GetRandomString(16),
		})
		if err != nil {
			t.Fatal(err)
		}
		t.Logf("subscription: %+v", sub)

		subscriptionId = sub.SubscriptionId
	}

	// 查询订阅
	for i := 0; i < 10; i++ {
		subDetail, err := cli.GetSubscription(ctx, subscriptionId)
		if err != nil {
			t.Fatal(err)
		}
		t.Logf("subscription detail: %+v", subDetail)

		// if subDetail.Status == "APPROVED" || subDetail.Status == "ACTIVE" {
		// 	break
		// }

		time.Sleep(6 * time.Second)
	}
}
