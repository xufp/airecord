import 'package:airecordapp/constant/ErrConstants.dart';

class MediaUploadAckResponse {
  final int code;
  final String msg;

  MediaUploadAckResponse({required this.code, required this.msg});

  factory MediaUploadAckResponse.fromJson(Map<String, dynamic> json) {
    return MediaUploadAckResponse(
      code: json['code'] ?? ErrConstants.SUCCESS_CODE,
      msg: json['msg'] ?? ErrConstants.SUCCESS_MSG,
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'msg': msg,
      };
}
