import '../../constant/ErrConstants.dart';

class Credential {
  final int code;
  final String msg;
  final String tmpSecretId; // 临时密钥 Key
  final String tmpSecretKey; // 临时秘钥 请求时需要用的 token 字符串
  final String sessionToken; // 临时秘钥 请求时需要用的 token 字符串
  final int startTime; // 密钥的起始时间 (layout: 2006-01-02 15:04:05)
  final int expiredTime; // 密钥的失效时间 (layout: 2006-01-02 15:04:05)
  final String objectName; // 授权资源对象名称
  final String region; // 地域
  final String bucket; // 桶名称

  Credential({
    required this.code,
    required this.msg,
    required this.tmpSecretId,
    required this.tmpSecretKey,
    required this.sessionToken,
    required this.startTime,
    required this.expiredTime,
    required this.objectName,
    required this.region,
    required this.bucket,
  });

  // 工厂方法: 从JSON数据创建MediaResponse对象
  factory Credential.fromJson(Map<String, dynamic> json) {
    return Credential(
      code: json['code'] ?? ErrConstants.SUCCESS_CODE,
      msg: json['msg'] ?? ErrConstants.SUCCESS_MSG,
      tmpSecretId: (json['tmp_secret_id'] as String?) ?? "",
      tmpSecretKey: (json['tmp_secret_key'] as String?) ?? "",
      sessionToken: (json['session_token'] as String?) ?? "",
      startTime: (json["start_time"] as int?) ?? 0,
      expiredTime: (json["expired_time"] as int?) ?? 0,
      objectName: (json["object_name"] as String?) ?? "",
      region: (json["region"] as String?) ?? "",
      bucket: (json["bucket"] as String?) ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'msg': msg,
      "tmp_secret_id": tmpSecretId,
      "tmp_secret_key": tmpSecretKey,
      "session_token": sessionToken,
      "start_time": startTime,
      "expired_time": expiredTime,
      "object_name": objectName,
      "region": region,
      "bucket": bucket,
    };
  }
}

class MediaUploadCredentialResponse {
  int code;
  String msg;
  int? mediaId; // 音频文件唯一ID
  Credential? credential; // 临时密钥 Id
  int? state;

  MediaUploadCredentialResponse({
    required this.code,
    required this.msg,
    this.mediaId,
    this.credential,
    this.state,
  });

  factory MediaUploadCredentialResponse.fromJson(Map<String, dynamic> json) {
    return MediaUploadCredentialResponse(
      code: json['code'] ?? ErrConstants.SUCCESS_CODE,
      msg: json['msg'] ?? ErrConstants.SUCCESS_MSG,
      mediaId: json['media_id'] ?? 0,
      credential: json['credential'] != null
          ? Credential.fromJson(json['credential'])
          : null,
      state: json['state'] ?? 0,
    );
  }
}
