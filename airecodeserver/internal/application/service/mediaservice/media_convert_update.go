package mediaservice

import (
	"context"

	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	domainservice "github.com/smartox/ai_record_server/internal/domain/service"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"trpc.group/trpc-go/trpc-go/errs"
)

func NewMediaConvertUpdate(
	transMgr repository.RepoTransMgr, userId int64,
) *MediaConvertUpdate {
	return &MediaConvertUpdate{
		transMgr: transMgr,
		userId:   userId,
	}
}

type MediaConvertUpdate struct {
	transMgr repository.RepoTransMgr
	userId   int64
	mediaRec *entity.MediaRec
}

func (m *MediaConvertUpdate) MediaConvertUpdate(
	ctx context.Context, req *protocol.MediaConvertUpdateReq,
) (*protocol.MediaConvertUpdateRsp, error) {
	if err := m.checkParams(ctx, req); err != nil {
		return nil, err
	}

	if err := m.updateDetail(ctx, req); err != nil {
		return nil, err
	}

	return &protocol.MediaConvertUpdateRsp{}, nil
}

func (m *MediaConvertUpdate) checkParams(ctx context.Context, req *protocol.MediaConvertUpdateReq) error {
	// 查询音频信息&校验
	mediaInfo, err := m.transMgr.GetRepository().MediaRepo().GetMediaInfo(ctx, req.MediaId)
	if err != nil {
		return err
	}

	if mediaInfo.UserId != m.userId {
		return errs.Newf(errorcode.ErrRecordNotExisted, "media not found")
	}

	// 查询识别记录
	mediaRec, err := m.transMgr.GetRepository().MediaRepo().GetMediaRec(ctx, mediaInfo.MediaId)
	if err != nil {
		return err
	}
	m.mediaRec = mediaRec

	return nil
}

func (m *MediaConvertUpdate) updateDetail(
	ctx context.Context, req *protocol.MediaConvertUpdateReq,
) error {
	// 生成转写明细
	switch req.Mode {
	case protocol.MediaConvertUpdateModeAll:
		sentenceDetail := entity.SentenceDetail{}
		for _, v := range req.SentenceDetail {
			sentence := entity.Sentence{
				Index:     v.Index,
				StartTime: v.StartTime,
				EndTime:   v.EndTime,
				Text:      v.Text,
				SpeakId:   v.SpeakId,
			}

			sentenceDetail.SentenceList = append(sentenceDetail.SentenceList, sentence)
		}

		m.mediaRec.SentenceDetail = sentenceDetail.Marshal()
	case protocol.MediaConvertUpdateModePart:
		// 修改片段map
		updateSentenceMap := make(map[int32]protocol.Sentence)
		for idx := range req.SentenceDetail {
			updateSentenceMap[req.SentenceDetail[idx].Index] = req.SentenceDetail[idx]
		}

		// 识别结果段落级别明细反序列化
		sentenceDetail := entity.SentenceDetail{}
		if err := sentenceDetail.Unmarshal(m.mediaRec.SentenceDetail); err != nil {
			return err
		}

		// 更新
		for _, v := range sentenceDetail.SentenceList {
			if newSentence, existed := updateSentenceMap[v.Index]; existed {
				sentenceDetail.SentenceList[v.Index].Text = newSentence.Text
			}
		}

		m.mediaRec.SentenceDetail = sentenceDetail.Marshal()
	default:
		return errs.Newf(errorcode.ErrParamsInvalid, "param mode out of range [1,2]")
	}

	// 更新转写明细
	if err := m.transMgr.DoTransaction(ctx, func(ctx context.Context, repo repository.AiRecordRepo) error {
		// 锁用户记录
		if _, err := repo.UserRepo().LockUserInfo(ctx, m.userId); err != nil {
			return err
		}

		// 更新转写记录
		if err := domainservice.NewUserMedia(repo.MediaRepo(), m.userId).UpdateMediaRec(ctx, m.mediaRec); err != nil {
			return err
		}

		return nil
	}); err != nil {
		return err
	}

	return nil
}
