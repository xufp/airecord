import 'package:json_annotation/json_annotation.dart';

import '../../constant/ErrConstants.dart';

@JsonSerializable()
class MediaSyncResponse {
  final int code;
  final String msg;
  final int page;
  final int size;
  final int total;
  final List<MediaInfo> mediaInfoList;

  MediaSyncResponse({
    required this.code,
    required this.msg,
    required this.page,
    required this.size,
    required this.total,
    required this.mediaInfoList,
  });

  // 用于生成类的工厂方法
  factory MediaSyncResponse.fromJson(Map<String, dynamic> json) {
    return MediaSyncResponse(
      code: json['code'] ?? ErrConstants.SUCCESS_CODE,
      msg: json['msg'] ?? ErrConstants.SUCCESS_MSG,
      page: (json['page'] as num?)?.toInt() ?? 0,
      size: (json['size'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      mediaInfoList: json['data'] != null
          ? (json['data'] as List<dynamic>)
              .map((e) => MediaInfo.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  // 用于将类转换成 JSON
  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'size': size,
      'total': total,
      'data': mediaInfoList,
    };
  }
}

class MediaInfo {
  final int mediaId; // 音频ID
  final String mediaName; // 音频名称
  final String fileFormat;
  final String fileSign; // 文件签名 (sha256)
  final String recordTime; // 录音时间
  final String recordAddress; // 录音地点
  final int duration; // 音频时长 (单位：毫秒)
  final String? deviceId; // 设备ID (可能为空)
  final int mediaType; // 音频类型 1：常规录音文件；2：速记录音文件
  final int state; // 音频状态 0: 初始状态(未上传),1:已上传, 2: 转写中，3：已转写， 4：转写失败

  int syncStatus = 0; // 同步状态，0：未开始同步，1：同步中，2：同步成功，3：同步失败

  MediaInfo({
    required this.mediaId,
    required this.mediaName,
    required this.fileFormat,
    required this.fileSign,
    required this.recordTime,
    required this.recordAddress,
    required this.duration,
    required this.state,
    required this.mediaType,
    this.deviceId,
  });

  // fromJson 工厂构造函数
  factory MediaInfo.fromJson(Map<String, dynamic> json) {
    return MediaInfo(
      mediaId: (json['media_id'] as num).toInt(),
      mediaName: json['media_name'],
      fileFormat: json['file_format'],
      fileSign: json['file_sign'],
      recordTime: json['record_time'],
      recordAddress: json['record_address'],
      duration: (json['duration'] as num).toInt(),
      state: (json['state'] as num).toInt(),
      deviceId: json['device_id'],
      mediaType: (json['media_type'] as num).toInt(),
    );
  }

  // toJson 方法，生成 JSON 对象
  Map<String, dynamic> toJson() {
    return {
      'media_id': mediaId,
      'media_name': mediaName,
      'file_format': fileFormat,
      'file_sign': fileSign,
      'record_time': recordTime,
      'record_address': recordAddress,
      'duration': duration,
      'state': state,
      'device_id': deviceId,
      'media_type': mediaType,
    };
  }
}
