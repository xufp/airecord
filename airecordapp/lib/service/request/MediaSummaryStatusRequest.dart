import 'BaseRequest.dart';

class MediaSummaryStatusRequest extends BaseRequest {
  final int mediaId;


  MediaSummaryStatusRequest({required this.mediaId});

  factory MediaSummaryStatusRequest.fromJson(Map<String, dynamic> json) {
    return MediaSummaryStatusRequest(
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
