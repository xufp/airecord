import 'package:json_annotation/json_annotation.dart';

import '../../constant/ErrConstants.dart';

@JsonSerializable()
class MediaConvertStatusResponse {
  final int code;
  final String msg;
  final int mediaId;
  final int state;
  final String memo;
  final String text;
  final List<SentenceDetail> sentenceDetailList;

  MediaConvertStatusResponse({
    required this.code,
    required this.msg,
    required this.mediaId,
    required this.state,
    required this.memo,
    required this.text,
    required this.sentenceDetailList,
  });

  // 用于生成类的工厂方法
  factory MediaConvertStatusResponse.fromJson(Map<String, dynamic> json) {
    return MediaConvertStatusResponse(
      code: json['code'] ?? ErrConstants.SUCCESS_CODE,
      msg: json['msg'] ?? ErrConstants.SUCCESS_MSG,
      mediaId: (json['media_id'] as num?)?.toInt() ?? 0,
      state: (json['state'] as num?)?.toInt() ?? 0,
      memo: (json['memo'] as String?) ?? "",
      text: (json['text'] as String?) ?? "",
      sentenceDetailList: json['sentence_detail'] != null
          ? (json['sentence_detail'] as List<dynamic>)
              .map((e) => SentenceDetail.fromJson(e as Map<String, dynamic>))
              .toList()
          : <SentenceDetail>[],
    );
  }

  // 用于将类转换成 JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'msg': msg,
      'media_id': mediaId,
      'state': state,
      'memo': memo,
      'text': text,
      'sentence_detail': sentenceDetailList,
    };
  }
}

class SentenceDetail {
  final int index;
  final int startTime;
  final int endTime;
  final String text;
  final int speakId;

  SentenceDetail({
    required this.index,
    required this.startTime,
    required this.endTime,
    required this.text,
    required this.speakId,
  });

  factory SentenceDetail.fromJson(Map<String, dynamic> json) {
    return SentenceDetail(
      index: (json['index'] as num).toInt(),
      startTime: (json['start_time'] as num).toInt(),
      endTime: (json['end_time'] as num).toInt(),
      text: json['text'] as String,
      speakId: (json['speak_id'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'start_time': startTime,
      'end_time': endTime,
      'text': text,
      'speak_id': speakId
    };
  }
}
