import 'BaseRequest.dart';

class GetHelpManualsRequest extends BaseRequest {
  String lang; // 语言

  GetHelpManualsRequest({
    required this.lang,
  });

  factory GetHelpManualsRequest.fromJson(Map<String, dynamic> json) {
    return GetHelpManualsRequest(
      lang: json['lang'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lang'] = lang;
    return data;
  }
}
