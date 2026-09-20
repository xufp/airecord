package objectstorage

// Credential 临时密钥
type Credential struct {
	TmpSecretID  string `json:"tmp_secret_id"`  // 临时密钥 Id
	TmpSecretKey string `json:"tmp_secret_key"` // 临时密钥 Key
	SessionToken string `json:"session_token"`  // 临时秘钥 请求时需要用的 token 字符串
	StartTime    int    `json:"start_time"`     // 密钥的起始时间（unix时间戳）
	ExpiredTime  int    `json:"expired_time"`   // 密钥的失效时间（unix时间戳）
	ObjectName   string `json:"object_name"`    // 授权资源对象名称（允许操作的资源路径）
}
