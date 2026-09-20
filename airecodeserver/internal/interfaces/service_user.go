package interfaces

import (
	"net/http"

	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/application/service/userservice"
)

func (i *AiRecordServerServiceImpl) UserInfo(w http.ResponseWriter, r *http.Request) {
	// 请求消息解析
	var req protocol.UserInfoReq
	if err := i.ParseRequestMsg(r, &req); err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 业务处理
	rsp, err := userservice.NewUserInfo(i.depCtx.TransMgr.GetRepository(), i.GetUserId(r.Context())).UserInfo(r.Context())
	if err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 返回消息
	i.SendResponseMsg(w, r, rsp)
}

func (i *AiRecordServerServiceImpl) UserPackage(w http.ResponseWriter, r *http.Request) {
	// 请求消息解析
	var req protocol.UserPackageReq
	if err := i.ParseRequestMsg(r, &req); err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 业务处理
	rsp, err := userservice.NewUserPackage(i.depCtx.TransMgr.GetRepository().ServiceRepo(),
		i.GetUserId(r.Context())).UserPackage(r.Context())
	if err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 返回消息
	i.SendResponseMsg(w, r, rsp)
}

func (i *AiRecordServerServiceImpl) UserPackageGive(w http.ResponseWriter, r *http.Request) {
	// 请求消息解析
	var req protocol.UserPackageGiveReq
	if err := i.ParseRequestMsg(r, &req); err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 业务处理
	rsp, err := userservice.NewUserPackageGive(i.depCtx.TransMgr,
		i.GetUserId(r.Context())).UserPackageGive(r.Context(), &req)
	if err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 返回消息
	i.SendResponseMsg(w, r, rsp)
}

func (i *AiRecordServerServiceImpl) UserPackageCostCheck(w http.ResponseWriter, r *http.Request) {
	// 请求消息解析
	var req protocol.UserPackageCostCheckReq
	if err := i.ParseRequestMsg(r, &req); err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 业务处理
	rsp, err := userservice.NewUserPackageCostCheck(i.depCtx.TransMgr.GetRepository().ServiceRepo(),
		i.GetUserId(r.Context())).UserPackageCostCheck(r.Context(), &req)
	if err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 返回消息
	i.SendResponseMsg(w, r, rsp)
}

func (i *AiRecordServerServiceImpl) PackagesAvailable(w http.ResponseWriter, r *http.Request) {
	// 请求消息解析
	var req protocol.PackagesAvailableReq
	if err := i.ParseRequestMsg(r, &req); err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 业务处理
	rsp, err := userservice.NewPackagesAvailable(i.depCtx.TransMgr.GetRepository(),
		i.GetUserId(r.Context())).PackagesAvailable(r.Context(), &req)
	if err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 返回消息
	i.SendResponseMsg(w, r, rsp)
}

func (i *AiRecordServerServiceImpl) CardActivate(w http.ResponseWriter, r *http.Request) {
	// 请求消息解析
	var req protocol.CardActivateReq
	if err := i.ParseRequestMsg(r, &req); err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 业务处理
	rsp, err := userservice.NewCardActivate(i.depCtx.TransMgr,
		i.GetUserId(r.Context())).CardActivate(r.Context(), &req)
	if err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 返回消息
	i.SendResponseMsg(w, r, rsp)
}

func (i *AiRecordServerServiceImpl) CardGenerate(w http.ResponseWriter, r *http.Request) {
	// 请求消息解析
	var req protocol.CardGenerateReq
	if err := i.ParseRequestMsg(r, &req); err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 业务处理
	rsp, err := userservice.NewCardGenerate(i.depCtx.TransMgr.GetRepository(),
		i.GetUserId(r.Context())).CardGenerate(r.Context(), &req)
	if err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 返回消息
	i.SendResponseMsg(w, r, rsp)
}

func (i *AiRecordServerServiceImpl) UserFeedback(w http.ResponseWriter, r *http.Request) {
	// 请求消息解析
	var req protocol.UserFeedbackReq
	if err := i.ParseRequestMsg(r, &req); err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 业务处理
	rsp, err := userservice.NewUserFeedback(i.depCtx.TransMgr,
		i.GetUserId(r.Context())).UserFeedback(r.Context(), &req)
	if err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 返回消息
	i.SendResponseMsg(w, r, rsp)
}

func (i *AiRecordServerServiceImpl) DeleteAccount(w http.ResponseWriter, r *http.Request) {
	// 请求消息解析
	var req protocol.DeleteAccountReq
	if err := i.ParseRequestMsg(r, &req); err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 业务处理
	rsp, err := userservice.NewDeleteAccount(i.depCtx.TransMgr,
		i.GetUserId(r.Context())).DeleteAccount(r.Context())
	if err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 返回消息
	i.SendResponseMsg(w, r, rsp)
}
