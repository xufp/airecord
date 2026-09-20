import 'dart:typed_data';

import 'package:airecordapp/command/v2/Crc16FastTbl.dart';

/// 新硬件 BLE 帧结构封装（录音笔BLE通讯协议 2025-11-24 版）。
///
/// 帧格式：
///   0x5A | len(1B, 上报为 3B) | cmd(1B) | params(0~240B) | CRC16(2B, 小端)
/// - len：命令 + 参数 + 校验的字节总数（即从 cmd 开始到 CRC 结束的长度）。
/// - CRC16：使用 [crc16Fast]，校验范围为 len 起始到 params 结尾。
///
/// 本类仅负责帧层封装与解析，不涉及业务含义。
class NewBleFrame {
  /// 帧头，固定 0x5A。
  static const int kMagic = 0x5A;

  /// 参数部分最大长度（协议定义）。
  static const int kMaxParamsLen = 240;

  /// 指令/应答码（uint8）。
  final int cmd;

  /// 参数字节。
  final Uint8List params;

  /// 是否是"上报帧"：上报帧的长度字段占 3 个字节（小端）。
  /// 目前仅 0x90 语音识别内容上报 / 0xA8 实时电平 / 0xFF 文件列表续包等可能用到。
  final bool isReport;

  NewBleFrame({
    required this.cmd,
    Uint8List? params,
    this.isReport = false,
  }) : params = params ?? Uint8List(0);

  /// 构造写入字节流。
  /// 写入方向固定使用 1 字节 len。
  Uint8List toBytes() {
    final int paramsLen = params.length;
    // len 字段值：cmd(1) + params(n) + crc(2)
    final int lenValue = 1 + paramsLen + 2;

    // 完整帧：magic(1) + len(1) + cmd(1) + params(n) + crc(2)
    final BytesBuilder builder = BytesBuilder();
    builder.addByte(kMagic);
    builder.addByte(lenValue & 0xFF);
    builder.addByte(cmd & 0xFF);
    if (paramsLen > 0) builder.add(params);

    // CRC 计算范围：len + cmd + params
    final Uint8List crcRange =
        Uint8List.fromList(builder.toBytes().sublist(1));
    final int crc = crc16Fast(crcRange);
    // 小端追加
    builder.addByte(crc & 0xFF);
    builder.addByte((crc >> 8) & 0xFF);

    return builder.toBytes();
  }

  /// 从字节流解析一帧；若 CRC 或帧头非法，返回 null。
  /// - [raw]：完整帧（可能带有额外尾部，解析仅取协议声明长度）。
  /// - [isReport]：为 true 时 len 字段解析为 3 字节（小端）。
  static NewBleFrame? fromBytes(Uint8List raw, {bool isReport = false}) {
    if (raw.isEmpty) return null;
    if (raw[0] != kMagic) return null;

    final int lenFieldSize = isReport ? 3 : 1;
    if (raw.length < 1 + lenFieldSize + 1 + 2) return null; // magic+len+cmd+crc

    int lenValue;
    if (isReport) {
      // 3 字节小端
      lenValue =
          (raw[1] & 0xFF) | ((raw[2] & 0xFF) << 8) | ((raw[3] & 0xFF) << 16);
    } else {
      lenValue = raw[1] & 0xFF;
    }
    if (lenValue < 3) return null; // 至少 cmd(1)+crc(2)

    final int cmdOffset = 1 + lenFieldSize;
    final int totalLen = 1 + lenFieldSize + lenValue; // magic + len + (cmd+params+crc)
    if (raw.length < totalLen) return null;

    final int cmd = raw[cmdOffset] & 0xFF;
    final int paramsLen = lenValue - 1 /*cmd*/ - 2 /*crc*/;
    final Uint8List params = Uint8List.fromList(
        raw.sublist(cmdOffset + 1, cmdOffset + 1 + paramsLen));

    // 校验 CRC：范围 len 起始到 params 结尾
    final Uint8List crcRange =
        Uint8List.fromList(raw.sublist(1, cmdOffset + 1 + paramsLen));
    final int calcCrc = crc16Fast(crcRange);
    final int recvCrc = (raw[cmdOffset + 1 + paramsLen] & 0xFF) |
        ((raw[cmdOffset + 2 + paramsLen] & 0xFF) << 8);
    if (calcCrc != recvCrc) return null;

    return NewBleFrame(cmd: cmd, params: params, isReport: isReport);
  }

  /// 尝试以"上报帧"和"普通帧"两种方式解析，任一成功即返回。
  /// 适配 notify 通道混合接收控制应答与上报帧的场景。
  static NewBleFrame? tryParse(Uint8List raw) {
    // 优先按普通帧（更常见）
    return fromBytes(raw, isReport: false) ??
        fromBytes(raw, isReport: true);
  }

  @override
  String toString() {
    return 'NewBleFrame(cmd=0x${cmd.toRadixString(16).padLeft(2, '0')}, '
        'paramsLen=${params.length}, isReport=$isReport)';
  }
}
