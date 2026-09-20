import 'BaseRequest.dart';

class GetAsrEngineModelsRequest extends BaseRequest{
  String? lang;

  GetAsrEngineModelsRequest({this.lang});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.lang != null) {
      data['lang'] = this.lang;
    }
    return data;
  }
}