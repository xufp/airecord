import 'dart:convert';
import 'package:airecordapp/constant/ErrConstants.dart';
import 'package:airecordapp/service/DioService.dart';
import 'package:airecordapp/service/request/ChatGPTRequest.dart';
import 'package:airecordapp/service/request/ChatMessage.dart';
import 'package:airecordapp/service/response/ChatGPTResponse.dart';
import 'package:airecordapp/util/LogUtil.dart';
import 'package:http/http.dart' as http;

class ChatGPTService {
  //openAI
  final String apiKey =
      'YOUR_AZURE_OPENAI_KEY'; // 替换为你的 OpenAI/Azure API Key
  final String apiUrl =
      'https://your-resource.cognitiveservices.azure.com/openai/deployments/gpt-4o/chat/completions?api-version=2024-08-01-preview'; // 替换为你的 OpenAI API URL

  //deepseek
  //final String apiKey = 'YOUR_DEEPSEEK_API_KEY'; // 替换为你的 DeepSeek API Key
  //final String apiUrl = 'https://api.deepseek.com/v1/chat/completions'; // 替换为你的 DeepSeek API URL

  Future<String> sendMessage(String message) async {
    try {
      print("message: $message");
      // 构造 HTTP 请求
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          //deepseek调用方式
          //'Authorization': 'Bearer $apiKey',
          //openai调用方式
          'api-key': '$apiKey',
        },
        body: jsonEncode({
          //openAI的模型
          "model": "gpt-4o", // 替换为所需的 GPT 模型
          //deepseek的模型
          //"model": "deepseek-reasoner",
          "messages": [
            {"role": "system", "content": "You are a helpful assistant."},
            {"role": "user", "content": message}
          ],
          "max_tokens": 2000,
        }),
      );

      // 处理响应
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        //final data = jsonDecode(response.body);
        final chatResponse = data['choices'][0]['message']['content'];
        print("chatResponse: $chatResponse");
        return chatResponse.trim();
      } else {
        return "出错了，请稍后重试。";
      }
    } catch (e) {
      return "无法连接到服务器，请检查网络连接。";
    }
  }

  final logger = LogUtil.inItLog();

  // 创建订单
  Future<String> sendMessageOK(String message) async {
    try {
      List<ChatMessage> messages = [ChatMessage(role: 'user', content: message)];

      ChatGPTRequest request = ChatGPTRequest(messages: messages);
      final resp = await DioService.chatGPT(request);
      if (resp.code == ErrConstants.SUCCESS_CODE) {
        // 从响应中提取messages列表
        final messages = resp.messages as List<dynamic>;

        // 查找最后一个assistant的回复
        final assistantMsg = messages.lastWhere(
                (msg) => msg['role'] == 'assistant',
            orElse: () => {'content': '未找到有效回复'}
        );

        return assistantMsg['content'] as String;
      }
    } catch (e) {
      logger.e('GPT对话异常:$e');
    }
    return ErrConstants.ERR_MSG;
  }


  Future<String> sendBatchMessage(List message) async {
    try {
      // 构造 HTTP 请求
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          //deepseek调用方式
          //'Authorization': 'Bearer $apiKey',
          //openai调用方式
          'api-key': '$apiKey',
        },
        body: jsonEncode({
          //openAI的模型
          "model": "gpt-4o", // 替换为所需的 GPT 模型
          //deepseek的模型
          //"model": "deepseek-reasoner",
          "messages": [
            {"role": "system", "content": "You are a helpful assistant."},
            {"role": "user", "content": message}
          ],
          "max_tokens": 2000,
        }),
      );

      // 处理响应
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        //final data = jsonDecode(response.body);
        final chatResponse = data['choices'][0]['message']['content'];
        return chatResponse.trim();
      } else {
        return "出错了，请稍后重试。";
      }
    } catch (e) {
      return "无法连接到服务器，请检查网络连接。";
    }
  }
}
