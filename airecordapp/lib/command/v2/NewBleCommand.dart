import 'dart:convert';
import 'dart:typed_data';

import 'package:airecordapp/command/v2/NewBleFrame.dart';

/// 新硬件 BLE 指令集（录音笔BLE通讯协议 2025-11-24 版）。
/// 本类仅生成写入帧字节流，不与业务控制层耦合。
class NewBleCommand {
  // =========== 服务通道划分 ===========
  // FFF0（FFF1 写 / FFF2 通知）：控制类、文件元数据类指令
  // FFE0（FFE1 写 / FFE2 通知）：录音开始/状态、实时电平、语音上报、文件数据下载

  // =========== 指令码常量 ===========
  static const int cmdQel = 0x01; // 电量读取
  static const int cmdReadRecState = 0x02; // 录音状态读取 (FFE0)
  static const int cmdReadFtpAddr = 0x03;
  static const int cmdReadFtpPort = 0x04;
  static const int cmdReadFtpUser = 0x05;
  static const int cmdReadFtpPwd = 0x06;
  static const int cmdReadVersion = 0x09;
  static const int cmdFileList = 0x13; // 查询本地音频文件信息
  static const int cmdReadSettings = 0xB1;

  static const int cmdWriteRecState = 0x80; // 录音 开/关/暂停/恢复 (FFE0)
  static const int cmdPowerOff = 0x85;
  static const int cmdReset = 0x86;
  static const int cmdWifiSwitch = 0x87;
  static const int cmdFileDownload = 0x84; // 文件下载
  static const int cmdFileDelete = 0x92; // 文件删除
  static const int cmdLedSwitch = 0x95;
  static const int cmdUsbSwitch = 0x96;
  static const int cmdResend = 0xA3; // 补包/续传
  static const int cmdTranscribeSwitch = 0xA4; // 开关实时转录
  static const int cmdClearAllFiles = 0x9A;
  static const int cmdWriteSettings = 0xB0;

  // 录音状态值
  static const int recStateOff = 0x00;
  static const int recStateOn = 0x01;
  static const int recStatePause = 0x02;
  static const int recStateResume = 0x03;

  // 文件下载同步操作
  static const int syncOpStart = 0x00;
  static const int syncOpCancel = 0x01;
  static const int syncOpPause = 0x02;
  static const int syncOpResume = 0x03;

  // ---------- 读取指令（走 FFF1 写入）----------

  /// 0x01 读取电量（返回 0~100）
  Uint8List qel() => NewBleFrame(cmd: cmdQel).toBytes();

  /// 0x02 读取录音状态（走 FFE1 写入）
  Uint8List readRecState() => NewBleFrame(cmd: cmdReadRecState).toBytes();

  /// 0x09 读取软件版本
  Uint8List readVersion() => NewBleFrame(cmd: cmdReadVersion).toBytes();

  /// 0x13 查询本地音频文件信息
  Uint8List fileList() => NewBleFrame(cmd: cmdFileList).toBytes();

  // ---------- 录音控制（走 FFE1 写入）----------

  /// 0x80 开始录音
  Uint8List recStart() => NewBleFrame(
        cmd: cmdWriteRecState,
        params: Uint8List.fromList([recStateOn]),
      ).toBytes();

  /// 0x80 停止录音
  Uint8List recStop() => NewBleFrame(
        cmd: cmdWriteRecState,
        params: Uint8List.fromList([recStateOff]),
      ).toBytes();

  /// 0x80 暂停录音
  Uint8List recPause() => NewBleFrame(
        cmd: cmdWriteRecState,
        params: Uint8List.fromList([recStatePause]),
      ).toBytes();

  /// 0x80 恢复录音
  Uint8List recResume() => NewBleFrame(
        cmd: cmdWriteRecState,
        params: Uint8List.fromList([recStateResume]),
      ).toBytes();

  // ---------- 实时转录开关（走 FFF1 写入）----------

  /// 0xA4 开启实时转录
  Uint8List transcribeOn() => NewBleFrame(
        cmd: cmdTranscribeSwitch,
        params: Uint8List.fromList([0x01]),
      ).toBytes();

  /// 0xA4 关闭实时转录
  Uint8List transcribeOff() => NewBleFrame(
        cmd: cmdTranscribeSwitch,
        params: Uint8List.fromList([0x00]),
      ).toBytes();

  // ---------- 文件下载与管理 ----------

  /// 0x84 请求下载某个音频文件。
  /// - [fileName]：ASCII 文件名
  /// - [startPkg]：起始包索引 0x000000~0xFFFFFF（大端：先发高字节）
  /// - [syncOp]：0 开始/1 取消/2 暂停/3 继续
  Uint8List fileDownload({
    required String fileName,
    int startPkg = 0,
    int syncOp = syncOpStart,
  }) {
    final Uint8List nameBytes =
        Uint8List.fromList(ascii.encode(fileName));
    final BytesBuilder p = BytesBuilder();
    p.add(nameBytes);
    // 起始包：3 字节，高字节先发
    p.addByte((startPkg >> 16) & 0xFF);
    p.addByte((startPkg >> 8) & 0xFF);
    p.addByte(startPkg & 0xFF);
    p.addByte(syncOp & 0xFF);
    return NewBleFrame(cmd: cmdFileDownload, params: p.toBytes()).toBytes();
  }

  /// 0x92 删除某个音频文件。
  Uint8List fileDelete(String fileName) {
    final Uint8List nameBytes =
        Uint8List.fromList(ascii.encode(fileName));
    return NewBleFrame(cmd: cmdFileDelete, params: nameBytes).toBytes();
  }

  /// 0xA3 续传补包：从指定包继续下载。无响应帧。
  Uint8List resendFrom(int startPkg) {
    final BytesBuilder p = BytesBuilder();
    p.addByte((startPkg >> 16) & 0xFF);
    p.addByte((startPkg >> 8) & 0xFF);
    p.addByte(startPkg & 0xFF);
    return NewBleFrame(cmd: cmdResend, params: p.toBytes()).toBytes();
  }

  /// 0xA3 结束下载（发送 0xFFFFFF）。
  Uint8List resendEnd() => resendFrom(0xFFFFFF);

  // ---------- 其他常用设备控制 ----------

  /// 0x85 关机
  Uint8List powerOff() => NewBleFrame(
        cmd: cmdPowerOff,
        params: Uint8List.fromList([0x00]),
      ).toBytes();

  /// 0x9A 清空设备上所有录音文件
  Uint8List clearAllFiles() => NewBleFrame(cmd: cmdClearAllFiles).toBytes();
}
