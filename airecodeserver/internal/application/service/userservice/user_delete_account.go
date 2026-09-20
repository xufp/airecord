package userservice

import (
	"context"
	"fmt"

	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"trpc.group/trpc-go/trpc-go/errs"
	"trpc.group/trpc-go/trpc-go/log"
)

func NewDeleteAccount(transMgr repository.RepoTransMgr, userId int64) *DeleteAccount {
	return &DeleteAccount{
		transMgr: transMgr,
		userId:   userId,
	}
}

type DeleteAccount struct {
	transMgr repository.RepoTransMgr
	userId   int64
}

func (d *DeleteAccount) DeleteAccount(ctx context.Context) (*protocol.DeleteAccountRsp, error) {
	if err := d.transMgr.DoTransaction(ctx, func(ctx context.Context, repo repository.AiRecordRepo) error {
		// 锁定用户记录
		userInfo, err := repo.UserRepo().LockUserInfo(ctx, d.userId)
		if err != nil {
			return err
		}

		// 校验用户状态
		if userInfo.State != entity.UserStateRegisterSuccess {
			return errs.Newf(errorcode.ErrUserAuthInvalid, "user state invalid, cannot delete account.")
		}

		// 更新用户状态为已注销, 邮箱地址变更为email+userid，支持同一个邮箱用户重新注册
		if userInfo.Email != nil {
			email := fmt.Sprintf("%s-%d", *userInfo.Email, userInfo.UserId)
			userInfo.Email = &email
		}
		userInfo.State = entity.UserStateDeactivated
		if err := repo.UserRepo().UpdateUserInfo(ctx, userInfo); err != nil {
			return err
		}

		// 使用户所有Token立即过期
		if err := repo.UserRepo().ExpireUserTokens(ctx, d.userId); err != nil {
			return err
		}

		log.InfoContextf(ctx, "user %d account deleted successfully", d.userId)
		return nil
	}); err != nil {
		return nil, err
	}

	return &protocol.DeleteAccountRsp{}, nil
}
