package userservice

import (
	"context"

	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	domainservice "github.com/smartox/ai_record_server/internal/domain/service"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"github.com/smartox/ai_record_server/internal/infrastructure/utils"
	"trpc.group/trpc-go/trpc-go/errs"
)

func NewUserPackageGive(transMgr repository.RepoTransMgr, userId int64) *UserPackageGive {
	return &UserPackageGive{
		transMgr: transMgr,
		userId:   userId,
	}
}

type UserPackageGive struct {
	userId       int64
	transMgr     repository.RepoTransMgr
	userPackages []*entity.UserPackage
}

func (u *UserPackageGive) UserPackageGive(ctx context.Context, req *protocol.UserPackageGiveReq) (
	*protocol.UserPackageGiveRsp, error,
) {
	// 套餐领取校验
	if err := u.checkPackage(ctx, req.PackageId); err != nil {
		return nil, err
	}

	// 套餐领取
	if err := u.givePackage(ctx, req.PackageId); err != nil {
		return nil, err
	}

	// 打包返回信息
	return u.packResponse(req.PackageId)
}

func (u *UserPackageGive) checkPackage(ctx context.Context, packageId int32) error {
	// 套餐有效性校验
	p, err := u.transMgr.GetRepository().ServiceRepo().GetPackage(ctx, packageId)
	if err != nil {
		return err
	}

	// 非免费领取类套餐，不允许领取
	if p.PackageType != entity.PackageTypeFreeGive {
		return errs.New(errorcode.ErrPackageNotFreeGive, "the package does not support free giving")
	}

	// 套餐有效期判断
	if !p.IsValid() {
		return errs.New(errorcode.ErrRecordNotExisted, "the package is not valid")
	}

	return nil
}

func (u *UserPackageGive) givePackage(ctx context.Context, packageId int32) error {
	if err := u.transMgr.DoTransaction(ctx, func(ctx context.Context, repo repository.AiRecordRepo) error {
		// 锁用户记录
		if _, err := repo.UserRepo().LockUserInfo(ctx, u.userId); err != nil {
			return err
		}

		// 限领一次校验
		packages, err := repo.ServiceRepo().FindUserPackageByPkgId(ctx, u.userId, packageId)
		if err != nil {
			return err
		}

		if len(packages) != 0 {
			return errs.Newf(errorcode.ErrPackageRepeatGive, "The package does not support repeat giving.")
		}

		// 领取套餐包
		u.userPackages, err = domainservice.NewUserService(repo.ServiceRepo(), u.userId).GivePackage(ctx, packageId, "free")
		if err != nil {
			return err
		}

		return nil
	}); err != nil {
		return err
	}

	return nil
}

func (u *UserPackageGive) packResponse(packageId int32) (*protocol.UserPackageGiveRsp, error) {
	rsp := &protocol.UserPackageGiveRsp{
		PackageId: packageId,
	}

	for _, up := range u.userPackages {
		usage := protocol.PackageUsage{
			ServiceType: up.ServiceType,
			BeginDate:   up.BeginDate.Format("2006-01-02 15:04:05"),
			EndDate:     up.EndDate.Format("2006-01-02 15:04:05"),
			Quantity:    up.Quantity,
		}

		switch up.ServiceType {
		case entity.ServiceTypeConvert:
			usage.Quantity = utils.OccupiedTime(usage.Quantity, utils.BlockSecond)
		}

		rsp.PackageDetail = append(rsp.PackageDetail, usage)
	}

	return rsp, nil
}
