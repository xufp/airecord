package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/smartox/ai_record_server/internal/admin/protocol"
	"github.com/smartox/ai_record_server/internal/admin/service"
	"github.com/smartox/ai_record_server/internal/domain/repository"
)

type ConfigHandler struct {
	transMgr repository.RepoTransMgr
}

func NewConfigHandler(transMgr repository.RepoTransMgr) *ConfigHandler {
	return &ConfigHandler{
		transMgr: transMgr,
	}
}

// ConfigList 获取配置列表
func (h *ConfigHandler) ConfigList(c *gin.Context) {
	var req protocol.ConfigListRequest
	if err := c.ShouldBindQuery(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	resp, err := service.NewConfigService(h.transMgr.GetRepository()).ConfigList(c.Request.Context(), &req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, resp)
}

// ConfigAdd 新增配置
func (h *ConfigHandler) ConfigAdd(c *gin.Context) {
	var req protocol.ConfigAddRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	resp, err := service.NewConfigService(h.transMgr.GetRepository()).ConfigAdd(c.Request.Context(), &req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, resp)
}

// ConfigUpdate 修改配置
func (h *ConfigHandler) ConfigUpdate(c *gin.Context) {
	var req protocol.ConfigUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	resp, err := service.NewConfigService(h.transMgr.GetRepository()).ConfigUpdate(c.Request.Context(), &req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, resp)
}

// ConfigDelete 删除配置
func (h *ConfigHandler) ConfigDelete(c *gin.Context) {
	var req protocol.ConfigDeleteRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	resp, err := service.NewConfigService(h.transMgr.GetRepository()).ConfigDelete(c.Request.Context(), &req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, resp)
}
