import 'BaseRequest.dart';

/**
 * 验证码请求体
 */
class VerifyCodeRequest extends BaseRequest {
  final String email;
  final String phone;
  final String code;

  VerifyCodeRequest({
    this.email = '',
    this.phone = '',
    required this.code,
  });

  factory VerifyCodeRequest.fromJson(Map<String, dynamic> json) {
    return VerifyCodeRequest(
      email: json['email'],
      phone: json['phone'],
      code: json['code'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'phone': phone,
      'code': code,
    };
  }
}
