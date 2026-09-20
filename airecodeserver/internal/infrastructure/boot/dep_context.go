package boot

import (
	"github.com/smartox/ai_record_server/internal/domain/repository"
	"github.com/smartox/ai_record_server/internal/infrastructure/persistence/ai_record_repo"
)

type DepContext struct {
	TransMgr repository.RepoTransMgr
}

func NewDepContext() (*DepContext, error) {
	transMgr, err := ai_record_repo.NewRepoTransMgr()
	if err != nil {
		return nil, err
	}

	return &DepContext{
		TransMgr: transMgr,
	}, nil
}
