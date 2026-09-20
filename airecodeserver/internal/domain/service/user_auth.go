package service

import (
	"context"
	"math/rand"
	"strconv"
	"strings"
	"time"

	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"github.com/smartox/ai_record_server/internal/infrastructure/utils"
	"trpc.group/trpc-go/trpc-go/errs"
	"trpc.group/trpc-go/trpc-go/log"
)

type UserAuth interface {
	GenVerifyCode(ctx context.Context, scene int32, uniKey string, expire int32) (string, error)
	CheckVerifyCode(ctx context.Context, scene int32, uniKey string, code string) error

	GenUserToken(ctx context.Context, userId int64, expire int32) (string, error)

	CreatePhoneUser(ctx context.Context, phone string, state int32) (*entity.UserInfo, error)
	CreateEmailUser(ctx context.Context, email string, password string, state int32) (*entity.UserInfo, error)

	BindUserPhone(ctx context.Context, userId int64, phone string) error
	BindUserEmail(ctx context.Context, userId int64, email string) error

	VerifyUserLogin(ctx context.Context, loginMethod int32, loginIdentifier string, code string) (*entity.UserInfo, error)

	ChangePassword(ctx context.Context, userId int64, currentPassword string, newPassword string) error
	ResetPassword(ctx context.Context, loginIdentifier string, code string, password string) error
}

func NewUserAuth(repo repository.UserRepo) UserAuth {
	return &UserAuthImpl{
		repo: repo,
	}
}

type UserAuthImpl struct {
	repo repository.UserRepo
}

// GenVerifyCode 生成验证码
func (u *UserAuthImpl) GenVerifyCode(ctx context.Context, scene int32, uniKey string, expire int32) (string, error) {
	rand.Seed(time.Now().UnixNano())
	random := rand.Intn(900000) + 100000

	verifyCode := entity.VerifyCode{
		Scene:      scene,
		UniKey:     uniKey,
		ExpireTime: time.Now().Add(time.Duration(expire) * time.Second),
		Code:       strconv.Itoa(random),
		State:      entity.VerifyCodeStateUnUsed,
	}

	if err := u.repo.SaveVerifyCode(ctx, &verifyCode); err != nil {
		return "", err
	}

	return verifyCode.Code, nil
}

// CheckVerifyCode 验证码校验
func (u *UserAuthImpl) CheckVerifyCode(ctx context.Context, scene int32, uniKey string, code string) error {
	verifyCode, err := u.repo.GetVerifyCode(ctx, scene, uniKey)
	if err != nil {
		// 未查询到有效期内的验证码，按已过期返回
		if errs.Code(err) == errorcode.ErrRecordNotExisted {
			return errs.Newf(errorcode.ErrVerifyCodeInvalid, "verify code invalid.")
		}
		return err
	}

	// 判断已删除或不一致，按已过期返回
	if verifyCode.State != entity.VerifyCodeStateUnUsed || verifyCode.Code != code {
		return errs.Newf(errorcode.ErrVerifyCodeInvalid, "verify code invalid.")
	}

	// 验证通过后，标记验证码已使用(此操作失败不影响返回)
	go func() {
		if err := u.repo.UsedVerifyCode(ctx, verifyCode.Id); err != nil {
			log.Errorf("UsedVerifyCode failed. error: %+v", err)
		}
	}()

	return nil
}

// GenUserToken 生成用户token
func (u *UserAuthImpl) GenUserToken(ctx context.Context, userId int64, expire int32) (string, error) {
	// 生成用户token信息
	token := utils.GenerateUUID()
	userToken := &entity.UserToken{
		UserId:     userId,
		Token:      token,
		ExpireTime: time.Now().Add(time.Duration(expire) * time.Second),
	}

	if err := u.repo.SaveUserToken(ctx, userToken); err != nil {
		return "", err
	}
	return token, nil
}

// CreatePhoneUser 创建手机用户
func (u *UserAuthImpl) CreatePhoneUser(ctx context.Context, phone string, state int32) (*entity.UserInfo, error) {
	userInfo := &entity.UserInfo{
		NickName:       "AIRecord-" + utils.GenerateMD5Hash(phone)[:4] + phone[len(phone)-4:],
		Phone:          &phone,
		State:          state,
		CreateTime:     time.Now(),
		LastUpdateTime: time.Now(),
	}

	if err := u.repo.SaveUserInfo(ctx, userInfo); err != nil {
		return nil, err
	}

	return userInfo, nil
}

func getUsernameFromEmail(email string) string {
	parts := strings.Split(email, "@")
	if len(parts) > 0 {
		return parts[0]
	}
	return ""
}

// CreateEmailUser 创建手机用户
func (u *UserAuthImpl) CreateEmailUser(
	ctx context.Context, email string, password string, state int32,
) (*entity.UserInfo, error) {
	userInfo := &entity.UserInfo{
		NickName:       getUsernameFromEmail(email),
		Email:          &email,
		Password:       utils.GenerateSha256(password),
		State:          state,
		CreateTime:     time.Now(),
		LastUpdateTime: time.Now(),
	}

	if err := u.repo.SaveUserInfo(ctx, userInfo); err != nil {
		return nil, err
	}

	return userInfo, nil
}

// BindUserPhone 用户绑定手机号码
func (u *UserAuthImpl) BindUserPhone(ctx context.Context, userId int64, phone string) error {
	// 用户信息验证-查验&绑定手机号
	userInfo, err := u.repo.GetUserInfoByUserId(ctx, userId)
	if err != nil {
		return err
	}

	// 已绑定手机
	if userInfo.State == entity.UserStateRegisterSuccess {
		// 绑定重入判断
		if *userInfo.Phone != phone {
			return errs.Newf(errorcode.ErrParamsInvalid, "params out of range phone")
		}

		return nil
	} else if userInfo.State == entity.UserStateDeactivated {
		// 已注销用户，不支持登录
		return errs.Newf(errorcode.ErrUserDeactivated, "the user has been deactivated.")
	}

	userInfo.Phone = &phone
	userInfo.State = entity.UserStateRegisterSuccess
	userInfo.LastUpdateTime = time.Now()

	// 更新用户信息(绑定用户手机号码)
	if err := u.repo.UpdateUserInfo(ctx, userInfo); err != nil {
		return err
	}

	return nil
}

// BindUserEmail 用户绑定邮箱地址
func (u *UserAuthImpl) BindUserEmail(ctx context.Context, userId int64, email string) error {
	// 用户信息验证-查验&绑定手机号
	userInfo, err := u.repo.GetUserInfoByUserId(ctx, userId)
	if err != nil {
		return err
	}

	// 已绑定手机
	if userInfo.State == entity.UserStateRegisterSuccess {
		// 绑定重入判断
		if *userInfo.Email != email {
			return errs.Newf(errorcode.ErrParamsInvalid, "params out of range email")
		}

		return nil
	} else if userInfo.State == entity.UserStateDeactivated {
		// 已注销用户，不支持登录
		return errs.Newf(errorcode.ErrUserDeactivated, "the user has been deactivated.")
	}

	userInfo.Email = &email
	userInfo.State = entity.UserStateRegisterSuccess
	userInfo.LastUpdateTime = time.Now()

	// 更新用户信息(绑定用户手机号码)
	if err := u.repo.UpdateUserInfo(ctx, userInfo); err != nil {
		return err
	}

	return nil
}

func (u *UserAuthImpl) VerifyUserLogin(
	ctx context.Context, loginMethod int32, loginIdentifier string, code string,
) (*entity.UserInfo, error) {
	// 验证码校验
	if err := u.CheckVerifyCode(ctx, entity.VerifyCodeSceneLogin, loginIdentifier,
		code); err != nil {
		return nil, err
	}

	var userInfo *entity.UserInfo
	var err error
	if loginMethod == entity.LoginMethodPhone {
		userInfo, err = u.repo.GetUserInfoByPhone(ctx, loginIdentifier)
		if err != nil {
			return nil, err
		}
	} else {
		userInfo, err = u.repo.GetUserInfoByEmail(ctx, loginIdentifier)
		if err != nil {
			return nil, err
		}

		// 验证通过后，当前用户状态待验证码验证，更新用户状态
		if userInfo.State == entity.UserStateWaitVerifyCode {
			userInfo.Email = &loginIdentifier
			userInfo.State = entity.UserStateRegisterSuccess
			userInfo.LastUpdateTime = time.Now()

			// 更新用户信息(绑定用户手机号码)
			if err := u.repo.UpdateUserInfo(ctx, userInfo); err != nil {
				return nil, err
			}
		}
	}

	// 已注销用户，不支持登录
	if userInfo.State == entity.UserStateDeactivated {
		return nil, errs.Newf(errorcode.ErrUserDeactivated, "the user has been deactivated.")
	}

	return userInfo, nil
}

func (u *UserAuthImpl) ChangePassword(
	ctx context.Context, userId int64, currentPassword string, newPassword string,
) error {
	// 用户状态校验
	userInfo, err := u.repo.GetUserInfoByUserId(ctx, userId)
	if err != nil {
		return err
	}

	if userInfo.State == entity.UserStateDeactivated {
		return errs.Newf(errorcode.ErrUserDeactivated, "the user has been deactivated.")
	}

	if userInfo.Password != utils.GenerateSha256(currentPassword) {
		return errs.Newf(errorcode.ErrInvalidPassword, "current password is incorrect")
	}

	if err := u.repo.UpdateUserPassword(ctx, userInfo.UserId, utils.GenerateSha256(newPassword)); err != nil {
		return err
	}

	return nil
}

func (u *UserAuthImpl) ResetPassword(
	ctx context.Context, loginIdentifier string, code string, password string,
) error {
	// 验证码校验
	if err := u.CheckVerifyCode(ctx, entity.VerifyCodeSceneResetPassword, loginIdentifier,
		code); err != nil {
		return err
	}

	// 用户状态校验
	userInfo, err := u.repo.GetUserInfoByEmail(ctx, loginIdentifier)
	if err != nil {
		return err
	}

	if userInfo.State == entity.UserStateDeactivated {
		return errs.Newf(errorcode.ErrUserDeactivated, "the user has been deactivated.")
	}

	if err := u.repo.UpdateUserPassword(ctx, userInfo.UserId, utils.GenerateSha256(password)); err != nil {
		return err
	}

	return nil
}
