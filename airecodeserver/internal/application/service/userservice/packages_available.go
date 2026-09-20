package userservice

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"trpc.group/trpc-go/trpc-go/errs"
)

func NewPackagesAvailable(repo repository.AiRecordRepo, userId int64) *PackagesAvailable {
	return &PackagesAvailable{
		repo:   repo,
		userId: userId,
	}
}

type PackagesAvailable struct {
	userId int64
	repo   repository.AiRecordRepo
}

func (u *PackagesAvailable) PackagesAvailable(
	ctx context.Context, req *protocol.PackagesAvailableReq,
) (*protocol.PackagesAvailableRsp, error) {
	packages, err := u.repo.ServiceRepo().FindAvailablePackages(ctx, req.PackageType)
	if err != nil {
		return nil, err
	}

	var ids []int32
	for _, p := range packages {
		ids = append(ids, p.PackageId)
	}

	rsp := &protocol.PackagesAvailableRsp{}
	for _, p := range packages {

		if p.PackageType == entity.PackageTypeFreeGive {
			// 限领一次校验
			ups, err := u.repo.ServiceRepo().FindUserPackageByPkgId(ctx, u.userId, p.PackageId)
			if err != nil {
				return nil, err
			}

			if len(ups) != 0 {
				continue
			}
		}

		pp := protocol.Package{
			PackageId:   p.PackageId,
			PackageType: p.PackageType,
			PackageName: p.PackageName,
			Description: p.Description,
			Price:       p.Price,
			Rates:       p.Rates,
			Currency:    p.Currency,
		}

		// 如果有语言参数且不是默认语言，尝试获取多语言信息
		if req.Lang != "" {
			i18nInfo, err := u.getPackageI18n(ctx, p.PackageId, req.Lang)
			if err == nil && i18nInfo != nil {
				// 如果找到多语言信息，使用多语言信息
				pp.PackageName = i18nInfo.PackageName
				pp.Description = i18nInfo.Description
			}
			// 如果获取多语言信息失败，保持使用默认值（原始套餐名称和描述）
		}

		rsp.Packages = append(rsp.Packages, pp)
	}

	if len(rsp.Packages) == 0 {
		return nil, errs.Newf(errorcode.ErrNoAvailablePackage, "not found available package.")
	}

	// 打包返回信息
	return rsp, nil
}

// PackageI18nInfo 套餐多语言信息
type PackageI18nInfo struct {
	PackageName string `json:"package_name"`
	Description string `json:"description"`
}

// getPackageI18n 获取套餐多语言信息
func (u *PackagesAvailable) getPackageI18n(ctx context.Context, packageId int32, lang string) (
	*PackageI18nInfo, error,
) {
	// 构建配置key
	configKey := fmt.Sprintf("package_%d_%s", packageId, lang)

	// 查询配置
	config, err := u.repo.UserRepo().GetAppConfig(ctx, entity.AppConfigTypePackageI18n, configKey)
	if err != nil {
		return nil, err
	}

	// 解析JSON配置
	var i18nInfo PackageI18nInfo
	if err := json.Unmarshal([]byte(config.ConfigValue), &i18nInfo); err != nil {
		return nil, errs.Newf(errorcode.ErrParseRequestMsg, "failed to parse package i18n config: %v", err)
	}

	return &i18nInfo, nil
}
