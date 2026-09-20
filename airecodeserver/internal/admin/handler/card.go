package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/smartox/ai_record_server/internal/admin/protocol"
	"github.com/smartox/ai_record_server/internal/admin/service"
	"github.com/smartox/ai_record_server/internal/domain/repository"
)

type CardHandler struct {
	transMgr repository.RepoTransMgr
}

func NewCardHandler(transMgr repository.RepoTransMgr) *CardHandler {
	return &CardHandler{
		transMgr: transMgr,
	}
}

// CardList 获取卡列表
func (h *CardHandler) CardList(c *gin.Context) {
	var req protocol.CardListRequest
	if err := c.ShouldBindQuery(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	resp, err := service.NewCardService(h.transMgr.GetRepository(), GetUserId(c)).CardList(c.Request.Context(), &req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, resp)
}

// CardAdd 新增卡
func (h *CardHandler) CardAdd(c *gin.Context) {
	var req protocol.CardAddRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	resp, err := service.NewCardService(h.transMgr.GetRepository(), GetUserId(c)).CardAdd(c.Request.Context(), &req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, resp)
}

// CardVoid 作废卡
func (h *CardHandler) CardVoid(c *gin.Context) {
	var req protocol.CardVoidRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	resp, err := service.NewCardService(h.transMgr.GetRepository(), GetUserId(c)).CardVoid(c.Request.Context(), &req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, resp)
}
