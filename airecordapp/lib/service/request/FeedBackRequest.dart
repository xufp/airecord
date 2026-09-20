import 'BaseRequest.dart';

/**
 * 激活会员请求
 */
class FeedBackRequest extends BaseRequest {
  final String content;
  final String contract;

  FeedBackRequest({
    this.content = '',
    this.contract = '',
  });

  factory FeedBackRequest.fromJson(Map<String, dynamic> json) {
    return FeedBackRequest(
      content: json['content'],
      contract: json['contract'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'contract': contract,
    };
  }
}
