package ai_record_repo

import (
	"context"
	"fmt"
	"time"

	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"github.com/smartox/ai_record_server/internal/infrastructure/utils"
	"gorm.io/gorm"
	"trpc.group/trpc-go/trpc-go/errs"
	"trpc.group/trpc-go/trpc-go/log"
)

func NewMediaRepoImpl(db *gorm.DB, crypto utils.Crypto) repository.MediaRepo {
	return &MediaRepoImpl{
		db:     db,
		crypto: crypto,
	}
}

type MediaRepoImpl struct {
	db     *gorm.DB
	crypto utils.Crypto
}

// SaveMediaInfo 保存音频信息
func (i *MediaRepoImpl) SaveMediaInfo(ctx context.Context, mediaInfo *entity.MediaInfo) error {
	if err := i.db.WithContext(ctx).Debug().Table(mediaInfo.TableName()).Create(mediaInfo).Error; err != nil {
		log.ErrorContextf(ctx, "%+v", err)
		return err
	}

	return nil
}

// GetMediaInfo 音频信息查询
func (i *MediaRepoImpl) GetMediaInfo(ctx context.Context, mediaId int64) (*entity.MediaInfo, error) {
	var mediaInfo *entity.MediaInfo
	tx := i.db.WithContext(ctx).Debug().Table(mediaInfo.TableName()).Where(
		"media_id = ? and lstate = ?", mediaId, entity.LStateActive).Limit(1).Find(&mediaInfo)
	if tx.Error != nil {
		return nil, tx.Error
	}

	if tx.RowsAffected != 1 {
		return nil, errs.Newf(errorcode.ErrRecordNotExisted, "media info not found.")
	}
	return mediaInfo, nil
}

// GetMediaInfoByName 通过MediaName查询用户音频信息
func (i *MediaRepoImpl) GetMediaInfoByName(ctx context.Context, userId int64, mediaName string) (
	*entity.MediaInfo, error,
) {
	var mediaInfo *entity.MediaInfo
	tx := i.db.WithContext(ctx).Debug().Table(mediaInfo.TableName()).Where(
		"user_id = ? and media_name = ? and lstate = ?",
		userId, mediaName, entity.LStateActive).Limit(1).Find(&mediaInfo)
	if tx.Error != nil {
		return nil, tx.Error
	}

	if tx.RowsAffected != 1 {
		return nil, errs.Newf(errorcode.ErrRecordNotExisted, "media file not found.")
	}
	return mediaInfo, nil
}

// GetUserMediaCount 获取用户音频文件数量
func (i *MediaRepoImpl) GetUserMediaCount(ctx context.Context, userId int64, states []int, lstates []int) (
	*int64, error,
) {
	var count int64
	var mediaInfo entity.MediaInfo
	tx := i.db.WithContext(ctx).Debug().Table(mediaInfo.TableName()).Where("user_id = ? and state in ? and lstate in ?",
		userId,
		states, lstates).Count(&count)
	if tx.Error != nil {
		return nil, tx.Error
	}

	return &count, nil
}

// FindUserMediaList 查询用户音频文件列表(分页)
func (i *MediaRepoImpl) FindUserMediaList(
	ctx context.Context, userId int64, offset int32, limit int32, states []int, lstates []int,
) (
	[]*entity.MediaInfo, error,
) {
	var mediaList []*entity.MediaInfo
	tx := i.db.WithContext(ctx).Debug().Where("user_id = ? and state in ? and lstate in ?", userId,
		states, lstates).Order("last_update_time desc").Offset(int(offset)).Limit(int(limit)).Find(&mediaList)
	if tx.Error != nil {
		return nil, tx.Error
	}

	return mediaList, nil
}

// FindUserLiveRecMedia 查询用户转写中的音频信息(6小时内，超出6小时按失败论)
func (i *MediaRepoImpl) FindUserLiveRecMedia(ctx context.Context, userId int64) ([]*entity.MediaInfo, error) {
	var mediaList []*entity.MediaInfo
	tx := i.db.WithContext(ctx).Debug().Where(
		"user_id = ? and state = ? and lstate = ? and create_time >= NOW() - INTERVAL 6 HOUR ", userId,
		entity.MediaStateProcessing, entity.LStateActive).Find(&mediaList)
	if tx.Error != nil {
		return nil, tx.Error
	}

	return mediaList, nil
}

// RemoveMediaInfo 用户音频文件删除
func (i *MediaRepoImpl) RemoveMediaInfo(ctx context.Context, mediaId int64, mediaName string) error {
	mediaInfo := entity.MediaInfo{
		MediaId: mediaId,
	}

	updates := map[string]interface{}{
		"media_name":       fmt.Sprintf("%s.%d", mediaName, mediaId),
		"lstate":           entity.LStateDeleted,
		"last_update_time": time.Now(),
	}

	if err := i.db.WithContext(ctx).Debug().Table(mediaInfo.TableName()).Where("media_id = ? and lstate = ?",
		mediaInfo.MediaId, entity.LStateActive).Limit(1).Updates(updates).Error; err != nil {
		return err
	}

	return nil
}

// UpdateMediaInfo 更新音频信息
func (i *MediaRepoImpl) UpdateMediaInfo(ctx context.Context, mediaInfo *entity.MediaInfo) error {
	// 构造更新信息
	updates := map[string]interface{}{
		"media_name":       mediaInfo.MediaName,
		"file_size":        mediaInfo.FileSize,
		"file_sign":        mediaInfo.FileSign,
		"duration":         mediaInfo.Duration,
		"media_url":        mediaInfo.MediaUrl,
		"state":            mediaInfo.State,
		"rec_time":         mediaInfo.RecTime,
		"summary":          mediaInfo.Summary,
		"description":      mediaInfo.Description,
		"last_update_time": time.Now(),
	}

	if err := i.db.WithContext(ctx).Debug().Table(mediaInfo.TableName()).Where("media_id = ? and lstate = ?",
		mediaInfo.MediaId, entity.LStateActive).Limit(1).Updates(updates).Error; err != nil {
		return err
	}

	return nil
}

// SaveMediaRec 保存音频识别记录
func (i *MediaRepoImpl) SaveMediaRec(ctx context.Context, mediaRec *entity.MediaRec) error {
	if err := i.db.WithContext(ctx).Debug().Table(mediaRec.TableName()).Create(mediaRec).Error; err != nil {
		return err
	}

	return nil
}

// GetMediaRec 获取音频转写记录
func (i *MediaRepoImpl) GetMediaRec(ctx context.Context, mediaId int64) (*entity.MediaRec, error) {
	var mediaRec *entity.MediaRec
	tx := i.db.WithContext(ctx).Debug().Table(mediaRec.TableName()).Where(
		"media_id = ? ", mediaId).Limit(2).Find(&mediaRec)
	if tx.Error != nil {
		return nil, tx.Error
	}

	if tx.RowsAffected != 1 {
		return nil, errs.Newf(errorcode.ErrRecordNotExisted, "media rec not found.")
	}

	// 敏感信息字段解密
	var err error
	mediaRec.Text, err = i.crypto.Decrypt(mediaRec.Text)
	if err != nil {
		return nil, errs.Newf(errorcode.ErrDataDecryptFailed, "media rec text decrypt failed. err: %s", err.Error())
	}

	mediaRec.SentenceDetail, err = i.crypto.Decrypt(mediaRec.SentenceDetail)
	if err != nil {
		return nil, errs.Newf(errorcode.ErrDataDecryptFailed, "media rec sentence_detail decrypt failed. err: %s",
			err.Error())
	}

	return mediaRec, nil
}

func (i *MediaRepoImpl) UpdateMediaRec(ctx context.Context, mediaRec *entity.MediaRec) error {
	// 构造更新信息
	updates := map[string]interface{}{
		"engine_type":      mediaRec.EngineType,
		"object_name":      mediaRec.ObjectName,
		"state":            mediaRec.State,
		"memo":             mediaRec.Memo,
		"task_id":          mediaRec.TaskId,
		"request_id":       mediaRec.RequestId,
		"duration":         mediaRec.Duration,
		"text":             mediaRec.Text,
		"sentence_detail":  mediaRec.SentenceDetail,
		"last_update_time": time.Now(),
	}

	// 敏感信息加密
	var err error
	updates["text"], err = i.crypto.Encrypt(updates["text"].(string))
	if err != nil {
		return errs.Newf(errorcode.ErrDataEncryptFailed, "media rec text encrypt failed. err: %s", err.Error())
	}

	updates["sentence_detail"], err = i.crypto.Encrypt(updates["sentence_detail"].(string))
	if err != nil {
		return errs.Newf(errorcode.ErrDataEncryptFailed, "media rec sentence_detail encrypt failed. err: %s", err.Error())
	}

	if err := i.db.WithContext(ctx).Debug().Table(mediaRec.TableName()).Where("media_id = ?",
		mediaRec.MediaId).Limit(1).Updates(updates).Error; err != nil {
		return err
	}

	return nil
}

// FindProcessingMediaRec 获取处理中的音频识别任务记录
func (i *MediaRepoImpl) FindProcessingMediaRec(ctx context.Context, states []int32) ([]*entity.MediaRec, error) {
	var mediaRecList []*entity.MediaRec
	tx := i.db.WithContext(ctx).Debug().Where("state in ? and last_update_time > now() - INTERVAL 1 DAY "+
		"and task_id <> '' ", states).Find(&mediaRecList)
	if tx.Error != nil {
		return nil, tx.Error
	}
	return mediaRecList, nil
}

// SaveMediaSummary 创建&保存音频总结记录
func (i *MediaRepoImpl) SaveMediaSummary(ctx context.Context, mediaSummary *entity.MediaSummary) error {
	mediaSummaryTmp := *mediaSummary
	if len(mediaSummaryTmp.Content) != 0 {
		var err error
		mediaSummaryTmp.Content, err = i.crypto.Encrypt(mediaSummaryTmp.Content)
		if err != nil {
			return errs.Newf(errorcode.ErrDataEncryptFailed, "media summary content encrypt failed. err: %s", err.Error())
		}
	}

	if err := i.db.WithContext(ctx).Debug().Table(mediaSummaryTmp.TableName()).Create(&mediaSummaryTmp).Error; err != nil {
		return err
	}

	mediaSummary.SummaryId = mediaSummaryTmp.SummaryId
	return nil
}

// GetMediaSummary 获取总结记录（仅获取最后一条）
func (i *MediaRepoImpl) GetMediaSummary(ctx context.Context, mediaId int64) (*entity.MediaSummary, error) {
	var mediaSummary *entity.MediaSummary
	tx := i.db.WithContext(ctx).Debug().Table(mediaSummary.TableName()).Where(
		"media_id = ?", mediaId).Order("summary_id desc").Limit(1).Find(&mediaSummary)
	if tx.Error != nil {
		return nil, tx.Error
	}

	if tx.RowsAffected != 1 {
		return nil, errs.Newf(errorcode.ErrRecordNotExisted, "media summary not found.")
	}

	// 敏感信息字段解密
	var err error
	mediaSummary.Content, err = i.crypto.Decrypt(mediaSummary.Content)
	if err != nil {
		return nil, errs.Newf(errorcode.ErrDataDecryptFailed,
			"media summary content decrypt failed. summary_id: %d, err: %s", mediaSummary.SummaryId, err.Error())
	}

	return mediaSummary, nil
}

// FindMediaSummary 获取音频的全部总结记录
func (i *MediaRepoImpl) FindMediaSummary(ctx context.Context, mediaId int64) ([]*entity.MediaSummary, error) {
	var summaryList []*entity.MediaSummary
	tx := i.db.WithContext(ctx).Debug().Where(
		"media_id = ?", mediaId).Find(&summaryList)
	if tx.Error != nil {
		return nil, tx.Error
	}

	// 敏感信息字段解密
	var err error
	for idx, _ := range summaryList {
		summaryList[idx].Content, err = i.crypto.Decrypt(summaryList[idx].Content)
		if err != nil {
			return nil, errs.Newf(errorcode.ErrDataDecryptFailed,
				"media summary content decrypt failed. summary_id: %d, err: %s",
				summaryList[idx].SummaryId, err.Error())
		}
	}

	return summaryList, nil
}

// UpdateMediaSummary 更新音频的总结记录信息（含结果等）
func (i *MediaRepoImpl) UpdateMediaSummary(ctx context.Context, mediaSummary *entity.MediaSummary) error {
	// 构造更新信息
	updates := map[string]interface{}{
		"state":            mediaSummary.State,
		"memo":             mediaSummary.Memo,
		"content_type":     mediaSummary.ContentType,
		"content":          mediaSummary.Content,
		"last_update_time": time.Now(),
	}

	// 敏感信息加密
	var err error
	updates["content"], err = i.crypto.Encrypt(updates["content"].(string))
	if err != nil {
		return errs.Newf(errorcode.ErrDataEncryptFailed, "media summary content encrypt failed. err: %s", err.Error())
	}

	if err := i.db.WithContext(ctx).Debug().Table(mediaSummary.TableName()).Where("summary_id = ?",
		mediaSummary.SummaryId).Limit(1).Updates(updates).Error; err != nil {
		return err
	}

	return nil
}
