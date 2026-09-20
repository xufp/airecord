package interfaces

import (
	"net/http"

	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/application/service/otherservice"
	"trpc.group/trpc-go/trpc-go/log"
)

func (i *AiRecordServerServiceImpl) RecordingUpload(w http.ResponseWriter, r *http.Request) {
	// 解析请求参数
	req := protocol.RecordingUploadReq{
		Req: r,
	}
	log.InfoContextf(r.Context(), "request %s %s body: [MultipartForm]", r.RequestURI, r.Method)

	// 业务处理
	rsp, err := otherservice.NewRecordingUpload().RecordingUpload(r.Context(), &req)
	if err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 返回消息
	i.SendResponseMsg(w, r, rsp)
}

// ChatCompletion Gpt聊天接口
func (i *AiRecordServerServiceImpl) ChatCompletion(w http.ResponseWriter, r *http.Request) {
	// 请求消息解析
	var req protocol.ChatCompletionReq
	if err := i.ParseRequestMsg(r, &req); err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 业务处理
	rsp, err := otherservice.NewChatCompletion(i.depCtx.TransMgr.GetRepository().ServiceRepo(),
		i.GetUserId(r.Context())).ChatCompletion(r.Context(), &req)
	if err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 返回消息
	i.SendResponseMsg(w, r, rsp)
}
