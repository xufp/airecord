package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/smartox/ai_record_server/internal/admin/protocol"
	"github.com/smartox/ai_record_server/internal/admin/service"
	"github.com/smartox/ai_record_server/internal/domain/repository"
)

type UserHandler struct {
	transMgr repository.RepoTransMgr
}

func NewUserHandler(transMgr repository.RepoTransMgr) *UserHandler {
	return &UserHandler{
		transMgr: transMgr,
	}
}

// UserList 获取用户列表
func (h *UserHandler) UserList(c *gin.Context) {
	var req protocol.UserListRequest
	if err := c.ShouldBindQuery(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	resp, err := service.NewUserService(h.transMgr.GetRepository()).UserList(c.Request.Context(), &req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, resp)
}

// UserCancel 注销用户
func (h *UserHandler) UserCancel(c *gin.Context) {
	var req protocol.UserCancelRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	resp, err := service.NewUserService(h.transMgr.GetRepository()).UserCancel(c.Request.Context(), &req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, resp)
}
