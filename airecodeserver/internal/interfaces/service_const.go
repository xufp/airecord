package interfaces

import (
	"net/http"

	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/application/service/constservice"
)

func (i *AiRecordServerServiceImpl) AppVersion(w http.ResponseWriter, r *http.Request) {
	// 请求消息解析
	var req protocol.AppVersionReq
	if err := i.ParseRequestMsg(r, &req); err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 业务处理
	rsp, err := constservice.NewAppVersion(i.depCtx.TransMgr).AppVersion(r.Context(), &req)
	if err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 返回消息
	i.SendResponseMsg(w, r, rsp)
}

func (i *AiRecordServerServiceImpl) UserAgreement(w http.ResponseWriter, r *http.Request) {
	// 请求消息解析
	var req protocol.UserAgreementReq
	if err := i.ParseRequestMsg(r, &req); err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 业务处理
	rsp, err := constservice.NewUserAgreement(i.depCtx.TransMgr.GetRepository().UserRepo()).UserAgreement(r.Context(),
		&req)
	if err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 返回消息
	i.SendResponseMsg(w, r, rsp)
}

func (i *AiRecordServerServiceImpl) PrivacyPolicy(w http.ResponseWriter, r *http.Request) {
	// 请求消息解析
	var req protocol.PrivacyPolicyReq
	if err := i.ParseRequestMsg(r, &req); err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 业务处理
	rsp, err := constservice.NewPrivacyPolicy(i.depCtx.TransMgr.GetRepository().UserRepo()).PrivacyPolicy(r.Context(),
		&req)
	if err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 返回消息
	i.SendResponseMsg(w, r, rsp)
}

func (i *AiRecordServerServiceImpl) HelpManuals(w http.ResponseWriter, r *http.Request) {
	// 请求消息解析
	var req protocol.HelpManualsReq
	if err := i.ParseRequestMsg(r, &req); err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 业务处理
	rsp, err := constservice.NewHelpManuals(i.depCtx.TransMgr.GetRepository().UserRepo()).HelpManuals(r.Context(), &req)
	if err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 返回消息
	i.SendResponseMsg(w, r, rsp)
}

func (i *AiRecordServerServiceImpl) PromptTemplates(w http.ResponseWriter, r *http.Request) {
	// 请求消息解析
	var req protocol.PromptTemplatesReq
	if err := i.ParseRequestMsg(r, &req); err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 业务处理
	rsp, err := constservice.NewPromptTemplates(i.depCtx.TransMgr.GetRepository().UserRepo()).PromptTemplates(r.Context(),
		&req)
	if err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 返回消息
	i.SendResponseMsg(w, r, rsp)
}

func (i *AiRecordServerServiceImpl) AsrEngineModels(w http.ResponseWriter, r *http.Request) {
	// 请求消息解析
	var req protocol.AsrEngineModelsReq
	if err := i.ParseRequestMsg(r, &req); err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 业务处理
	rsp, err := constservice.NewAsrEngineModels(i.depCtx.TransMgr.GetRepository().UserRepo()).AsrEngineModels(r.Context(),
		&req)
	if err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 返回消息
	i.SendResponseMsg(w, r, rsp)
}

func (i *AiRecordServerServiceImpl) BleDeviceList(w http.ResponseWriter, r *http.Request) {
	// 请求消息解析
	var req protocol.BleDeviceListReq
	if err := i.ParseRequestMsg(r, &req); err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 业务处理
	rsp, err := constservice.NewBleDeviceList(i.depCtx.TransMgr.GetRepository().UserRepo()).BleDeviceList(r.Context(),
		&req)
	if err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 返回消息
	i.SendResponseMsg(w, r, rsp)
}
