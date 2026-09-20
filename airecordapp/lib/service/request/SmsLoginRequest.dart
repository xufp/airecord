import 'BaseRequest.dart';

class SmsLoginRequest extends BaseRequest {
  final String phone;
  final String code;

  SmsLoginRequest({
    required this.phone,
    required this.code,
  });

  factory SmsLoginRequest.fromJson(Map<String, dynamic> json) {
    return SmsLoginRequest(
      phone: json['phone'],
      code: json['code'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'code': code,
    };
  }
}
