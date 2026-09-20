import 'BaseRequest.dart';

/**
 * 重置密码请求
 */
class ResetPasswordRequest extends BaseRequest {
  final String email;
  final String newPassword;
  final String code;

  ResetPasswordRequest({
    required this.email,
    this.newPassword = "",
    this.code = "",
  });

  factory ResetPasswordRequest.fromJson(Map<String, dynamic> json) {
    return ResetPasswordRequest(
      email: json['email'],
      newPassword: json['new_password'],
      code: json['code'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'new_password': newPassword,
      'code': code,
    };
  }
}
