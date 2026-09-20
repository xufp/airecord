package entity

import (
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"github.com/smartox/ai_record_server/internal/infrastructure/utils"
	"trpc.group/trpc-go/trpc-go/errs"
)

// ServiceUsage 服务使用情况
type ServiceUsage struct {
	ServiceType int32 `json:"service_type"` // 服务类型
	Used        int64 `json:"used"`         // 已用量
	Total       int64 `json:"total"`        // 总量
}

// CheckBalance 检查服务可用余额是否充足
func (u *ServiceUsage) CheckBalance(quantity int64) error {
	switch u.ServiceType {
	case ServiceTypeConvert:
		if u.Total-u.Used < utils.OccupiedTime(quantity, utils.BlockMillisecond) {
			return errs.Newf(errorcode.ErrBalanceInsufficient, "insufficient user convert times")
		}
	}

	return nil
}
