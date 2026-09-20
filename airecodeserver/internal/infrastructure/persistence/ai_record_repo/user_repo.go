package ai_record_repo

import (
	"context"
	"time"

	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
	"trpc.group/trpc-go/trpc-go/errs"
)

func NewUserRepoImpl(db *gorm.DB) repository.UserRepo {
	return &UserRepoImpl{
		db: db,
	}
}

type UserRepoImpl struct {
	db *gorm.DB
}

// SaveVerifyCode 保存验证码
func (i *UserRepoImpl) SaveVerifyCode(ctx context.Context, verifyCode *entity.VerifyCode) error {
	return i.db.WithContext(ctx).Debug().Transaction(func(tx *gorm.DB) error {
		if err := tx.WithContext(ctx).Debug().Table(verifyCode.TableName()).Create(verifyCode).Error; err != nil {
			return err
		}
		return nil
	})
}

// GetVerifyCode 获取有效验证码
func (i *UserRepoImpl) GetVerifyCode(ctx context.Context, scene int32, uniKey string) (*entity.VerifyCode, error) {
	var verifyCode *entity.VerifyCode
	tx := i.db.WithContext(ctx).Debug().Table(verifyCode.TableName()).Where(
		"scene = ? and uni_key = ? and expire_time > NOW()", scene,
		uniKey).Order("last_update_time desc").Limit(1).Find(&verifyCode)
	if tx.Error != nil {
		return nil, tx.Error
	}

	if tx.RowsAffected != 1 {
		return nil, errs.Newf(errorcode.ErrRecordNotExisted, "verify code not found.")
	}

	return verifyCode, nil
}

// UsedVerifyCode 更新验证码状态为已使用
func (i *UserRepoImpl) UsedVerifyCode(ctx context.Context, id int64) error {
	// update
	updates := map[string]interface{}{}
	updates["state"] = entity.VerifyCodeStateIsUsed
	updates["last_update_time"] = time.Now()

	var verifyCode *entity.VerifyCode
	if err := i.db.WithContext(ctx).Debug().Table(verifyCode.TableName()).Where(
		"id = ? and state = ?", id, entity.VerifyCodeStateUnUsed).Limit(1).Updates(updates).Error; err != nil {
		return err
	}

	return nil
}

// SaveUserInfo 保存用户信息
func (i *UserRepoImpl) SaveUserInfo(ctx context.Context, userInfo *entity.UserInfo) error {
	if err := i.db.WithContext(ctx).Debug().Table(userInfo.TableName()).Create(userInfo).Error; err != nil {
		return err
	}
	return nil
}

// LockUserInfo 事务锁定用户信息记录
func (i *UserRepoImpl) LockUserInfo(ctx context.Context, userId int64) (*entity.UserInfo, error) {
	var userInfo *entity.UserInfo
	tx := i.db.WithContext(ctx).Debug().Table(userInfo.TableName()).Where(
		"user_id = ? ", userId).Limit(1).Clauses(clause.Locking{Strength: "UPDATE"}).Find(&userInfo)
	if tx.Error != nil {
		return nil, tx.Error
	}

	if tx.RowsAffected != 1 {
		return nil, errs.Newf(errorcode.ErrUserNotFound, "user not found.")
	}

	return userInfo, nil
}

// GetUserInfoByUserId 根据用户ID查询用户信息
func (i *UserRepoImpl) GetUserInfoByUserId(ctx context.Context, userId int64) (*entity.UserInfo, error) {
	var userInfo *entity.UserInfo
	tx := i.db.WithContext(ctx).Debug().Table(userInfo.TableName()).Where(
		"user_id = ? ", userId).Limit(1).Find(&userInfo)
	if tx.Error != nil {
		return nil, tx.Error
	}

	if tx.RowsAffected != 1 {
		return nil, errs.Newf(errorcode.ErrUserNotFound, "user not found.")
	}

	return userInfo, nil
}

// GetUserInfoByPhone 根据电话号码查询用户信息
func (i *UserRepoImpl) GetUserInfoByPhone(ctx context.Context, phone string) (*entity.UserInfo, error) {
	var userInfo *entity.UserInfo
	tx := i.db.WithContext(ctx).Debug().Table(userInfo.TableName()).Where(
		"phone = ? ", phone).Limit(1).Find(&userInfo)
	if tx.Error != nil {
		return nil, tx.Error
	}

	if tx.RowsAffected != 1 {
		return nil, errs.Newf(errorcode.ErrUserNotFound, "user not found.")
	}

	return userInfo, nil
}

// GetUserInfoByEmail 根据邮箱查询用户信息
func (i *UserRepoImpl) GetUserInfoByEmail(ctx context.Context, email string) (*entity.UserInfo, error) {
	var userInfo *entity.UserInfo
	tx := i.db.WithContext(ctx).Debug().Table(userInfo.TableName()).Where(
		"email = ? ", email).Limit(1).Find(&userInfo)
	if tx.Error != nil {
		return nil, tx.Error
	}

	if tx.RowsAffected != 1 {
		return nil, errs.Newf(errorcode.ErrUserNotFound, "user not found.")
	}

	return userInfo, nil
}

// UpdateUserInfo 更新用户信息
func (i *UserRepoImpl) UpdateUserInfo(ctx context.Context, userInfo *entity.UserInfo) error {
	// update
	updates := map[string]interface{}{}
	updates["nick_name"] = userInfo.NickName
	updates["sex"] = userInfo.Sex
	updates["province"] = userInfo.Province
	updates["city"] = userInfo.City
	updates["country"] = userInfo.Country
	updates["head_img_url"] = userInfo.HeadImgUrl
	updates["phone"] = userInfo.Phone
	updates["email"] = userInfo.Email
	updates["state"] = userInfo.State

	updates["last_update_time"] = time.Now()

	if err := i.db.WithContext(ctx).Debug().Table(userInfo.TableName()).Where(
		"user_id = ?", userInfo.UserId).Limit(1).Updates(updates).Error; err != nil {
		return err
	}

	return nil
}

// UpdateUserPassword 更新用户密码
func (i *UserRepoImpl) UpdateUserPassword(ctx context.Context, userId int64, password string) error {
	// update
	updates := map[string]interface{}{}
	updates["password"] = password
	updates["last_update_time"] = time.Now()

	userInfo := entity.UserInfo{}
	if err := i.db.WithContext(ctx).Debug().Table(userInfo.TableName()).Where(
		"user_id = ?", userId).Limit(1).Updates(updates).Error; err != nil {
		return err
	}

	return nil
}

// SaveUserToken 保存用户token信息
func (i *UserRepoImpl) SaveUserToken(ctx context.Context, userToken *entity.UserToken) error {
	return i.db.WithContext(ctx).Debug().Transaction(func(tx *gorm.DB) error {
		if err := tx.WithContext(ctx).Debug().Table(userToken.TableName()).Create(userToken).Error; err != nil {
			return err
		}
		return nil
	})
}

// GetUserToken 获取用户有效token信息
func (i *UserRepoImpl) GetUserToken(ctx context.Context, token string) (*entity.UserToken, error) {
	var userToken *entity.UserToken
	tx := i.db.WithContext(ctx).Debug().Table(userToken.TableName()).Where(
		"token = ? and expire_time > NOW() ", token).Limit(1).Find(&userToken)
	if tx.Error != nil {
		return nil, tx.Error
	}

	if tx.RowsAffected != 1 {
		return nil, errs.Newf(errorcode.ErrRecordNotExisted, "user token not found.")
	}

	return userToken, nil
}

// GetLatestTokenByUserId 根据用户ID获取最新的token信息
func (i *UserRepoImpl) GetLatestTokenByUserId(ctx context.Context, userId int64) (*entity.UserToken, error) {
	var userToken *entity.UserToken
	tx := i.db.WithContext(ctx).Debug().Table(userToken.TableName()).Where(
		"user_id = ?", userId).Order("create_time DESC").Limit(1).Find(&userToken)
	if tx.Error != nil {
		return nil, tx.Error
	}

	if tx.RowsAffected != 1 {
		return nil, errs.Newf(errorcode.ErrRecordNotExisted, "user token not found.")
	}

	return userToken, nil
}

// GetLatestTokensByUserIds 批量获取用户最新token信息
func (i *UserRepoImpl) GetLatestTokensByUserIds(ctx context.Context, userIds []int64) (map[int64]*entity.UserToken, error) {
	if len(userIds) == 0 {
		return make(map[int64]*entity.UserToken), nil
	}

	var userTokens []*entity.UserToken
	var userToken entity.UserToken

	// 使用子查询获取每个用户的最新token信息
	subQuery := i.db.WithContext(ctx).Debug().Table(userToken.TableName()).
		Select("user_id, MAX(create_time) as max_create_time").
		Where("user_id IN ?", userIds).
		Group("user_id")

	err := i.db.WithContext(ctx).Debug().Table(userToken.TableName()).
		Joins("INNER JOIN (?) as latest ON t_user_token.user_id = latest.user_id AND t_user_token.create_time = latest.max_create_time", subQuery).
		Where("t_user_token.user_id IN ?", userIds).
		Find(&userTokens).Error

	if err != nil {
		return nil, err
	}

	// 转换为map格式
	result := make(map[int64]*entity.UserToken)
	for _, token := range userTokens {
		result[token.UserId] = token
	}

	return result, nil
}

// SaveThirdAuth 保存第三方授权信息
func (i *UserRepoImpl) SaveThirdAuth(ctx context.Context, thirdAuth *entity.ThirdAuth) error {
	return i.db.WithContext(ctx).Debug().Transaction(func(tx *gorm.DB) error {
		if err := tx.WithContext(ctx).Debug().Table(thirdAuth.TableName()).Create(thirdAuth).Error; err != nil {
			return err
		}
		return nil
	})
}

// GetThirdAuth 获取第三方授权信息
func (i *UserRepoImpl) GetThirdAuth(ctx context.Context, channel int32, openid string) (*entity.ThirdAuth, error) {
	var thirdAuth *entity.ThirdAuth
	tx := i.db.WithContext(ctx).Debug().Table(thirdAuth.TableName()).Where(
		"channel = ? and openid = ? ", channel, openid).Limit(1).Find(&thirdAuth)
	if tx.Error != nil {
		return nil, tx.Error
	}

	if tx.RowsAffected != 1 {
		return nil, errs.Newf(errorcode.ErrRecordNotExisted, "third auth not found.")
	}

	return thirdAuth, nil
}

// SaveUserFeedback 保存用户反馈信息
func (i *UserRepoImpl) SaveUserFeedback(ctx context.Context, feedback *entity.UserFeedback) error {
	return i.db.WithContext(ctx).Debug().Transaction(func(tx *gorm.DB) error {
		if err := tx.WithContext(ctx).Debug().Table(feedback.TableName()).Create(feedback).Error; err != nil {
			return err
		}
		return nil
	})
}

// GetAppConfig 获取应用配置信息
func (i *UserRepoImpl) GetAppConfig(ctx context.Context, cfgType int32, cfgKey string) (*entity.AppConfig, error) {
	var appConfig *entity.AppConfig
	tx := i.db.WithContext(ctx).Debug().Table(appConfig.TableName()).Where(
		"config_type =? and config_key =? and lstate =?", cfgType, cfgKey,
		entity.AppConfigLstateActive).Limit(1).Find(&appConfig)

	if tx.Error != nil {
		return nil, tx.Error
	}

	if tx.RowsAffected != 1 {
		return nil, errs.Newf(errorcode.ErrRecordNotExisted, "app config not found.")
	}
	return appConfig, nil
}

// FindAppConfig 查询应用配置信息
func (i *UserRepoImpl) FindAppConfig(ctx context.Context, cfgType []int32) ([]*entity.AppConfig, error) {
	var appCfgs []*entity.AppConfig
	tx := i.db.WithContext(ctx).Debug().Where("config_type in ? and lstate = ? ", cfgType,
		entity.AppConfigLstateActive).Find(&appCfgs)

	if tx.Error != nil {
		return nil, tx.Error
	}

	return appCfgs, nil
}

// SaveAppConfig 保存应用配置
func (i *UserRepoImpl) SaveAppConfig(ctx context.Context, config *entity.AppConfig) error {
	return i.db.WithContext(ctx).Debug().Transaction(func(tx *gorm.DB) error {
		if err := tx.WithContext(ctx).Debug().Table(config.TableName()).Create(config).Error; err != nil {
			return err
		}
		return nil
	})
}

// UpdateAppConfig 更新应用配置
func (i *UserRepoImpl) UpdateAppConfig(ctx context.Context, config *entity.AppConfig) error {
	return i.db.WithContext(ctx).Debug().Transaction(func(tx *gorm.DB) error {
		if err := tx.WithContext(ctx).Debug().Table(config.TableName()).Where(
			"id = ? and config_type = ? and lstate = ?", config.Id, config.ConfigType,
			entity.AppConfigLstateActive).Updates(map[string]interface{}{
			"config_value":     config.ConfigValue,
			"config_desc":      config.ConfigDesc,
			"last_update_time": time.Now(),
		}).Error; err != nil {
			return err
		}
		return nil
	})
}

// DeleteAppConfig 删除应用配置
func (i *UserRepoImpl) DeleteAppConfig(ctx context.Context, id int64) error {
	return i.db.WithContext(ctx).Debug().Transaction(func(tx *gorm.DB) error {
		if err := tx.WithContext(ctx).Debug().Table((&entity.AppConfig{}).TableName()).Where(
			"id = ? and lstate = ?", id, entity.AppConfigLstateActive).Updates(
			map[string]interface{}{"lstate": entity.AppConfigLstateDeleted}).Error; err != nil {
			return err
		}
		return nil
	})
}

// ExpireUserTokens 使用户所有Token立即过期
func (i *UserRepoImpl) ExpireUserTokens(ctx context.Context, userId int64) error {
	updates := map[string]interface{}{}
	updates["expire_time"] = time.Now()
	updates["last_update_time"] = time.Now()

	var userToken entity.UserToken
	if err := i.db.WithContext(ctx).Debug().Table(userToken.TableName()).Where(
		"user_id = ? and expire_time > NOW()", userId).Updates(updates).Error; err != nil {
		return err
	}

	return nil
}

// GetUserList 获取用户列表
func (i *UserRepoImpl) GetUserList(ctx context.Context, userId int64, keyword string, state int32) ([]*entity.UserInfo, error) {
	var userList []*entity.UserInfo
	var userInfo entity.UserInfo

	query := i.db.WithContext(ctx).Debug().Table(userInfo.TableName())

	// 添加用户ID精确查询条件
	if userId > 0 {
		query = query.Where("user_id = ?", userId)
	}

	// 添加关键字搜索条件
	if keyword != "" {
		query = query.Where("nick_name LIKE ? OR email LIKE ? OR phone LIKE ?",
			"%"+keyword+"%", "%"+keyword+"%", "%"+keyword+"%")
	}

	// 添加状态筛选条件
	if state > 0 {
		query = query.Where("state = ?", state)
	}

	// 按创建时间倒序排列
	if err := query.Order("create_time DESC").Find(&userList).Error; err != nil {
		return nil, err
	}

	return userList, nil
}
