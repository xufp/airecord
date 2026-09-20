package protocol

// LoginRequest 登录请求
type LoginRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required"`
}

// LoginResponse 登录响应
type LoginResponse struct {
	Msg         string `json:"msg"`
	AccessToken string `json:"access_token"`
}

// CardListRequest 卡列表请求
type CardListRequest struct {
	CardState int32  `json:"status" form:"card_state"`   // 激活码状态：active, void
	CardCode  string `json:"card_code" form:"card_code"` // 激活码
}

// CardInfo 卡信息
type CardInfo struct {
	CardCode         string `json:"card_code"`          // 激活码
	CardExpireTime   string `json:"card_expire_time"`   // 激活卡过期时间
	CardState        int32  `json:"card_state"`         // 激活码状态
	ActivationUserId int64  `json:"activation_user_id"` // 激活用户ID
	ActivationTime   string `json:"activation_time"`    // 激活时间
	CardOrderId      string `json:"card_order_id"`      // 激活卡订单号
	PackageId        int32  `json:"package_id"`         // 套餐ID
	CreateTime       string `json:"create_time"`        // 创建时间
	LastUpdateTime   string `json:"last_update_time"`   // 更新时间
}

// CardListResponse 卡列表响应
type CardListResponse struct {
	Total int64      `json:"total"`
	List  []CardInfo `json:"list"`
}

// CardAddRequest 新增卡请求
type CardAddRequest struct {
	PackageID      int32  `json:"package_id"`       // 套餐ID
	CardExpireTime string `json:"card_expire_time"` // 激活卡过期时间
}

// CardAddResponse 新增卡响应
type CardAddResponse struct {
	Msg      string `json:"msg"`
	CardCode string `json:"card_code"`
}

// CardVoidRequest 作废卡请求
type CardVoidRequest struct {
	CardCode string `json:"card_code" binding:"required"` // 激活码
}

// CardVoidResponse 作废卡响应
type CardVoidResponse struct {
	Msg string `json:"msg"`
}

// UserListRequest 用户列表请求
type UserListRequest struct {
	UserId  int64  `json:"user_id" form:"user_id"` // 用户ID
	Keyword string `json:"keyword" form:"keyword"` // 关键字：用户名/邮箱/电话号码
	State   int32  `json:"state" form:"state"`     // 用户状态
}

// UserInfo 用户信息
type UserInfo struct {
	UserId               int64  `json:"user_id"`                // 用户ID
	NickName             string `json:"nick_name"`              // 用户名称
	Email                string `json:"email"`                  // 邮箱
	Phone                string `json:"phone"`                  // 电话号码
	State                int32  `json:"state"`                  // 用户状态
	CreateTime           string `json:"create_time"`            // 创建时间
	LastLoginTime        string `json:"last_login_time"`        // 最后登录时间
	MembershipLevel      int32  `json:"membership_level"`       // 会员等级
	MembershipExpireTime string `json:"membership_expire_time"` // 会员过期时间
}

// UserListResponse 用户列表响应
type UserListResponse struct {
	Total int64      `json:"total"`
	List  []UserInfo `json:"list"`
}

// UserCancelRequest 用户注销请求
type UserCancelRequest struct {
	UserId int64 `json:"user_id" binding:"required"` // 用户ID
}

// UserCancelResponse 用户注销响应
type UserCancelResponse struct {
	Msg string `json:"msg"`
}

// ConfigListRequest 配置列表请求
type ConfigListRequest struct {
	ConfigType int32  `json:"config_type" form:"config_type"` // 配置类型
	Keyword    string `json:"keyword" form:"keyword"`         // 搜索关键词
}

// ConfigInfo 配置信息
type ConfigInfo struct {
	Id             int32  `json:"id"`
	ConfigType     int32  `json:"config_type"`      // 配置类型
	ConfigKey      string `json:"config_key"`       // 配置键
	ConfigValue    string `json:"config_value"`     // 配置值
	ConfigDesc     string `json:"config_desc"`      // 配置描述
	CreatedTime    string `json:"create_time"`      // 创建时间
	LastUpdateTime string `json:"last_update_time"` // 更新时间
}

// ConfigListResponse 配置列表响应
type ConfigListResponse struct {
	Total int64        `json:"total"`
	List  []ConfigInfo `json:"list"`
}

// ConfigAddRequest 新增配置请求
type ConfigAddRequest struct {
	ConfigType  int32  `json:"config_type" binding:"required"`  // 配置类型
	ConfigKey   string `json:"config_key" binding:"required"`   // 配置键
	ConfigValue string `json:"config_value" binding:"required"` // 配置值
	ConfigDesc  string `json:"config_desc"`                     // 配置描述
}

// ConfigAddResponse 新增配置响应
type ConfigAddResponse struct {
	Msg string `json:"msg"`
}

// ConfigUpdateRequest 修改配置请求
type ConfigUpdateRequest struct {
	Id          int32  `json:"id" binding:"required"`           // 配置ID
	ConfigType  int32  `json:"config_type" binding:"required"`  // 配置类型
	ConfigKey   string `json:"config_key" binding:"required"`   // 配置键
	ConfigValue string `json:"config_value" binding:"required"` // 配置值
	ConfigDesc  string `json:"config_desc"`                     // 配置描述
}

// ConfigUpdateResponse 修改配置响应
type ConfigUpdateResponse struct {
	Msg string `json:"msg"`
}

// ConfigDeleteRequest 删除配置请求
type ConfigDeleteRequest struct {
	Id int64 `json:"id" binding:"required"` // 配置ID
}

// ConfigDeleteResponse 删除配置响应
type ConfigDeleteResponse struct {
	Msg string `json:"msg"`
}

// PackageListRequest 套餐列表请求
type PackageListRequest struct {
	PackageId   int32  `json:"package_id" form:"package_id"`     // 套餐ID
	Keyword     string `json:"keyword" form:"keyword"`           // 关键字：套餐名称/描述
	PackageType int32  `json:"package_type" form:"package_type"` // 套餐类型
}

// PackageInfo 套餐信息
type PackageInfo struct {
	PackageId      int32  `json:"package_id"`       // 套餐ID
	PackageType    int32  `json:"package_type"`     // 套餐类型
	PackageName    string `json:"package_name"`     // 套餐名称
	Description    string `json:"description"`      // 套餐描述
	Price          int64  `json:"price"`            // 套餐总价（单位：分）
	Rates          int64  `json:"rates"`            // 套餐折扣率(%)
	Currency       string `json:"currency"`         // 币种
	BeginDate      string `json:"begin_date"`       // 套餐有效期-开始
	EndDate        string `json:"end_date"`         // 套餐有效期-结束
	CreateTime     string `json:"create_time"`      // 创建时间
	LastUpdateTime string `json:"last_update_time"` // 更新时间
}

// PackageListResponse 套餐列表响应
type PackageListResponse struct {
	Total int64         `json:"total"`
	List  []PackageInfo `json:"list"`
}

// PackageDetailResponse 套餐详情响应
type PackageDetailResponse struct {
	PackageInfo
}

// PackageServiceInfo 套餐服务信息
type PackageServiceInfo struct {
	ServiceId      int32  `json:"service_id"`       // 服务ID
	ServiceType    int32  `json:"service_type"`     // 服务类型
	ServiceName    string `json:"service_name"`     // 服务名称
	Description    string `json:"description"`      // 服务描述
	Quantity       int64  `json:"quantity"`         // 服务量（时长：单位秒）
	Price          int64  `json:"price"`            // 价格（单位：分）
	Currency       string `json:"currency"`         // 币种
	ValidityDays   int32  `json:"validity_days"`    // 服务有效期天数
	CreateTime     string `json:"create_time"`      // 创建时间
	LastUpdateTime string `json:"last_update_time"` // 更新时间
}

// PackageServicesResponse 套餐服务列表响应
type PackageServicesResponse struct {
	Total int64                `json:"total"`
	List  []PackageServiceInfo `json:"list"`
}
