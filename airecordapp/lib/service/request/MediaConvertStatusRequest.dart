import 'BaseRequest.dart';

class MediaConvertStatusRequest extends BaseRequest {
  final int mediaId;
  final bool detail;

  MediaConvertStatusRequest({required this.mediaId, required this.detail});

  factory MediaConvertStatusRequest.fromJson(Map<String, dynamic> json) {
    return MediaConvertStatusRequest(
      mediaId: (json['media_id'] as num).toInt(),
      detail: json['detail'] as bool,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'media_id': mediaId,
      'detail': detail,
    };
  }
}
