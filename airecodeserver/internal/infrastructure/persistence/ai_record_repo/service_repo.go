package ai_record_repo

import (
	"context"
	"time"

	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"github.com/smartox/ai_record_server/internal/infrastructure/utils"
	"gorm.io/gorm"
	"trpc.group/trpc-go/trpc-go/errs"
	"trpc.group/trpc-go/trpc-go/log"
)

func NewServiceRepoImpl(db *gorm.DB, crypto utils.Crypto) repository.ServiceRepo {
	return &ServiceRepoImpl{
		db:     db,
		crypto: crypto,
	}
}

type ServiceRepoImpl struct {
	db     *gorm.DB
	crypto utils.Crypto
}

// GetService 查询服务信息
func (i *ServiceRepoImpl) GetService(ctx context.Context, serviceId int32) (*entity.Service, error) {
	var s *entity.Service
	tx := i.db.WithContext(ctx).Debug().Table(s.TableName()).Where(
		"service_id = ? ", serviceId).Limit(1).Find(&s)
	if tx.Error != nil {
		return nil, tx.Error
	}

	if tx.RowsAffected != 1 {
		return nil, errs.Newf(errorcode.ErrRecordNotExisted, "service_id %d not found.", serviceId)
	}

	return s, nil
}

// GetPackage 查询套餐信息
func (i *ServiceRepoImpl) GetPackage(ctx context.Context, packageId int32) (*entity.Package, error) {
	var p *entity.Package
	tx := i.db.WithContext(ctx).Debug().Table(p.TableName()).Where("package_id = ? ", packageId).Limit(1).Find(&p)
	if tx.Error != nil {
		return nil, tx.Error
	}

	if tx.RowsAffected != 1 {
		return nil, errs.Newf(errorcode.ErrRecordNotExisted, "package_id %d not found.", packageId)
	}

	return p, nil
}

// FindPackageService 查询套餐包含的服务
func (i *ServiceRepoImpl) FindPackageService(ctx context.Context, packageId int32) ([]*entity.PackageService, error) {
	var ps []*entity.PackageService
	tx := i.db.WithContext(ctx).Debug().Where("package_id = ?", packageId).Find(&ps)
	if tx.Error != nil {
		return nil, tx.Error
	}

	return ps, nil
}

// SaveUserPackage 保存用户套餐信息
func (i *ServiceRepoImpl) SaveUserPackage(ctx context.Context, userPkg *entity.UserPackage) error {
	if err := i.db.WithContext(ctx).Debug().Table(userPkg.TableName()).Create(userPkg).Error; err != nil {
		return err
	}

	return nil
}

// FindUserPackage 查找用户当前有效的指定服务套餐包
func (i *ServiceRepoImpl) FindUserPackage(ctx context.Context, userId int64, serviceType int32) (
	[]*entity.UserPackage, error,
) {
	var packages []*entity.UserPackage
	now := time.Now()
	tx := i.db.WithContext(ctx).Debug().Where(
		"user_id = ? and service_type = ? and begin_date <= ? and end_date >= ? ", userId,
		serviceType, now, now).Order("begin_date asc").Find(&packages)

	if tx.Error != nil {
		return nil, tx.Error
	}

	return packages, nil
}

// FindUserPackageByPkgId 查询用户指定套餐ID的套餐包
func (i *ServiceRepoImpl) FindUserPackageByPkgId(
	ctx context.Context, userId int64, packageId int32,
) ([]*entity.UserPackage, error) {
	var packages []*entity.UserPackage
	tx := i.db.WithContext(ctx).Debug().Where(
		"user_id = ? and package_id = ? ", userId, packageId).Find(&packages)
	if tx.Error != nil {
		return nil, tx.Error
	}

	return packages, nil
}

// SaveUserCost 保存用户消费记录
func (i *ServiceRepoImpl) SaveUserCost(ctx context.Context, cost *entity.UserCost) error {
	if err := i.db.WithContext(ctx).Debug().Table(cost.TableName()).Create(cost).Error; err != nil {
		return err
	}

	return nil
}

// FindUserServiceCost 查询用户指定服务类型的消费记录
func (i *ServiceRepoImpl) FindUserServiceCost(ctx context.Context, userId int64, serviceType int32) (
	[]*entity.UserCost, error,
) {
	var costs []*entity.UserCost
	tx := i.db.WithContext(ctx).Debug().Where("user_id = ? and service_type = ? ", userId, serviceType).Find(&costs)
	if tx.Error != nil {
		return nil, tx.Error
	}

	return costs, nil
}

// FindUserPackageCost 查找用户指定套餐的消费记录
func (i *ServiceRepoImpl) FindUserPackageCost(ctx context.Context, userId int64, userPackageId []int64) (
	[]*entity.UserCost, error,
) {
	var costs []*entity.UserCost
	tx := i.db.WithContext(ctx).Debug().Where("user_id = ? and user_package_id in ? ", userId,
		userPackageId).Find(&costs)
	if tx.Error != nil {
		return nil, tx.Error
	}

	return costs, nil
}

// FindAvailablePackages 可购买(领取)套餐包查询
func (i *ServiceRepoImpl) FindAvailablePackages(ctx context.Context, packageType int32) ([]*entity.Package, error) {
	var packages []*entity.Package
	now := time.Now()
	tx := i.db.WithContext(ctx).Debug().Where("package_type = ? and begin_date <= ? and end_date >= ?", packageType, now,
		now).Find(&packages)
	if tx.Error != nil {
		return nil, tx.Error
	}

	return packages, nil
}

// FindPackages 查询套餐列表（支持筛选）
func (i *ServiceRepoImpl) FindPackages(
	ctx context.Context, packageId int32, keyword string, packageType int32,
) ([]*entity.Package, error) {
	var packages []*entity.Package

	// 构建查询条件
	query := i.db.WithContext(ctx).Debug().Table((&entity.Package{}).TableName())

	// 套餐ID筛选
	if packageId > 0 {
		query = query.Where("package_id = ?", packageId)
	}

	// 套餐类型筛选
	if packageType > 0 {
		query = query.Where("package_type = ?", packageType)
	}

	// 关键字筛选（套餐名称或描述）
	if keyword != "" {
		query = query.Where("package_name LIKE ? OR description LIKE ?", "%"+keyword+"%", "%"+keyword+"%")
	}

	// 查询所有符合条件的套餐
	if err := query.Order("create_time DESC").Find(&packages).Error; err != nil {
		return nil, err
	}

	return packages, nil
}

// SaveOrder 保存订单信息
func (i *ServiceRepoImpl) SaveOrder(ctx context.Context, order *entity.Order) error {
	if err := i.db.WithContext(ctx).Debug().Table(order.TableName()).Create(order).Error; err != nil {
		log.ErrorContextf(ctx, "%+v", err)
		return err
	}

	return nil
}

// GetOrder 查询订单信息
func (i *ServiceRepoImpl) GetOrder(ctx context.Context, orderId string) (*entity.Order, error) {
	var order *entity.Order
	tx := i.db.WithContext(ctx).Debug().Table(order.TableName()).Where(
		"order_id =? and lstate = ? ", orderId, entity.OrderLStateActive).Limit(1).Find(&order)
	if tx.Error != nil {
		return nil, tx.Error
	}
	if tx.RowsAffected != 1 {
		return nil, errs.Newf(errorcode.ErrRecordNotExisted, "order_id %s not found.", orderId)
	}
	return order, nil
}

// GetOrderCount 查询用户订单数量
func (i *ServiceRepoImpl) GetOrderCount(ctx context.Context, userId int64, states []int32) (*int64, error) {
	var count int64
	var order entity.Order
	tx := i.db.WithContext(ctx).Debug().Table(order.TableName()).Where("user_id = ? and state in ? and lstate = ?",
		userId, states, entity.OrderLStateActive).Count(&count)
	if tx.Error != nil {
		return nil, tx.Error
	}

	return &count, nil
}

// FindOrderList 查询用户订单列表
func (i *ServiceRepoImpl) FindOrderList(ctx context.Context, userId int64, offset int32, limit int32, states []int32) (
	[]*entity.Order, error,
) {
	var orderList []*entity.Order
	tx := i.db.WithContext(ctx).Debug().Where("user_id = ? and state in ? and lstate = ?", userId, states,
		entity.OrderLStateActive).Order("last_update_time desc").Offset(int(offset)).Limit(int(limit)).Find(&orderList)
	if tx.Error != nil {
		return nil, tx.Error
	}
	return orderList, nil
}

// UpdateOrder 更新订单信息
func (i *ServiceRepoImpl) UpdateOrder(ctx context.Context, order *entity.Order) error {
	// 构造更新信息
	updates := map[string]interface{}{
		"pay_time":         order.PayTime,
		"payment_id":       order.PaymentId,
		"payment_desc":     order.PaymentDesc,
		"memo":             order.Memo,
		"state":            order.State,
		"last_update_time": time.Now(),
	}

	if err := i.db.WithContext(ctx).Debug().Table(order.TableName()).Where("order_id = ? and lstate = ?",
		order.OrderId, entity.LStateActive).Limit(1).Updates(updates).Error; err != nil {
		return err
	}

	return nil
}

// GetOrderByPaymentId 根据支付ID查询订单信息
func (i *ServiceRepoImpl) GetOrderByPaymentId(ctx context.Context, paymentId string) (*entity.Order, error) {
	var order *entity.Order
	tx := i.db.WithContext(ctx).Debug().Table(order.TableName()).Where(
		"payment_id = ? and lstate = ? ", paymentId, entity.OrderLStateActive).Limit(1).Find(&order)
	if tx.Error != nil {
		return nil, tx.Error
	}
	if tx.RowsAffected != 1 {
		return nil, errs.Newf(errorcode.ErrRecordNotExisted, "payment_id %s not found.", paymentId)
	}
	return order, nil
}

// SaveMembership 保存会员信息
func (i *ServiceRepoImpl) SaveMembership(ctx context.Context, membership *entity.Membership) error {
	if err := i.db.WithContext(ctx).Debug().Table(membership.TableName()).Create(membership).Error; err != nil {
		return err
	}
	return nil
}

// UpdateMembership 更新会员信息
func (i *ServiceRepoImpl) UpdateMembership(ctx context.Context, membership *entity.Membership) error {
	// 构造更新信息
	updates := map[string]interface{}{
		"expire_time":      membership.ExpireTime,
		"state":            membership.State,
		"last_update_time": time.Now(),
	}

	if err := i.db.WithContext(ctx).Debug().Table(membership.TableName()).Where("user_id = ? and level = ?",
		membership.UserId, membership.Level).Limit(1).Updates(updates).Error; err != nil {
		return err
	}
	return nil
}

// FetchTopMembership 获取当前有效的最高级别会员信息(仅返回一条会员记录)
func (i *ServiceRepoImpl) FetchTopMembership(ctx context.Context, userId int64) (*entity.Membership, error) {
	var memberships *entity.Membership
	tx := i.db.WithContext(ctx).Debug().Table(memberships.TableName()).Where(
		"user_id = ? and state = ? and level < ? and expire_time > now() ", userId,
		entity.MembershipStateActive, entity.MembershipLevelAdmin).Order("level desc").Limit(1).Find(&memberships)
	if tx.Error != nil {
		return nil, tx.Error
	}
	if tx.RowsAffected != 1 {
		return nil, errs.Newf(errorcode.ErrRecordNotExisted, "user_id %d not found.", userId)
	}
	return memberships, nil
}

// GetMembership 查询会员信息
func (i *ServiceRepoImpl) GetMembership(ctx context.Context, userId int64, level int32) (*entity.Membership, error) {
	var memberships *entity.Membership
	tx := i.db.WithContext(ctx).Debug().Table(memberships.TableName()).Where(
		"user_id =? and level =? ", userId, level).Limit(1).Find(&memberships)
	if tx.Error != nil {
		return nil, tx.Error
	}
	if tx.RowsAffected != 1 {
		return nil, errs.Newf(errorcode.ErrRecordNotExisted, "user_id %d not found.", userId)
	}
	return memberships, nil
}

// GetMembershipByUserId 根据用户ID查询会员信息
func (i *ServiceRepoImpl) GetMembershipByUserId(ctx context.Context, userId int64) (*entity.Membership, error) {
	var memberships *entity.Membership
	tx := i.db.WithContext(ctx).Debug().Table(memberships.TableName()).Where(
		"user_id = ? and state = ?", userId, entity.MembershipStateActive).Order("level desc").Limit(1).Find(&memberships)
	if tx.Error != nil {
		return nil, tx.Error
	}
	if tx.RowsAffected != 1 {
		return nil, errs.Newf(errorcode.ErrRecordNotExisted, "user_id %d membership not found.", userId)
	}
	return memberships, nil
}

// GetMembershipsByUserIds 批量获取用户会员信息
func (i *ServiceRepoImpl) GetMembershipsByUserIds(ctx context.Context, userIds []int64) (
	map[int64]*entity.Membership, error,
) {
	if len(userIds) == 0 {
		return make(map[int64]*entity.Membership), nil
	}

	var memberships []*entity.Membership
	var membership entity.Membership

	// 使用子查询获取每个用户的最新会员信息
	subQuery := i.db.WithContext(ctx).Debug().Table(membership.TableName()).
		Select("user_id, MAX(level) as max_level").
		Where("user_id IN ? AND state = ?", userIds, entity.MembershipStateActive).
		Group("user_id")

	err := i.db.WithContext(ctx).Debug().Table(membership.TableName()).
		Joins("INNER JOIN (?) as latest ON t_membership.user_id = latest.user_id AND t_membership.level = latest.max_level",
			subQuery).
		Where("t_membership.user_id IN ? AND t_membership.state = ?", userIds, entity.MembershipStateActive).
		Find(&memberships).Error

	if err != nil {
		return nil, err
	}

	// 转换为map格式
	result := make(map[int64]*entity.Membership)
	for _, membership := range memberships {
		result[membership.UserId] = membership
	}

	return result, nil
}

// SaveActivationCard 保存激活卡信息
func (i *ServiceRepoImpl) SaveActivationCard(ctx context.Context, activationCard *entity.ActivationCard) error {
	activationCardTmp := *activationCard
	if len(activationCardTmp.CardPwd) != 0 {
		var err error
		activationCardTmp.CardPwd, err = i.crypto.Encrypt(activationCardTmp.CardPwd)
		if err != nil {
			return errs.Newf(errorcode.ErrDataEncryptFailed, "activation card pwd encrypt failed. err: %s", err.Error())
		}
	}

	if err := i.db.WithContext(ctx).Debug().Table(activationCardTmp.TableName()).Create(activationCardTmp).Error; err != nil {
		return err
	}
	return nil
}

// UpdateActivationCard 更新激活卡信息
func (i *ServiceRepoImpl) UpdateActivationCard(ctx context.Context, activationCard *entity.ActivationCard) error {
	// 构造更新信息
	updates := map[string]interface{}{
		"card_state":         activationCard.CardState,
		"activation_user_id": activationCard.ActivationUserId,
		"activation_time":    activationCard.ActivationTime,
		"last_update_time":   time.Now(),
	}

	if err := i.db.WithContext(ctx).Debug().Table(activationCard.TableName()).Where("card_no =?",
		activationCard.CardNo).Limit(1).Updates(updates).Error; err != nil {
		return err
	}

	return nil
}

// GetActivationCard 查询激活卡信息
func (i *ServiceRepoImpl) GetActivationCard(ctx context.Context, cardNo string) (*entity.ActivationCard, error) {
	var activationCard *entity.ActivationCard
	tx := i.db.WithContext(ctx).Debug().Table(activationCard.TableName()).Where(
		"card_no =? ", cardNo).Limit(1).Find(&activationCard)
	if tx.Error != nil {
		return nil, tx.Error
	}
	if tx.RowsAffected != 1 {
		return nil, errs.Newf(errorcode.ErrRecordNotExisted, "card_no %s not found.", cardNo)
	}

	// 敏感信息字段解密
	var err error
	activationCard.CardPwd, err = i.crypto.Decrypt(activationCard.CardPwd)
	if err != nil {
		return nil, errs.Newf(errorcode.ErrDataDecryptFailed, "activation card pwd decrypt failed. err: %s", err.Error())
	}

	return activationCard, nil
}

// FindActivationCard 查询激活卡列表
func (i *ServiceRepoImpl) FindActivationCard(ctx context.Context) ([]*entity.ActivationCard, error) {
	var activationCards []*entity.ActivationCard
	tx := i.db.WithContext(ctx).Debug().Table((&entity.ActivationCard{}).TableName()).Where("card_state in ?",
		[]int32{
			entity.ActivationCardStateDeactivated, entity.ActivationCardStateActivated, entity.ActivationCardStateDeleted,
		}).Find(&activationCards)
	if tx.Error != nil {
		return nil, tx.Error
	}

	// 敏感信息字段解密
	for _, activationCard := range activationCards {
		var err error
		activationCard.CardPwd, err = i.crypto.Decrypt(activationCard.CardPwd)
		if err != nil {
			return nil, errs.Newf(errorcode.ErrDataDecryptFailed, "activation card pwd decrypt failed. err: %s", err.Error())
		}
	}

	return activationCards, nil
}

// DeleteActivationCard 删除激活卡信息
func (i *ServiceRepoImpl) DeleteActivationCard(ctx context.Context, cardNo string) error {
	tx := i.db.WithContext(ctx).Debug().Table((&entity.ActivationCard{}).TableName()).Where("card_no = ? and card_state = ?",
		cardNo, entity.ActivationCardStateDeactivated).Limit(1).Updates(map[string]interface{}{
		"card_state": entity.ActivationCardStateDeleted,
	})
	if tx.Error != nil {
		return tx.Error
	}

	if tx.RowsAffected != 1 {
		return errs.Newf(errorcode.ErrRecordNotExisted, "card_no %s not found.", cardNo)
	}

	return nil
}

// SaveSubscriptionProduct 保存订阅产品信息
func (i *ServiceRepoImpl) SaveSubscriptionProduct(ctx context.Context, product *entity.SubscriptionProduct) error {
	if err := i.db.WithContext(ctx).Debug().Table(product.TableName()).Create(product).Error; err != nil {
		return err
	}
	return nil
}

// GetSubscriptionProduct 查询订阅产品信息(通过名称查询)
func (i *ServiceRepoImpl) GetSubscriptionProduct(ctx context.Context, productName string) (
	*entity.SubscriptionProduct, error,
) {
	var product *entity.SubscriptionProduct
	tx := i.db.WithContext(ctx).Debug().Table(product.TableName()).Where("product_name =? ",
		productName).Limit(1).Find(&product)
	if tx.Error != nil {
		return nil, tx.Error
	}
	if tx.RowsAffected != 1 {
		return nil, errs.Newf(errorcode.ErrRecordNotExisted, "product_name %s not found.", productName)
	}
	return product, nil
}

// SaveSubscriptionPlan 保存订阅计划信息
func (i *ServiceRepoImpl) SaveSubscriptionPlan(ctx context.Context, plan *entity.SubscriptionPlan) error {
	if err := i.db.WithContext(ctx).Debug().Table(plan.TableName()).Create(plan).Error; err != nil {
		return err
	}
	return nil
}

// GetSubscriptionPlan 查询订阅计划信息(通过套餐ID查询)
func (i *ServiceRepoImpl) GetSubscriptionPlan(ctx context.Context, packageId int32) (*entity.SubscriptionPlan, error) {
	var plan *entity.SubscriptionPlan
	tx := i.db.WithContext(ctx).Debug().Table(plan.TableName()).Where("package_id =? ", packageId).Limit(1).Find(&plan)
	if tx.Error != nil {
		return nil, tx.Error
	}
	if tx.RowsAffected != 1 {
		return nil, errs.Newf(errorcode.ErrRecordNotExisted, "package_id %d not found.", packageId)
	}
	return plan, nil
}

// SaveSubscriptionDeduct 保存订阅扣款信息
func (i *ServiceRepoImpl) SaveSubscriptionDeduct(ctx context.Context, deduct *entity.SubscriptionDeduct) error {
	if err := i.db.WithContext(ctx).Debug().Table(deduct.TableName()).Create(deduct).Error; err != nil {
		return err
	}
	return nil
}

// GetSubscriptionDeduct 查询订阅扣款信息(通过扣款ID查询)
func (i *ServiceRepoImpl) GetSubscriptionDeduct(ctx context.Context, deductId string) (
	*entity.SubscriptionDeduct, error,
) {
	var deduct *entity.SubscriptionDeduct
	tx := i.db.WithContext(ctx).Debug().Table(deduct.TableName()).Where("deduct_id =? ", deductId).Limit(1).Find(&deduct)
	if tx.Error != nil {
		return nil, tx.Error
	}
	if tx.RowsAffected != 1 {
		return nil, errs.Newf(errorcode.ErrRecordNotExisted, "deduct_id %s not found.", deductId)
	}
	return deduct, nil
}
