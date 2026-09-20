package repository

import (
	"context"

	"github.com/smartox/ai_record_server/internal/domain/entity"
)

// MediaRepo 音频资源操作接口
type MediaRepo interface {
	SaveMediaInfo(ctx context.Context, mediaInfo *entity.MediaInfo) error
	GetMediaInfo(ctx context.Context, mediaId int64) (*entity.MediaInfo, error)
	GetMediaInfoByName(ctx context.Context, userId int64, mediaName string) (*entity.MediaInfo, error)
	GetUserMediaCount(ctx context.Context, userId int64, states []int, lstates []int) (*int64, error)
	FindUserMediaList(ctx context.Context, userId int64, offset int32, limit int32, states []int, lstates []int) (
		[]*entity.MediaInfo, error,
	)
	FindUserLiveRecMedia(ctx context.Context, userId int64) ([]*entity.MediaInfo, error)
	UpdateMediaInfo(ctx context.Context, mediaInfo *entity.MediaInfo) error
	RemoveMediaInfo(ctx context.Context, mediaId int64, mediaName string) error

	SaveMediaRec(ctx context.Context, mediaRec *entity.MediaRec) error
	GetMediaRec(ctx context.Context, mediaId int64) (*entity.MediaRec, error)
	UpdateMediaRec(ctx context.Context, mediaRec *entity.MediaRec) error
	FindProcessingMediaRec(ctx context.Context, states []int32) ([]*entity.MediaRec, error)

	// SaveMediaSummary 创建&保存音频总结记录
	SaveMediaSummary(ctx context.Context, mediaSummary *entity.MediaSummary) error
	// GetMediaSummary 获取指定音频的最后一条总结记录
	GetMediaSummary(ctx context.Context, mediaId int64) (*entity.MediaSummary, error)
	// FindMediaSummary 获取指定音频的全部总结记录
	FindMediaSummary(ctx context.Context, mediaId int64) ([]*entity.MediaSummary, error)
	// UpdateMediaSummary 更新音频的总结记录信息（含结果等）
	UpdateMediaSummary(ctx context.Context, mediaSummary *entity.MediaSummary) error
}
