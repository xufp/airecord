import 'BaseRequest.dart';

class MediaUploadAckRequest extends BaseRequest {
  final int mediaId;

  MediaUploadAckRequest(this.mediaId);

  factory MediaUploadAckRequest.fromJson(Map<String, dynamic> json) {
    return MediaUploadAckRequest(
      json['media_id'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'media_id': mediaId};
  }
}
