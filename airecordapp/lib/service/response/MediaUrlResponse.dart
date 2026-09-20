import 'package:json_annotation/json_annotation.dart';

import '../../constant/ErrConstants.dart';

@JsonSerializable()
class MediaUrlResponse {
  final int code;
  final String msg;
  final int mediaId;
  final String url;

  MediaUrlResponse({
    required this.code,
    required this.msg,
    required this.mediaId,
    required this.url,
  });

  // 用于生成类的工厂方法
  factory MediaUrlResponse.fromJson(Map<String, dynamic> json) {
    return MediaUrlResponse(
      code: json['code'] ?? ErrConstants.SUCCESS_CODE,
      msg: json['msg'] ?? ErrConstants.SUCCESS_MSG,
      mediaId: (json['media_id'] as num?)?.toInt() ?? 0,
      url: (json['url'] as String?) ?? "",
    );
  }

  // 用于将类转换成 JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'msg': msg,
      'media_id': mediaId,
      'url': url,
    };
  }
}
