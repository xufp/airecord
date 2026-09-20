import 'package:airecordapp/constant/ErrConstants.dart';

class MediaRemoveResponse {
  final int code;
  final String msg;

  MediaRemoveResponse({required this.code, required this.msg});

  factory MediaRemoveResponse.fromJson(Map<String, dynamic> json) {
    return MediaRemoveResponse(
      code: json['code'] ?? ErrConstants.SUCCESS_CODE,
      msg: json['msg'] ?? ErrConstants.SUCCESS_MSG,
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'msg': msg,
      };
}
