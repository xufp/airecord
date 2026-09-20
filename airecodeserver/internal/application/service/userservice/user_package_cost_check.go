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

func NewUserPackageCostCheck(repo repository.ServiceRepo, userId int64) *UserPackageCostCheck {
	return &UserPackageCostCheck{
		repo:   repo,
		userId: userId,
	}
}

type UserPackageCostCheck struct {
	userId int64
	repo   repository.ServiceRepo
}

func (c *UserPackageCostCheck) UserPackageCostCheck(
	ctx context.Context, req *protocol.UserPackageCostCheckReq,
) (*protocol.UserPackageCostCheckRsp, error) {
	// 用户套餐消费校验
	isSufficient, err := c.CostCheck(ctx, req)
	if err != nil {
		return nil, err
	}

	// 打包返回信息
	return &protocol.UserPackageCostCheckRsp{
		IsSufficient: isSufficient,
	}, nil
}

// CostCheck 用户套餐消费校验
func (c *UserPackageCostCheck) CostCheck(ctx context.Context, req *protocol.UserPackageCostCheckReq) (bool, error) {
	usage, err := domainservice.NewUserService(c.repo, c.userId).GetUserServiceUsage(ctx, req.ServiceType)
	if err != nil {
		return false, err
	}

	log.Debugf("usage: %+v", usage)

	isSufficient := false
	switch usage.ServiceType {
	case entity.ServiceTypeConvert:
		if usage.Total-usage.Used >= utils.OccupiedTime(req.CostAmount, utils.BlockMillisecond) {
			isSufficient = true
		}
	}

	return isSufficient, nil
}
