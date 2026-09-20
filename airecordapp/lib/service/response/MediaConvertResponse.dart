import 'package:airecordapp/constant/ErrConstants.dart';

class MediaConvertResponse {
  final int code;
  final String msg;
  final int? mediaId;
  final int? state;
  final String? text;

  MediaConvertResponse({
    required this.code,
    required this.msg,
    this.mediaId,
    this.state,
    this.text,
  });

  factory MediaConvertResponse.fromJson(Map<String, dynamic> json) {
    return MediaConvertResponse(
      code: json['code'] ?? ErrConstants.SUCCESS_CODE,
      msg: json['msg'] ?? ErrConstants.SUCCESS_MSG,
      mediaId: json['media_id'] as int?,
      state: json['state'] as int?,
      text: json['text'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'msg': msg,
        'media_id': mediaId,
        'state': state,
        'text': text,
      };
}

enum MediaConvertState {
  wait(0), // 等待转写
  doing(1), // 转写中
  success(2), // 转写成功
  failed(3); // 转写失败

  final int value;

  const MediaConvertState(this.value);
}
