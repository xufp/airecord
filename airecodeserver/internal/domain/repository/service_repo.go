package repository

import (
	"context"

	"github.com/smartox/ai_record_server/internal/domain/entity"
)

type ServiceRepo interface {
	// GetService 查询服务信息
	GetService(ctx context.Context, serviceId int32) (*entity.Service, error)
	// GetPackage 查询套餐信息
	GetPackage(ctx context.Context, packageId int32) (*entity.Package, error)
	// FindPackageService 查询套餐包含的服务
	FindPackageService(ctx context.Context, packageId int32) ([]*entity.PackageService, error)

	// SaveUserPackage 保存用户套餐信息
	SaveUserPackage(ctx context.Context, userPkg *entity.UserPackage) error
	// FindUserPackage 查找用户当前有效的指定服务套餐包
	FindUserPackage(ctx context.Context, userId int64, serviceType int32) ([]*entity.UserPackage, error)
	// FindUserPackageByPkgId 查询用户指定套餐ID的套餐包
	FindUserPackageByPkgId(ctx context.Context, userId int64, packageId int32) ([]*entity.UserPackage, error)

	// SaveUserCost 保存用户消费记录
	SaveUserCost(ctx context.Context, cost *entity.UserCost) error
	// FindUserServiceCost 查询用户指定服务类型的消费记录
	FindUserServiceCost(ctx context.Context, userId int64, serviceType int32) ([]*entity.UserCost, error)
	// FindUserPackageCost 查找用户指定套餐的消费记录
	FindUserPackageCost(ctx context.Context, userId int64, userPackageId []int64) ([]*entity.UserCost, error)

	// FindAvailablePackages 可购买(领取)套餐包查询
	FindAvailablePackages(ctx context.Context, packageType int32) ([]*entity.Package, error)
	// FindPackages 查询套餐列表（支持筛选）
	FindPackages(ctx context.Context, packageId int32, keyword string, packageType int32) ([]*entity.Package, error)

	// SaveOrder 保存订单信息
	SaveOrder(ctx context.Context, order *entity.Order) error
	// GetOrder 查询订单信息
	GetOrder(ctx context.Context, orderId string) (*entity.Order, error)
	// GetOrderByPaymentId 根据支付ID查询订单信息
	GetOrderByPaymentId(ctx context.Context, paymentId string) (*entity.Order, error)
	// GetOrderCount 查询用户订单数量
	GetOrderCount(ctx context.Context, userId int64, states []int32) (*int64, error)
	// FindOrderList 查询用户订单列表
	FindOrderList(ctx context.Context, userId int64, offset int32, limit int32, states []int32) ([]*entity.Order, error)
	// UpdateOrder 更新订单信息
	UpdateOrder(ctx context.Context, order *entity.Order) error

	// SaveMembership 保存会员信息
	SaveMembership(ctx context.Context, membership *entity.Membership) error
	// UpdateMembership 更新会员信息
	UpdateMembership(ctx context.Context, membership *entity.Membership) error
	// FetchTopMembership 获取当前有效的最高级别会员信息(仅返回一条会员记录)
	FetchTopMembership(ctx context.Context, userId int64) (*entity.Membership, error)
	// GetMembership 查询会员信息
	GetMembership(ctx context.Context, userId int64, level int32) (*entity.Membership, error)
	// GetMembershipByUserId 根据用户ID查询会员信息
	GetMembershipByUserId(ctx context.Context, userId int64) (*entity.Membership, error)
	// GetMembershipsByUserIds 批量获取用户会员信息
	GetMembershipsByUserIds(ctx context.Context, userIds []int64) (map[int64]*entity.Membership, error)

	// SaveActivationCard 保存激活卡信息
	SaveActivationCard(ctx context.Context, activationCard *entity.ActivationCard) error
	// UpdateActivationCard 更新激活卡信息
	UpdateActivationCard(ctx context.Context, activationCard *entity.ActivationCard) error
	// GetActivationCard 查询激活卡信息
	GetActivationCard(ctx context.Context, cardNo string) (*entity.ActivationCard, error)
	// FindActivationCard 查询激活卡列表
	FindActivationCard(ctx context.Context) ([]*entity.ActivationCard, error)
	// DeleteActivationCard 删除激活卡信息
	DeleteActivationCard(ctx context.Context, cardNo string) error

	// SaveSubscriptionProduct 保存订阅产品信息
	SaveSubscriptionProduct(ctx context.Context, product *entity.SubscriptionProduct) error
	// GetSubscriptionProduct 查询订阅产品信息(通过名称查询)
	GetSubscriptionProduct(ctx context.Context, productName string) (*entity.SubscriptionProduct, error)
	// SaveSubscriptionPlan 保存订阅计划信息
	SaveSubscriptionPlan(ctx context.Context, plan *entity.SubscriptionPlan) error
	// GetSubscriptionPlan 查询订阅计划信息(通过套餐ID查询)
	GetSubscriptionPlan(ctx context.Context, packageId int32) (*entity.SubscriptionPlan, error)
	// SaveSubscriptionDeduct 保存订阅扣款信息
	SaveSubscriptionDeduct(ctx context.Context, deduct *entity.SubscriptionDeduct) error
	// GetSubscriptionDeduct 查询订阅扣款信息(通过扣款ID查询)
	GetSubscriptionDeduct(ctx context.Context, deductId string) (*entity.SubscriptionDeduct, error)
}
