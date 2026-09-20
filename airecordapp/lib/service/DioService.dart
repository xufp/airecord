import 'package:airecordapp/constant/ErrConstants.dart';
import 'package:airecordapp/db/Cache.dart';
import 'package:airecordapp/service/request/ActivateMemberRequest.dart';
import 'package:airecordapp/service/request/ChatGPTRequest.dart';
import 'package:airecordapp/service/request/CreateOrderRequest.dart';
import 'package:airecordapp/service/request/EmailLoginRequest.dart';
import 'package:airecordapp/service/request/FeedBackRequest.dart';
import 'package:airecordapp/service/request/GetAppVersionRequest.dart';
import 'package:airecordapp/service/request/GetCodeRequest.dart';
import 'package:airecordapp/service/request/GetHelpManualsRequest.dart';
import 'package:airecordapp/service/request/GetPrivacyPolicyRequest.dart';
import 'package:airecordapp/service/request/GetPromptTemplatesRequest.dart';
import 'package:airecordapp/service/request/GetUserAgreementRequest.dart';
import 'package:airecordapp/service/request/MediaConvertRecordsRequest.dart';
import 'package:airecordapp/service/request/MediaConvertResetRequest.dart';
import 'package:airecordapp/service/request/MediaSummaryRequest.dart';
import 'package:airecordapp/service/request/MediaSummaryStatusRequest.dart';
import 'package:airecordapp/service/request/MediaUpdateRequest.dart';
import 'package:airecordapp/service/request/OrderDetailRequest.dart';
import 'package:airecordapp/service/request/OrderListRequest.dart';
import 'package:airecordapp/service/request/PackageAvailableRequest.dart';
import 'package:airecordapp/service/request/ResetPasswordRequest.dart';
import 'package:airecordapp/service/request/UserPackageGiveRequest.dart';
import 'package:airecordapp/service/request/VerifyCodeRequest.dart';
import 'package:airecordapp/service/response/ActivateMemberResponse.dart';
import 'package:airecordapp/service/response/BleDeviceResponse.dart';
import 'package:airecordapp/service/response/ChatGPTResponse.dart';
import 'package:airecordapp/service/response/CreateOrderResponse.dart';
import 'package:airecordapp/service/response/EmailLoginResponse.dart';
import 'package:airecordapp/service/response/FeedBackResponse.dart';
import 'package:airecordapp/service/response/GetAppVersionResponse.dart';
import 'package:airecordapp/service/response/GetCodeResponse.dart';
import 'package:airecordapp/service/response/GetHelpManualsResponse.dart';
import 'package:airecordapp/service/response/GetPrivacyPolicyResponse.dart';
import 'package:airecordapp/service/response/GetPromptTemplatesResponse.dart';
import 'package:airecordapp/service/response/GetUserAgreementResponse.dart';
import 'package:airecordapp/service/response/MediaConvertRecordsResponse.dart';
import 'package:airecordapp/service/response/MediaConvertResetResponse.dart';
import 'package:airecordapp/service/response/MediaSummaryResponse.dart';
import 'package:airecordapp/service/response/MediaSummaryStatusResponse.dart';
import 'package:airecordapp/service/response/MediaUpdateResponse.dart';
import 'package:airecordapp/service/response/OrderDetailResponse.dart';
import 'package:airecordapp/service/response/OrderListResponse.dart';
import 'package:airecordapp/service/response/PackageAvailableResponse.dart';
import 'package:airecordapp/service/response/ResetPasswordResponse.dart';
import 'package:airecordapp/service/response/VerifyCodeResponse.dart';
import 'request/MediaConvertStatusRequest.dart';
import 'request/MediaRemoveRequest.dart';
import 'request/MediaUploadAckRequest.dart';
import 'request/MediaUploadCredentialRequest.dart';
import 'request/UerPackageRequest.dart';
import 'response/MediaUploadAckResponse.dart';
import 'response/MediaUploadCredentialResponse.dart';
import 'package:flutter/material.dart';
import 'request/MediaConvertRequest.dart';
import 'request/MediaUploadRequest.dart';
import 'request/SmsCodeRequest.dart';
import 'request/SmsLoginRequest.dart';
import 'request/UserInfoRequest.dart';
import 'response/SmsCodeResponse.dart';
import 'request/MediaSyncRequest.dart';
import 'request/MediaUrlRequest.dart';
import 'response/MediaConvertResponse.dart';
import 'response/MediaConvertStatusResponse.dart';
import 'response/MediaRemoveResponse.dart';
import 'response/MediaSyncResponse.dart';
import 'response/MediaUploadResponse.dart';
import 'response/MediaUrlResponse.dart';
import 'response/SmsLoginResponse.dart';
import 'response/UerPackageResponse.dart';
import 'response/UserInfoResponse.dart';
import 'response/UserPackageGiveResponse.dart';
import '../client/DioClient.dart';
import '../config/RoutesConfig.dart';
import 'request/GetAsrEngineModelsRequest.dart';
import 'response/GetAsrEngineModelsResponse.dart';
import 'response/DeleteAccountResponse.dart';

class DioService {
  static DioClient _dioClient = DioClient();
  static DioClient _dioCLientNoAuth = DioClient(isAuth: false);

  // 获取手机验证码
  static Future<SmsCodeResponse> smsCode(
      {required BuildContext context, required SmsCodeRequest req}) async {
    Map<String, dynamic> apiResponse = await _dioCLientNoAuth.jsonPost(
        route: RoutesConfig.SMS_CODE, req: req) as Map<String, dynamic>;
    SmsCodeResponse response = SmsCodeResponse.fromJson(apiResponse);
    if (response.code == ErrConstants.SUCCESS_CODE) {
      showSnackBarSuccess(context, '获取验证码成功了');
    } else {
      showSnackBarFail(context, '获取验证码失败');
    }
    return response;
  }

  // 短信验证码登录
  static Future<SmsLoginResponse> smsLogin(
      {required BuildContext context, required SmsLoginRequest req}) async {
    Map<String, dynamic> apiResponse = await _dioCLientNoAuth.jsonPost(
        route: RoutesConfig.SMS_LOGIN, req: req) as Map<String, dynamic>;
    SmsLoginResponse response = SmsLoginResponse.fromJson(apiResponse);
    if (response.code == ErrConstants.SUCCESS_CODE &&
        response.accessToken != null) {
      // 设置登录token
      await Cache.saveToken(response.accessToken ?? "", req.phone);
      showSnackBarSuccess(context, '登录成功了');
    } else {
      showSnackBarFail(context, '验证码不正确');
    }
    return response;
  }

  // 邮箱密码登录
  static Future<EmailLoginResponse> emailLogin(
      {required BuildContext context, required EmailLoginRequest req}) async {
    Map<String, dynamic> apiResponse = await _dioCLientNoAuth.jsonPost(
        route: RoutesConfig.EMAIL_LOGIN, req: req) as Map<String, dynamic>;
    EmailLoginResponse response = EmailLoginResponse.fromJson(apiResponse);
    return response;
  }

  // 邮箱注册
  static Future<EmailLoginResponse> emailRegister(
      {required BuildContext context, required EmailLoginRequest req}) async {
    Map<String, dynamic> apiResponse = await _dioCLientNoAuth.jsonPost(
        route: RoutesConfig.EMAIL_REGISTER, req: req) as Map<String, dynamic>;
    EmailLoginResponse response = EmailLoginResponse.fromJson(apiResponse);
    return response;
  }

  // 获取验证码
  static Future<GetCodeResponse> getCode(
      {required BuildContext context, required GetCodeRequest req}) async {
    Map<String, dynamic> apiResponse = await _dioCLientNoAuth.jsonPost(
        route: RoutesConfig.GET_CODE, req: req) as Map<String, dynamic>;
    GetCodeResponse response = GetCodeResponse.fromJson(apiResponse);
    return response;
  }

  // 验证码验证
  static Future<VerifyCodeResponse> verifyCode(
      {required BuildContext context, required VerifyCodeRequest req}) async {
    Map<String, dynamic> apiResponse = await _dioCLientNoAuth.jsonPost(
        route: RoutesConfig.VERIFY_CODE, req: req) as Map<String, dynamic>;
    VerifyCodeResponse response = VerifyCodeResponse.fromJson(apiResponse);
    return response;
  }

  // 密码重置阶段：第一步获取验证码
  static Future<ResetPasswordResponse> sendCodeByResetPassword(
      {required BuildContext context,
      required ResetPasswordRequest req}) async {
    Map<String, dynamic> apiResponse = await _dioCLientNoAuth.jsonPost(
        route: RoutesConfig.RESET_PASSWORD, req: req) as Map<String, dynamic>;
    ResetPasswordResponse response =
        ResetPasswordResponse.fromJson(apiResponse);
    return response;
  }

  // 密码重置阶段：第二步重置密码
  static Future<ResetPasswordResponse> resetPassword(
      {required BuildContext context,
      required ResetPasswordRequest req}) async {
    Map<String, dynamic> apiResponse = await _dioCLientNoAuth.jsonPost(
        route: RoutesConfig.RESET_PASSWORD, req: req) as Map<String, dynamic>;
    ResetPasswordResponse response =
        ResetPasswordResponse.fromJson(apiResponse);
    return response;
  }

  // 用户信息获取
  static Future<UserInfoResponse> userInfo() async {
    UserInfoRequest req = UserInfoRequest();
    Map<String, dynamic> apiResponse = await _dioClient.get(
        route: RoutesConfig.USER_INFO, req: req) as Map<String, dynamic>;
    UserInfoResponse response = UserInfoResponse.fromJson(apiResponse);
    return response;
  }

  // 用户套餐查询
  static Future<UerPackageResponse> userPackage() async {
    UerPackageRequest uerPackageRequest = UerPackageRequest();
    Map<String, dynamic> apiResponse = await _dioClient.get(
        route: RoutesConfig.USER_PACKAGE,
        req: uerPackageRequest) as Map<String, dynamic>;
    UerPackageResponse response = UerPackageResponse.fromJson(apiResponse);
    return response;
  }

  // 激活会员
  static Future<ActivateMemberResponse> activateMember(
      ActivateMemberRequest req) async {
    Map<String, dynamic> apiResponse = await _dioClient.jsonPost(
        route: RoutesConfig.CARD_ACTIVATE, req: req) as Map<String, dynamic>;
    ActivateMemberResponse response =
        ActivateMemberResponse.fromJson(apiResponse);
    return response;
  }

  // 服务套餐包领取
  // - [context] 传入时会在成功/失败后弹出 SnackBar 提示；不传（或不需要 UI 反馈的场景，
  //   例如注册成功后自动领取）则保持静默。
  // - [req] 必须携带 package_id，服务端强制校验 required。
  static Future<UserPackageGiveResponse> userPackageGive({
    required UserPackageGiveRequest req,
    BuildContext? context,
  }) async {
    Map<String, dynamic> apiResponse = await _dioClient.jsonPost(
        route: RoutesConfig.USER_PACKAGE_GIVE, req: req) as Map<String, dynamic>;
    UserPackageGiveResponse response =
        UserPackageGiveResponse.fromJson(apiResponse);
    if (context != null) {
      if (response.code == ErrConstants.SUCCESS_CODE) {
        showSnackBarSuccess(context, '成功');
      } else {
        showSnackBarFail(context, '失败了');
      }
    }
    return response;
  }


  // 用户反馈
  static Future<FeedBackResponse> userFeedBack(
      FeedBackRequest req) async {
    Map<String, dynamic> apiResponse = await _dioClient.jsonPost(
        route: RoutesConfig.USER_FEEDBACK, req: req) as Map<String, dynamic>;
    FeedBackResponse response = FeedBackResponse.fromJson(apiResponse);
    return response;
  }

  // 音频文件上传
  static Future<MediaUploadResponse> mediaUpload(
      {required BuildContext context,
      required String filePath,
      required String fileName,
      MediaUploadRequest? req}) async {
    Map<String, dynamic> apiResponse = await _dioClient.uploadFile(
        filePath: filePath,
        fileName: fileName,
        route: RoutesConfig.MEDIA_UPLOAD,
        req: req) as Map<String, dynamic>;
    MediaUploadResponse response = MediaUploadResponse.fromJson(apiResponse);
    return response;
  }

  // 音频文件上传秘钥获取（云存储临时秘钥）
  static Future<MediaUploadCredentialResponse> mediaUploadCredential(
      MediaUploadCredentialRequest req) async {
    Map<String, dynamic> apiResponse = await _dioClient.jsonPost(
        route: RoutesConfig.MEDIA_UPLOAD_CREDENTIAL, req: req);
    MediaUploadCredentialResponse response =
        MediaUploadCredentialResponse.fromJson(apiResponse);
    return response;
  }

  // 音频文件转写
  static Future<MediaConvertResponse> mediaConvert(
      MediaConvertRequest req) async {
    Map<String, dynamic> apiResponse = await _dioClient.jsonPost(
        route: RoutesConfig.MEDIA_CONVERT, req: req) as Map<String, dynamic>;
    MediaConvertResponse response = MediaConvertResponse.fromJson(apiResponse);
    return response;
  }

  // 音频文件上传确认
  static Future<MediaUploadAckResponse> mediaUploadAck(
      MediaUploadAckRequest req) async {
    Map<String, dynamic> apiResponse = await _dioClient.jsonPost(
        route: RoutesConfig.MEDIA_UPLOAD_ACK, req: req);
    MediaUploadAckResponse response =
        MediaUploadAckResponse.fromJson(apiResponse);
    return response;
  }

  // 音频信息删除
  static Future<MediaRemoveResponse> mediaRemove(MediaRemoveRequest req) async {
    Map<String, dynamic> apiResponse =
        await _dioClient.jsonPost(route: RoutesConfig.MEDIA_REMOVE, req: req);
    MediaRemoveResponse response = MediaRemoveResponse.fromJson(apiResponse);
    return response;
  }

  // 音频转写状态查询
  static Future<MediaConvertStatusResponse> mediaConvertStatus(
      MediaConvertStatusRequest req) async {
    Map<String, dynamic> apiResponse = await _dioClient.get(
        route: RoutesConfig.MEDIA_CONVERT_STATUS, req: req);
    MediaConvertStatusResponse response =
        MediaConvertStatusResponse.fromJson(apiResponse);
    return response;
  }

  // 音频信息云端同步
  static Future<MediaSyncResponse> mediaSync(MediaSyncRequest req) async {
    Map<String, dynamic> apiResponse =
        await _dioClient.get(route: RoutesConfig.MEDIA_SYNC, req: req);
    MediaSyncResponse response = MediaSyncResponse.fromJson(apiResponse);
    return response;
  }

  // 音频信息云端同步
  static Future<MediaUrlResponse> mediaUrl(MediaUrlRequest req) async {
    Map<String, dynamic> apiResponse =
        await _dioClient.get(route: RoutesConfig.MEDIA_URL, req: req);
    MediaUrlResponse response = MediaUrlResponse.fromJson(apiResponse);
    return response;
  }

  // 音频文件总结
  static Future<MediaSummaryResponse> mediaSummary(
      MediaSummaryRequest req) async {
    Map<String, dynamic> apiResponse = await _dioClient.jsonPost(
        route: RoutesConfig.MEDIA_SUMMARY,
        req: req,
        receiveTimeout: const Duration(minutes: 2)) as Map<String, dynamic>;
    MediaSummaryResponse response = MediaSummaryResponse.fromJson(apiResponse);
    return response;
  }

  // 音频文件总结状态查询
  static Future<MediaSummaryStatusResponse> mediaSummaryStatus(
      MediaSummaryStatusRequest req) async {
    Map<String, dynamic> apiResponse = await _dioClient.get(
        route: RoutesConfig.MEDIA_SUMMARY_STATUS,
        req: req,
        receiveTimeout: const Duration(minutes: 2)) as Map<String, dynamic>;
    MediaSummaryStatusResponse response =
        MediaSummaryStatusResponse.fromJson(apiResponse);
    return response;
  }

  // 音频文件名称更改
  static Future<MediaUpdateResponse> mediaUpdate(MediaUpdateRequest req) async {
    Map<String, dynamic> apiResponse = await _dioClient.jsonPost(
        route: RoutesConfig.MEDIA_UPDATE, req: req) as Map<String, dynamic>;
    MediaUpdateResponse response = MediaUpdateResponse.fromJson(apiResponse);
    return response;
  }

  // 查询转写记录
  static Future<MediaConvertRecordsResponse> queryConvertRecord(
      MediaConvertRecordsRequest req) async {
    Map<String, dynamic> apiResponse = await _dioClient.get(
        route: RoutesConfig.MEDIA_CONVERT_RECORDS,
        req: req) as Map<String, dynamic>;
    MediaConvertRecordsResponse response =
        MediaConvertRecordsResponse.fromJson(apiResponse);
    return response;
  }

  // 重置转写记录
  static Future<MediaConvertResetResponse> resetConvertRecord(
      MediaConvertResetRequest req) async {
    Map<String, dynamic> apiResponse = await _dioClient.jsonPost(
        route: RoutesConfig.MEDIA_CONVERT_RESET, req: req);
    MediaConvertResetResponse response =
    MediaConvertResetResponse.fromJson(apiResponse);
    return response;
  }


  /**
   * 更新服务器端文件名
   */
  static Future<MediaUpdateResponse> updateRemoteFileName(
      int mediaId, String fileName) async {
    MediaUpdateRequest request =
        MediaUpdateRequest(mediaId: mediaId, mediaName: fileName);
    //调用后端更改文件名操作
    return DioService.mediaUpdate(request);
  }

  // 查询用户可购买的套餐包
  static Future<PackageAvailableResponse> queryPackageAvailable(
      PackageAvailableRequest req) async {
    Map<String, dynamic> apiResponse = await _dioClient.get(
        route: RoutesConfig.PACKAGES_AVAILABLE,
        req: req) as Map<String, dynamic>;
    PackageAvailableResponse response =
        PackageAvailableResponse.fromJson(apiResponse);
    return response;
  }

  // 订单创建
  static Future<CreateOrderResponse> createOrder(CreateOrderRequest req) async {
    Map<String, dynamic> apiResponse = await _dioClient.jsonPost(
        route: RoutesConfig.ORDER_CREATE, req: req) as Map<String, dynamic>;
    CreateOrderResponse response = CreateOrderResponse.fromJson(apiResponse);
    return response;
  }

  // 订单详情查询
  static Future<OrderDetailResponse> queryOrderDetail(
      OrderDetailRequest req) async {
    Map<String, dynamic> apiResponse = await _dioClient.get(
        route: RoutesConfig.ORDER_DETAIL, req: req) as Map<String, dynamic>;
    OrderDetailResponse response = OrderDetailResponse.fromJson(apiResponse);
    return response;
  }

  // 订单列表查询
  static Future<OrderListResponse> queryOrderList(OrderListRequest req) async {
    Map<String, dynamic> apiResponse = await _dioClient.get(
        route: RoutesConfig.ORDER_LIST, req: req) as Map<String, dynamic>;
    OrderListResponse response = OrderListResponse.fromJson(apiResponse);
    return response;
  }

  // 获取用户协议
  static Future<GetUserAgreementResponse> getUserAgreement(
      GetUserAgreementRequest req) async {
    Map<String, dynamic> apiResponse = await _dioClient.get(
        route: RoutesConfig.USER_AGREEMENT, req: req) as Map<String, dynamic>;
    GetUserAgreementResponse response =
        GetUserAgreementResponse.fromJson(apiResponse);
    return response;
  }

  // 获取隐私手册
  static Future<GetPrivacyPolicyResponse> getPrivacyPolicy(
      GetPrivacyPolicyRequest req) async {
    Map<String, dynamic> apiResponse = await _dioClient.get(
        route: RoutesConfig.PRIVACY_POLICY, req: req) as Map<String, dynamic>;
    GetPrivacyPolicyResponse response =
        GetPrivacyPolicyResponse.fromJson(apiResponse);
    return response;
  }

  // 获取帮助手册
  static Future<GetHelpManualsResponse> getHelpManuals(
      GetHelpManualsRequest req) async {
    Map<String, dynamic> apiResponse = await _dioClient.get(
        route: RoutesConfig.HELP_MANUALS, req: req) as Map<String, dynamic>;
    GetHelpManualsResponse response =
        GetHelpManualsResponse.fromJson(apiResponse);
    return response;
  }

  // 获取最新应用版本
  static Future<GetAppVersionResponse> getAppVersion(
      GetAppVersionRequest req) async {
    Map<String, dynamic> apiResponse = await _dioClient.get(
        route: RoutesConfig.APP_VERSION, req: req) as Map<String, dynamic>;
    GetAppVersionResponse response =
        GetAppVersionResponse.fromJson(apiResponse);
    return response;
  }

// 获取总结模板
  static Future<GetPromptTemplatesResponse> getPromptTemplates(
      GetPromptTemplatesRequest req) async {
    Map<String, dynamic> apiResponse = await _dioClient.get(
        route: RoutesConfig.PROMPT_TEMPLATES, req: req) as Map<String, dynamic>;
    GetPromptTemplatesResponse response =
        GetPromptTemplatesResponse.fromJson(apiResponse);
    return response;
  }

  // 获取蓝牙设备列表
  static Future<BleDeviceResponse> bleDeviceList() async {
    Map<String, dynamic> apiResponse = await _dioClient.get(
        route: RoutesConfig.BLE_DEVICE_LIST) as Map<String, dynamic>;
    BleDeviceResponse response = BleDeviceResponse.fromJson(apiResponse);
    return response;
  }

  // GPT对话
  static Future<ChatGPTResponse> chatGPT(ChatGPTRequest req) async {
    Map<String, dynamic> apiResponse = await _dioClient.jsonPost(
        route: RoutesConfig.CHAT_GPT,
        req: req,
        receiveTimeout: const Duration(minutes: 2)) as Map<String, dynamic>;
    ChatGPTResponse response = ChatGPTResponse.fromJson(apiResponse);
    return response;
  }

  // 获取转写引擎模型列表
  static Future<GetAsrEngineModelsResponse> getAsrEngineModels(GetAsrEngineModelsRequest req) async {
    Map<String, dynamic> apiResponse = await _dioClient.get(
        route: RoutesConfig.ASR_ENGINE_MODELS, req: req) as Map<String, dynamic>;
    GetAsrEngineModelsResponse response = GetAsrEngineModelsResponse.fromJson(apiResponse);
    return response;
  }

  // 删除账号
  static Future<DeleteAccountResponse> deleteAccount() async {
    Map<String, dynamic> apiResponse = await _dioClient.jsonPost(
        route: RoutesConfig.DELETE_ACCOUNT) as Map<String, dynamic>;
    DeleteAccountResponse response = DeleteAccountResponse.fromJson(apiResponse);
    return response;
  }
}

void showSnackBarFail(BuildContext context, String message) {
  final snackBar = SnackBar(
    content: Center(
      child: Text(
        message,
        style: const TextStyle(color: Colors.red), // 文本颜色
      ),
    ),
    backgroundColor: Colors.transparent, // 设置背景为透明
    behavior: SnackBarBehavior.floating, // 使 SnackBar 浮动
    duration: const Duration(seconds: 1),
    elevation: 0, // 去除阴影
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void showSnackBarSuccess(BuildContext context, String message) {
  final snackBar = SnackBar(
    content: Center(
      child: Text(
        message,
        style: const TextStyle(color: Colors.green), // 文本颜色
      ),
    ),
    backgroundColor: Colors.transparent, // 设置背景为透明
    behavior: SnackBarBehavior.floating, // 使 SnackBar 浮动
    duration: const Duration(seconds: 1),
    elevation: 0, // 去除阴影
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
