import 'BaseRequest.dart';

class MediaSummaryRequest extends BaseRequest {
  int mediaId;
  String engine;
  String promptId;

  MediaSummaryRequest({
    required this.mediaId,
    this.promptId = '',
    this.engine = '',
  });

  factory MediaSummaryRequest.fromJson(Map<String, dynamic> json) {
    return MediaSummaryRequest(
      mediaId: json['media_id'] as int,
      engine: json['engine'] as String,
      promptId: json['prompt_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['media_id'] = mediaId;
    data['engine'] = engine;
    data['prompt_id'] = promptId;
    return data;
  }
}
