import 'BaseRequest.dart';

class MediaRemoveRequest extends BaseRequest {
  final int mediaId;

  MediaRemoveRequest(this.mediaId);

  factory MediaRemoveRequest.fromJson(Map<String, dynamic> json) {
    return MediaRemoveRequest(
      json['media_id'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'media_id': mediaId};
  }
}
