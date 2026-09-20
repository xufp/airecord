import 'BaseRequest.dart';

class MediaConvertRequest extends BaseRequest {
  int mediaId;
  String engineType;

  MediaConvertRequest({
    required this.mediaId,
    required this.engineType,
  });

  factory MediaConvertRequest.fromJson(Map<String, dynamic> json) {
    return MediaConvertRequest(
      mediaId: json['media_id'] as int,
      engineType: json['engine_type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['media_id'] = mediaId;
    data['engine_type'] = engineType;
    return data;
  }
}
