package handler

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/smartox/ai_record_server/internal/admin/protocol"
	"github.com/smartox/ai_record_server/internal/admin/service"
	"github.com/smartox/ai_record_server/internal/domain/repository"
)

type PackageHandler struct {
	transMgr repository.RepoTransMgr
}

func NewPackageHandler(transMgr repository.RepoTransMgr) *PackageHandler {
	return &PackageHandler{
		transMgr: transMgr,
	}
}

// PackageList 获取套餐列表
func (h *PackageHandler) PackageList(c *gin.Context) {
	var req protocol.PackageListRequest
	if err := c.ShouldBindQuery(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	resp, err := service.NewPackageService(h.transMgr.GetRepository().ServiceRepo(), GetUserId(c)).PackageList(c.Request.Context(), &req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, resp)
}

// PackageDetail 获取套餐详情
func (h *PackageHandler) PackageDetail(c *gin.Context) {
	packageIdStr := c.Param("id")
	packageId, err := strconv.ParseInt(packageIdStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的套餐ID"})
		return
	}

	resp, err := service.NewPackageService(h.transMgr.GetRepository().ServiceRepo(), GetUserId(c)).PackageDetail(c.Request.Context(), int32(packageId))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, resp)
}

// PackageServices 获取套餐服务列表
func (h *PackageHandler) PackageServices(c *gin.Context) {
	packageIdStr := c.Param("id")
	packageId, err := strconv.ParseInt(packageIdStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的套餐ID"})
		return
	}

	resp, err := service.NewPackageService(h.transMgr.GetRepository().ServiceRepo(), GetUserId(c)).PackageServices(c.Request.Context(), int32(packageId))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, resp)
}
