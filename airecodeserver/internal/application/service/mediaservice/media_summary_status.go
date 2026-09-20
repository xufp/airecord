package mediaservice

import (
	"context"

	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"trpc.group/trpc-go/trpc-go/errs"
)

func NewMediaSummaryStatus(repo repository.MediaRepo, userId int64) *MediaSummaryStatus {
	return &MediaSummaryStatus{
		repo:   repo,
		userId: userId,
	}
}

type MediaSummaryStatus struct {
	repo   repository.MediaRepo
	userId int64
}

func (m *MediaSummaryStatus) MediaSummaryStatus(ctx context.Context, req *protocol.MediaSummaryStatusReq) (
	*protocol.MediaSummaryStatusRsp, error,
) {
	// 查询音频信息&校验
	mediaInfo, err := m.repo.GetMediaInfo(ctx, req.MediaId)
	if err != nil {
		return nil, err
	}

	if mediaInfo.UserId != m.userId {
		return nil, errs.Newf(errorcode.ErrRecordNotExisted, "media not found")
	}

	// 查询总结
	mediaSummary, err := m.repo.GetMediaSummary(ctx, req.MediaId)
	if err != nil {
		return nil, err
	}

	return &protocol.MediaSummaryStatusRsp{
		MediaId: req.MediaId,
		State:   mediaSummary.State,
		Memo:    mediaSummary.Memo,
		Content: mediaSummary.Content,
	}, nil
}
