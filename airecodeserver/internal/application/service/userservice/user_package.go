package userservice

import (
	"context"

	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	domainservice "github.com/smartox/ai_record_server/internal/domain/service"
	"github.com/smartox/ai_record_server/internal/infrastructure/utils"
	"trpc.group/trpc-go/trpc-go/log"
)

func NewUserPackage(repo repository.ServiceRepo, userId int64) *UserPackage {
	return &UserPackage{
		repo:   repo,
		userId: userId,
	}
}

type UserPackage struct {
	userId  int64
	repo    repository.ServiceRepo
	convert protocol.ServiceUsage
}

func (u *UserPackage) UserPackage(ctx context.Context) (*protocol.UserPackageRsp, error) {
	// 语音转写服务
	if err := u.userConvertQry(ctx); err != nil {
		return nil, err
	}

	// 打包返回信息
	return &protocol.UserPackageRsp{
		Convert: u.convert,
	}, nil
}

func (u *UserPackage) userConvertQry(ctx context.Context) error {
	usage, err := domainservice.NewUserService(u.repo, u.userId).GetUserServiceUsage(ctx,
		entity.ServiceTypeConvert)
	if err != nil {
		return err
	}

	log.InfoContextf(ctx, "convert usage: %+v", usage)

	u.convert.Used = utils.OccupiedTime(usage.Used, utils.BlockSecond)
	u.convert.Total = usage.Total / utils.BlockSecond

	return nil
}
