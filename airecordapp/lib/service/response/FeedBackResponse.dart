
import 'package:airecordapp/constant/ErrConstants.dart';

class FeedBackResponse {
  final int code;
  final String msg;

  FeedBackResponse({
    required this.code,
    required this.msg,
  });

  factory FeedBackResponse.fromJson(Map<String, dynamic> json) {
    return FeedBackResponse(
      code: json['code'] ?? ErrConstants.SUCCESS_CODE,
      msg: json['msg'] ?? ErrConstants.SUCCESS_MSG,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (code != null) 'code': code,
      if (msg != null) 'msg': msg,
    };
  }
}
