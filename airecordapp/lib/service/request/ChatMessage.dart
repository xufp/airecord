import 'BaseRequest.dart';

class ChatMessage extends BaseRequest {
  final String role;
  final String content;

  ChatMessage({
    required this.role,
    required this.content
  });


  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'] as String,
      content: json['content'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['role'] = role;
    data['content'] = content;
    return data;
  }

}
