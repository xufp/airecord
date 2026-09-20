import 'BaseRequest.dart';

class SmsCodeRequest extends BaseRequest {
  final String phone;

  SmsCodeRequest({
    required this.phone,
  });

  factory SmsCodeRequest.fromJson(Map<String, dynamic> json) {
    return SmsCodeRequest(
      phone: json['phone'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
    };
  }
}
