import 'BaseRequest.dart';

class MediaSyncRequest extends BaseRequest {
  final int page;
  final int size;

  MediaSyncRequest({required this.page, required this.size});

  factory MediaSyncRequest.fromJson(Map<String, dynamic> json) {
    return MediaSyncRequest(
      page: (json['page'] as num).toInt(),
      size: (json['size'] as num).toInt(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'size': size,
    };
  }
}
