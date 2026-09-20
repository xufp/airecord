import '../../constant/ErrConstants.dart';

class SmsCodeResponse {
  final int code;
  final String msg;

  SmsCodeResponse({
    required this.code,
    required this.msg,
  });

  factory SmsCodeResponse.fromJson(Map<String, dynamic> json) {
    return SmsCodeResponse(
      code: json['code'] ?? ErrConstants.SUCCESS_CODE,
      msg: json['msg'] ?? ErrConstants.SUCCESS_MSG,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (code != null) 'code': code,
      if (msg != null) 'msg': msg,
    };
  }
}
