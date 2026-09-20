package service

import (
	"context"
	"fmt"
	"time"

	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"github.com/smartox/ai_record_server/internal/infrastructure/utils"
	"trpc.group/trpc-go/trpc-go/errs"
)

type UserService interface {
	// GivePackage 用户套餐领取
	GivePackage(ctx context.Context, packageId int32, orderId string) ([]*entity.UserPackage, error)

	// GetUserServiceUsage 查询用户服务使用情况
	GetUserServiceUsage(ctx context.Context, serviceType int32) (*entity.ServiceUsage, error)
	// GetUserPackageUsed 查询用户套餐的已使用量
	GetUserPackageUsed(ctx context.Context, userPackageId int64) (*int64, error)
	// GetPackageServiceValidityDays 查询套餐服务的有效期天数(按转写服务计算)
	GetPackageServiceValidityDays(ctx context.Context, packageId int32) (int32, error)

	// UserConvertServiceCost 用户转写服务消费
	UserConvertServiceCost(ctx context.Context, mediaId int64, duration int64, overdraft bool) error

	// CreateOrder 创建订单
	CreateOrder(ctx context.Context, pkg *entity.Package, channel int32) (*entity.Order, error)

	// GetMembership 获取会员信息
	GetMembership(ctx context.Context) (*entity.Membership, error)
	// ActiveMembership 会员激活领取
	ActiveMembership(ctx context.Context, packageId int32) error
	// ActiveCard 激活卡激活
	ActiveCard(ctx context.Context, cardNo string, cardPwd string) error
}

// NewUserService 封装用户所有服务类操作
func NewUserService(repo repository.ServiceRepo, userId int64) UserService {
	return &UserServiceImpl{
		repo:   repo,
		userId: userId,
	}
}

// UserServiceImpl 用户服务类接口
type UserServiceImpl struct {
	repo   repository.ServiceRepo
	userId int64
}

// GivePackage 用户套餐领取
func (u *UserServiceImpl) GivePackage(ctx context.Context, packageId int32, orderId string) (
	[]*entity.UserPackage, error,
) {
	// 查询套餐服务列表
	ps, err := u.repo.FindPackageService(ctx, packageId)
	if err != nil {
		return nil, err
	}

	// 生成用户套餐信息
	var userPackages []*entity.UserPackage
	for _, s := range ps {
		service, err := u.repo.GetService(ctx, s.ServiceId)
		if err != nil {
			return nil, err
		}

		up := &entity.UserPackage{
			UserId:         u.userId,
			PackageId:      packageId,
			ServiceType:    service.ServiceType,
			BeginDate:      time.Now(), // 即时生效
			EndDate:        time.Now().AddDate(0, 0, int(service.ValidityDays)),
			Quantity:       service.Quantity,
			OrderId:        orderId,
			CreateTime:     time.Now(),
			LastUpdateTime: time.Now(),
		}

		userPackages = append(userPackages, up)
	}

	// 更新已领取套餐信息
	for _, pkg := range userPackages {
		if err := u.repo.SaveUserPackage(ctx, pkg); err != nil {
			return nil, err
		}
	}

	return userPackages, nil
}

// GetUserServiceUsage 查询用户服务使用情况
func (u *UserServiceImpl) GetUserServiceUsage(ctx context.Context, serviceType int32) (
	*entity.ServiceUsage, error,
) {
	packages, err := u.repo.FindUserPackage(ctx, u.userId, serviceType)
	if err != nil {
		return nil, err
	}

	usage := entity.ServiceUsage{
		ServiceType: serviceType,
	}

	var userPackageIds []int64
	for _, p := range packages {
		// 统计套餐总量
		usage.Total += p.Quantity

		// 转写服务套餐列表
		if serviceType == entity.ServiceTypeConvert {
			userPackageIds = append(userPackageIds, p.UserPackageId)
		}
	}

	// 查询用户套餐已用记录
	costs, err := u.repo.FindUserPackageCost(ctx, u.userId, userPackageIds)
	if err != nil {
		return nil, err
	}

	for _, c := range costs {
		usage.Used += c.QuantityUsed - c.QuantityCanceled
	}

	return &usage, nil
}

// GetUserPackageUsed 查询用户套餐的已使用量
func (u *UserServiceImpl) GetUserPackageUsed(ctx context.Context, userPackageId int64) (
	*int64, error,
) {
	// 查询用户指定套餐已用记录
	costs, err := u.repo.FindUserPackageCost(ctx, u.userId, []int64{userPackageId})
	if err != nil {
		return nil, err
	}

	used := int64(0)
	for _, c := range costs {
		used += c.QuantityUsed - c.QuantityCanceled
	}

	return &used, nil
}

// GetPackageServiceValidityDays 查询套餐服务的有效期天数(按转写服务计算)
func (u *UserServiceImpl) GetPackageServiceValidityDays(ctx context.Context, packageId int32) (int32, error) {
	ps, err := u.repo.FindPackageService(ctx, packageId)
	if err != nil {
		return 0, err
	}

	validityDays := int32(0)
	for _, s := range ps {
		service, err := u.repo.GetService(ctx, s.ServiceId)
		if err != nil {
			return 0, err
		}

		if service.ServiceType == entity.ServiceTypeConvert {
			validityDays = service.ValidityDays
			break
		}
	}

	return validityDays, nil
}

// UserConvertServiceCost 用户转写服务消费
func (u *UserServiceImpl) UserConvertServiceCost(
	ctx context.Context, mediaId int64, duration int64, overdraft bool,
) error {
	// 消费数量（单位由毫秒转为秒）
	quantity := utils.OccupiedTime(duration, utils.BlockMillisecond)

	// 查询当前用户套餐记录（用于计算消费扣除）
	var userCosts []*entity.UserCost
	packages, err := u.repo.FindUserPackage(ctx, u.userId, entity.ServiceTypeConvert)
	if err != nil {
		return err
	}

	userCostTmp := entity.UserCost{
		UserId:           u.userId,
		ServiceType:      entity.ServiceTypeConvert,
		UserPackageId:    0,
		QuantityUsed:     0,
		QuantityCanceled: 0,
		CostDate:         time.Now().Format("2006-01-02"),
		Description:      "",
		MediaId:          mediaId,
		CreateTime:       time.Now(),
		LastUpdateTime:   time.Now(),
	}

	var lastCost *entity.UserCost = nil
	consume := quantity
	for _, pkg := range packages {
		used, err := u.GetUserPackageUsed(ctx, pkg.UserPackageId)
		if err != nil {
			return err
		}
		balance := pkg.Quantity - *used

		cost := userCostTmp
		cost.UserPackageId = pkg.UserPackageId

		if balance >= consume {
			cost.QuantityUsed = consume
			consume = 0
		} else {
			cost.QuantityUsed = balance
			consume -= balance
		}

		userCosts = append(userCosts, &cost)

		if consume <= 0 {
			break
		}
		lastCost = &cost
	}

	if consume > 0 {
		if overdraft {
			// 余额部分不足，将剩余量记录到最后一笔消费中
			lastCost.QuantityUsed += consume
		} else {
			return errs.Newf(errorcode.ErrBalanceInsufficient, "insufficient user convert times")
		}
	}

	// 写入t_user_cost记录
	for _, userCost := range userCosts {
		if err := u.repo.SaveUserCost(ctx, userCost); err != nil {
			return err
		}
	}

	return nil
}

func (u *UserServiceImpl) CreateOrder(ctx context.Context, pkg *entity.Package, channel int32) (
	*entity.Order, error,
) {
	order := &entity.Order{
		OrderId:        fmt.Sprintf("%d", utils.GetSnowflake().GenerateID()),
		UserId:         u.userId,
		PackageId:      pkg.PackageId,
		PackageName:    pkg.PackageName,
		State:          entity.OrderStateInit,
		Amount:         pkg.GetAmount(),
		Currency:       pkg.Currency,
		PayTime:        nil,
		PayChannel:     channel,
		PaymentType:    entity.OrderPaymentTypeOnce,
		PaymentId:      "",
		PaymentDesc:    "",
		Memo:           "",
		Lstate:         entity.OrderLStateActive,
		CreateTime:     time.Now(),
		LastUpdateTime: time.Now(),
	}

	// 订阅类套餐，支付类型为订阅支付
	if pkg.PackageType == entity.PackageTypeSubscription {
		order.PaymentType = entity.OrderPaymentTypeSubscription
	}

	if err := u.repo.SaveOrder(ctx, order); err != nil {
		return nil, err
	}

	return order, nil
}

// GetMembership 获取会员信息
func (u *UserServiceImpl) GetMembership(ctx context.Context) (*entity.Membership, error) {
	membership, err := u.repo.FetchTopMembership(ctx, u.userId)
	if err != nil {
		return &entity.Membership{
			UserId:     u.userId,
			Level:      entity.MembershipLevel0,
			ExpireTime: time.Date(9999, 12, 31, 23, 59, 59, 0, time.Local),
			State:      entity.MembershipStateActive,
		}, nil
	}
	return membership, nil
}

// ActiveMembership 会员激活
func (u *UserServiceImpl) ActiveMembership(ctx context.Context, packageId int32) error {
	// 查询套餐服务列表
	pkg, err := u.repo.GetPackage(ctx, packageId)
	if err != nil {
		return err
	}

	if pkg.PackageType != entity.PackageTypeSubscription {
		return errs.Newf(errorcode.ErrPackageNotSupport, "package type not support active membership")
	}

	// 查询套餐服务的有效期天数
	validityDays, err := u.GetPackageServiceValidityDays(ctx, packageId)
	if err != nil {
		return err
	}

	// 创建会员记录（查询level2会员记录，不存在则创建，存在则更新）
	membership, err := u.repo.GetMembership(ctx, u.userId, entity.MembershipLevel2)
	if err != nil {
		if errs.Code(err) != errorcode.ErrRecordNotExisted {
			return err
		}
		// 创建会员记录
		membership = &entity.Membership{
			UserId:         u.userId,
			Level:          entity.MembershipLevel2,
			ExpireTime:     utils.CalcExpireTime(time.Now(), int(validityDays)),
			State:          entity.MembershipStateActive,
			CreateTime:     time.Now(),
			LastUpdateTime: time.Now(),
		}
		if err := u.repo.SaveMembership(ctx, membership); err != nil {
			return err
		}
	} else {
		// 更新会员的过期时间
		if membership.ExpireTime.Before(time.Now()) {
			membership.ExpireTime = utils.CalcExpireTime(time.Now(), int(validityDays))
		} else {
			membership.ExpireTime = utils.CalcExpireTime(membership.ExpireTime, int(validityDays))
		}
		// 会员状态暂不更新
		// membership.State = entity.MembershipStateActive
		if err := u.repo.UpdateMembership(ctx, membership); err != nil {
			return err
		}
	}

	return nil
}

// ActiveCard 激活卡激活
func (u *UserServiceImpl) ActiveCard(ctx context.Context, cardNo string, cardPwd string) error {
	// 激活卡信息检查
	card, err := u.repo.GetActivationCard(ctx, cardNo)
	if err != nil {
		if errs.Code(err) == errorcode.ErrRecordNotExisted {
			return errs.Newf(errorcode.ErrActivationCardInvalid, "card not existed")
		}
		return err
	}

	pkg, err := u.repo.GetPackage(ctx, card.PackageId)
	if err != nil || pkg.PackageType != entity.PackageTypeActivationCard {
		return errs.Newf(errorcode.ErrActivationCardInvalid, "card package invalid")
	}

	if card.CardPwd != cardPwd {
		return errs.Newf(errorcode.ErrActivationCardInvalid, "card password error")
	}

	// 激活卡未过期
	if card.CardExpireTime.Before(time.Now()) {
		return errs.Newf(errorcode.ErrActivationCardInvalid, "card is expired")
	}

	// 激活卡状态为未激活状态时有效
	if card.CardState != entity.ActivationCardStateDeactivated {
		return errs.Newf(errorcode.ErrActivationCardIsUsed, "card is used")
	}

	// 更新激活状态信息
	card.CardState = entity.ActivationCardStateActivated
	card.ActivationUserId = u.userId
	now := time.Now()
	card.ActivationTime = &now
	if err := u.repo.UpdateActivationCard(ctx, card); err != nil {
		return err
	}

	// 会员卡激活
	if _, err := u.repo.GetMembership(ctx, u.userId, entity.MembershipLevel1); err != nil {
		if errs.Code(err) != errorcode.ErrRecordNotExisted {
			return err
		}

		// 创建会员记录(初级永久会员)
		membership := &entity.Membership{
			UserId:         u.userId,
			Level:          entity.MembershipLevel1,
			ExpireTime:     time.Date(9999, 12, 31, 23, 59, 59, 0, time.Local),
			State:          entity.MembershipStateActive,
			CreateTime:     time.Now(),
			LastUpdateTime: time.Now(),
		}
		if err := u.repo.SaveMembership(ctx, membership); err != nil {
			return err
		}
	}

	// 激活服务领取
	if _, err := u.GivePackage(ctx, card.PackageId, card.CardNo); err != nil {
		return err
	}

	return nil
}
