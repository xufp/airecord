package ai_record_repo

import (
	"context"

	"github.com/smartox/ai_record_server/internal/domain/repository"
	"github.com/smartox/ai_record_server/internal/infrastructure/utils"
	"gorm.io/gorm"
	tgorm "trpc.group/trpc-go/trpc-database/gorm"
)

// NewRepoTransMgr 创建事务管理器
func NewRepoTransMgr() (repository.RepoTransMgr, error) {
	db, err := tgorm.NewClientProxy("ai_record_db_master")
	if err != nil {
		return nil, err
	}

	return &RepoTransMgrImpl{
		db:   db,
		repo: nil,
	}, nil
}

type RepoTransMgrImpl struct {
	db   *gorm.DB
	repo repository.AiRecordRepo
}

func (m *RepoTransMgrImpl) DoTransaction(
	ctx context.Context, fc func(ctx context.Context, repo repository.AiRecordRepo) error,
) error {
	return m.db.WithContext(ctx).Debug().Transaction(func(tx *gorm.DB) error {
		newRepo := newAiRecordRepo(tx)
		return fc(ctx, newRepo)
	})
}

// GetRepository 获取仓库实例
func (m *RepoTransMgrImpl) GetRepository() repository.AiRecordRepo {
	if m.repo == nil {
		m.repo = newAiRecordRepo(m.db)
	}

	return m.repo
}

func newAiRecordRepo(db *gorm.DB) repository.AiRecordRepo {
	crypto := utils.NewAesGCM(string([]byte{115, 109, 97, 114, 116, 111, 46, 116, 111, 112, 46, 50, 48, 50, 52}))

	return &AiRecordRepoImpl{
		media:   NewMediaRepoImpl(db, crypto),
		service: NewServiceRepoImpl(db, crypto),
		user:    NewUserRepoImpl(db),
	}
}

type AiRecordRepoImpl struct {
	db      *gorm.DB
	media   repository.MediaRepo
	service repository.ServiceRepo
	user    repository.UserRepo
}

func (i *AiRecordRepoImpl) MediaRepo() repository.MediaRepo {
	return i.media
}

func (i *AiRecordRepoImpl) ServiceRepo() repository.ServiceRepo {
	return i.service
}

func (i *AiRecordRepoImpl) UserRepo() repository.UserRepo {
	return i.user
}
