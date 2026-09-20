package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/smartox/ai_record_server/internal/admin/protocol"
	"github.com/smartox/ai_record_server/internal/admin/service"
	"github.com/smartox/ai_record_server/internal/application/service/authservice"
	"github.com/smartox/ai_record_server/internal/domain/repository"
)

type AuthHandler struct {
	transMgr repository.RepoTransMgr
}

func NewAuthHandler(transMgr repository.RepoTransMgr) *AuthHandler {
	return &AuthHandler{transMgr: transMgr}
}

func (h *AuthHandler) Authorization(ctx *gin.Context) (int64, error) {
	// Authorization认证
	userId, err := authservice.NewAuthCheck(h.transMgr).Authorization(ctx.Request.Context(), ctx.Request, true)
	if err != nil {
		return 0, err
	}
	return userId, nil
}

func (h *AuthHandler) Login(c *gin.Context) {
	// 登录逻辑
	var req protocol.LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"msg": "参数错误"})
		return
	}

	// 登录验证
	authLogin := service.NewAuthLogin(h.transMgr.GetRepository())
	rsp, err := authLogin.AuthLogin(c.Request.Context(), &req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"msg": err.Error()})
		return
	}

	// 登录成功，返回token
	c.JSON(http.StatusOK, rsp)
}

func GetUserId(ctx *gin.Context) int64 {
	return ctx.GetInt64("UserId")
}
