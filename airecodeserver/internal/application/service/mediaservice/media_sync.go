package mediaservice

import (
	"context"

	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"trpc.group/trpc-go/trpc-go/errs"
)

func NewMediaSync(repo repository.AiRecordRepo, userId int64) *MediaSync {
	return &MediaSync{
		repo:   repo,
		userId: userId,
	}
}

type MediaSync struct {
	repo   repository.AiRecordRepo
	userId int64
}

func (m *MediaSync) MediaSync(ctx context.Context, req *protocol.MediaSyncReq) (*protocol.MediaSyncRsp, error) {
	// 查询总记录数
	count, err := m.repo.MediaRepo().GetUserMediaCount(ctx, m.userId,
		[]int{entity.MediaStateUploaded, entity.MediaStateProcessing, entity.MediaStateSuccess, entity.MediaStateFailed},
		[]int{entity.LStateActive})
	if err != nil {
		return nil, err
	}

	if int64(req.Size*(req.Page-1)) > *count {
		return nil, errs.Newf(errorcode.ErrParamsInvalid, "params out of range page=%d", req.Page)
	}

	// 查询分页记录
	mediaList, err := m.repo.MediaRepo().FindUserMediaList(ctx, m.userId, req.Size*(req.Page-1), req.Size,
		[]int{entity.MediaStateUploaded, entity.MediaStateProcessing, entity.MediaStateSuccess, entity.MediaStateFailed},
		[]int{entity.LStateActive})
	if err != nil {
		return nil, err
	}

	// 构造返回消息
	rsp := &protocol.MediaSyncRsp{
		Page:  req.Page,
		Size:  req.Size,
		Total: int32(*count),
	}

	for _, media := range mediaList {
		mediaData := protocol.MediaData{
			MediaId:       media.MediaId,
			MediaName:     media.MediaName,
			FileFormat:    media.FileFormat,
			FileSign:      media.FileSign,
			RecordTime:    media.RecordTime.Format("2006-01-02 15:04:05"),
			RecordAddress: media.RecordAddress,
			Duration:      media.Duration,
			// Summary:       media.Summary,
			DeviceId:  media.DeviceId,
			MediaType: media.MediaType,
			State:     media.State,
		}

		rsp.Data = append(rsp.Data, mediaData)
	}

	return rsp, nil
}
