import 'package:airecordapp/constant/ErrConstants.dart';

class MediaUpdateResponse {
  final int code;
  final String msg;

  MediaUpdateResponse({
    required this.code,
    required this.msg,
  });

  factory MediaUpdateResponse.fromJson(Map<String, dynamic> json) {
    return MediaUpdateResponse(
      code: json['code'] ?? ErrConstants.SUCCESS_CODE,
      msg: json['msg'] ?? ErrConstants.SUCCESS_MSG,
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'msg': msg,
      };
}
