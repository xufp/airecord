package router

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/smartox/ai_record_server/internal/admin/handler"
	"github.com/smartox/ai_record_server/internal/infrastructure/boot"
	"github.com/smartox/ai_record_server/internal/infrastructure/config"
	"github.com/smartox/ai_record_server/internal/infrastructure/utils"
	"trpc.group/trpc-go/trpc-go/log"
)

// NewAiRecordAdminImpl 创建管理后台实现
func NewAiRecordAdminImpl(depCtx *boot.DepContext) http.Handler {
	router := NewRouter(depCtx)

	// 设置路由
	router.SetupRoutes()

	return router.Handler()
}

// Router 路由管理器
type Router struct {
	engine *gin.Engine
	depCtx *boot.DepContext
}

func NewRouter(depCtx *boot.DepContext) *Router {
	// 设置为发布模式
	gin.SetMode(gin.ReleaseMode)
	// 创建Gin引擎
	engine := gin.Default()

	return &Router{
		engine: engine,
		depCtx: depCtx,
	}
}

// SetupRoutes 设置路由
func (r *Router) SetupRoutes() {
	r.engine.LoadHTMLGlob(fmt.Sprintf("%s/*html", config.GetServerConfig().Admin.HtmlPath))
	r.engine.Static("/admin/assets", config.GetServerConfig().Admin.AssetsPath)

	// 根路径处理
	r.engine.GET("/", func(c *gin.Context) {
		c.File(fmt.Sprintf("%s/index.html", config.GetServerConfig().Admin.HtmlPath))
	})

	// 登录接口
	r.engine.POST("/api/login", handler.NewAuthHandler(r.depCtx.TransMgr).Login)

	// 创建handler实例
	cardHandler := handler.NewCardHandler(r.depCtx.TransMgr)
	configHandler := handler.NewConfigHandler(r.depCtx.TransMgr)
	userHandler := handler.NewUserHandler(r.depCtx.TransMgr)
	packageHandler := handler.NewPackageHandler(r.depCtx.TransMgr)

	// 登录态校验中间件
	auth := r.engine.Group("/api", r.AuthMiddleware(true))
	{
		auth.GET("/config/list", configHandler.ConfigList)
		auth.POST("/config/add", configHandler.ConfigAdd)
		auth.POST("/config/update", configHandler.ConfigUpdate)
		auth.POST("/config/delete", configHandler.ConfigDelete)

		auth.GET("/card/list", cardHandler.CardList)
		auth.POST("/card/add", cardHandler.CardAdd)
		auth.POST("/card/void", cardHandler.CardVoid)

		auth.GET("/user/list", userHandler.UserList)
		auth.POST("/user/cancel", userHandler.UserCancel)

		auth.GET("/package/list", packageHandler.PackageList)
		auth.GET("/package/detail/:id", packageHandler.PackageDetail)
		auth.GET("/package/services/:id", packageHandler.PackageServices)
	}

	// 处理前端路由 - 所有未匹配的路由都返回index.html
	r.engine.NoRoute(func(c *gin.Context) {
		// 如果是API请求，返回404
		if strings.HasPrefix(c.Request.URL.Path, "/api/") {
			c.JSON(http.StatusNotFound, gin.H{"error": "API not found"})
			return
		}
		// 否则返回index.html，让前端路由处理
		c.File(fmt.Sprintf("%s/index.html", config.GetServerConfig().Admin.HtmlPath))
	})
}

func (r *Router) Handler() http.Handler {
	return r.engine.Handler()
}

// responseWriter 自定义响应写入器，用于捕获响应内容
type responseWriter struct {
	gin.ResponseWriter
	body *bytes.Buffer
}

func (w responseWriter) Write(b []byte) (int, error) {
	w.body.Write(b)
	return w.ResponseWriter.Write(b)
}

func (w responseWriter) WriteString(s string) (int, error) {
	w.body.WriteString(s)
	return w.ResponseWriter.WriteString(s)
}

func (r *Router) AuthMiddleware(forceAuth bool) gin.HandlerFunc {
	return func(c *gin.Context) {
		start := time.Now()
		log.WithContextFields(c.Request.Context(), "MSG_NO", utils.GenerateMD5Hash(utils.GenerateUUID()))

		// 记录请求参数
		var requestBody []byte
		if c.Request.Body != nil {
			requestBody, _ = io.ReadAll(c.Request.Body)
			// 重新设置请求体，因为读取后需要重置
			c.Request.Body = io.NopCloser(bytes.NewBuffer(requestBody))
		}

		// 创建自定义响应写入器
		responseBody := &bytes.Buffer{}
		writer := &responseWriter{
			ResponseWriter: c.Writer,
			body:           responseBody,
		}
		c.Writer = writer

		// 打印请求日志（在入口处）
		requestLogMsg := fmt.Sprintf("[REQUEST] [%s|%s] %s",
			r.GetClientIP(c.Request),
			c.Request.Method,
			c.Request.RequestURI)

		// 记录请求参数（如果是POST/PUT/PATCH请求且有请求体）
		if len(requestBody) > 0 && (c.Request.Method == "POST" || c.Request.Method == "PUT" || c.Request.Method == "PATCH") {
			// 尝试格式化JSON，如果不是JSON则直接显示
			var prettyJSON bytes.Buffer
			if json.Indent(&prettyJSON, requestBody, "", "  ") == nil {
				requestLogMsg += fmt.Sprintf("\nRequest Body: %s", prettyJSON.String())
			} else {
				// 如果不是JSON，限制长度避免日志过长
				if len(requestBody) > 1000 {
					requestLogMsg += fmt.Sprintf("\nRequest Body: %s...", string(requestBody[:1000]))
				} else {
					requestLogMsg += fmt.Sprintf("\nRequest Body: %s", string(requestBody))
				}
			}
		}

		log.InfoContextf(c.Request.Context(), requestLogMsg)

		// Authorization认证
		if forceAuth {
			userId, err := handler.NewAuthHandler(r.depCtx.TransMgr).Authorization(c)
			if err != nil {
				c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"msg": "未登录"})
				return
			}
			c.Set("UserId", userId)
		}

		// 下一个处理器调用
		c.Next()

		// 打印响应日志（在业务处理结束后）
		duration := time.Since(start)
		statusCode := c.Writer.Status()

		// 构建响应日志消息
		responseLogMsg := fmt.Sprintf("[RESPONSE] [%v] [%s|%s] %s",
			duration,
			r.GetClientIP(c.Request),
			c.Request.Method,
			c.Request.RequestURI)

		// 记录响应状态和内容
		responseLogMsg += fmt.Sprintf("\nResponse Status: %d", statusCode)

		// 记录响应内容（限制长度避免日志过长）
		responseContent := responseBody.String()
		if len(responseContent) > 1000 {
			responseLogMsg += fmt.Sprintf("\nResponse Body: %s...", responseContent[:1000])
		} else if len(responseContent) > 0 {
			responseLogMsg += fmt.Sprintf("\nResponse Body: %s", responseContent)
		}

		log.InfoContextf(c.Request.Context(), responseLogMsg)
	}
}

func (r *Router) GetClientIP(req *http.Request) string {
	// 尝试从 X-Forwarded-For 中获取
	forwarded := req.Header.Get("X-Forwarded-For")
	if forwarded != "" {
		// X-Forwarded-For 可能包含多个 IP 地址，用逗号分隔，取第一个
		return strings.Split(forwarded, ",")[0]
	}

	// 尝试从 X-Real-IP 中获取
	realIP := req.Header.Get("X-Real-IP")
	if realIP != "" {
		return realIP
	}

	// 默认情况下，从 RemoteAddr 中获取
	ip := req.RemoteAddr
	// 去除端口号
	if colon := strings.LastIndex(ip, ":"); colon != -1 {
		ip = ip[:colon]
	}
	return ip
}
