import 'package:airecordapp/constant/ErrConstants.dart';

class MediaSummaryStatusResponse {
  final int code;
  final String msg;
  final int? mediaId;
  final int? state;
  final String? memo;
  final String? content;

  MediaSummaryStatusResponse({
    required this.code,
    required this.msg,
    this.mediaId = 0,
    this.state = -1,
    this.memo = '',
    this.content = '',
  });

  factory MediaSummaryStatusResponse.fromJson(Map<String, dynamic> json) {
    return MediaSummaryStatusResponse(
      code: json['code'] ?? ErrConstants.SUCCESS_CODE,
      msg: json['msg'] ?? ErrConstants.SUCCESS_MSG,
      mediaId: json['media_id'] as int?,
      state: json['state'] as int?,
      memo: json['memo'] as String?,
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

enum MediaSummaryStatusState {
  wait(0), // 等待
  doing(1), // 总结中
  success(2), // 已完成
  failed(3); // 总结失败

  final int value;

  const MediaSummaryStatusState(this.value);
}
