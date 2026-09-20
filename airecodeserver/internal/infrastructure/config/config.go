package config

import (
	tconfig "trpc.group/trpc-go/trpc-go/config"
)

var (
	serverConf *ServerConfig
)

type ServerConfig struct {
	Global  GlobalCfg  `yaml:"global"`
	Auth    AuthCfg    `yaml:"auth"`
	Media   MediaCfg   `yaml:"media"`
	Gpt     GptCfg     `yaml:"gpt"`
	Payment PaymentCfg `yaml:"payment"`
	Crontab CrontabCfg `yaml:"crontab"`
	Admin   AdminCfg   `yaml:"admin"`
}

type GlobalCfg struct {
	WorkerId int64 `yaml:"worker_id"`
}

type SmsCodeCfg struct {
	Expire     int32  `yaml:"expire"`      // 验证码过期时间（单位/秒）
	Endpoint   string `yaml:"endpoint"`    // 接入域名
	SecretId   string `yaml:"secret_id"`   // 腾讯云账户密钥对 SecretId
	SecretKey  string `yaml:"secret_key"`  // 腾讯云账户密钥对 SecretKey
	AppId      string `yaml:"app_id"`      // 短信应用ID
	SignName   string `yaml:"sign_name"`   // 短信签名
	TemplateId string `yaml:"template_id"` // 短信模版ID
	Enable     bool   `yaml:"enable"`      // 配置是否启用短信验证码登录功能
	IsTest     bool   `yaml:"is_test"`     // 是否用于测试，测试时不调用api发送短信
}

type EmailCfg struct {
	Enable   bool   `yaml:"enable"`    // 是否启用本功能选项
	Expire   int32  `yaml:"expire"`    // 验证码过期时间（单位/秒）
	SmtpHost string `yaml:"smtp_host"` // smtp host
	SmtpPort int32  `yaml:"smtp_port"` // smtp port
	UserName string `yaml:"username"`  // 发件人邮箱地址
	Password string `yaml:"password"`  // 发件人邮箱密码
}

type TokenCfg struct {
	Expire     int32 `yaml:"expire"`      // token过期时间(单位: 分钟)
	TempExpire int32 `yaml:"temp_expire"` // 临时token过期时间(单位: 分钟)
}

type ThirdOAuthCfg struct {
	Wechat WechatCfg `yaml:"wechat"`
}

type WechatCfg struct {
	AppId     string `yaml:"app_id"`
	AppSecret string `yaml:"app_secret"`
}

type AuthCfg struct {
	SmsCode    SmsCodeCfg    `yaml:"sms_code"`
	Token      TokenCfg      `yaml:"token"`
	ThirdOAuth ThirdOAuthCfg `yaml:"third_oauth"`
	Email      EmailCfg      `yaml:"email"`
}

type MediaCfg struct {
	SupportFormat []string   `yaml:"support_format"`
	Storage       StorageCft `yaml:"storage"`
	Asr           AsrCfg     `yaml:"asr"`
}

type CosCfg struct {
	Host      string `yaml:"host"`
	AppId     string `yaml:"app_id"`
	SecretId  string `yaml:"secret_id"`
	SecretKey string `yaml:"secret_key"`
	Region    string `yaml:"region"`
	Bucket    string `yaml:"bucket"`
	Path      string `yaml:"path"`
	Expire    int64  `yaml:"expire"`
}

type StorageCft struct {
	Path string `yaml:"path"` // 本地文件存储路径
	Cos  CosCfg `yaml:"cos"`  // cos配置
}

const (
	StorageModeFilePrefix = "file://"
	StorageModeCosPrefix  = "cos://"
)

type AsrCfg struct {
	AppId     string `yaml:"app_id"`
	SecretId  string `yaml:"secret_id"`
	SecretKey string `yaml:"secret_key"`
}

type HunYuanCfg struct {
	AppId     string `yaml:"app_id"`
	SecretId  string `yaml:"secret_id"`
	SecretKey string `yaml:"secret_key"`
	Model     string `yaml:"model"`
}

type OpenAiCfg struct {
	ApiType    string `yaml:"api_type"`    // API类型 openai or azure
	SecretKey  string `yaml:"secret_key"`  //	密钥
	Model      string `yaml:"model"`       // 模型
	BaseUrl    string `yaml:"base_url"`    // Azure填写Base url
	ApiVersion string `yaml:"api_version"` // Azure填写Api version
}

const (
	OpenAiApiTypeOpenAi = "openai"
	OpenAiApiTypeAzure  = "azure"
)

type GptCfg struct {
	TextLimit int        `yaml:"text_limit"` // GPT最低文本长度限制
	Default   string     `yaml:"default"`    // 默认GPT引擎
	HunYuan   HunYuanCfg `yaml:"hunyuan"`    // GPT引擎-hunyuan
	OpenAi    OpenAiCfg  `yaml:"openai"`     // GPT引擎-openai
}

type PayPalCfg struct {
	ClientId              string `yaml:"client_id"`
	Secret                string `yaml:"secret"`
	IsSandbox             bool   `yaml:"is_sandbox"`
	ReturnUrl             string `yaml:"return_url"`
	CancelUrl             string `yaml:"cancel_url"`
	SubscriptionReturnUrl string `yaml:"subscription_return_url"`
	SubscriptionCancelUrl string `yaml:"subscription_cancel_url"`
	WebBaseUrl            string `yaml:"web_base_url"` // 前端页面基路径，用于支付完成后 redirect（如 https://airecord.smarto.top/shop）
}

type PaymentCfg struct {
	Enable bool      `yaml:"enable"`
	PayPal PayPalCfg `yaml:"paypal"`
}

type CrontabCfg struct {
	AudioRecStatus string `yaml:"audio_rec_status"`
}

type AdminCfg struct {
	Enable     bool   `yaml:"enable"`      // 是否启用本功能选项
	HtmlPath   string `yaml:"html_path"`   // html文件路径
	StaticPath string `yaml:"static_path"` // 静态文件路径
	AssetsPath string `yaml:"assets_path"` // 静态文件路径
}

// InitServerConfig 服务配置初始化
func InitServerConfig(path string) error {
	cfgBuf, err := tconfig.Load(path)
	if err != nil {
		return err
	}

	conf := &ServerConfig{}
	err = cfgBuf.Unmarshal(conf)
	if err != nil {
		return err
	}

	serverConf = conf
	return nil
}

func GetServerConfig() *ServerConfig {
	return serverConf
}
