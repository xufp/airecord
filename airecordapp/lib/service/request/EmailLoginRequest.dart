import 'BaseRequest.dart';

/**
 * 登录或注册请求
 */
class EmailLoginRequest extends BaseRequest {
  final String email;
  final String password;
  final bool register;

  EmailLoginRequest({
    required this.email,
    required this.password,
    this.register = false,
  });

  factory EmailLoginRequest.fromJson(Map<String, dynamic> json) {
    return EmailLoginRequest(
      email: json['email'],
      password: json['password'],
      register: json['register'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'register': register,
    };
  }
}
