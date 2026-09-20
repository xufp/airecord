package service

import (
	"context"
	"fmt"

	"github.com/smartox/ai_record_server/internal/admin/protocol"
	"github.com/smartox/ai_record_server/internal/domain/repository"
)

type PackageService struct {
	repo   repository.ServiceRepo
	userId int64
}

func NewPackageService(repo repository.ServiceRepo, userId int64) *PackageService {
	return &PackageService{
		repo:   repo,
		userId: userId,
	}
}

// PackageList 获取套餐列表
func (s *PackageService) PackageList(ctx context.Context, req *protocol.PackageListRequest) (*protocol.PackageListResponse, error) {
	// 查询套餐列表
	packages, err := s.repo.FindPackages(ctx, req.PackageId, req.Keyword, req.PackageType)
	if err != nil {
		return nil, fmt.Errorf("查询套餐列表失败: %v", err)
	}

	// 转换为响应格式
	var packageInfos []protocol.PackageInfo
	for _, pkg := range packages {
		packageInfos = append(packageInfos, protocol.PackageInfo{
			PackageId:      pkg.PackageId,
			PackageType:    pkg.PackageType,
			PackageName:    pkg.PackageName,
			Description:    pkg.Description,
			Price:          pkg.Price,
			Rates:          pkg.Rates,
			Currency:       pkg.Currency,
			BeginDate:      pkg.BeginDate.Format("2006-01-02 15:04:05"),
			EndDate:        pkg.EndDate.Format("2006-01-02 15:04:05"),
			CreateTime:     pkg.CreateTime.Format("2006-01-02 15:04:05"),
			LastUpdateTime: pkg.LastUpdateTime.Format("2006-01-02 15:04:05"),
		})
	}

	return &protocol.PackageListResponse{
		Total: int64(len(packageInfos)),
		List:  packageInfos,
	}, nil
}

// PackageDetail 获取套餐详情
func (s *PackageService) PackageDetail(ctx context.Context, packageId int32) (*protocol.PackageDetailResponse, error) {
	// 获取套餐基本信息
	pkg, err := s.repo.GetPackage(ctx, packageId)
	if err != nil {
		return nil, fmt.Errorf("获取套餐信息失败: %v", err)
	}

	// 转换为响应格式
	packageInfo := protocol.PackageInfo{
		PackageId:      pkg.PackageId,
		PackageType:    pkg.PackageType,
		PackageName:    pkg.PackageName,
		Description:    pkg.Description,
		Price:          pkg.Price,
		Rates:          pkg.Rates,
		Currency:       pkg.Currency,
		BeginDate:      pkg.BeginDate.Format("2006-01-02 15:04:05"),
		EndDate:        pkg.EndDate.Format("2006-01-02 15:04:05"),
		CreateTime:     pkg.CreateTime.Format("2006-01-02 15:04:05"),
		LastUpdateTime: pkg.LastUpdateTime.Format("2006-01-02 15:04:05"),
	}

	return &protocol.PackageDetailResponse{
		PackageInfo: packageInfo,
	}, nil
}

// PackageServices 获取套餐服务列表
func (s *PackageService) PackageServices(ctx context.Context, packageId int32) (*protocol.PackageServicesResponse, error) {
	// 获取套餐包含的服务
	packageServices, err := s.repo.FindPackageService(ctx, packageId)
	if err != nil {
		return nil, fmt.Errorf("获取套餐服务失败: %v", err)
	}

	// 获取每个服务的详细信息
	var serviceInfos []protocol.PackageServiceInfo
	for _, ps := range packageServices {
		service, err := s.repo.GetService(ctx, ps.ServiceId)
		if err != nil {
			// 如果服务不存在，跳过
			continue
		}

		serviceInfos = append(serviceInfos, protocol.PackageServiceInfo{
			ServiceId:      service.ServiceId,
			ServiceType:    service.ServiceType,
			ServiceName:    service.ServiceName,
			Description:    service.Description,
			Quantity:       service.Quantity,
			Price:          service.Price,
			Currency:       service.Currency,
			ValidityDays:   service.ValidityDays,
			CreateTime:     service.CreateTime.Format("2006-01-02 15:04:05"),
			LastUpdateTime: service.LastUpdateTime.Format("2006-01-02 15:04:05"),
		})
	}

	return &protocol.PackageServicesResponse{
		Total: int64(len(serviceInfos)),
		List:  serviceInfos,
	}, nil
}
