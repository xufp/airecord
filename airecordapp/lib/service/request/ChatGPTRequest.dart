import 'BaseRequest.dart';
import 'ChatMessage.dart';

class ChatGPTRequest extends BaseRequest {

  final List<ChatMessage> messages;

  ChatGPTRequest({
    required this.messages
  });

  factory ChatGPTRequest.fromJson(Map<String, dynamic> json) {
    List a= json['messages'] as List;
    List<ChatMessage> messages1 = [];
    for(int i=0;i<a.length;i++){
      ChatMessage b = ChatMessage.fromJson(a[i]);
      messages1.add(b);
    }
    return ChatGPTRequest(
      messages: messages1,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['messages'] = messages;
    return data;
  }
}
