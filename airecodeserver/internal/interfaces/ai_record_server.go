package interfaces

import (
	"context"
	"encoding/json"
	"io"
	"net/http"
	"strings"
	"time"

	"github.com/gorilla/mux"
	"github.com/gorilla/schema"
	"github.com/smartox/ai_record_server/internal/application/service/authservice"
	"github.com/smartox/ai_record_server/internal/infrastructure/boot"
	"github.com/smartox/ai_record_server/internal/infrastructure/errorcode"
	"github.com/smartox/ai_record_server/internal/infrastructure/utils"
	"trpc.group/trpc-go/trpc-go/errs"
	"trpc.group/trpc-go/trpc-go/log"
)

// NewAiRecordServerServiceImpl service注册实现
func NewAiRecordServerServiceImpl(depCtx *boot.DepContext) http.Handler {
	impl := &AiRecordServerServiceImpl{
		router: mux.NewRouter(),
		depCtx: depCtx,
	}
	impl.RegisterService()

	return impl.router
}

type AiRecordServerServiceImpl struct {
	router *mux.Router
	depCtx *boot.DepContext
}

type Methods struct {
	path      string
	f         func(w http.ResponseWriter, r *http.Request)
	methods   []string
	forceAuth bool
}

// RegisterService 服务注册
func (i *AiRecordServerServiceImpl) RegisterService() {
	// 服务配置
	methods := []Methods{
		{"/v1/auth/third_login", i.AuthThirdLogin, []string{http.MethodPost}, false},
		{"/v1/auth/get_code", i.AuthGetCode, []string{http.MethodPost}, false},
		{"/v1/auth/register", i.AuthRegister, []string{http.MethodPost}, false},
		{"/v1/auth/login", i.AuthLogin, []string{http.MethodPost}, false},
		{"/v1/auth/verify_code", i.AuthVerifyCode, []string{http.MethodPost}, false},
		{"/v1/auth/reset_password", i.AuthResetPassword, []string{http.MethodPost}, false},
		{"/v1/auth/change_password", i.AuthChangePassword, []string{http.MethodPost}, true},
		{"/v1/user_info", i.UserInfo, []string{http.MethodGet}, true},
		{"/v1/user/package", i.UserPackage, []string{http.MethodGet}, true},
		{"/v1/user/package/cost/check", i.UserPackageCostCheck, []string{http.MethodPost}, true},
		{"/v1/user/package_give", i.UserPackageGive, []string{http.MethodPost}, true},
		{"/v1/packages/available", i.PackagesAvailable, []string{http.MethodGet}, true},
		{"/v1/media/upload", i.MediaUpload, []string{http.MethodPost}, true},
		{"/v1/media/upload/credential", i.MediaUploadCredential, []string{http.MethodPost}, true},
		{"/v1/media/upload/ack", i.MediaUploadAck, []string{http.MethodPost}, true},
		{"/v1/media/url", i.MediaUrl, []string{http.MethodGet}, true},
		{"/v1/media/sync", i.MediaSync, []string{http.MethodGet}, true},
		{"/v1/media/remove", i.MediaRemove, []string{http.MethodPost}, true},
		{"/v1/media/convert", i.MediaConvert, []string{http.MethodPost}, true},
		{"/v1/media/convert/status", i.MediaConvertStatus, []string{http.MethodGet}, true},
		{"/v1/media/convert/update", i.MediaConvertUpdate, []string{http.MethodPost}, true},
		{"/v1/media/convert/records", i.MediaConvertRecords, []string{http.MethodGet}, true},
		{"/v1/media/convert/reset", i.MediaConvertReset, []string{http.MethodPost}, true},
		{"/v1/media/update", i.MediaUpdate, []string{http.MethodPost}, true},
		{"/v1/media/summary", i.MediaSummary, []string{http.MethodPost}, true},
		{"/v1/media/summary/status", i.MediaSummaryStatus, []string{http.MethodGet}, true},
		{"/v1/media/summary/update", i.MediaSummaryUpdate, []string{http.MethodPost}, true},

		{"/v1/order/create", i.OrderCreate, []string{http.MethodPost}, true},
		{"/v1/order/detail", i.OrderDetail, []string{http.MethodGet}, true},
		{"/v1/order/list", i.OrderList, []string{http.MethodGet}, true},
		// paypal支付回调接口
		{"/v1/order/paypal/return", i.PaypalReturn, []string{http.MethodPost, http.MethodGet}, false},
		{"/v1/order/paypal/cancel", i.PaypalCancel, []string{http.MethodPost, http.MethodGet}, false},
		{"/v1/order/paypal/notify", i.PaypalNotify, []string{http.MethodPost, http.MethodGet}, false},
		{
			"/v1/order/paypal/subscription/return", i.PaypalSubscriptionReturn, []string{http.MethodPost, http.MethodGet},
			false,
		},
		{
			"/v1/order/paypal/subscription/cancel", i.PaypalSubscriptionCancel, []string{http.MethodPost, http.MethodGet},
			false,
		},

		{"/v1/card/activate", i.CardActivate, []string{http.MethodPost}, true},
		{"/v1/user/feedback", i.UserFeedback, []string{http.MethodPost}, false},
		{"/v1/user/delete_account", i.DeleteAccount, []string{http.MethodPost}, true},
		{"/v1/user_agreement", i.UserAgreement, []string{http.MethodGet}, false},
		{"/v1/privacy_policy", i.PrivacyPolicy, []string{http.MethodGet}, false},
		{"/v1/help_manuals", i.HelpManuals, []string{http.MethodGet}, false},
		{"/v1/app_version", i.AppVersion, []string{http.MethodGet}, false},
		{"/v1/asr_engine_models", i.AsrEngineModels, []string{http.MethodGet}, false},
		{"/v1/prompt_templates", i.PromptTemplates, []string{http.MethodGet}, false},
		{"/v1/ble/device/list", i.BleDeviceList, []string{http.MethodGet}, false},
		{"/v1/chat", i.ChatCompletion, []string{http.MethodPost}, true},

		// for test...
		{"/v1/card/generate", i.CardGenerate, []string{http.MethodPost}, true},
		{"/v1/auth/sms_code/{phone}", i.AuthSmsCodeState, []string{http.MethodGet}, false},
		{"/v1/recording/upload", i.RecordingUpload, []string{http.MethodPost}, false},
		// register new services here ↑↑↑↑
		{"/v1/media/speech", i.MediaSpeechHandler, []string{http.MethodGet}, true},
	}

	// 服务注册
	for _, m := range methods {
		log.Infof("register method %v %s success.", m.methods, m.path)
		i.router.HandleFunc(m.path, i.middleware(m.f, m.forceAuth)).Methods(m.methods...)
	}
}

func (i *AiRecordServerServiceImpl) middleware(next http.HandlerFunc, forceAuth bool) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		log.WithContextFields(r.Context(), "MSG_NO", utils.GenerateMD5Hash(utils.GenerateUUID()))

		// Authorization认证
		userId, errAuth := authservice.NewAuthCheck(i.depCtx.TransMgr).Authorization(r.Context(), r, forceAuth)
		if errAuth != nil {
			i.SendErrorMsg(w, r, http.StatusUnauthorized, errAuth)
			return
		}

		ctx := context.WithValue(r.Context(), "UserId", userId)
		r = r.WithContext(ctx)

		// 下一个处理器调用
		next.ServeHTTP(w, r)

		log.InfoContextf(r.Context(), "[%v] [reply|%s] %s %s", time.Since(start), i.GetClientIP(r), r.Method, r.RequestURI)
	}
}

func (i *AiRecordServerServiceImpl) GetUserId(ctx context.Context) int64 {
	return ctx.Value("UserId").(int64)
}

func (i *AiRecordServerServiceImpl) GetClientIP(r *http.Request) string {
	// 尝试从 X-Forwarded-For 中获取
	forwarded := r.Header.Get("X-Forwarded-For")
	if forwarded != "" {
		// X-Forwarded-For 可能包含多个 IP 地址，用逗号分隔，取第一个
		return strings.Split(forwarded, ",")[0]
	}

	// 尝试从 X-Real-IP 中获取
	realIP := r.Header.Get("X-Real-IP")
	if realIP != "" {
		return realIP
	}

	// 默认情况下，从 RemoteAddr 中获取
	ip := r.RemoteAddr
	// 去除端口号
	if colon := strings.LastIndex(ip, ":"); colon != -1 {
		ip = ip[:colon]
	}
	return ip
}

// ParseRequestMsg 解析请求消息
func (i *AiRecordServerServiceImpl) ParseRequestMsg(r *http.Request, v any) error {
	if r.Method == http.MethodGet && len(r.URL.Query()) != 0 {
		log.InfoContextf(r.Context(), "request %s %s", r.Method, r.RequestURI)

		decoder := schema.NewDecoder()
		err := decoder.Decode(v, r.URL.Query())
		if err != nil {
			return err
		}

		// 请求参数校验
		if err := utils.ValidateStruct(v); err != nil {
			return err
		}

		return nil
	}

	msg, _ := io.ReadAll(r.Body)

	log.InfoContextf(r.Context(), "request %s %s body: %s", r.Method, r.RequestURI, msg)

	if len(msg) == 0 {
		// post请求不允许body为空
		if r.Method == http.MethodPost {
			return errs.Newf(errorcode.ErrParseRequestMsg, "request msg is empty")
		}
		return nil
	}

	// 请求消息解码
	err := json.Unmarshal(msg, &v)
	if err != nil {
		return errs.Newf(errorcode.ErrParseRequestMsg, "request msg Unmarshal fail. %s", err.Error())
	}

	// 请求参数校验
	if err := utils.ValidateStruct(v); err != nil {
		return err
	}

	return nil
}

// ResponseWrite 消息返回
func (i *AiRecordServerServiceImpl) ResponseWrite(w http.ResponseWriter, r *http.Request, status int, msg string) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)

	writeLen, err := w.Write([]byte(msg))
	if err != nil {
		log.ErrorContextf(r.Context(), "%s response error. %+v", r.RequestURI, err)
		return
	}

	log.InfoContextf(r.Context(), "response %s len: %d, msg: %s", r.RequestURI, writeLen, msg)
	return
}

// SendErrorMsg 错误消息返回
func (i *AiRecordServerServiceImpl) SendErrorMsg(w http.ResponseWriter, r *http.Request, status int, err error) {
	i.ResponseWrite(w, r, status, errorcode.MarshalErrorMsg(err))
}

// SendResponseMsg 响应消息返回
func (i *AiRecordServerServiceImpl) SendResponseMsg(w http.ResponseWriter, r *http.Request, rsp any) {
	// 返回消息打包
	buf, err := i.PackResponseMsg(rsp)
	if err != nil {
		i.SendErrorMsg(w, r, http.StatusBadRequest, err)
		return
	}

	// 返回消息
	i.ResponseWrite(w, r, http.StatusOK, buf)
}

// PackResponseMsg 打包返回消息
func (i *AiRecordServerServiceImpl) PackResponseMsg(v any) (string, error) {
	buf, err := json.Marshal(v)
	if err != nil {
		return "", errs.Newf(errorcode.ErrPackResponseMsg, "response msg Marshal fail. %s", err.Error())
	}

	if string(buf) == "{}" {
		buf = []byte("")
	}

	return string(buf), nil
}
