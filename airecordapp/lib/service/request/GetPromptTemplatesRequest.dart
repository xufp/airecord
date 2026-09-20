import 'BaseRequest.dart';

class GetPromptTemplatesRequest extends BaseRequest {

  String? lang;

  GetPromptTemplatesRequest({this.lang});

  factory GetPromptTemplatesRequest.fromJson(Map<String, dynamic> json) {
    return GetPromptTemplatesRequest(
      lang: json['lang'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.lang != null) {
      data['lang'] = this.lang;
    }
    return data;
  }
}
