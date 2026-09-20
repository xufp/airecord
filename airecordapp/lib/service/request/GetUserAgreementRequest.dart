import 'BaseRequest.dart';

class GetUserAgreementRequest extends BaseRequest {
  String lang; // 语言

  GetUserAgreementRequest({
    required this.lang,
  });

  factory GetUserAgreementRequest.fromJson(Map<String, dynamic> json) {
    return GetUserAgreementRequest(
      lang: json['lang'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lang'] = lang;
    return data;
  }
}
