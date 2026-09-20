package interfaces

import (
	"net/http"

	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/application/service/mediaservice"
	"trpc.group/trpc-go/trpc-go/log"
)

func (i *AiRecordServerServiceImpl) MediaUpload(w http.ResponseWriter, r *http.Request) {
	// 解析请求参数
	req := protocol.MediaUploadReq{
		Req: r,
	}
	log.InfoContextf(r.Context(), "request %s %s body: [MultipartForm]", r.RequestURI, r.Method)

	// 业务处理
	rsp, err := mediaservice.NewMediaUpload(i.depCtx.TransMgr,
		i.GetUserId(r.Context())).MediaUpload(r.Context(), &req)
	if err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 返回消息
	i.SendResponseMsg(w, r, rsp)
}

func (i *AiRecordServerServiceImpl) MediaConvert(w http.ResponseWriter, r *http.Request) {
	// 请求消息解析
	var req protocol.MediaConvertReq
	if err := i.ParseRequestMsg(r, &req); err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 业务处理
	rsp, err := mediaservice.NewMediaConvert(i.depCtx.TransMgr,
		i.GetUserId(r.Context())).MediaConvert(r.Context(), &req)
	if err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 返回消息
	i.SendResponseMsg(w, r, rsp)
}

func (i *AiRecordServerServiceImpl) MediaSync(w http.ResponseWriter, r *http.Request) {
	// 请求消息解析
	var req protocol.MediaSyncReq
	if err := i.ParseRequestMsg(r, &req); err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 业务处理
	rsp, err := mediaservice.NewMediaSync(i.depCtx.TransMgr.GetRepository(),
		i.GetUserId(r.Context())).MediaSync(r.Context(), &req)
	if err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 返回消息
	i.SendResponseMsg(w, r, rsp)
}

func (i *AiRecordServerServiceImpl) MediaUrl(w http.ResponseWriter, r *http.Request) {
	// 请求消息解析
	var req protocol.MediaUrlReq
	if err := i.ParseRequestMsg(r, &req); err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 业务处理
	rsp, err := mediaservice.NewMediaUrl(i.depCtx.TransMgr.GetRepository().MediaRepo(),
		i.GetUserId(r.Context())).MediaUrl(r.Context(), &req)
	if err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 返回消息
	i.SendResponseMsg(w, r, rsp)
}

func (i *AiRecordServerServiceImpl) MediaRemove(w http.ResponseWriter, r *http.Request) {
	// 请求消息解析
	var req protocol.MediaRemoveReq
	if err := i.ParseRequestMsg(r, &req); err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 业务处理
	rsp, err := mediaservice.NewMediaRemove(i.depCtx.TransMgr, i.GetUserId(r.Context())).MediaRemove(r.Context(), &req)
	if err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 返回消息
	i.SendResponseMsg(w, r, rsp)
}

func (i *AiRecordServerServiceImpl) MediaUploadCredential(w http.ResponseWriter, r *http.Request) {
	// 请求消息解析
	var req protocol.MediaUploadCredentialReq
	if err := i.ParseRequestMsg(r, &req); err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 业务处理
	rsp, err := mediaservice.NewMediaUploadCredential(i.depCtx.TransMgr,
		i.GetUserId(r.Context())).MediaUploadCredential(r.Context(), &req)
	if err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 返回消息
	i.SendResponseMsg(w, r, rsp)
}

func (i *AiRecordServerServiceImpl) MediaConvertStatus(w http.ResponseWriter, r *http.Request) {
	// 请求消息解析
	var req protocol.MediaConvertStatusReq
	if err := i.ParseRequestMsg(r, &req); err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 业务处理
	rsp, err := mediaservice.NewMediaConvertStatus(i.depCtx.TransMgr,
		i.GetUserId(r.Context())).MediaConvertStatus(r.Context(),
		&req)
	if err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 返回消息
	i.SendResponseMsg(w, r, rsp)
}

func (i *AiRecordServerServiceImpl) MediaConvertRecords(w http.ResponseWriter, r *http.Request) {
	// 请求消息解析
	var req protocol.MediaConvertRecordsReq
	if err := i.ParseRequestMsg(r, &req); err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 业务处理
	rsp, err := mediaservice.NewMediaConvertRecords(i.depCtx.TransMgr.GetRepository().MediaRepo(),
		i.GetUserId(r.Context())).MediaConvertRecord(r.Context(),
		&req)
	if err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 返回消息
	i.SendResponseMsg(w, r, rsp)
}

func (i *AiRecordServerServiceImpl) MediaUploadAck(w http.ResponseWriter, r *http.Request) {
	// 请求消息解析
	var req protocol.MediaUploadAckReq
	if err := i.ParseRequestMsg(r, &req); err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 业务处理
	rsp, err := mediaservice.NewMediaUploadAck(i.depCtx.TransMgr,
		i.GetUserId(r.Context())).MediaUploadAck(r.Context(),
		&req)
	if err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 返回消息
	i.SendResponseMsg(w, r, rsp)
}

func (i *AiRecordServerServiceImpl) MediaSummary(w http.ResponseWriter, r *http.Request) {
	// 请求消息解析
	var req protocol.MediaSummaryReq
	if err := i.ParseRequestMsg(r, &req); err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 业务处理
	rsp, err := mediaservice.NewMediaSummary(i.depCtx.TransMgr,
		i.GetUserId(r.Context())).MediaSummary(r.Context(),
		&req)
	if err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 返回消息
	i.SendResponseMsg(w, r, rsp)
}

func (i *AiRecordServerServiceImpl) MediaSummaryStatus(w http.ResponseWriter, r *http.Request) {
	// 请求消息解析
	var req protocol.MediaSummaryStatusReq
	if err := i.ParseRequestMsg(r, &req); err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 业务处理
	rsp, err := mediaservice.NewMediaSummaryStatus(i.depCtx.TransMgr.GetRepository().MediaRepo(),
		i.GetUserId(r.Context())).MediaSummaryStatus(r.Context(), &req)
	if err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 返回消息
	i.SendResponseMsg(w, r, rsp)
}

func (i *AiRecordServerServiceImpl) MediaSummaryUpdate(w http.ResponseWriter, r *http.Request) {
	// 请求消息解析
	var req protocol.MediaSummaryUpdateReq
	if err := i.ParseRequestMsg(r, &req); err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 业务处理
	rsp, err := mediaservice.NewMediaSummaryUpdate(i.depCtx.TransMgr,
		i.GetUserId(r.Context())).MediaSummaryUpdate(r.Context(), &req)
	if err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 返回消息
	i.SendResponseMsg(w, r, rsp)
}

func (i *AiRecordServerServiceImpl) MediaConvertUpdate(w http.ResponseWriter, r *http.Request) {
	// 请求消息解析
	var req protocol.MediaConvertUpdateReq
	if err := i.ParseRequestMsg(r, &req); err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 业务处理
	rsp, err := mediaservice.NewMediaConvertUpdate(i.depCtx.TransMgr,
		i.GetUserId(r.Context())).MediaConvertUpdate(r.Context(), &req)
	if err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 返回消息
	i.SendResponseMsg(w, r, rsp)
}

func (i *AiRecordServerServiceImpl) MediaUpdate(w http.ResponseWriter, r *http.Request) {
	// 请求消息解析
	var req protocol.MediaUpdateReq
	if err := i.ParseRequestMsg(r, &req); err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 业务处理
	rsp, err := mediaservice.NewMediaUpdate(i.depCtx.TransMgr, i.GetUserId(r.Context())).MediaUpdate(r.Context(), &req)
	if err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 返回消息
	i.SendResponseMsg(w, r, rsp)
}

func (i *AiRecordServerServiceImpl) MediaConvertReset(w http.ResponseWriter, r *http.Request) {
	// 请求消息解析
	var req protocol.MediaConvertResetReq
	if err := i.ParseRequestMsg(r, &req); err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 业务处理
	rsp, err := mediaservice.NewMediaConvertReset(i.depCtx.TransMgr,
		i.GetUserId(r.Context())).MediaConvertReset(r.Context(), &req)
	if err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 返回消息
	i.SendResponseMsg(w, r, rsp)
}
