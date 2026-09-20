package mediaservice

import (
	"context"

	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"trpc.group/trpc-go/trpc-go/errs"
)

func NewMediaConvertRecords(repo repository.MediaRepo, userId int64) *MediaConvertRecords {
	return &MediaConvertRecords{
		repo:   repo,
		userId: userId,
	}
}

type MediaConvertRecords struct {
	repo   repository.MediaRepo
	userId int64
}

func (m *MediaConvertRecords) MediaConvertRecord(
	ctx context.Context, req *protocol.MediaConvertRecordsReq,
) (*protocol.MediaConvertRecordsRsp, error) {
	// 查询总记录数
	count, err := m.repo.GetUserMediaCount(ctx, m.userId, []int{entity.MediaStateSuccess},
		[]int{entity.LStateActive, entity.LStateDeleted})
	if err != nil {
		return nil, err
	}

	if int64(req.Size*(req.Page-1)) > *count {
		return nil, errs.Newf(errorcode.ErrParamsInvalid, "params out of range page=%d", req.Page)
	}

	// 查询分页记录
	mediaList, err := m.repo.FindUserMediaList(ctx, m.userId, req.Size*(req.Page-1), req.Size,
		[]int{entity.MediaStateSuccess},
		[]int{entity.LStateActive, entity.LStateDeleted})
	if err != nil {
		return nil, err
	}

	// 构造返回消息
	rsp := &protocol.MediaConvertRecordsRsp{
		Page:  req.Page,
		Size:  req.Size,
		Total: int32(*count),
	}

	for _, media := range mediaList {
		records := protocol.MediaConvertRecords{
			MediaId:   media.MediaId,
			MediaName: media.MediaName,
			Duration:  media.Duration,
			Deleted:   false,
		}

		if media.RecTime != nil {
			records.RecTime = media.RecTime.Format("2006-01-02 15:04:05")
		}
		if media.Lstate == entity.LStateDeleted {
			records.Deleted = true
		}

		rsp.Data = append(rsp.Data, records)
	}

	return rsp, nil
}
