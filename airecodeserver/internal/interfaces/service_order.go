package interfaces

import (
	"fmt"
	"net/http"

	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/application/service/orderservice"
	"github.com/smartox/ai_record_server/internal/infrastructure/config"
	"trpc.group/trpc-go/trpc-go/log"
)

func (i *AiRecordServerServiceImpl) OrderCreate(w http.ResponseWriter, r *http.Request) {
	// 请求消息解析
	var req protocol.OrderCreateReq
	if err := i.ParseRequestMsg(r, &req); err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 业务处理
	rsp, err := orderservice.NewOrderCreate(i.depCtx.TransMgr,
		i.GetUserId(r.Context())).OrderCreate(r.Context(), &req)
	if err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 返回消息
	i.SendResponseMsg(w, r, rsp)
}

func (i *AiRecordServerServiceImpl) OrderDetail(w http.ResponseWriter, r *http.Request) {
	// 请求消息解析
	var req protocol.OrderDetailReq
	if err := i.ParseRequestMsg(r, &req); err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}
	// 业务处理
	rsp, err := orderservice.NewOrderDetail(i.depCtx.TransMgr.GetRepository().ServiceRepo(),
		i.GetUserId(r.Context())).OrderDetail(r.Context(),
		&req)
	if err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}
	// 返回消息
	i.SendResponseMsg(w, r, rsp)
}

func (i *AiRecordServerServiceImpl) OrderList(w http.ResponseWriter, r *http.Request) {
	// 请求消息解析
	var req protocol.OrderListReq
	if err := i.ParseRequestMsg(r, &req); err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 业务处理
	rsp, err := orderservice.NewOrderList(i.depCtx.TransMgr.GetRepository().ServiceRepo(),
		i.GetUserId(r.Context())).OrderList(r.Context(),
		&req)
	if err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}
	// 返回消息
	i.SendResponseMsg(w, r, rsp)
}

func (i *AiRecordServerServiceImpl) PaypalReturn(w http.ResponseWriter, r *http.Request) {
	webBase := config.GetServerConfig().Payment.PayPal.WebBaseUrl

	// 请求消息解析
	var req protocol.PaypalReturnReq
	if err := i.ParseRequestMsg(r, &req); err != nil {
		log.ErrorContextf(r.Context(), "PaypalReturn parse err: %v", err)
		http.Redirect(w, r, fmt.Sprintf("%s/pay/success", webBase), http.StatusFound)
		return
	}

	// 业务处理
	rsp, err := orderservice.NewPaypalReturn(i.depCtx.TransMgr).PaypalReturn(r.Context(), &req)
	if err != nil {
		log.ErrorContextf(r.Context(), "PaypalReturn err: %v", err)
		http.Redirect(w, r, fmt.Sprintf("%s/pay/success", webBase), http.StatusFound)
		return
	}

	// 302 redirect 到前端成功页，带上 order_id
	redirectURL := fmt.Sprintf("%s/pay/success?order_id=%s", webBase, rsp.OrderId)
	http.Redirect(w, r, redirectURL, http.StatusFound)
}

func (i *AiRecordServerServiceImpl) PaypalCancel(w http.ResponseWriter, r *http.Request) {
	webBase := config.GetServerConfig().Payment.PayPal.WebBaseUrl

	// 请求消息解析
	var req protocol.PaypalCancelReq
	if err := i.ParseRequestMsg(r, &req); err != nil {
		log.ErrorContextf(r.Context(), "PaypalCancel parse err: %v", err)
		http.Redirect(w, r, fmt.Sprintf("%s/pay/cancel", webBase), http.StatusFound)
		return
	}

	// 业务处理（更新订单状态）
	_, err := orderservice.NewPaypalCancel(i.depCtx.TransMgr).PaypalCancel(r.Context(), &req)
	if err != nil {
		log.ErrorContextf(r.Context(), "PaypalCancel err: %v", err)
	}

	// 302 redirect 到前端取消页
	http.Redirect(w, r, fmt.Sprintf("%s/pay/cancel", webBase), http.StatusFound)
}

func (i *AiRecordServerServiceImpl) PaypalNotify(w http.ResponseWriter, r *http.Request) {
	// 请求消息解析
	var req protocol.PaypalNotifyReq
	if err := i.ParseRequestMsg(r, &req); err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 业务处理
	rsp, err := orderservice.NewPaypalNotify(i.depCtx.TransMgr).PaypalNotify(r.Context(), &req)
	if err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 返回消息
	i.SendResponseMsg(w, r, rsp)
}

func (i *AiRecordServerServiceImpl) PaypalSubscriptionReturn(w http.ResponseWriter, r *http.Request) {
	webBase := config.GetServerConfig().Payment.PayPal.WebBaseUrl

	// 请求消息解析
	var req protocol.PaypalSubscriptionReturnReq
	if err := i.ParseRequestMsg(r, &req); err != nil {
		log.ErrorContextf(r.Context(), "PaypalSubscriptionReturn parse err: %v", err)
		http.Redirect(w, r, fmt.Sprintf("%s/pay/success", webBase), http.StatusFound)
		return
	}

	// 业务处理
	rsp, err := orderservice.NewPaypalSubscriptionReturn(i.depCtx.TransMgr).PaypalSubscriptionReturn(r.Context(), &req)
	if err != nil {
		log.ErrorContextf(r.Context(), "PaypalSubscriptionReturn err: %v", err)
		http.Redirect(w, r, fmt.Sprintf("%s/pay/success", webBase), http.StatusFound)
		return
	}

	// 302 redirect 到前端成功页
	redirectURL := fmt.Sprintf("%s/pay/success?order_id=%s", webBase, rsp.OrderId)
	http.Redirect(w, r, redirectURL, http.StatusFound)
}

func (i *AiRecordServerServiceImpl) PaypalSubscriptionCancel(w http.ResponseWriter, r *http.Request) {
	webBase := config.GetServerConfig().Payment.PayPal.WebBaseUrl

	// 请求消息解析
	var req protocol.PaypalSubscriptionCancelReq
	if err := i.ParseRequestMsg(r, &req); err != nil {
		log.ErrorContextf(r.Context(), "PaypalSubscriptionCancel parse err: %v", err)
		http.Redirect(w, r, fmt.Sprintf("%s/pay/cancel", webBase), http.StatusFound)
		return
	}

	// 业务处理
	_, err := orderservice.NewPaypalSubscriptionCancel(i.depCtx.TransMgr).PaypalSubscriptionCancel(r.Context(), &req)
	if err != nil {
		log.ErrorContextf(r.Context(), "PaypalSubscriptionCancel err: %v", err)
	}

	// 302 redirect 到前端取消页
	http.Redirect(w, r, fmt.Sprintf("%s/pay/cancel", webBase), http.StatusFound)
}
