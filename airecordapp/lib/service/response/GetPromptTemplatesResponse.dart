import 'package:airecordapp/constant/ErrConstants.dart';
import 'package:airecordapp/service/response/Link.dart';
import 'package:airecordapp/service/response/MediaConvertRecord.dart';
import 'package:airecordapp/service/response/PackageRecord.dart';
import 'package:airecordapp/service/response/PromptTemplates.dart';
import 'package:airecordapp/service/response/QuestionAnswer.dart';

class GetPromptTemplatesResponse {
  int code;
  String msg;
  List<PromptTemplates>? data;
  GetPromptTemplatesResponse({
    required this.code,
    required this.msg,
     this.data,
  });

  factory GetPromptTemplatesResponse.fromJson(Map<String, dynamic> json) {
    var data = json['data'];
    List<PromptTemplates> promptTemplatesList = [];
    if (data != null && data.isNotEmpty) {
      List<dynamic> dataList = data;
      dataList.forEach((element) {
        if (element is Map<String, dynamic>) {
          Map<String, dynamic> map = element;
          String promptId = map['prompt_id'];
          String promptDesc = map['prompt_desc'];
          PromptTemplates promptTemplates = PromptTemplates(
            promptId: promptId,
            promptDesc: promptDesc,);
          promptTemplatesList.add(promptTemplates);
        }
      });
    }
    return GetPromptTemplatesResponse(
      code: json['code'] ?? ErrConstants.SUCCESS_CODE,
      msg: json['msg'] ?? ErrConstants.SUCCESS_MSG,
      data: promptTemplatesList,
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'msg': msg,
        'data': data,
      };
}
