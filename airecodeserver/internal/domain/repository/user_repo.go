package repository

import (
	"context"

	"github.com/smartox/ai_record_server/internal/domain/entity"
)

type UserRepo interface {
	SaveVerifyCode(ctx context.Context, verifyCode *entity.VerifyCode) error
	GetVerifyCode(ctx context.Context, scene int32, uniKey string) (*entity.VerifyCode, error)
	UsedVerifyCode(ctx context.Context, id int64) error

	SaveUserInfo(ctx context.Context, userInfo *entity.UserInfo) error
	LockUserInfo(ctx context.Context, userId int64) (*entity.UserInfo, error)
	GetUserInfoByUserId(ctx context.Context, userId int64) (*entity.UserInfo, error)
	GetUserInfoByPhone(ctx context.Context, phone string) (*entity.UserInfo, error)
	GetUserInfoByEmail(ctx context.Context, email string) (*entity.UserInfo, error)
	UpdateUserInfo(ctx context.Context, userInfo *entity.UserInfo) error
	UpdateUserPassword(ctx context.Context, userId int64, password string) error

	SaveUserToken(ctx context.Context, userToken *entity.UserToken) error
	GetUserToken(ctx context.Context, token string) (*entity.UserToken, error)
	// GetLatestTokenByUserId 获取用户最新token信息
	GetLatestTokenByUserId(ctx context.Context, userId int64) (*entity.UserToken, error)
	// GetLatestTokensByUserIds 批量获取用户最新token信息
	GetLatestTokensByUserIds(ctx context.Context, userIds []int64) (map[int64]*entity.UserToken, error)

	SaveThirdAuth(ctx context.Context, thirdAuth *entity.ThirdAuth) error
	GetThirdAuth(ctx context.Context, channel int32, openid string) (*entity.ThirdAuth, error)

	// SaveUserFeedback 保存用户反馈
	SaveUserFeedback(ctx context.Context, feedback *entity.UserFeedback) error
	// GetAppConfig 获取应用配置
	GetAppConfig(ctx context.Context, cfgType int32, cfgKey string) (*entity.AppConfig, error)
	// FindAppConfig 获取应用配置列表
	FindAppConfig(ctx context.Context, cfgType []int32) ([]*entity.AppConfig, error)
	// SaveAppConfig 保存应用配置
	SaveAppConfig(ctx context.Context, config *entity.AppConfig) error
	// UpdateAppConfig 更新应用配置
	UpdateAppConfig(ctx context.Context, config *entity.AppConfig) error
	// DeleteAppConfig 删除应用配置
	DeleteAppConfig(ctx context.Context, id int64) error
	// GetUserList 获取用户列表
	GetUserList(ctx context.Context, userId int64, keyword string, state int32) ([]*entity.UserInfo, error)
	// ExpireUserTokens 使用户所有Token立即过期
	ExpireUserTokens(ctx context.Context, userId int64) error
}
