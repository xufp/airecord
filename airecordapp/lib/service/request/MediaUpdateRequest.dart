import 'BaseRequest.dart';

class MediaUpdateRequest extends BaseRequest {
  int mediaId;
  String mediaName;

  MediaUpdateRequest({
    required this.mediaId,
    required this.mediaName,
  });

  factory MediaUpdateRequest.fromJson(Map<String, dynamic> json) {
    return MediaUpdateRequest(
      mediaId: json['media_id'] as int,
      mediaName: json['media_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['media_id'] = mediaId;
    data['media_name'] = mediaName;
    return data;
  }
}
