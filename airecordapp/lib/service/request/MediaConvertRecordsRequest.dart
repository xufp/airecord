import 'BaseRequest.dart';

class MediaConvertRecordsRequest extends BaseRequest {
  int page;
  int size;

  MediaConvertRecordsRequest({
    required this.page,
    required this.size,
  });

  factory MediaConvertRecordsRequest.fromJson(Map<String, dynamic> json) {
    return MediaConvertRecordsRequest(
      page: json['page'] as int,
      size: json['size'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['page'] = page;
    data['size'] = size;
    return data;
  }
}
