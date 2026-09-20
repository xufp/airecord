package orderservice

import (
	"context"
	"time"

	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"trpc.group/trpc-go/trpc-go/errs"
	"trpc.group/trpc-go/trpc-go/log"
)

func NewOrderList(repo repository.ServiceRepo, userId int64) *OrderList {
	return &OrderList{
		repo:   repo,
		userId: userId,
	}
}

type OrderList struct {
	repo   repository.ServiceRepo
	userId int64
}

func (s *OrderList) OrderList(ctx context.Context, req *protocol.OrderListReq) (
	*protocol.OrderListRsp, error,
) {
	// 参数校验
	for _, state := range req.States {
		if state < entity.OrderStatePending || state > entity.OrderStateCompleted {
			return nil, errs.Newf(errorcode.ErrParamsInvalid, "params out of range [1,4] state: %d", state)
		}
	}

	// 可选参数处理
	states := req.States
	log.InfoContextf(ctx, "OrderList req states: %v", states)
	if len(states) == 0 {
		states = []int32{
			entity.OrderStatePending,
			entity.OrderStateSuccess,
			entity.OrderStateFailed,
			entity.OrderStateCompleted,
		}
	}

	// 查询订单总数量
	count, err := s.repo.GetOrderCount(ctx, s.userId, states)
	if err != nil {
		return nil, err
	}

	if int64(req.Size*(req.Page-1)) > *count {
		return nil, errs.Newf(errorcode.ErrParamsInvalid, "params out of range page=%d", req.Page)
	}

	// 查询分页订单列表
	orderList, err := s.repo.FindOrderList(ctx, s.userId, req.Size*(req.Page-1), req.Size, states)
	if err != nil {
		return nil, err
	}

	// 构造返回消息
	rsp := protocol.OrderListRsp{
		Page:  req.Page,
		Size:  req.Size,
		Total: int32(*count),
	}

	for _, order := range orderList {
		detail := protocol.OrderDetail{
			OrderId:     order.OrderId,
			Amount:      order.Amount,
			Currency:    order.Currency,
			PayChannel:  order.PayChannel,
			PackageName: order.PackageName,
			State:       order.State,
			PayTime:     "",
		}

		if order.PayTime != nil {
			detail.PayTime = order.PayTime.Format(time.DateTime)
		}

		rsp.Data = append(rsp.Data, detail)
	}

	return &rsp, nil
}
