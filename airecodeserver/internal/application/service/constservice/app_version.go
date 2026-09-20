package constservice

import (
	"context"
	"strings"
	"time"

	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/domain/entity"
	"github.com/smartox/ai_record_server/internal/domain/repository"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"trpc.group/trpc-go/trpc-go/errs"
)

func NewAppVersion(transMgr repository.RepoTransMgr) *AppVersion {
	return &AppVersion{
		transMgr: transMgr,
	}
}

type AppVersion struct {
	transMgr repository.RepoTransMgr
}

func (u *AppVersion) AppVersion(ctx context.Context, req *protocol.AppVersionReq) (
	*protocol.AppVersionRsp, error,
) {
	cfgType := int32(0)
	if req.Platform == "ios" {
		cfgType = entity.AppConfigTypeIosAppVersion
	} else if req.Platform == "android" {
		cfgType = entity.AppConfigTypeAndroidAppVersion
	} else {
		return nil, errs.Newf(errorcode.ErrParamsInvalid, "params out of range platform = %v", req.Platform)
	}

	// 查询版本信息
	versions, err := u.transMgr.GetRepository().UserRepo().FindAppConfig(ctx, []int32{cfgType})
	if err != nil {
		return nil, err
	}

	if len(versions) == 0 {
		return nil, errs.Newf(errorcode.ErrRecordNotExisted, "no version found")
	}

	// 获取最新版本
	version := u.latestVersion(versions)

	rsp := &protocol.AppVersionRsp{
		Platform:    req.Platform,
		ForceUpdate: false,
	}

	if len(req.CurrentVersion) == 0 {
		// 没有指定版本号，返回最新版本
		rsp.LatestVersion = version.ConfigKey
		rsp.DownloadUrl = version.ConfigValue
		rsp.ReleaseNotes = version.ConfigDesc
		rsp.UpdateTime = version.LastUpdateTime.Format(time.DateTime)
	} else {
		if req.CurrentVersion < version.ConfigKey {
			rsp.LatestVersion = version.ConfigKey
			rsp.DownloadUrl = version.ConfigValue
			rsp.ReleaseNotes = version.ConfigDesc
			rsp.UpdateTime = version.LastUpdateTime.Format(time.DateTime)

			// 检查当前版本是否需求强制更新
			if _, err := u.transMgr.GetRepository().UserRepo().GetAppConfig(ctx, cfgType,
				req.CurrentVersion); err != nil && errs.Code(err) == errorcode.ErrRecordNotExisted {
				rsp.ForceUpdate = true
			}
		} else {
			rsp.LatestVersion = req.CurrentVersion
		}
	}

	return rsp, nil
}

func (u *AppVersion) latestVersion(versions []*entity.AppConfig) *entity.AppConfig {
	if len(versions) == 0 {
		return nil
	}

	latest := versions[0]
	for _, version := range versions[1:] {
		if strings.Compare(version.ConfigKey, latest.ConfigKey) > 0 {
			latest = version
		}
	}

	return latest
}
