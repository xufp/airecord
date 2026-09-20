package orderservice

import (
	"context"
	"time"

	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"trpc.group/trpc-go/trpc-go/errs"
)

func NewOrderDetail(repo repository.ServiceRepo, userId int64) *OrderDetail {
	return &OrderDetail{
		repo:   repo,
		userId: userId,
	}
}

type OrderDetail struct {
	repo   repository.ServiceRepo
	userId int64
}

func (s *OrderDetail) OrderDetail(ctx context.Context, req *protocol.OrderDetailReq) (
	*protocol.OrderDetailRsp, error,
) {
	order, err := s.repo.GetOrder(ctx, req.OrderId)
	if err != nil {
		return nil, err
	}

	if order.UserId != s.userId {
		return nil, errs.Newf(errorcode.ErrRecordNotExisted, "order not found")
	}

	rsp := protocol.OrderDetailRsp{}
	rsp.OrderId = order.OrderId
	rsp.Amount = order.Amount
	rsp.Currency = order.Currency
	rsp.PayChannel = order.PayChannel
	rsp.PackageName = order.PackageName
	rsp.State = order.State
	if order.PayTime != nil {
		rsp.PayTime = order.PayTime.Format(time.DateTime)
	}

	return &rsp, nil
}
