package service

import (
	"context"
	"strings"
	"time"

	"github.com/smartox/ai_record_server/internal/admin/protocol"
	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/domain/repository"
)

type ConfigService struct {
	repo repository.AiRecordRepo
}

func NewConfigService(repo repository.AiRecordRepo) *ConfigService {
	return &ConfigService{
		repo: repo,
	}
}

// ConfigList 获取配置列表
func (s *ConfigService) ConfigList(ctx context.Context, req *protocol.ConfigListRequest) (
	*protocol.ConfigListResponse, error,
) {
	var configTypeList []int32
	if req.ConfigType != 0 {
		configTypeList = append(configTypeList, req.ConfigType)
	} else {
		configTypeList = append(configTypeList, 1, 2, 3, 4, 5, 6, 7, 8)
	}

	configs, err := s.repo.UserRepo().FindAppConfig(ctx, configTypeList)
	if err != nil {
		return nil, err
	}

	// 转换为协议层类型
	respConfigs := make([]protocol.ConfigInfo, 0)
	for _, config := range configs {
		if req.Keyword != "" && !(strings.Contains(config.ConfigKey, req.Keyword) ||
			strings.Contains(config.ConfigDesc, req.Keyword)) {
			continue
		}

		respConfigs = append(respConfigs, protocol.ConfigInfo{
			Id:             config.Id,
			ConfigType:     config.ConfigType,
			ConfigKey:      config.ConfigKey,
			ConfigValue:    config.ConfigValue,
			ConfigDesc:     config.ConfigDesc,
			CreatedTime:    config.CreateTime.Format(time.DateTime),
			LastUpdateTime: config.LastUpdateTime.Format(time.DateTime),
		})
	}

	return &protocol.ConfigListResponse{
		Total: int64(len(respConfigs)),
		List:  respConfigs,
	}, nil
}

// GetConfigName 获取配置名称
func GetConfigName(configType int32) string {
	switch configType {
	case entity.AppConfigTypeAppProtocol:
		return "应用协议"
	case entity.AppConfigTypeHelpManual:
		return "帮助手册"
	case entity.AppConfigTypeIosAppVersion:
		return "IOS应用版本信息"
	case entity.AppConfigTypeAndroidAppVersion:
		return "Android应用版本信息"
	case entity.AppConfigTypeAsrEngineModel:
		return "Asr引擎模型"
	case entity.AppConfigTypePromptTemplate:
		return "Prompt模板"
	case entity.AppConfigTypeBleDevice:
		return "蓝牙设备"
	default:
	}
	return ""
}

// ConfigAdd 新增配置
func (s *ConfigService) ConfigAdd(ctx context.Context, req *protocol.ConfigAddRequest) (
	*protocol.ConfigAddResponse, error,
) {
	// 新增配置
	config := &entity.AppConfig{
		ConfigType:     req.ConfigType,
		ConfigKey:      req.ConfigKey,
		ConfigValue:    req.ConfigValue,
		ConfigDesc:     req.ConfigDesc,
		ConfigName:     GetConfigName(req.ConfigType),
		Lstate:         entity.AppConfigLstateActive,
		CreateTime:     time.Now(),
		LastUpdateTime: time.Now(),
	}

	if err := s.repo.UserRepo().SaveAppConfig(ctx, config); err != nil {
		return nil, err
	}

	return &protocol.ConfigAddResponse{
		Msg: "新增成功",
	}, nil
}

// ConfigUpdate 修改配置
func (s *ConfigService) ConfigUpdate(
	ctx context.Context, req *protocol.ConfigUpdateRequest,
) (*protocol.ConfigUpdateResponse, error) {
	// 更新配置
	config := &entity.AppConfig{
		Id:             req.Id,
		ConfigType:     req.ConfigType,
		ConfigKey:      req.ConfigKey,
		ConfigValue:    req.ConfigValue,
		ConfigDesc:     req.ConfigDesc,
		ConfigName:     GetConfigName(req.ConfigType),
		LastUpdateTime: time.Now(),
	}

	if err := s.repo.UserRepo().UpdateAppConfig(ctx, config); err != nil {
		return nil, err
	}

	return &protocol.ConfigUpdateResponse{
		Msg: "修改成功",
	}, nil
}

// ConfigDelete 删除配置
func (s *ConfigService) ConfigDelete(
	ctx context.Context, req *protocol.ConfigDeleteRequest,
) (*protocol.ConfigDeleteResponse, error) {
	// 删除配置
	if err := s.repo.UserRepo().DeleteAppConfig(ctx, req.Id); err != nil {
		return nil, err
	}

	return &protocol.ConfigDeleteResponse{
		Msg: "删除成功",
	}, nil
}
