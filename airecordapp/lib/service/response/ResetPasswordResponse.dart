import '../../constant/ErrConstants.dart';

/**
 * 重置密码响应
 */
class ResetPasswordResponse {
  final int code;
  final String msg;

  ResetPasswordResponse({
    required this.code,
    required this.msg,
  });

  factory ResetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponse(
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
