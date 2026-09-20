// 请求路由配置
class RoutesConfig {
  static const String BASE_URL = 'https://your-api-domain.com/'; // 接口基础路由
  static const String BASE_WSS_URL =
      'wss://your-api-domain.com:443/'; // websocket接口基础路由
  static const String SMS_CODE = 'v1/auth/sms_code'; // 查询当前手机号码的有效验证码
  static const String SMS_LOGIN = 'v1/auth/sms_login'; // 短信验证码登录
  static const String USER_INFO = 'v1/user_info'; // 用户信息获取
  static const String USER_PACKAGE = 'v1/user/package'; // 用户套餐查询
  static const String USER_PACKAGE_GIVE = 'v1/user/package_give'; // 服务套餐包领取
  static const String USER_FEEDBACK = 'v1/user/feedback'; //用户反馈
  static const String MEDIA_UPLOAD = 'v1/media/upload'; // 音频文件上传
  static const String MEDIA_CONVERT = 'v1/media/convert'; // 音频文件转写
  static const String MEDIA_SPEECH = 'v1/media/speech'; // 音频文件流转写
  static const String CARD_ACTIVATE = 'v1/card/activate'; // 激活会员
  static const String MEDIA_UPLOAD_CREDENTIAL =
      "v1/media/upload/credential"; // 音频文件上传秘钥获取（云存储临时秘钥）
  static const String MEDIA_CONVERT_STATUS =
      "v1/media/convert/status"; // 音频转写状态查询

  static const String MEDIA_CONVERT_RESET =
      "v1/media/convert/reset"; // 音频文件上传秘钥获取（云存储临时秘钥）
  static const String MEDIA_UPLOAD_ACK = "v1/media/upload/ack"; // 音频文件上传完成确认
  static const String MEDIA_REMOVE = "v1/media/remove"; // 音频文件删除
  static const String MEDIA_SYNC = "v1/media/sync"; // 音频信息同步（云端->本地）
  static const String MEDIA_URL = "v1/media/url"; // 音频文件链接获取
  static const String MEDIA_CONVERT_RECORDS = "v1/media/convert/records"; // 音频文件链接获取
  static const String EMAIL_LOGIN = "v1/auth/login"; // 邮箱登录
  static const String EMAIL_REGISTER = "v1/auth/register"; // 邮箱注册
  static const String VERIFY_CODE = "v1/auth/verify_code"; // 验证码
  static const String RESET_PASSWORD = "v1/auth/reset_password"; // 重置密码
  static const String GET_CODE = "v1/auth/get_code"; // 获取验证码
  static const String MEDIA_SUMMARY = 'v1/media/summary'; // 音频文件总结
  static const String MEDIA_SUMMARY_STATUS = 'v1/media/summary/status'; // 音频文件总结状态
  static const String MEDIA_UPDATE = 'v1/media/update'; // 音频文件总结
  static const String PACKAGES_AVAILABLE = 'v1/packages/available'; //用户可购买(领取)套餐查询
  static const String ORDER_CREATE = 'v1/order/create'; //订单创建
  static const String ORDER_DETAIL = 'v1/order/detail'; //订单详情查询
  static const String ORDER_LIST = 'v1/order/list'; //订单列表查询

  static const String USER_AGREEMENT = 'v1/user_agreement'; //用户协议
  static const String PRIVACY_POLICY = 'v1/privacy_policy'; //隐私政策
  static const String HELP_MANUALS = 'v1/help_manuals'; //帮助手册
  static const String APP_VERSION = 'v1/app_version'; //app版本信息
  static const String ASR_ENGINE_MODELS = 'v1/asr_engine_models'; //语音识别引擎模型列表
  static const String PROMPT_TEMPLATES = 'v1/prompt_templates'; //prompt模板列表
  static const String BLE_DEVICE_LIST = 'v1/ble/device/list'; //获取蓝牙设备列表
  static const String CHAT_GPT = 'v1/chat'; //GPT对话
  static const String DELETE_ACCOUNT = 'v1/user/delete_account'; //删除账号
}
