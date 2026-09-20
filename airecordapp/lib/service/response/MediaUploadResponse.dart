import 'package:airecordapp/constant/ErrConstants.dart';

class MediaUploadResponse {
  final int code;
  final String msg;
  int? mediaId;

  MediaUploadResponse({required this.code, required this.msg, this.mediaId});

  factory MediaUploadResponse.fromJson(Map<String, dynamic> json) {
    return MediaUploadResponse(
      code: json['code'] ?? ErrConstants.SUCCESS_CODE,
      msg: json['msg'] ?? ErrConstants.SUCCESS_MSG,
      mediaId: json['media_id'],
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'msg': msg,
        'media_id': mediaId,
      };
}
