import 'dart:convert';

import 'package:airecordapp/service/response/UserInfoResponse.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Cache {
  static Future<SharedPreferences>? _sp;

  static Future get sp async {
    if (_sp != null) {
      return _sp;
    }
    _sp = _initSp();
    return _sp;
  }

  static Future<SharedPreferences> _initSp() async {
    return await SharedPreferences.getInstance();
  }

  // 登录token
  static Future<String> get authToken async {
    String authToken = "token " + (await token);
    return authToken;
  }

  // 获取存储token信息
  static Future<String> get token async {
    SharedPreferences prefs = await sp;
    String token = prefs.getString('token') ?? '';
    return token;
  }

  // 存储登录token信息
  static Future<void> saveToken(String token, String userId) async {
    SharedPreferences prefs = await sp;
    await prefs.setString('token', token);
    await prefs.setString('userId', userId);
  }

  static Future<void> saveUserInfo(UserInfoResponse userInfo) async {
    SharedPreferences prefs = await sp;
    await prefs.setString('userInfo', jsonEncode(userInfo));
  }

  // 存储登录token信息
  static Future<bool> removeToken() async {
    SharedPreferences prefs = await sp;
    return await prefs.remove('token');
  }

  // 存储设备信息
  static Future<void> saveDevInfo(
      String platformName,
      String remoteId,
      String characteristicWrite,
      String characteristicNotify,
      String characteristicBatteryNotify) async {
    SharedPreferences prefs = await sp;
    await prefs.setString('platformName', platformName);
    await prefs.setString('remoteId', remoteId);
    await prefs.setString('characteristicWrite', characteristicWrite);
    await prefs.setString('characteristicNotify', characteristicNotify);
    await prefs.setString('characteristicBatteryNotify', characteristicBatteryNotify);
  }

  // 获取设备名称
  static Future<String> get platformName async {
    SharedPreferences prefs = await sp;
    String platformName = prefs.getString('platformName') ?? '';
    return platformName;
  }

  // 获取设备remoteId
  static Future<String> get remoteId async {
    SharedPreferences prefs = await sp;
    String remoteId = prefs.getString('remoteId') ?? '';
    return remoteId;
  }

  // 获取设备characteristicWrite
  static Future<String> get characteristicWrite async {
    SharedPreferences prefs = await sp;
    String characteristicWrite = prefs.getString('characteristicWrite') ?? '';
    return characteristicWrite;
  }

  // 获取设备characteristicNotify
  static Future<String> get characteristicNotify async {
    SharedPreferences prefs = await sp;
    String characteristicNotify = prefs.getString('characteristicNotify') ?? '';
    return characteristicNotify;
  }

  // 获取设备characteristicBatteryNotify
  static Future<String> get characteristicBatteryNotify async {
    SharedPreferences prefs = await sp;
    String characteristicNotify = prefs.getString('characteristicBatteryNotify') ?? '';
    return characteristicNotify;
  }

  // 删除设备缓存
  static Future<bool> removeDevCache() async {
    SharedPreferences prefs = await sp;
    await prefs.remove('remoteId');
    await prefs.remove('platformName');
    await prefs.remove('characteristicWrite');
    await prefs.remove('characteristicNotify');
    await prefs.remove('characteristicBatteryNotify');
    return true;
  }

  // ==================== 新硬件 V2 专属缓存（与 V1 完全隔离）====================

  /// 存储 V2 设备信息。
  /// - [platformName]：设备广播名（如 AI-RTCAPEN）
  /// - [remoteId]：BLE 设备 id（Android MAC / iOS uuid）
  /// - [writeFff]/[notifyFff]：FFF0 服务下的写/通知特征 UUID
  /// - [writeFfe]/[notifyFfe]：FFE0 服务下的写/通知特征 UUID
  static Future<void> saveDevInfoV2({
    required String platformName,
    required String remoteId,
    required String writeFff,
    required String notifyFff,
    required String writeFfe,
    required String notifyFfe,
  }) async {
    SharedPreferences prefs = await sp;
    await prefs.setString('v2_platformName', platformName);
    await prefs.setString('v2_remoteId', remoteId);
    await prefs.setString('v2_uuidWriteFff', writeFff);
    await prefs.setString('v2_uuidNotifyFff', notifyFff);
    await prefs.setString('v2_uuidWriteFfe', writeFfe);
    await prefs.setString('v2_uuidNotifyFfe', notifyFfe);
  }

  static Future<String> get v2PlatformName async {
    SharedPreferences prefs = await sp;
    return prefs.getString('v2_platformName') ?? '';
  }

  static Future<String> get v2RemoteId async {
    SharedPreferences prefs = await sp;
    return prefs.getString('v2_remoteId') ?? '';
  }

  static Future<String> get v2UuidWriteFff async {
    SharedPreferences prefs = await sp;
    return prefs.getString('v2_uuidWriteFff') ?? '';
  }

  static Future<String> get v2UuidNotifyFff async {
    SharedPreferences prefs = await sp;
    return prefs.getString('v2_uuidNotifyFff') ?? '';
  }

  static Future<String> get v2UuidWriteFfe async {
    SharedPreferences prefs = await sp;
    return prefs.getString('v2_uuidWriteFfe') ?? '';
  }

  static Future<String> get v2UuidNotifyFfe async {
    SharedPreferences prefs = await sp;
    return prefs.getString('v2_uuidNotifyFfe') ?? '';
  }

  static Future<bool> removeDevCacheV2() async {
    SharedPreferences prefs = await sp;
    await prefs.remove('v2_platformName');
    await prefs.remove('v2_remoteId');
    await prefs.remove('v2_uuidWriteFff');
    await prefs.remove('v2_uuidNotifyFff');
    await prefs.remove('v2_uuidWriteFfe');
    await prefs.remove('v2_uuidNotifyFfe');
    return true;
  }

  // 获取用户信息
  static Future<UserInfoResponse> get userInfo async {
    SharedPreferences prefs = await sp;
    String userInfo = prefs.getString('userInfo') ?? '';
    if (userInfo.isNotEmpty) {
      Map<String, dynamic> userInfoMap = jsonDecode(userInfo);
      return UserInfoResponse.fromJson(userInfoMap);
    }
    return UserInfoResponse();
  }

  // 获取存储的userId
  static Future<String> get userId async {
    SharedPreferences prefs = await sp;
    String userId = prefs.getString('userId') ?? '';
    return userId;
  }

  // 存储登录token信息
  static Future<bool> removeAll() async {
    SharedPreferences prefs = await sp;
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('userInfo');
    return true;
  }
}
