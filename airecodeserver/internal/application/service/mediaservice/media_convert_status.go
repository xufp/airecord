package mediaservice

import (
	"context"

	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"trpc.group/trpc-go/trpc-go/errs"
)

func NewMediaConvertStatus(
	transMgr repository.RepoTransMgr, userId int64,
) *MediaConvertStatus {
	return &MediaConvertStatus{
		transMgr: transMgr,
		userId:   userId,
	}
}

type MediaConvertStatus struct {
	transMgr repository.RepoTransMgr
	userId   int64
}

func (m *MediaConvertStatus) MediaConvertStatus(
	ctx context.Context, req *protocol.MediaConvertStatusReq,
) (*protocol.MediaConvertStatusRsp, error) {
	// 查询音频信息&校验
	mediaInfo, err := m.transMgr.GetRepository().MediaRepo().GetMediaInfo(ctx, req.MediaId)
	if err != nil {
		return nil, err
	}

	if mediaInfo.UserId != m.userId {
		return nil, errs.Newf(errorcode.ErrRecordNotExisted, "media not found")
	}

	// 未启用转写，直接返回
	if mediaInfo.State == entity.MediaStateInit || mediaInfo.State == entity.MediaStateUploaded {
		return &protocol.MediaConvertStatusRsp{
			MediaId: mediaInfo.MediaId,
			State:   entity.MediaRecStateNotConvert,
			Memo:    "not convert",
		}, nil
	}

	// 查询识别记录
	mediaRec, err := m.transMgr.GetRepository().MediaRepo().GetMediaRec(ctx, mediaInfo.MediaId)
	if err != nil {
		return nil, err
	}

	// 识别结果段落级别明细反序列化
	sentenceDetail := entity.SentenceDetail{}
	if err := sentenceDetail.Unmarshal(mediaRec.SentenceDetail); err != nil {
		return nil, err
	}

	// 构造返回参数
	rsp := &protocol.MediaConvertStatusRsp{
		MediaId: mediaRec.MediaId,
		State:   mediaRec.State,
		Memo:    mediaRec.Memo,
	}

	// 根据传入参数打包返回结果
	if !req.Detail {
		rsp.Text = mediaRec.Text
	} else {
		for _, v := range sentenceDetail.SentenceList {
			sentence := protocol.Sentence{
				Index:     v.Index,
				StartTime: v.StartTime,
				EndTime:   v.EndTime,
				Text:      v.Text,
				SpeakId:   v.SpeakId,
			}
			rsp.SentenceDetail = append(rsp.SentenceDetail, sentence)
		}
	}

	return rsp, nil
}
