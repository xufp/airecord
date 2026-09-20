import 'package:airecordapp/constant/ErrConstants.dart';
import 'package:airecordapp/service/response/ChatMessage.dart';

class ChatGPTResponse {
  int code;
  String msg;
  List<dynamic>? messages;

  ChatGPTResponse({
    required this.code,
    required this.msg,
    this.messages,
  });

  factory ChatGPTResponse.fromJson(Map<String, dynamic> json) {
    return ChatGPTResponse(
        code: json['code'] ?? ErrConstants.SUCCESS_CODE,
        msg: json['msg'] ?? ErrConstants.SUCCESS_MSG,
        messages: json['messages']);
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'msg': msg,
      };
}
