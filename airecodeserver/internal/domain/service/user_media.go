package service

import (
  "context"
  "time"

  "github.com/smartox/ai_record_server/internal/domain/entity"
  "github.com/smartox/ai_record_server/internal/domain/repository"
  "github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
  "github.com/smartox/ai_record_server/internal/infrastructure/utils"
  "trpc.group/trpc-go/trpc-go/errs"
  "trpc.group/trpc-go/trpc-go/log"
)

type UserMedia interface {
  CreateMediaInfo(ctx context.Context, mediaInfo *entity.MediaInfo) (*entity.MediaInfo, error)
  UpdateMediaInfo(ctx context.Context, mediaInfo *entity.MediaInfo) error
  RemoveMediaInfo(ctx context.Context, mediaId int64, mediaName string) error

  CreateMediaConvert(ctx context.Context, mediaId int64, recForm int32, engineType string) (*entity.MediaRec, error)
  UpdateMediaRec(ctx context.Context, mediaRec *entity.MediaRec) error

  CreateMediaSummary(ctx context.Context, mediaId int64, engine string, prompt string) (*entity.MediaSummary, error)
}

func NewUserMedia(repo repository.MediaRepo, userId int64) UserMedia {
  return &UserMediaImpl{
    repo:   repo,
    userId: userId,
  }
}

type UserMediaImpl struct {
  repo   repository.MediaRepo
  userId int64
}

func (m *UserMediaImpl) CreateMediaInfo(ctx context.Context, mediaInfo *entity.MediaInfo) (*entity.MediaInfo, error) {
  // 补全部分信息
  mediaInfo.Lstate = entity.LStateActive
  mediaInfo.CreateTime = time.Now()
  mediaInfo.LastUpdateTime = time.Now()

  // 文件重复上传校验
  saved, err := m.repo.GetMediaInfoByName(ctx, m.userId, mediaInfo.MediaName)
  if err == nil {
    // 文件已存在
    if (len(mediaInfo.FileSign) != 0 && saved.FileSign == mediaInfo.FileSign) ||
        (saved.FileFormat == mediaInfo.FileFormat && saved.FileSize == mediaInfo.FileSize && saved.Duration == mediaInfo.Duration) {
      mediaInfo = saved
      log.InfoContextf(ctx, "media repeat create.")
      return saved, nil
    } else {
      return saved, errs.Newf(errorcode.ErrMediaNameExisted, "media name is existed")
    }
  }

  // 更新入库
  if err := m.repo.SaveMediaInfo(ctx, mediaInfo); err != nil {
    return nil, err
  }

  return mediaInfo, nil
}

func (m *UserMediaImpl) UpdateMediaInfo(ctx context.Context, mediaInfo *entity.MediaInfo) error {
  return m.repo.UpdateMediaInfo(ctx, mediaInfo)
}

func (m *UserMediaImpl) RemoveMediaInfo(ctx context.Context, mediaId int64, mediaName string) error {
  return m.repo.RemoveMediaInfo(ctx, mediaId, mediaName)
}

func (m *UserMediaImpl) CreateMediaConvert(
    ctx context.Context, mediaId int64, recForm int32, engineType string,
) (*entity.MediaRec, error) {
  mediaInfo, err := m.repo.GetMediaInfo(ctx, mediaId)
  if err != nil {
    return nil, err
  }

  // 转写中，直接返回
  if mediaInfo.State == entity.MediaStateProcessing || mediaInfo.State == entity.MediaStateSuccess {
    return m.repo.GetMediaRec(ctx, mediaId)
  }

  // 更新音频的转写状态
  mediaInfo.State = entity.MediaStateProcessing
  if err := m.repo.UpdateMediaInfo(ctx, mediaInfo); err != nil {
    return nil, err
  }

  // 查询转写任务记录
  saved, err := m.repo.GetMediaRec(ctx, mediaId)
  if err == nil {
    // 已存在，将转写状态更新为转写等待
    saved.RecForm = recForm
    saved.EngineType = engineType
    saved.State = entity.MediaRecStateWaiting
    saved.Memo = "waiting"
    return saved, m.UpdateMediaRec(ctx, saved)
  }

  // 不存在转写任务记录，构建转写任务记录
  mediaRec := &entity.MediaRec{
    MediaId:        mediaId,
    RecForm:        recForm,
    EngineType:     engineType,
    Format:         mediaInfo.FileFormat,
    ObjectName:     utils.GetObjectName(mediaInfo.MediaUrl),
    State:          entity.MediaRecStateWaiting,
    Memo:           "waiting",
    Duration:       mediaInfo.Duration,
    CreateTime:     time.Now(),
    LastUpdateTime: time.Now(),
  }

  if err := m.repo.SaveMediaRec(ctx, mediaRec); err != nil {
    return nil, err
  }

  return mediaRec, nil
}

func GetMediaState(recState int32) int32 {
  mediaState := int32(entity.MediaStateUploaded)
  switch recState {
  case entity.MediaRecStateWaiting:
    mediaState = entity.MediaStateProcessing
  case entity.MediaRecStateDoing:
    mediaState = entity.MediaStateProcessing
  case entity.MediaRecStateSuccess:
    mediaState = entity.MediaStateSuccess
  case entity.MediaRecStateFailed:
    mediaState = entity.MediaStateUploaded
  }
  return mediaState
}

// UpdateMediaRec 更新识别信息
func (m *UserMediaImpl) UpdateMediaRec(ctx context.Context, mediaRec *entity.MediaRec) error {
  mediaInfo, err := m.repo.GetMediaInfo(ctx, mediaRec.MediaId)
  if err != nil {
    return err
  }

  // 更新media info
  mediaState := GetMediaState(mediaRec.State)
  if mediaInfo.State != mediaState {
    mediaInfo.State = mediaState
    // mediaInfo.Summary = utils.TruncateString(mediaRec.Text, 64)
    if mediaInfo.State == entity.MediaStateSuccess {
      recTime := time.Now()
      mediaInfo.RecTime = &recTime
      mediaInfo.Duration = mediaRec.Duration
    }

    if err := m.repo.UpdateMediaInfo(ctx, mediaInfo); err != nil {
      return err
    }
  }

  return m.repo.UpdateMediaRec(ctx, mediaRec)
}

func (m *UserMediaImpl) CreateMediaSummary(
    ctx context.Context, mediaId int64, engine string, prompt string,
) (*entity.MediaSummary, error) {
  // 查询最后一条总结记录，重入校验
  oldSummary, err := m.repo.GetMediaSummary(ctx, mediaId)
  if err == nil && oldSummary.Engine == engine && oldSummary.Prompt == prompt &&
      oldSummary.State != entity.MediaSummaryStateFailed {
    return oldSummary, nil
  }

  // 创建新的总结记录
  mediaSummary := &entity.MediaSummary{
    MediaId:        mediaId,
    Engine:         engine,
    Prompt:         prompt,
    State:          entity.MediaSummaryStateWaiting,
    ContentType:    entity.MediaSummaryContentTypeEngine,
    CreateTime:     time.Now(),
    LastUpdateTime: time.Now(),
  }

  if err := m.repo.SaveMediaSummary(ctx, mediaSummary); err != nil {
    return nil, err
  }

  return mediaSummary, nil
}
