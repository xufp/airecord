package otherservice

import (
	"context"
	"fmt"
	"io"
	"mime/multipart"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/smartox/ai_record_server/internal/application/protocol"
	"github.com/smartox/ai_record_server/internal/infrastructure/config"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"trpc.group/trpc-go/trpc-go/errs"
	"trpc.group/trpc-go/trpc-go/log"
)

func NewRecordingUpload() *RecordingUpload {
	return &RecordingUpload{}
}

type RecordingUpload struct {
	deviceInfo protocol.DeviceInfo
}

func (m *RecordingUpload) RecordingUpload(ctx context.Context, req *protocol.RecordingUploadReq) (
	*protocol.RecordingUploadRsp, error,
) {
	// 解析请求参数
	if err := m.parseRequestParams(ctx, req); err != nil {
		return nil, err
	}

	return &protocol.RecordingUploadRsp{
		Code:     0,
		Codename: "success",
		Data:     m.deviceInfo,
		IsError:  false,
	}, nil
}

func (m *RecordingUpload) parseRequestParams(ctx context.Context, req *protocol.RecordingUploadReq) error {
	// 限制上传文件的大小（这里限制为10MB）
	if err := req.Req.ParseMultipartForm(10 << 20); err != nil {
		return err
	}

	// 获取文件元信息
	m.deviceInfo = protocol.DeviceInfo{
		Source:          req.Req.FormValue("source"),
		Sn:              req.Req.FormValue("sn"),
		Status:          req.Req.FormValue("status"),
		BatteryLevel:    req.Req.FormValue("batteryLevel"),
		TotalDiskSpace:  req.Req.FormValue("totalDiskSpace"),
		RemainDiskSpace: req.Req.FormValue("remainDiskSpace"),
		NetworkSpeed:    req.Req.FormValue("networkSpeed"),
		CreateTime:      req.Req.FormValue("create_time"),
		Duration:        req.Req.FormValue("duration"),
		FileName:        req.Req.FormValue("file_name"),
	}
	log.InfoContextf(ctx, "body: [%+v]", m.deviceInfo)

	// 获取上传的文件
	file, handler, err := req.Req.FormFile("record_file")
	if err != nil {
		log.ErrorContextf(ctx, "got formFile err %s", err.Error())
		return errs.Newf(errorcode.ErrParamsInvalid, "error retrieving the file")
	}
	defer func(file multipart.File) {
		err := file.Close()
		if err != nil {
			log.ErrorContextf(ctx, "formFile close err %s", err.Error())
		}
	}(file)

	log.InfoContextf(ctx, "upload file name: %s", handler.Filename)

	// Generate a unique filename
	ext := filepath.Ext(handler.Filename)
	name := strings.TrimSuffix(handler.Filename, ext)
	newFileName := fmt.Sprintf("%s_%s%s", name, time.Now().Format("20060102150405"), ext)
	log.InfoContextf(ctx, "upload file name new: %s", newFileName)

	// 创建上传文件的目录
	dirPath := filepath.Join(config.GetServerConfig().Media.Storage.Path, "recording_tmp")
	if err := os.MkdirAll(dirPath, 0755); err != nil {
		fmt.Printf("Failed to create upload directory: %v\n", err)
		return err
	}
	// 创建保存文件的路径
	filePath := filepath.Join(dirPath, newFileName)

	// 创建目标文件
	dst, err := os.Create(filePath)
	if err != nil {
		return errs.Newf(errorcode.ErrParamsInvalid, "error saving the file")
	}
	defer func(dst *os.File) {
		err := dst.Close()
		if err != nil {
			log.ErrorContextf(ctx, "saveFile close err %s", err.Error())
		}
	}(dst)

	// 将上传的文件内容复制到目标文件
	if _, err := io.Copy(dst, file); err != nil {
		return errs.Newf(errorcode.ErrParamsInvalid, "error writing the file")
	}

	return nil
}
