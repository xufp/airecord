import 'BaseRequest.dart';

/**
 * 获取验证码
 */
class GetCodeRequest extends BaseRequest {
  final String email;
  final String phone;

  GetCodeRequest({
    required this.email,
    this.phone = ""
  });

  factory GetCodeRequest.fromJson(Map<String, dynamic> json) {
    return GetCodeRequest(
      email: json['email'],
      phone: json['phone'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'phone': phone,
    };
  }
}
