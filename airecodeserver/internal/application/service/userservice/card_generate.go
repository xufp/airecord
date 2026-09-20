package userservice

import (
	"context"
	"time"

	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"github.com/smartox/ai_record_server/internal/infrastructure/utils"
	"trpc.group/trpc-go/trpc-go/errs"
	"trpc.group/trpc-go/trpc-go/log"
)

func NewCardGenerate(repo repository.AiRecordRepo, userId int64) *CardGenerate {
	return &CardGenerate{
		repo:   repo,
		userId: userId,
	}
}

type CardGenerate struct {
	repo   repository.AiRecordRepo
	userId int64
}

func (c *CardGenerate) CardGenerate(ctx context.Context, req *protocol.CardGenerateReq) (
	*protocol.CardGenerateRsp, error,
) {
	// 用户权限查询, 非管理员用户不允许生成激活码
	if _, err := c.repo.ServiceRepo().GetMembership(ctx, c.userId, entity.MembershipLevelAdmin); err != nil {
		return nil, err
	}

	var activateCard *utils.ActivateCard
	if len(req.CardNo) != 0 {
		card, err := c.repo.ServiceRepo().GetActivationCard(ctx, req.CardNo)
		if err != nil {
			if errs.Code(err) != errorcode.ErrRecordNotExisted {
				return nil, err
			}

			// 卡号不存在，直接生成
			activateCard = &utils.ActivateCard{
				CardNo:  req.CardNo,
				CardPwd: utils.GetRandomString(6),
			}
		} else {
			activateCard = &utils.ActivateCard{
				CardNo:  card.CardNo,
				CardPwd: card.CardPwd,
			}

			return &protocol.CardGenerateRsp{
				CardCode: activateCard.Encode(),
				State:    card.CardState,
			}, nil
		}
	} else {
		activateCard = utils.NewActivateCard().Generate()
	}

	if req.PackageId == 0 {
		req.PackageId = 90010003 // 激活卡默认套餐
	} else {
		// 检查套餐是否存在
		pkg, err := c.repo.ServiceRepo().GetPackage(ctx, req.PackageId)
		if err != nil {
			return nil, err
		}

		// 检查套餐是否有效
		if pkg.PackageType != entity.PackageTypeActivationCard {
			return nil, errs.Newf(errorcode.ErrPackageNotSupport, "套餐不支持当前服务")
		}
	}

	if req.CardExpireTime == "" {
		req.CardExpireTime = time.Now().AddDate(1, 0, 0).Format(time.DateTime)
	}

	expireTime, err := time.ParseInLocation(time.DateTime, req.CardExpireTime, time.Local)
	if err != nil {
		return nil, err
	}

	// 生成卡号&密码
	card := &entity.ActivationCard{
		CardNo:         activateCard.CardNo,
		CardPwd:        activateCard.CardPwd,
		CardState:      entity.ActivationCardStateDeactivated,
		CardOrderId:    "free generate",
		CardExpireTime: expireTime,
		PackageId:      req.PackageId, // 激活卡套餐
		CreateTime:     time.Now(),
		LastUpdateTime: time.Now(),
	}

	if err := c.repo.ServiceRepo().SaveActivationCard(ctx, card); err != nil {
		return nil, err
	}

	log.WarnContextf(ctx, "Card Generate Success. activate card: %+v", activateCard)

	return &protocol.CardGenerateRsp{
		CardCode: activateCard.Encode(),
		State:    card.CardState,
	}, nil
}
