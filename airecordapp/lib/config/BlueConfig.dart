import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BlueConfig {
  // 定义一个服务的GUID
  static Guid SERVICE_UUID = Guid('ae20');
  static const String CHARACTERISTIC_SERVICE_UUID = 'ae20';
  static const String CHARACTERISTIC_WRITE = 'ae21'; // 可写特征码
  static const String CHARACTERISTIC_NOTIFY = 'ae22'; // 监听响应征码
}
