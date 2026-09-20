import 'BaseRequest.dart';

class MediaUploadRequest extends BaseRequest {
  final String mediaName;
  final String recordTime;
  final String recordAddress;
  final String deviceId;

  MediaUploadRequest({
    required this.mediaName,
    required this.recordTime,
    required this.recordAddress,
    required this.deviceId,
  });

  factory MediaUploadRequest.fromJson(Map<String, dynamic> json) {
    return MediaUploadRequest(
      mediaName: json['media_name'],
      recordTime: json['record_time'],
      recordAddress: json['record_address'] ?? '',
      deviceId: json['device_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'media_name': mediaName,
      'record_time': recordTime,
      'record_address': recordAddress,
      'device_id': deviceId,
    };
  }
}
