import 'BaseRequest.dart';

class GetPrivacyPolicyRequest extends BaseRequest {
  String lang; // 语言

  GetPrivacyPolicyRequest({
    required this.lang,
  });

  factory GetPrivacyPolicyRequest.fromJson(Map<String, dynamic> json) {
    return GetPrivacyPolicyRequest(
      lang: json['lang'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lang'] = lang;
    return data;
  }
}
