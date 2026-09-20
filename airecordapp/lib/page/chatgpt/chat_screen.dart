import 'package:airecordapp/page/chatgpt/chatgpt_service.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatGPTService _chatGPTService = ChatGPTService();
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> _messages = []; // 存储聊天记录

  // 发送消息
  void _sendMessage() async {
    final userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    // 添加用户消息到聊天记录
    setState(() {
      _messages.add({"role": "user", "content": userMessage});
    });
    _controller.clear();

    // 显示一个临时的加载状态
    setState(() {
      _messages.add({"role": "assistant", "content": "正在生成回复..."});
    });

    // 调用 ChatGPT 接口获取回复
    final gptResponse = await _chatGPTService.sendMessageOK(userMessage);

    // 移除临时加载状态，并更新 GPT 响应
    setState(() {
      _messages.removeLast(); // 移除 "正在生成回复..."
      _messages.add({"role": "assistant", "content": gptResponse});
    });
  }

  /*Widget _listBuilder(BuildContext context, int index){
    final message = _messages[index];
    final isUser = message['role'] == 'user';
    return Container(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: isUser ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.all(12),
        child: Text(
          message['content'] ?? '',
          style: TextStyle(fontSize: 12, color: Colors.white),
        ),
      ),
    );
  }*/

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Column(
          children: [
            // 聊天消息列表
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isUser = message['role'] == 'user';
                  return Container(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isUser ? Colors.blue[100] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.all(12),
                      child: Text(
                        message['content'] ?? '',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            ),
            // 输入框和发送按钮
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "输入你的消息...",
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _sendMessage,
                    child: Text("发送"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}