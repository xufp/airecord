package userservice

import (
	"context"
	"time"

	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	domainservice "github.com/smartox/ai_record_server/internal/domain/service"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"trpc.group/trpc-go/trpc-go/errs"
)

func NewUserInfo(repo repository.AiRecordRepo, userId int64) *UserInfo {
	return &UserInfo{
		repo:   repo,
		userId: userId,
		state:  0,
	}
}

type UserInfo struct {
	repo   repository.AiRecordRepo
	userId int64
	state  int32
}

func (u *UserInfo) UserInfo(ctx context.Context) (
	*protocol.UserInfoRsp, error,
) {
	// 用户信息查询
	userInfo, err := u.repo.UserRepo().GetUserInfoByUserId(ctx, u.userId)
	if err != nil {
		return nil, errs.Newf(errorcode.ErrUserAuthInvalid, "user auth invalid.")
	}

	// 会员信息查询
	membership, err := domainservice.NewUserService(u.repo.ServiceRepo(), u.userId).GetMembership(ctx)
	if err != nil {
		return nil, err
	}

	// 打包返回信息
	return &protocol.UserInfoRsp{
		NickName:             userInfo.NickName,
		Sex:                  userInfo.Sex,
		Province:             userInfo.Province,
		City:                 userInfo.City,
		Country:              userInfo.Country,
		HeadImgUrl:           userInfo.HeadImgUrl,
		MembershipLevel:      membership.Level,
		MembershipExpireTime: membership.ExpireTime.Format(time.DateTime),
	}, nil
}
