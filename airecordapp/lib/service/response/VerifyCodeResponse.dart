import '../../constant/ErrConstants.dart';

class VerifyCodeResponse {
  final int code;
  final String msg;
  final int? state;
  final String? accessToken;

  VerifyCodeResponse({
    required this.code,
    required this.msg,
    this.state,
    this.accessToken,
  });

  factory VerifyCodeResponse.fromJson(Map<String, dynamic> json) {
    return VerifyCodeResponse(
      code: json['code'] ?? ErrConstants.SUCCESS_CODE,
      msg: json['msg'] ?? ErrConstants.SUCCESS_MSG,
      state: json['state'] as int?,
      accessToken: json['access_token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (code != null) 'code': code,
      if (msg != null) 'msg': msg,
      if (state != null) 'state': state,
      if (accessToken != null) 'access_token': accessToken,
    };
  }
}
