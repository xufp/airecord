package errorcode

import (
	"encoding/json"
	"errors"

	"trpc.group/trpc-go/trpc-go/errs"
)

const (
	ModuleID = 10001 * 1000
)

// 通用类错误码
const (
	ErrUnDefined         = ModuleID + 100 // 未定义错误
	ErrRemoteCallFail    = ModuleID + 101 // 远程调用失败
	ErrParseRequestMsg   = ModuleID + 102 // 请求参数解析错误
	ErrPackResponseMsg   = ModuleID + 103 // 返回参数序列化错误
	ErrParamsInvalid     = ModuleID + 104 // 请求参数错误
	ErrRecordNotExisted  = ModuleID + 105 // 查询记录不存在
	ErrServiceNotSupport = ModuleID + 106 // 暂不提供服务（功能）
	ErrDataEncryptFailed = ModuleID + 107 // 数据加密失败
	ErrDataDecryptFailed = ModuleID + 108 // 数据解密失败
)

// 用户授权类错误码
const (
	ErrUserAuthInvalid      = ModuleID + 201 // 用户授权无效（token无效）
	ErrUserNotFound         = ModuleID + 202 // 用户不存在
	ErrInvalidPassword      = ModuleID + 203 // 密码错误
	ErrVerifyCodeSendFailed = ModuleID + 204 // 验证码发送失败
	ErrVerifyCodeInvalid    = ModuleID + 205 // 验证码无效
	ErrUserDeactivated      = ModuleID + 206 // 用户已注销
	ErrUserIsExisted        = ModuleID + 207 // 用户已存在，不需要注册
)

// 服务类错误码
const (
	ErrPackageNotFreeGive    = ModuleID + 301 // 套餐不能免费领取
	ErrPackageRepeatGive     = ModuleID + 302 // 套餐不允许重复领取
	ErrBalanceInsufficient   = ModuleID + 303 // 套餐服务余额不足
	ErrNoAvailablePackage    = ModuleID + 304 // 没有可购买（领取）的套餐包
	ErrPackageNotSupport     = ModuleID + 305 // 套餐不支持当前服务
	ErrMembershipNotActive   = ModuleID + 306 // 会员未激活
	ErrActivationCardInvalid = ModuleID + 307 // 激活卡无效
	ErrActivationCardIsUsed  = ModuleID + 308 // 激活卡已领用

	ErrOrderCreateFailed               = ModuleID + 310 // 订单创建失败
	ErrOrderCaptureFailed              = ModuleID + 311 // 订单支付失败
	ErrOrderPaypalInitFailed           = ModuleID + 312 // PayPal初始化失败
	ErrOrderDetailGetFailed            = ModuleID + 313 // 订单详情获取失败
	ErrNotSupportPayChannel            = ModuleID + 314 // 不支持的支付渠道
	ErrOrderDealFailed                 = ModuleID + 315 // 订单处理失败
	ErrCreatePaymentProductFailed      = ModuleID + 316 // 创建支付产品失败
	ErrCreatePaymentPlanFailed         = ModuleID + 317 // 创建支付计划失败
	ErrCreatePaymentSubscriptionFailed = ModuleID + 318 // 创建支付订阅失败
	ErrGetPaymentSubscriptionFailed    = ModuleID + 319 // 获取支付订阅失败
)

// 音频类错误码
const (
	ErrMediaNotSupportConvert = ModuleID + 401 // 音频文件类型不支持当前转写模式
	ErrMediaRepeatUpload      = ModuleID + 402 // 文件上传重入
	ErrMediaNameExisted       = ModuleID + 403 // 音频名称已存在(非重入错误)
	ErrMediaFormatNotSupport  = ModuleID + 404 // 音频格式不支持
	ErrFileOperatorFailed     = ModuleID + 405 // 文件操作失败
	ErrMediaFileNotExisted    = ModuleID + 406 // 音频文件不存在（未上传）
	ErrRecServiceNotAllow     = ModuleID + 407 // 拒绝服务（已存在转写中的速记音频）
	ErrEngineNotSupport       = ModuleID + 408 // 引擎模型暂不支持
	ErrMediaNotConvert        = ModuleID + 409 // 音频未转写完成
	ErrTextTooShortSummary    = ModuleID + 410 // 用于总结的文本过短
	ErrMediaRecNotNeedReset   = ModuleID + 411 // 音频转写当前不需要重置
)

// ErrorMsg 自定义错误消息结构
type ErrorMsg struct {
	Code int32  `json:"code"`
	Msg  string `json:"msg"`
}

// StdErrorToTrpc 标准error转为trpc error
func StdErrorToTrpc(err error) error {
	var customErr *errs.Error
	if ok := errors.As(err, &customErr); !ok {
		return errs.Newf(ErrUnDefined, err.Error())
	}

	return err
}

// MarshalErrorMsg 自定义错误消息结构序列号为json
func MarshalErrorMsg(err error) string {
	err = StdErrorToTrpc(err)

	errMsg := ErrorMsg{
		Code: int32(errs.Code(err)),
		Msg:  errs.Msg(err),
	}

	buf, err := json.Marshal(errMsg)
	if err != nil {
		return err.Error()
	}
	return string(buf)
}
