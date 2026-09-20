import 'BaseRequest.dart';

class MediaConvertResetRequest extends BaseRequest {
  int mediaId;
  MediaConvertResetRequest({
    required this.mediaId,
  });

  factory MediaConvertResetRequest.fromJson(Map<String, dynamic> json) {
    return MediaConvertResetRequest(
      mediaId: json['media_id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['media_id'] = mediaId;
    return data;
  }
}
