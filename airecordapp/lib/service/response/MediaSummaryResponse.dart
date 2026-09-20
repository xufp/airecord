import 'package:airecordapp/constant/ErrConstants.dart';

class MediaSummaryResponse {
  final int code;
  final String msg;
  final int? mediaId;
  final int? state;
  final String? content;

  MediaSummaryResponse({
    required this.code,
    required this.msg,
    this.mediaId,
    this.state,
    this.content,
  });

  factory MediaSummaryResponse.fromJson(Map<String, dynamic> json) {
    return MediaSummaryResponse(
      code: json['code'] ?? ErrConstants.SUCCESS_CODE,
      msg: json['msg'] ?? ErrConstants.SUCCESS_MSG,
      mediaId: json['media_id'] as int?,
      state: json['state'] as int?,
      content: json['content'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'msg': msg,
        'media_id': mediaId,
        'state': state,
        'content': content,
      };
}

enum MediaSummaryState {
  wait(0), // 等待
  doing(1), // 总结中
  success(2), // 已完成
  failed(3); // 总结失败

  final int value;

  const MediaSummaryState(this.value);
}
