import "BaseRequest.dart";

class MediaUploadCredentialRequest extends BaseRequest {
  final String mediaName;
  final String fileFormat;
  final int fileSize;
  final String recordTime;
  final int duration;
  final String fileSign;
  String? recordAddress;
  String? deviceId;

  MediaUploadCredentialRequest({
    required this.mediaName,
    required this.fileFormat,
    required this.fileSize,
    required this.recordTime,
    required this.duration,
    required this.fileSign,
    this.recordAddress,
    this.deviceId,
  });

  @override
  Map<String, dynamic> toJson() => {
        "media_name": mediaName,
        "file_format": fileFormat,
        "file_size": fileSize,
        "record_time": recordTime,
        "duration": duration,
        "file_sign": fileSign,
        "record_address": recordAddress,
        "device_id": deviceId,
      };
}
