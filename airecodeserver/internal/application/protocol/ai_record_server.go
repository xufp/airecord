package protocol

import (
	"encoding/json"
	"net/http"

	"trpc.group/trpc-go/trpc-go/log"
)

// AuthThirdLoginReq 第三方平台登录请求参数
type AuthThirdLoginReq struct {
	Channel int32  `json:"channel" validate:"required,min=1,max=1"` // 第三方授权渠道 1：微信平台
	Code    string `json:"code" validate:"required,min=1,max=256"`  // 授权码
}

// AuthThirdLoginRsp 微信平台票据code登录返回参数
type AuthThirdLoginRsp struct {
	State       int32  `json:"state"`        // 登录状态
	AccessToken string `json:"access_token"` // 用户登录token
}

// AuthGetCodeReq 获取验证码请求参数
type AuthGetCodeReq struct {
	Phone string `json:"phone" validate:"omitempty,e164"`  // 电话号码
	Email string `json:"email" validate:"omitempty,email"` // email
}

// AuthGetCodeRsp 获取验证码返回参数
type AuthGetCodeRsp struct {
}

// UserInfoReq 用户信息查询请求参数
type UserInfoReq struct {
}

// UserInfoRsp 用户信息查询返回参数
type UserInfoRsp struct {
	NickName             string `json:"nick_name"`              // 用户名称
	Sex                  int32  `json:"sex"`                    // 普通用户性别，1 为男性，2 为女性
	Province             string `json:"province"`               // 普通用户个人资料填写的省份
	City                 string `json:"city"`                   // 普通用户个人资料填写的城市
	Country              string `json:"country"`                // 国家，如中国为 CN
	HeadImgUrl           string `json:"head_img_url"`           // 用户头像，最后一个数值代表正方形头像大小（有 0、46、64、96、132 数值可选，0 代表 640*640 正方形头像），用户没有头像时该项为空
	MembershipLevel      int32  `json:"membership_level"`       // 会员等级
	MembershipExpireTime string `json:"membership_expire_time"` // 会员过期时间
}

// UserPackageReq 用户套餐用量查询请求参数
type UserPackageReq struct {
}

// ServiceUsage 服务使用情况
type ServiceUsage struct {
	Used  int64 `json:"used"`  // 已用量 （时长：单位分钟/容量：单位MB）
	Total int64 `json:"total"` // 总量 （时长：单位分钟/容量：单位MB）
}

// UserPackageRsp 用户套餐用量查询返回参数
type UserPackageRsp struct {
	Convert ServiceUsage `json:"convert"` // 语音转写服务情况
}

// UserPackageCostCheckReq 用户套餐消费校验（判断是否满足消费需求）请求参数
type UserPackageCostCheckReq struct {
	ServiceType int32 `json:"service_type" validate:"required,min=1,max=1"` // 1：语音转写，
	CostAmount  int64 `json:"cost_amount" validate:"required,min=1"`        // 请求消费量（单位：毫秒/byte）
}

// UserPackageCostCheckRsp 用户套餐消费校验（判断是否满足消费需求）返回参数
type UserPackageCostCheckRsp struct {
	IsSufficient bool `json:"is_sufficient"` // true: 余额充足，false: 余额不足
}

// UserPackageGiveReq 套餐领取请求参数
type UserPackageGiveReq struct {
	PackageId int32 `json:"package_id" validate:"required"` // 套餐ID 90010000-新注册用户免费套餐
}

// PackageUsage 套餐使用信息
type PackageUsage struct {
	ServiceType int32  `json:"service_type"` // 1：语音转写，
	BeginDate   string `json:"begin_date"`   // 生效开始时间(2006-01-02 15:04:05)
	EndDate     string `json:"end_date"`     // 生效结束时间(2006-01-02 15:04:05)
	Quantity    int64  `json:"quantity"`     // 服务量（时长：单位分钟/容量：单位MB）
}

// UserPackageGiveRsp 套餐领取返回参数
type UserPackageGiveRsp struct {
	PackageId     int32          `json:"package_id"`     // 套餐ID 90010000-新注册用户免费套餐
	PackageDetail []PackageUsage `json:"package_detail"` // 套餐明细
}

// PackagesAvailableReq 用户可购买(领取)套餐查询请求参数
type PackagesAvailableReq struct {
	PackageType int32  `json:"package_type" schema:"package_type" validate:"required,min=1,max=3"` // 套餐类型 1-免费体验类，2-付费类, 3: 订阅计划
	Lang        string `json:"lang" schema:"lang"`                                                 // 语言代码(zh/en/ja/ko等)，可选参数
}

// type PackageService struct {
// 	ServiceType  int32  `json:"service_type"`  // 服务类型 1：语音转写，
// 	ServiceName  string `json:"service_name"`  // 服务名称
// 	Quantity     int64  `json:"quantity"`      // 服务量（时长：单位分钟/容量：单位MB）
// 	ValidityDays int32  `json:"validity_days"` // 服务有效期天数
// }

type Package struct {
	PackageId   int32  `json:"package_id"`   // 套餐ID
	PackageType int32  `json:"package_type"` // 套餐类型 1：付费类，2：免费体验类
	PackageName string `json:"package_name"` // 套餐名称（根据语言参数返回对应语言）
	Description string `json:"description"`  // 套餐描述（根据语言参数返回对应语言）
	Price       int64  `json:"price"`        // 套餐总价 (单位：分)
	Rates       int64  `json:"rates"`        // 套餐折扣率(%) 购买价格 = price * (rates / 100.0)
	Currency    string `json:"currency"`     // 币种
	// Services    []PackageService `json:"services"`     // 套餐服务
}

// PackagesAvailableRsp 用户可购买(领取)套餐查询返回参数
type PackagesAvailableRsp struct {
	Packages []Package `json:"packages"` // 套餐列表
}

// MediaMeta 音频文件元信息
type MediaMeta struct {
	MediaName     string `json:"media_name" validate:"required"`  // 音频名称
	FileSign      string `json:"file_sign" validate:"required"`   // 文件签名(sha256)
	RecordTime    string `json:"record_time" validate:"required"` // 文件创建时间/录音时间
	RecordAddress string `json:"record_address"`                  // 文件记录地址
	DeviceId      string `json:"device_id"`                       // 设备IDs
}

// MediaUploadReq 音频文件上传请求参数
type MediaUploadReq struct {
	Req *http.Request `json:"req"`
}

// MediaUploadRsp 音频文件上传返回参数
type MediaUploadRsp struct {
	MediaId int64 `json:"media_id"` // 音频ID
}

// MediaUploadCredentialReq 音频文件上传临时秘钥请求
type MediaUploadCredentialReq struct {
	MediaName     string `json:"media_name" validate:"required"`      // 音频名称
	FileFormat    string `json:"file_format" validate:"required"`     // 音频文件格式 wav, mp3 ...
	FileSize      int64  `json:"file_size" validate:"required,min=1"` // 文件大小(单位：byte)
	Duration      int64  `json:"duration" validate:"required,min=1"`  // 音频时长(单位：毫秒)
	RecordTime    string `json:"record_time" validate:"required"`     // 文件创建时间/录音时间
	RecordAddress string `json:"record_address"`                      // 文件记录地址
	DeviceId      string `json:"device_id"`                           // 设备IDs
}

// Credential 临时密钥
type Credential struct {
	TmpSecretId  string `json:"tmp_secret_id"`  // 临时密钥 Id
	TmpSecretKey string `json:"tmp_secret_key"` // 临时密钥 Key
	SessionToken string `json:"session_token"`  // 临时秘钥 请求时需要用的 token 字符串
	StartTime    int32  `json:"start_time"`     // 密钥的起始时间 （unix时间戳）
	ExpiredTime  int32  `json:"expired_time"`   // 密钥的失效时间（unix时间戳）
	ObjectName   string `json:"object_name"`    // 授权资源对象名称（允许操作的资源路径）
	Region       string `json:"region"`         // region
	Bucket       string `json:"bucket"`         // bucket
}

// MediaUploadCredentialRsp 音频文件上传临时秘钥返回
type MediaUploadCredentialRsp struct {
	MediaId    int64      `json:"media_id"`   // 音频ID
	Credential Credential `json:"credential"` // 临时密钥信息
	State      int32      `json:"state"`      // 音频状态：0: 初始状态(未上传),1:已上传, 2: 转写中...
}

// MediaUploadAckReq 音频文件上传确认请求参数
type MediaUploadAckReq struct {
	MediaId int64 `json:"media_id" validate:"required,min=1"` // 音频ID
}

// MediaUploadAckRsp 音频文件上传确认返回参数
type MediaUploadAckRsp struct {
}

// MediaUpdateReq 音频信息修改请求参数
type MediaUpdateReq struct {
	MediaId   int64  `json:"media_id" validate:"required,min=1"` // 音频ID
	MediaName string `json:"media_name" validate:"required"`     // 音频名称
}

// MediaUpdateRsp 音频信息修改返回参数
type MediaUpdateRsp struct {
}

// MediaConvertReq 音频转写请求参数
type MediaConvertReq struct {
	MediaId    int64  `json:"media_id" validate:"required,min=1"` // 音频ID
	EngineType string `json:"engine_type" validate:"required"`    // 引擎类型 16k_zh：中文通用; 16k_en：英语；
}

// MediaConvertRsp 音频转写返回参数
type MediaConvertRsp struct {
	MediaId int64  `json:"media_id"`       // 音频ID
	State   int32  `json:"state"`          // 转写状态 0：转写等待，1：转写中，2：已转写成功，3：转写失败
	Memo    string `json:"memo,omitempty"` // 备注，失败时的错误消息
	Text    string `json:"text,omitempty"` // 音频转写结果
}

// Sentence 句子/段落级别的识别结果
type Sentence struct {
	Index     int32  `json:"index"`      // 序号，从0开始递增
	StartTime uint32 `json:"start_time"` // 开始时间
	EndTime   uint32 `json:"end_time"`   // 结束时间
	Text      string `json:"text"`       // 文本结果
	SpeakId   int32  `json:"speak_id"`   // 说话人Id
}

// MediaConvertStatusReq 查询音频转写状态请求参数
type MediaConvertStatusReq struct {
	MediaId int64 `json:"media_id"  schema:"media_id" validate:"required,min=1"` // 音频ID
	Detail  bool  `json:"detail" schema:"detail"`                                // 是否查询明细，传true时只返回明细，否则只返回汇总结果
}

// MediaConvertStatusRsp 查询音频转写状态返回参数
type MediaConvertStatusRsp struct {
	MediaId        int64      `json:"media_id"`                  // 音频ID
	State          int32      `json:"state"`                     // 转写状态
	Memo           string     `json:"memo,omitempty"`            // 备注，失败时的错误消息
	Text           string     `json:"text,omitempty"`            // 音频转写结果
	SentenceDetail []Sentence `json:"sentence_detail,omitempty"` // 段落级别结果明细
}

const (
	MediaConvertUpdateModeAll  = 1 // 修改模式 1-完整（sentence_detail中包含全部的明细）
	MediaConvertUpdateModePart = 2 // 修改模式 2-片段（sentence_detail中只包含将要修改的段落）
)

// MediaConvertUpdateReq 音频转写结果修改请求参数
type MediaConvertUpdateReq struct {
	MediaId        int64      `json:"media_id" validate:"required,min=1"`   // 音频ID
	Mode           int32      `json:"mode" validate:"required,min=1,max=2"` // 修改模式，1-完整（sentence_detail中包含全部的明细）， 2-片段（sentence_detail中只包含将要修改的段落）
	SentenceDetail []Sentence `json:"sentence_detail" validate:"required"`  // 段落级别结果明细
}

// MediaConvertUpdateRsp 音频转写结果修改返回参数
type MediaConvertUpdateRsp struct {
}

// MediaConvertRecordsReq 音频转写记录查询请求参数
type MediaConvertRecordsReq struct {
	Page int32 `json:"page" schema:"page" validate:"required,min=1"`         // 请求页码（从1开始计数）
	Size int32 `json:"size" schema:"size" validate:"required,min=1,max=100"` // 每页记录数
}

// MediaConvertRecords 音频转写记录
type MediaConvertRecords struct {
	MediaId   int64  `json:"media_id"`   // 音频ID
	MediaName string `json:"media_name"` // 音频名称
	RecTime   string `json:"rec_time"`   // 音频转写成功时间
	Duration  int64  `json:"duration"`   // 音频时长/s
	Deleted   bool   `json:"deleted"`    // 记录是否已被删除，false：未删除(有效), ture：已删除
}

// MediaConvertRecordsRsp 音频转写记录查询返回参数
type MediaConvertRecordsRsp struct {
	Page  int32                 `json:"page"`  // 请求页码（从1开始计数）
	Size  int32                 `json:"size"`  // 每页记录数
	Total int32                 `json:"total"` // 总记录数
	Data  []MediaConvertRecords `json:"data"`  // 音频转写记录列表
}

// MediaSyncReq 音频同步请求参数
type MediaSyncReq struct {
	Page int32 `json:"page" schema:"page" validate:"required,min=1"`         // 请求页码（从1开始计数）
	Size int32 `json:"size" schema:"size" validate:"required,min=1,max=100"` // 每页记录数
}

// MediaData 音频信息同步返回数据
type MediaData struct {
	MediaId       int64  `json:"media_id"`       // 音频ID
	MediaName     string `json:"media_name"`     // 音频名称
	FileFormat    string `json:"file_format"`    // 音频文件格式 wav, mp3 ...
	FileSign      string `json:"file_sign"`      // 文件签名(sha256)
	RecordTime    string `json:"record_time"`    // 录音时间
	RecordAddress string `json:"record_address"` // 录音地点
	Duration      int64  `json:"duration"`       // 音频时长(单位：毫秒)
	DeviceId      string `json:"device_id"`      // 设备ID
	MediaType     int32  `json:"media_type"`     // 音频类型 1：常规录音文件；2：速记录音文件
	State         int32  `json:"state"`          // 音频状态：0: 初始状态(未上传),1:已上传, 2: 转写中，3：已转写， 4：转写失败
}

// MediaSyncRsp 音频同步返回参数
type MediaSyncRsp struct {
	Page  int32       `json:"page"`  // 请求页码（从1开始计数）
	Size  int32       `json:"size"`  // 每页记录数
	Total int32       `json:"total"` // 总记录数
	Data  []MediaData `json:"data"`  // 音频信息列表
}

// MediaUrlReq 音频文件Url获取请求参数
type MediaUrlReq struct {
	MediaId int64 `json:"media_id" schema:"media_id"` // 音频ID
}

// MediaUrlRsp 音频文件Url获取返回参数
type MediaUrlRsp struct {
	MediaId int64  `json:"media_id"` // 音频ID
	Url     string `json:"url"`      // 文件路径
}

// MediaRemoveReq 音频文件删除请求参数
type MediaRemoveReq struct {
	MediaId int64 `json:"media_id"` // 音频ID
}

// MediaRemoveRsp 音频文件删除返回参数
type MediaRemoveRsp struct {
}

// MediaSpeechReq 音频速记请求参数
type MediaSpeechReq struct {
	MediaName     string `json:"media_name" schema:"media_name" validate:"required"`   // 音频名称
	FileFormat    string `json:"file_format" schema:"file_format" validate:"required"` // 音频文件格式 wav, mp3 ...
	EngineType    string `json:"engine_type" schema:"engine_type" validate:"required"` // 引擎类型 16k_zh：中文通用; 16k_en：英语；
	RecordAddress string `json:"record_address" schema:"record_address"`               // 文件记录地址
	DeviceId      string `json:"device_id" schema:"device_id"`                         // 设备ID
}

// type MediaStream struct {
// 	Type string `json:"type"`
// }

// SpeechResult 速记识别结果段
type SpeechResult struct {
	SliceType uint32 `json:"slice_type"` // 识别结果类型：1: 一段话识别中，不稳定结果(可能变化)，2：一段话识别结束，返回该段话的完整识别结果（稳定）
	Index     int32  `json:"index"`      // 当前一段话结果在整个音频流中的序号，从0开始逐句递增
	StartTime uint32 `json:"start_time"` // 当前一段话结果在整个音频流中的起始时间
	EndTime   uint32 `json:"end_time"`   // 当前一段话结果在整个音频流中的结束时间
	Text      string `json:"text"`       // 当前一段话文本结果
}

const (
	SliceTypeChange = 1 // 一段话识别中，不稳定结果(可能变化)
	SliceTypeStable = 2 // 一段话识别结束，稳定结果
)

// MediaSpeechData 音频数据
type MediaSpeechData struct {
	DataType int    // 数据类型 TextMessage = 1，BinaryMessage = 2
	Content  []byte // 数据内容
}

// MediaSpeechRsp 音频速记识别结果返回参数
type MediaSpeechRsp struct {
	Code    int32        `json:"code"`               // 状态码，0代表正常，非0值表示发生错误
	Msg     string       `json:"msg"`                // 错误说明
	MediaId int64        `json:"media_id,omitempty"` // 音频ID
	Result  SpeechResult `json:"result,omitempty"`   // 最新语音识别结果
	Final   int32        `json:"final,omitempty"`    // 1-表示音频流全部识别结束
}

// Marshal 音频速记识别结果序列化
func (m *MediaSpeechRsp) Marshal() []byte {
	buf, err := json.Marshal(m)
	if err != nil {
		log.Errorf("MediaSpeechRsp msg marshal err %s", err.Error())
	}
	return buf
}

// AuthLoginReq 用户邮箱登录请求参数
type AuthLoginReq struct {
	Email    string `json:"email" validate:"required,email"`    // email地址
	Password string `json:"password" validate:"required,min=8"` // 密码（8位以上字符）
	Register bool   `json:"register"`                           // 登录用户不存在是否注册，false: 不注册，true: 注册
}

// AuthLoginRsp 用户邮箱登录返回参数
type AuthLoginRsp struct {
	State       int32  `json:"state"`        // 登录状态 1：待验证，2：登录成功
	AccessToken string `json:"access_token"` // 用户登录token -- 1：待验证状态，不返回token
}

// AuthRegisterReq 用户邮箱登录请求参数
type AuthRegisterReq struct {
	Email    string `json:"email" validate:"required,email"`    // email地址
	Password string `json:"password" validate:"required,min=8"` // 密码（8位以上字符）
}

// AuthRegisterRsp 用户邮箱登录返回参数
type AuthRegisterRsp struct {
	State int32 `json:"state"` // 状态 1：注册成功，待验证
}

// AuthVerifyCodeReq 验证请求参数
type AuthVerifyCodeReq struct {
	Phone string `json:"phone" validate:"omitempty,e164"`  // 电话号码
	Email string `json:"email" validate:"omitempty,email"` // email
	Code  string `json:"code" validate:"required,len=6"`   // 验证码
}

// AuthVerifyCodeRsp 验证码登录返回参数
type AuthVerifyCodeRsp struct {
	State       int32  `json:"state"`        // 登录状态 2：登录成功
	AccessToken string `json:"access_token"` // 用户登录token
}

// AuthChangePasswordReq 修改密码请求参数
type AuthChangePasswordReq struct {
	CurrentPassword string `json:"current_password" validate:"required,min=8"` // 当前密码
	NewPassword     string `json:"new_password" validate:"required,min=8"`     // 新密码
}

// AuthChangePasswordRsp 修改密码返回参数
type AuthChangePasswordRsp struct {
}

// AuthResetPasswordReq 密码重置请求参数
type AuthResetPasswordReq struct {
	Email       string `json:"email" validate:"required,email"`         // email
	Code        string `json:"code" validate:"omitempty,len=6"`         // 验证码
	NewPassword string `json:"new_password" validate:"omitempty,min=8"` // 新密码
}

// AuthResetPasswordRsp 密码重置返回参数
type AuthResetPasswordRsp struct {
}

// MediaSummaryReq 音频内容总结请求参数
type MediaSummaryReq struct {
	MediaId  int64  `json:"media_id"  validate:"required"`         // 音频ID
	PromptId string `json:"prompt_id" validate:"omitempty,max=64"` // 总结PromptId要求，默认可不传. 通过接口【获取Prompt模板列表】接口获取
	Prompt   string `json:"prompt" validate:"omitempty,max=1024"`  // 总结Prompt内容，默认可不传. 当prompt_id为空时，prompt不为空时，优先使用prompt
	Engine   string `json:"engine" validate:"omitempty"`           // 生成总结文本的大模型引擎。默认不传，由后台决定
}

// MediaSummaryRsp 音频内容总结返回参数
type MediaSummaryRsp struct {
	MediaId int64  `json:"media_id"` // 音频ID
	State   int32  `json:"state"`    // 状态 0-等待中，1-总结中，2-已完成，3-总结失败
	Content string `json:"content"`  // 总结内容
}

// MediaSummaryStatusReq 音频内容总结结果查询请求参数
type MediaSummaryStatusReq struct {
	MediaId int64 `json:"media_id" schema:"media_id" validate:"required"` // 音频ID
}

// MediaSummaryStatusRsp 音频内容总结结果查询返回参数
type MediaSummaryStatusRsp struct {
	MediaId int64  `json:"media_id"`          // 音频ID
	State   int32  `json:"state"`             // 状态 0-等待中，1-总结中，2-已完成，3-总结失败
	Memo    string `json:"memo,omitempty"`    // 备注，失败时的错误消息
	Content string `json:"content,omitempty"` // 总结内容
}

// MediaSummaryUpdateReq 音频总结内容修改请求参数
type MediaSummaryUpdateReq struct {
	MediaId int64  `json:"media_id" schema:"media_id" validate:"required"` // 音频ID
	Content string `json:"content" schema:"content" validate:"required"`   // 总结内容
}

// MediaSummaryUpdateRsp 音频总结内容修改返回参数
type MediaSummaryUpdateRsp struct {
}

// OrderCreateReq 订单创建请求参数
type OrderCreateReq struct {
	PackageId  int32 `json:"package_id" validate:"required"`  // 套餐ID
	PayChannel int32 `json:"pay_channel" validate:"required"` // 支付渠道 1-paypal, 2-apple pay, 3-alipay, 4-wechat pay
}

type Link struct {
	Method string `json:"method"` // GET/POST
	Href   string `json:"href"`   // 支付链接
}

// OrderCreateRsp 订单创建返回参数
type OrderCreateRsp struct {
	OrderId string `json:"order_id"` // 订单ID
	State   int32  `json:"state"`    // 订单状态 0：初始化，1：待支付，2：已支付成功，3：支付失败/撤销, 4: 已完成(执行发货)...
	Link    Link   `json:"link"`     // paypal支付链接
}

// PaypalReturnReq paypal支付返回请求参数
type PaypalReturnReq struct {
	PaymentId string `json:"token" schema:"token"`
	PayerId   string `json:"payer_id" schema:"PayerID"`
}

// PaypalReturnRsp paypal支付返回返回参数
type PaypalReturnRsp struct {
	OrderId string `json:"order_id"` // 订单ID
	State   int32  `json:"state"`    // 订单状态 0：初始化，1：待支付，2：已支付成功，3：支付失败/撤销, 4: 已完成(执行发货)...
	Memo    string `json:"memo"`     // 备注信息
}

// PaypalCancelReq paypal支付取消请求参数
type PaypalCancelReq struct {
	PaymentId string `json:"token" schema:"token"`
}

// PaypalCancelRsp paypal支付取消返回参数
type PaypalCancelRsp struct {
	OrderId string `json:"order_id"` // 订单ID
	State   int32  `json:"state"`    // 订单状态 0：初始化，1：待支付，2：已支付成功，3：支付失败/撤销, 4: 已完成(执行发货)...
	Memo    string `json:"memo"`     // 备注信息
}

// PaypalSubscriptionReturnReq paypal支付订阅返回请求参数
type PaypalSubscriptionReturnReq struct {
	PaymentId string `json:"subscription_id" schema:"subscription_id"` // 订阅ID
	BaToken   string `json:"ba_token" schema:"ba_token"`               //
	Token     string `json:"token" schema:"token"`                     //
}

// PaypalSubscriptionReturnRsp paypal支付订阅返回返回参数
type PaypalSubscriptionReturnRsp struct {
	OrderId string `json:"order_id"` // 订单ID
	State   int32  `json:"state"`    // 订单状态 0：初始化，1：待支付，2：已支付成功，3：支付失败, 4: 已完成(执行发货)...
	Memo    string `json:"memo"`     // 备注信息
}

// PaypalSubscriptionCancelReq paypal支付订阅取消请求参数
type PaypalSubscriptionCancelReq struct {
	PaymentId string `json:"subscription_id" schema:"subscription_id"` // 订阅ID
	BaToken   string `json:"ba_token" schema:"ba_token"`               //
	Token     string `json:"token" schema:"token"`                     //
}

// PaypalSubscriptionCancelRsp paypal支付订阅取消返回参数
type PaypalSubscriptionCancelRsp struct {
	OrderId string `json:"order_id"` // 订单ID
	State   int32  `json:"state"`    // 订单状态 0：初始化，1：待支付，2：已支付成功，3：支付失败/撤销, 4: 已完成(执行发货)...
	Memo    string `json:"memo"`     // 备注信息
}

type Resource struct {
	Id                 string            `json:"id"`
	CustomId           string            `json:"custom_id"`
	Custom             string            `json:"custom"`
	SupplementaryData  SupplementaryData `json:"supplementary_data"`
	PlanId             string            `json:"plan_id"`
	BillingAgreementId string            `json:"billing_agreement_id"`
	Amount             struct {
		Total    string `json:"total"`
		Currency string `json:"currency"`
	} `json:"amount"`
	State string `json:"state"`
}
type SupplementaryData struct {
	RelatedIds RelatedIds `json:"related_ids"`
}
type RelatedIds struct {
	OrderId string `json:"order_id"`
}

// PaypalNotifyReq paypal支付通知请求参数
type PaypalNotifyReq struct {
	EventType string   `json:"event_type"` // 事件类型
	Resource  Resource `json:"resource"`
}

// PaypalNotifyRsp paypal支付通知返回参数
type PaypalNotifyRsp struct {
}

// OrderDetailReq 订单详情查询请求参数
type OrderDetailReq struct {
	OrderId string `json:"order_id" schema:"order_id"`
}

// OrderDetailRsp 订单详情查询返回参数
type OrderDetailRsp struct {
	OrderDetail
}

// OrderListReq 订单列表查询请求参数
type OrderListReq struct {
	States []int32 `json:"states" schema:"states" validate:"omitempty"`          // 订单状态 0：初始化，1：待支付，2：已支付成功，3：支付失败/撤销, 4: 已完成(执行发货)...
	Page   int32   `json:"page" schema:"page" validate:"required,min=1"`         // 请求页码（从1开始计数）
	Size   int32   `json:"size" schema:"size" validate:"required,min=1,max=100"` // 每页记录数
}

// OrderDetail 订单详情
type OrderDetail struct {
	OrderId     string `json:"order_id"`     // 订单ID
	Amount      int64  `json:"amount"`       // 订单金额
	Currency    string `json:"currency"`     // 币种
	PayTime     string `json:"pay_time"`     // 支付时间(2006-01-02 15:04:05)
	PayChannel  int32  `json:"pay_channel"`  // 支付渠道 1-paypal, 2-apple pay, 3-alipay, 4-wechat pay
	PackageName string `json:"package_name"` // 套餐名称
	State       int32  `json:"state"`        // 订单状态 0：初始化，1：待支付，2：已支付成功，3：支付失败/撤销, 4: 已完成(执行发货)...
}

// OrderListRsp 订单列表查询返回参数
type OrderListRsp struct {
	Page  int32         `json:"page"`  // 请求页码（从1开始计数）
	Size  int32         `json:"size"`  // 每页记录数
	Total int32         `json:"total"` // 总记录数
	Data  []OrderDetail `json:"data"`  // 订单详情列表
}

// CardActivateReq 激活卡请求参数
type CardActivateReq struct {
	CardCode string `json:"card_code" validate:"required,min=1,max=32"` // 激活码
}

// CardActivateRsp 激活卡返回参数
type CardActivateRsp struct {
}

// CardGenerateReq 生成激活卡请求参数
type CardGenerateReq struct {
	CardNo         string `json:"card_no"`          // 卡号,可不传，传入存在则直接返回，不存在则按此卡号创建
	CardExpireTime string `json:"card_expire_time"` // 激活卡过期时间 2006-01-02 15:04:05
	PackageId      int32  `json:"package_id"`       // 套餐ID
}

// CardGenerateRsp 生成激活卡返回参数
type CardGenerateRsp struct {
	// CardNo   string `json:"card_no"`   // 卡号
	// CardPwd  string `json:"card_pwd"`  // 卡密
	CardCode string `json:"card_code"` // 激活码
	State    int32  `json:"state"`     // 状态 1：未激活，2：已激活
}

// UserFeedbackReq 用户反馈请求参数
type UserFeedbackReq struct {
	Content  string `json:"content" validate:"required,min=1,max=4096"`  // 反馈内容
	Contract string `json:"contract" validate:"omitempty,min=0,max=256"` // 联系方式
}

// UserFeedbackRsp 用户反馈返回参数
type UserFeedbackRsp struct {
}

// DeleteAccountReq 账号删除请求参数
type DeleteAccountReq struct {
}

// DeleteAccountRsp 账号删除返回参数
type DeleteAccountRsp struct {
}

// UserAgreementReq 用户协议查询请求参数
type UserAgreementReq struct {
	Lang string `json:"lang" schema:"lang"` // 语言类型 zh/en
}

// UserAgreementRsp 用户协议查询返回参数
type UserAgreementRsp struct {
	Content    string `json:"content"`     // 协议内容
	UpdateTime string `json:"update_time"` // 更新时间(2006-01-02 15:04:05)
}

// PrivacyPolicyReq 隐私政策查询请求参数
type PrivacyPolicyReq struct {
	Lang string `json:"lang" schema:"lang"` // 语言类型 zh/en
}

// PrivacyPolicyRsp 隐私政策查询返回参数
type PrivacyPolicyRsp struct {
	Content    string `json:"content"`     // 隐私政策内容
	UpdateTime string `json:"update_time"` // 更新时间(2006-01-02 15:04:05)
}

// HelpManualsReq 帮助手册查询请求参数
type HelpManualsReq struct {
	Lang string `json:"lang" schema:"lang"` // 语言类型 zh/en
}

// HelpManual 帮助手册记录
type HelpManual struct {
	Question string `json:"question"` // 问题
	Answer   string `json:"answer"`   // 答案
}

// HelpManualsRsp 帮助手册查询返回参数
type HelpManualsRsp struct {
	Data []HelpManual `json:"data"` // 帮助手册内容
}

// AppVersionReq 获取最新版本号请求参数
type AppVersionReq struct {
	Platform       string `json:"platform" schema:"platform" validate:"required,min=1,max=16"`                // 平台 ios/android
	CurrentVersion string `json:"current_version" schema:"current_version" validate:"omitempty,min=1,max=16"` // 当前版本号 v1.0.0
}

// AppVersionRsp 获取最新版本号返回参数
type AppVersionRsp struct {
	LatestVersion string `json:"latest_version"`          // 最新版本号 v1.0.1 (无最新版本时，原参数返回)
	Platform      string `json:"platform"`                // 平台 ios/android
	DownloadUrl   string `json:"download_url,omitempty"`  // 下载地址 (无最新版本时，不返回)
	ReleaseNotes  string `json:"release_notes,omitempty"` // 更新说明：新版本改动
	UpdateTime    string `json:"update_time,omitempty"`   // 更新时间(2006-01-02 15:04:05)
	ForceUpdate   bool   `json:"force_update"`            // 是否强制更新 是-true
}

// AsrEngineModelsReq 转写引擎模型查询请求参数
type AsrEngineModelsReq struct {
	Lang string `json:"lang" schema:"lang"` // 语言类型 zh/en
}

// EngineModel 引擎模型
type EngineModel struct {
	EngineType string `json:"engine_type"` // 引擎类型 16k_zh：中文; 16k_en：英语；...
	EngineDesc string `json:"engine_desc"` // 引擎描述
}

// AsrEngineModelsRsp 转写引擎模型查询返回参数
type AsrEngineModelsRsp struct {
	Data []EngineModel `json:"data"` // 引擎模型列表
}

// PromptTemplatesReq Prompt模板查询请求参数
type PromptTemplatesReq struct {
	Lang string `json:"lang" schema:"lang"` // 语言类型 zh/en
}

// PromptTemplate 模板
type PromptTemplate struct {
	PromptId   string `json:"prompt_id"`   // PromptID
	PromptDesc string `json:"prompt_desc"` // Prompt描述
}

// PromptTemplatesRsp Prompt模板查询返回参数
type PromptTemplatesRsp struct {
	Data []PromptTemplate `json:"data"` // Prompt模板列表
}

// RecordingUploadReq 文件上传请求参数
type RecordingUploadReq struct {
	Req *http.Request `json:"req"`
}

// DeviceInfo 设备信息
type DeviceInfo struct {
	Source          string `json:"source"`          // 数据来源
	Sn              string `json:"sn"`              // 设备序列号
	Status          string `json:"status"`          // 设备状态
	BatteryLevel    string `json:"batteryLevel"`    // 电池电量
	TotalDiskSpace  string `json:"totalDiskSpace"`  // 总磁盘空间
	RemainDiskSpace string `json:"remainDiskSpace"` // 剩余磁盘空间
	NetworkSpeed    string `json:"networkSpeed"`    // 网络速度
	CreateTime      string `json:"create_time"`     // 创建时间（时间戳）
	Duration        string `json:"duration"`        // 音频时长（单位：秒）
	FileName        string `json:"file_name"`       // 文件名
}

// RecordingUploadRsp 文件上传返回参数
type RecordingUploadRsp struct {
	Code     int        `json:"code"`
	Codename string     `json:"codename"`
	Data     DeviceInfo `json:"data"`
	IsError  bool       `json:"isError"`
}

// Message 消息结构
type Message struct {
	Role    string `json:"role"`    // 角色，可选值包括 system、user、assistant、 tool。
	Content string `json:"content"` // 文本内容
}

// ChatCompletionReq 聊天请求参数
type ChatCompletionReq struct {
	Messages []Message `json:"messages"`
}

// ChatCompletionRsp 聊天返回参数
type ChatCompletionRsp struct {
	Messages []Message `json:"messages"`
}

// BleDevice 蓝牙录音笔设备
type BleDevice struct {
	DeviceType                  string `json:"device_type"`                   // 设备类型
	DeviceName                  string `json:"device_name"`                   // 设备名称
	DeviceBleUUID               string `json:"device_uuid"`                   // 设备蓝牙UUID
	DeviceImage                 string `json:"device_image"`                  // 设备图片
	DeviceDesc                  string `json:"device_desc"`                   // 设备描述
	CharacteristicWrite         string `json:"characteristic_write"`          // 特征值-写
	CharacteristicNotify        string `json:"characteristic_notify"`         // 特征值-通知
	CharacteristicBatteryNotify string `json:"characteristic_battery_notify"` // 特征值-电池
}

// BleDeviceListReq 蓝牙设备列表请求参数
type BleDeviceListReq struct {
}

// BleDeviceListRsp 蓝牙设备列表返回参数
type BleDeviceListRsp struct {
	Data []BleDevice `json:"data"`
}

// MediaConvertResetReq 音频转写重置请求参数
type MediaConvertResetReq struct {
	MediaId int64 `json:"media_id" schema:"media_id"` // 音频ID
}

// MediaConvertResetRsp 音频转写重置返回参数
type MediaConvertResetRsp struct {
}
