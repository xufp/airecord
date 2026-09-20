package service

import (
	"context"
	"time"

	"github.com/smartox/ai_record_server/internal/admin/protocol"
	appprotocol "github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/application/service/userservice"
	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"github.com/smartox/ai_record_server/internal/infrastructure/utils"
	"trpc.group/trpc-go/trpc-go/errs"
)

type CardService struct {
	repo   repository.AiRecordRepo
	userId int64
}

func NewCardService(repo repository.AiRecordRepo, userId int64) *CardService {
	return &CardService{
		repo:   repo,
		userId: userId,
	}
}

// CardList 获取卡列表
func (s *CardService) CardList(ctx context.Context, req *protocol.CardListRequest) (*protocol.CardListResponse, error) {
	var cardList []*entity.ActivationCard
	var err error
	if req.CardCode != "" {
		// 激活码解码
		activateCard := utils.NewActivateCard()
		if err := activateCard.Decode(req.CardCode); err != nil {
			return nil, err
		}

		// 卡列表查询
		card, err := s.repo.ServiceRepo().GetActivationCard(ctx, activateCard.CardNo)
		if err != nil {
			if errs.Code(err) != errorcode.ErrRecordNotExisted {
				return nil, err
			}
		} else {
			if card.CardPwd == activateCard.CardPwd {
				cardList = append(cardList, card)
			}
		}
	} else {
		// 卡列表查询
		cardList, err = s.repo.ServiceRepo().FindActivationCard(ctx)
		if err != nil {
			return nil, err
		}
	}

	// 卡列表转换
	cardListResp := make([]protocol.CardInfo, 0)
	for _, card := range cardList {
		// 卡状态过滤
		if req.CardState != 0 && req.CardState != card.CardState {
			continue
		}

		cardInfo := protocol.CardInfo{
			CardCode:         (&utils.ActivateCard{CardNo: card.CardNo, CardPwd: card.CardPwd}).Encode(),
			CardExpireTime:   card.CardExpireTime.Format(time.DateTime),
			CardState:        card.CardState,
			ActivationUserId: card.ActivationUserId,
			CardOrderId:      card.CardOrderId,
			PackageId:        card.PackageId,
			CreateTime:       card.CreateTime.Format(time.DateTime),
			LastUpdateTime:   card.LastUpdateTime.Format(time.DateTime),
		}

		if card.ActivationTime != nil {
			cardInfo.ActivationTime = card.ActivationTime.Format(time.DateTime)
		}

		cardListResp = append(cardListResp, cardInfo)
	}

	return &protocol.CardListResponse{
		Total: int64(len(cardListResp)),
		List:  cardListResp,
	}, nil
}

// CardAdd 新增卡
func (s *CardService) CardAdd(ctx context.Context, req *protocol.CardAddRequest) (*protocol.CardAddResponse, error) {
	appReq := &appprotocol.CardGenerateReq{
		PackageId:      req.PackageID,
		CardExpireTime: req.CardExpireTime,
	}

	appRsp, err := userservice.NewCardGenerate(s.repo, s.userId).CardGenerate(ctx, appReq)
	if err != nil {
		return nil, err
	}

	return &protocol.CardAddResponse{
		Msg:      "新增成功",
		CardCode: appRsp.CardCode,
	}, nil
}

// CardVoid 作废卡
func (s *CardService) CardVoid(ctx context.Context, req *protocol.CardVoidRequest) (*protocol.CardVoidResponse, error) {
	activateCard := utils.NewActivateCard()
	if err := activateCard.Decode(req.CardCode); err != nil {
		return nil, err
	}

	err := s.repo.ServiceRepo().DeleteActivationCard(ctx, activateCard.CardNo)
	if err != nil {
		return nil, err
	}

	return &protocol.CardVoidResponse{
		Msg: "作废成功",
	}, nil
}
