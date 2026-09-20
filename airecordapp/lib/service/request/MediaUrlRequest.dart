import 'BaseRequest.dart';

class MediaUrlRequest extends BaseRequest {
  final int mediaId;

  MediaUrlRequest({required this.mediaId});

  factory MediaUrlRequest.fromJson(Map<String, dynamic> json) {
    return MediaUrlRequest(
      mediaId: (json['media_id'] as num).toInt(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'media_id': mediaId,
    };
  }
}
