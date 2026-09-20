package constservice

import (
	"encoding/json"

	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	"golang.org/x/net/context"
)

func NewBleDeviceList(repo repository.UserRepo) *BleDeviceList {
	return &BleDeviceList{
		repo: repo,
	}
}

type BleDeviceList struct {
	repo repository.UserRepo
}

func (u *BleDeviceList) BleDeviceList(ctx context.Context, req *protocol.BleDeviceListReq) (
	*protocol.BleDeviceListRsp, error,
) {
	// 查询全部蓝牙设备信息
	devices, err := u.repo.FindAppConfig(ctx, []int32{entity.AppConfigTypeBleDevice})
	if err != nil {
		return nil, err
	}

	rsp := &protocol.BleDeviceListRsp{}
	for _, device := range devices {
		var d protocol.BleDevice
		if err := json.Unmarshal([]byte(device.ConfigValue), &d); err != nil {
			return nil, err
		}
		rsp.Data = append(rsp.Data, d)
	}

	return rsp, nil
}
