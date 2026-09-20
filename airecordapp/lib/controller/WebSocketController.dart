import 'dart:io';

import 'package:airecordapp/config/RoutesConfig.dart';
import 'package:airecordapp/enum/EngineTypeEnum.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketController extends GetxController {
  IOWebSocketChannel? webSocketChannel;
  final String _baseUrl = RoutesConfig.BASE_WSS_URL;
  String? _url;

  // 设置音频文件流转写url
  WebSocketController setMediaSpeechUrl(
      {required String mediaName,
      required String fileFormat,
      String? engineType}) {
    if (engineType == null) {
      engineType = EngineTypeEnum.ZH.type;
    }
    _url = _baseUrl +
        RoutesConfig.MEDIA_SPEECH +
        '?media_name=$mediaName&file_format=$fileFormat&engine_type=$engineType';
    return this;
  }

  Future<void> initializeWebSocket() async {
    final HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    String token = await _getAuthorizationToken();
    Map<String, dynamic> headers = {'Authorization': token};
    webSocketChannel = IOWebSocketChannel.connect(_url ?? '',
        headers: headers, customClient: httpClient);
  }

  void closeWebSocket() {
    if (webSocketChannel != null) {
      webSocketChannel!.sink.close(status.normalClosure, '正常关闭socket');
      webSocketChannel = null;
    }
  }

  // 格式化token
  Future<String> _getAuthorizationToken() async {
    String token = "";
    await _getToken().then((String? value) {
      if (value != null || value != "") {
        token = "token " + value!;
      }
    });
    return Future.value(token);
  }

// 获取登录token信息
  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
