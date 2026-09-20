package service

import (
	"context"
	"fmt"
	"time"

	"github.com/smartox/ai_record_server/internal/admin/protocol"
	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/domain/repository"
)

type UserService struct {
	repo repository.AiRecordRepo
}

func NewUserService(repo repository.AiRecordRepo) *UserService {
	return &UserService{
		repo: repo,
	}
}

// UserList 获取用户列表
func (s *UserService) UserList(ctx context.Context, req *protocol.UserListRequest) (*protocol.UserListResponse, error) {
	// 获取用户列表
	users, err := s.repo.UserRepo().GetUserList(ctx, req.UserId, req.Keyword, req.State)
	if err != nil {
		return nil, err
	}

	if len(users) == 0 {
		return &protocol.UserListResponse{
			Total: 0,
			List:  []protocol.UserInfo{},
		}, nil
	}

	// 提取用户ID列表
	userIds := make([]int64, 0, len(users))
	for _, user := range users {
		userIds = append(userIds, user.UserId)
	}

	// 批量获取会员信息
	memberships, err := s.repo.ServiceRepo().GetMembershipsByUserIds(ctx, userIds)
	if err != nil {
		// 如果批量获取失败，记录错误但不影响主流程
		memberships = make(map[int64]*entity.Membership)
	}

	// 批量获取最新token信息
	tokens, err := s.repo.UserRepo().GetLatestTokensByUserIds(ctx, userIds)
	if err != nil {
		// 如果批量获取失败，记录错误但不影响主流程
		tokens = make(map[int64]*entity.UserToken)
	}

	var userList []protocol.UserInfo
	for _, user := range users {
		// 获取会员信息
		membership, exists := memberships[user.UserId]
		if !exists {
			// 如果没有会员信息，使用默认值
			membership = &entity.Membership{
				Level:      0,
				ExpireTime: time.Time{},
			}
		}

		// 获取最后登录时间（从token表获取）
		lastLoginTime := ""
		if token, exists := tokens[user.UserId]; exists && token != nil {
			lastLoginTime = token.CreateTime.Format(time.DateTime)
		}

		// 处理可能为nil的字段
		email := ""
		if user.Email != nil {
			email = *user.Email
		}
		phone := ""
		if user.Phone != nil {
			phone = *user.Phone
		}

		userInfo := protocol.UserInfo{
			UserId:               user.UserId,
			NickName:             user.NickName,
			Email:                email,
			Phone:                phone,
			State:                user.State,
			CreateTime:           user.CreateTime.Format(time.DateTime),
			LastLoginTime:        lastLoginTime,
			MembershipLevel:      membership.Level,
			MembershipExpireTime: membership.ExpireTime.Format(time.DateTime),
		}

		userList = append(userList, userInfo)
	}

	return &protocol.UserListResponse{
		Total: int64(len(userList)),
		List:  userList,
	}, nil
}

// UserCancel 注销用户
func (s *UserService) UserCancel(ctx context.Context, req *protocol.UserCancelRequest) (
	*protocol.UserCancelResponse, error,
) {
	// 获取用户信息
	user, err := s.repo.UserRepo().GetUserInfoByUserId(ctx, req.UserId)
	if err != nil {
		return nil, err
	}

	// 检查用户状态
	if user.State == entity.UserStateDeactivated {
		return &protocol.UserCancelResponse{
			Msg: "用户已经注销",
		}, nil
	}
	// 检查用户状态, 只有正常状态的用户才能注销
	if user.State != entity.UserStateRegisterSuccess {
		return &protocol.UserCancelResponse{
			Msg: "用户状态异常, 无法注销",
		}, nil
	}

	// 更新用户状态为已注销, 邮箱地址变更为email+userid，支持同一个邮箱用户重新注册
	if user.Email != nil {
		email := fmt.Sprintf("%s-%d", *user.Email, user.UserId)
		user.Email = &email
	}
	user.State = entity.UserStateDeactivated
	if err := s.repo.UserRepo().UpdateUserInfo(ctx, user); err != nil {
		return nil, err
	}

	return &protocol.UserCancelResponse{
		Msg: "用户注销成功",
	}, nil
}
