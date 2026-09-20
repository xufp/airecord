import 'package:airecordapp/constant/ErrConstants.dart';
import 'package:airecordapp/service/response/Link.dart';
import 'package:airecordapp/service/response/MediaConvertRecord.dart';
import 'package:airecordapp/service/response/PackageRecord.dart';

class GetPrivacyPolicyResponse {
  int code;
  String msg;
  String? content;
  String? updateTime;

  GetPrivacyPolicyResponse({
    required this.code,
    required this.msg,
     this.content,
     this.updateTime,
  });

  factory GetPrivacyPolicyResponse.fromJson(Map<String, dynamic> json) {
    return GetPrivacyPolicyResponse(
      code: json['code'] ?? ErrConstants.SUCCESS_CODE,
      msg: json['msg'] ?? ErrConstants.SUCCESS_MSG,
      content: json['content'],
      updateTime: json['update_time'],
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'msg': msg,
        'content': content,
        'update_time': updateTime,
      };
}
