package interfaces

import (
	"net/http"

	"github.com/gorilla/mux"
	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/application/service/userservice"
	"github.com/smartox/ai_record_server/internal/domain/entity"
)

func (i *AiRecordServerServiceImpl) AuthThirdLogin(w http.ResponseWriter, r *http.Request) {
	// 请求消息解析
	var req protocol.AuthThirdLoginReq
	if err := i.ParseRequestMsg(r, &req); err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 业务处理
	rsp, err := userservice.NewAuthThirdLogin(i.depCtx.TransMgr.GetRepository().UserRepo()).AuthThirdLogin(r.Context(),
		&req)
	if err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 返回消息
	i.SendResponseMsg(w, r, rsp)
}

func (i *AiRecordServerServiceImpl) AuthGetCode(w http.ResponseWriter, r *http.Request) {
	// 请求消息解析
	var req protocol.AuthGetCodeReq
	if err := i.ParseRequestMsg(r, &req); err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 业务处理
	rsp, err := userservice.NewAuthGetCode(i.depCtx.TransMgr.GetRepository().UserRepo()).AuthGetCode(r.Context(), &req)
	if err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 返回消息
	i.SendResponseMsg(w, r, rsp)
}

func (i *AiRecordServerServiceImpl) AuthVerifyCode(w http.ResponseWriter, r *http.Request) {
	// 请求消息解析
	var req protocol.AuthVerifyCodeReq
	if err := i.ParseRequestMsg(r, &req); err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 业务处理
	rsp, err := userservice.NewAuthVerifyCode(i.depCtx.TransMgr.GetRepository().UserRepo(),
		i.GetUserId(r.Context())).AuthVerifyCode(r.Context(),
		&req)
	if err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 返回消息
	i.SendResponseMsg(w, r, rsp)
}

func (i *AiRecordServerServiceImpl) AuthRegister(w http.ResponseWriter, r *http.Request) {
	// 请求消息解析
	var req protocol.AuthRegisterReq
	if err := i.ParseRequestMsg(r, &req); err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 业务处理
	rsp, err := userservice.NewAuthRegister(i.depCtx.TransMgr.GetRepository().UserRepo()).AuthRegister(r.Context(), &req)
	if err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 返回消息
	i.SendResponseMsg(w, r, rsp)
}

func (i *AiRecordServerServiceImpl) AuthLogin(w http.ResponseWriter, r *http.Request) {
	// 请求消息解析
	var req protocol.AuthLoginReq
	if err := i.ParseRequestMsg(r, &req); err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 业务处理
	rsp, err := userservice.NewAuthLogin(i.depCtx.TransMgr.GetRepository().UserRepo()).AuthLogin(r.Context(), &req)
	if err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 返回消息
	i.SendResponseMsg(w, r, rsp)
}

func (i *AiRecordServerServiceImpl) AuthChangePassword(w http.ResponseWriter, r *http.Request) {
	// 请求消息解析
	var req protocol.AuthChangePasswordReq
	if err := i.ParseRequestMsg(r, &req); err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 业务处理
	rsp, err := userservice.NewAuthChangePassword(i.depCtx.TransMgr.GetRepository().UserRepo(),
		i.GetUserId(r.Context())).AuthChangePassword(r.Context(), &req)
	if err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 返回消息
	i.SendResponseMsg(w, r, rsp)
}

func (i *AiRecordServerServiceImpl) AuthResetPassword(w http.ResponseWriter, r *http.Request) {
	// 请求消息解析
	var req protocol.AuthResetPasswordReq
	if err := i.ParseRequestMsg(r, &req); err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 业务处理
	rsp, err := userservice.NewAuthResetPassword(i.depCtx.TransMgr.GetRepository().UserRepo()).AuthResetPassword(r.Context(),
		&req)
	if err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 返回消息
	i.SendResponseMsg(w, r, rsp)
}

// AuthSmsCodeState for test. todo: delete
func (i *AiRecordServerServiceImpl) AuthSmsCodeState(w http.ResponseWriter, r *http.Request) {
	// 请求消息解析
	vars := mux.Vars(r)
	phone := vars["phone"]

	// 业务处理
	rsp, err := i.depCtx.TransMgr.GetRepository().UserRepo().GetVerifyCode(r.Context(), entity.VerifyCodeSceneLogin,
		phone)
	if err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 返回消息
	i.SendResponseMsg(w, r, rsp)
}
