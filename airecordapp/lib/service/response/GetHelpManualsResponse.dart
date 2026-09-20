import 'package:airecordapp/constant/ErrConstants.dart';
import 'package:airecordapp/service/response/Link.dart';
import 'package:airecordapp/service/response/MediaConvertRecord.dart';
import 'package:airecordapp/service/response/PackageRecord.dart';
import 'package:airecordapp/service/response/QuestionAnswer.dart';

class GetHelpManualsResponse {
  int code;
  String msg;
  List<QuestionAnswer>? data;
  GetHelpManualsResponse({
    required this.code,
    required this.msg,
     this.data,
  });

  factory GetHelpManualsResponse.fromJson(Map<String, dynamic> json) {
    var data = json['data'];
    List<QuestionAnswer> questionAnswerList = [];
    if (data != null && data.isNotEmpty) {
      List<dynamic> dataList = data;
      dataList.forEach((element) {
        if (element is Map<String, dynamic>) {
          Map<String, dynamic> map = element;
          String question = map['question'];
          String answer = map['answer'];
          QuestionAnswer questionAnswer = QuestionAnswer(
              question: question,
              answer: answer,);
          questionAnswerList.add(questionAnswer);
        }
      });
    }
    return GetHelpManualsResponse(
      code: json['code'] ?? ErrConstants.SUCCESS_CODE,
      msg: json['msg'] ?? ErrConstants.SUCCESS_MSG,
      data: questionAnswerList,
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'msg': msg,
        'data': data,
      };
}
