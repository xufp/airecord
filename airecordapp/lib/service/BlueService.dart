import 'dart:io';
import 'dart:typed_data';

import 'package:airecordapp/command/BluetoothBatteryMsg.dart';
import 'package:airecordapp/command/BluetoothCommand.dart';
import 'package:airecordapp/command/BluetoothBatteryCommand.dart';
import 'package:airecordapp/command/BluetoothMsg.dart';
import 'package:airecordapp/db/Cache.dart';
import 'package:airecordapp/util/LogUtil.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/**
 * 蓝牙基础操作封装
 */
class BlueService {
  BluetoothCharacteristic? blueWrite;
  BluetoothCharacteristic? blueNotify;
  BluetoothCharacteristic? blueBatteryNotify;
  final BluetoothCommand cmd = BluetoothCommand();
  final BluetoothBatteryCommand batteryCmd = BluetoothBatteryCommand();
  final logger = LogUtil.inItLog();

  /**
   * 设备扫描
   */
  Future<void> startScan(String uuid) async {
    try {
      int divisor = Platform.isAndroid ? 8 : 1;
      await FlutterBluePlus.startScan(
          withServices: [Guid(uuid)],
          timeout: const Duration(seconds: 15),
          continuousUpdates: true,
          continuousDivisor: divisor,
          androidScanMode: AndroidScanMode.lowPower);
    } catch (e) {
      logger.e("Start Scan Error:$e");
    }
  }

  /**
   * 初始化蓝牙模块信息
   */
  Future<void> initBlue(List<BluetoothCharacteristic> characteristics) async {
    await _closeSubscribe();
    if (blueWrite == null || blueNotify == null || blueBatteryNotify == null) {
      for (BluetoothCharacteristic c in characteristics) {
        var cUuid = c.uuid.str;
        if (await Cache.characteristicWrite == cUuid) {
          blueWrite = c;
        }
        if (await Cache.characteristicNotify == cUuid) {
          blueNotify = c;
        }
        if (await Cache.characteristicBatteryNotify == cUuid) {
          blueBatteryNotify = c;
        }
      }
    }
    // 初始化监听
    await _onSubscribe();
  }

  // 先关闭之前的监听器
  _closeSubscribe() async {
    try {
      await blueNotify?.setNotifyValue(false);
      await blueBatteryNotify?.setNotifyValue(false);
    } catch (e) {
      logger.e('关闭监听蓝牙数据下发异常');
    }
  }

  // 监听下发数据
  Future _onSubscribe() async {
    try {
      // 数据不在监听中，设置为监听中
      if (!blueNotify!.isNotifying) {
        await blueNotify?.setNotifyValue(true);
      }
      if (blueNotify!.properties.read) {
        await blueNotify?.read();
      }

      // 电池电量监听
      if (!blueBatteryNotify!.isNotifying) {
        await blueBatteryNotify?.setNotifyValue(true);
      }
      if (blueBatteryNotify!.properties.read) {
        await blueBatteryNotify?.read();
      }
    } catch (e) {
      logger.e('监听蓝牙数据下发异常$e');
    }
  }

  /**
   * 监听格式化下发数据
   */
  Map<String, dynamic> listen(Uint8List serializedMsg) {
    BluetoothMsg deserializedMsg = BluetoothMsg.fromBytes(serializedMsg);
    int dataType = deserializedMsg.dataContent.dataType;
    int cmd = deserializedMsg.dataContent.cmd;
    Uint8List data = deserializedMsg.dataContent.data;
    logger.d('监听蓝牙下发数据，dataType=$dataType, cmd=$cmd, data=$data');
    return {
      'dataType': dataType,
      'cmd': cmd,
      'data': data,
    };
  }

  /**
   * 监听电量格式化下发数据
   */
  Map<String, dynamic> listenBattery(Uint8List serializedMsg) {
    BluetoothBatteryMsg deserializedMsg =
        BluetoothBatteryMsg.fromBytes(serializedMsg);
    int dataType = deserializedMsg.dataContent.dataType;
    int cmd = deserializedMsg.dataContent.cmd;
    Uint8List data = deserializedMsg.dataContent.data;
    logger.d('监听电量蓝牙下发数据，dataType=$dataType, cmd=$cmd, data=$data');
    return {
      'dataType': dataType,
      'cmd': cmd,
      'data': data,
    };
  }

  /**
   * 同步系统时间
   */
  Future syncTime() async {
    Uint8List packet = cmd.syncTime();
    return await _writeWithoutResponse(packet);
  }


  /**
   * 获取录音笔电量
   */
  Future qel() async {
    Uint8List packet = cmd.qel();
    return await _writeBatteryWithoutResponse(packet);
  }

  /**
   * 扫描音频文件列表
   */
  Future<bool> scanAudioList() async {
    List<int> packet = cmd.fileAudioList();
    return await _writeWithoutResponse(packet);
  }

  /**
   * 删除音频文件
   */
  Future<bool> delFile(List<String> fileList) async {
    List<int> packet = cmd.delFile(fileList);
    return await _writeWithoutResponse(packet);
  }

  /**
   * 终止导入音频文件
   */
  Future importAudioStop() async {
    Uint8List packet = cmd.importAudioStop();
    return await _writeWithoutResponse(packet);
  }

  /**
   * 开始导入文件
   */
  Future<bool> importFile(List<String> fileList) async {
    List<int> packet = cmd.import(fileList);
    return await _writeWithoutResponse(packet);
  }

  // 开始实时转写音频，启动设备并开始录音
  Future<bool> startTran() async {
    Uint8List packet = cmd.startTran();
    return await _writeWithoutResponse(packet);
  }

  // 暂停转写，设备暂时停止录音
  Future<bool> tranPause() async {
    Uint8List packet = cmd.tranPause();
    return await _writeWithoutResponse(packet);
  }

  // 继续转写，设备重新开始录音
  Future<bool> tranResume() async {
    Uint8List packet = cmd.tranResume();
    return await _writeWithoutResponse(packet);
  }

  // 结束实时转写音频
  Future tranCancel() async {
    Uint8List packet = cmd.tranCancel();
    return await _writeWithoutResponse(packet);
  }

  // 开始录音成功，回复设备
  Future<bool> startRecordSuccess() async {
    Uint8List packet = cmd.startRecordSuccess();
    return await _writeWithoutResponse(packet);
  }

  // 保存录音成功，回复设备
  Future<bool> saveRecordSuccess() async {
    Uint8List packet = cmd.saveRecordSuccess();
    return await _writeWithoutResponse(packet);
  }

  // 暂停录音成功，回复设备
  Future<bool> pauseRecordSuccess() async {
    Uint8List packet = cmd.pauseRecordSuccess();
    return await _writeWithoutResponse(packet);
  }

  // 继续录音成功，回复设备
  Future<bool> resumeRecordSuccess() async {
    Uint8List packet = cmd.resumeRecordSuccess();
    return await _writeWithoutResponse(packet);
  }

  // 无响应写入蓝牙命令
  Future _writeWithoutResponse(List<int> writeCmd) async {
    if (!blueNotify!.isNotifying) {
      return Future.value(false);
    }
    try {
      await blueWrite?.write(writeCmd,
          withoutResponse: blueWrite!.properties.writeWithoutResponse);
      if (blueWrite!.properties.read) {
        await blueWrite?.read();
      }
      return Future.value(true);
    } catch (e) {
      logger.e('写入蓝牙命令失败了...$e');
      return Future.value(false);
    }
  }

  // 无响应写入电池蓝牙命令
  Future _writeBatteryWithoutResponse(List<int> writeCmd) async {
    if (!blueBatteryNotify!.isNotifying) {
      return Future.value(false);
    }
    try {
      await blueWrite?.write(writeCmd,
          withoutResponse: blueWrite!.properties.writeWithoutResponse);
      if (blueWrite!.properties.read) {
        await blueWrite?.read();
      }
      return Future.value(true);
    } catch (e) {
      logger.e('写入电池蓝牙命令失败了...$e');
      return Future.value(false);
    }
  }

  // 清理服务内部缓存的蓝牙特征引用
  void clearServiceCache() {
    logger.d('清理 BlueService 内部缓存');
    blueWrite = null;
    blueNotify = null;
    blueBatteryNotify = null;
  }
}
