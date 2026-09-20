package repository

import "context"

// RepoTransMgr 事务管理器
type RepoTransMgr interface {
	DoTransaction(ctx context.Context, fc func(ctx context.Context, repo AiRecordRepo) error) error

	// GetRepository 获取仓库实例
	GetRepository() AiRecordRepo
}

// AiRecordRepo 资源库管理
type AiRecordRepo interface {
	MediaRepo() MediaRepo
	ServiceRepo() ServiceRepo
	UserRepo() UserRepo
}
