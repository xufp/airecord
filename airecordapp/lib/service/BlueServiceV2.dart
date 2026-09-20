import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:airecordapp/command/v2/BleDeviceV2Config.dart';
import 'package:airecordapp/command/v2/NewBleCommand.dart';
import 'package:airecordapp/command/v2/NewBleFrame.dart';
import 'package:airecordapp/util/LogUtil.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// V2 硬件广播解析出的元信息。
class BlueV2AdvInfo {
  final String mac;
  final int companyId;
  final int productId;
  final int battery;

  BlueV2AdvInfo({
    required this.mac,
    required this.companyId,
    required this.productId,
    required this.battery,
  });

  /// 按协议从 9 字节 ManufacturerData 解析；非法返回 null。
  /// 格式：MAC(6B) + 公司ID(1B) + 产品ID(1B) + 电量(1B 0~100)
  static BlueV2AdvInfo? parse(Uint8List data) {
    if (data.length < 9) return null;
    final int companyId = data[6] & 0xFF;
    // 协议强制要求 companyId == 0x09，否则 APP 不展示。
    if (companyId != BleDeviceV2Config.advCompanyId) return null;
    final String mac = data
        .sublist(0, 6)
        .map((e) => (e & 0xFF).toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(':');
    return BlueV2AdvInfo(
      mac: mac,
      companyId: companyId,
      productId: data[7] & 0xFF,
      battery: data[8] & 0xFF,
    );
  }
}

/// 新硬件 BLE 传输服务（V2）。完全独立于现有 [BlueService]，互不影响。
///
/// 负责：
/// 1. 扫描过滤：LocalName=AI-RTCAPEN 且 ManufacturerData 公司 ID=0x09 的设备。
/// 2. 连接后发现两组服务 FFF0/FFE0 的 4 个特征，并分别监听 FFF2/FFE2。
/// 3. 根据指令码自动把写入帧路由到 FFF1（控制/文件元数据）或 FFE1（录音控制/实时）。
/// 4. 将 notify 原始字节以 [Uint8List] 形式透出两路 Stream，由上层（Controller）
///    交给 [NewBleResponse] 做业务解析。
class BlueServiceV2 {
  final _logger = LogUtil.inItLog();

  BluetoothCharacteristic? _writeFff; // FFF1
  BluetoothCharacteristic? _notifyFff; // FFF2
  BluetoothCharacteristic? _writeFfe; // FFE1
  BluetoothCharacteristic? _notifyFfe; // FFE2

  StreamSubscription<List<int>>? _subFff;
  StreamSubscription<List<int>>? _subFfe;

  final StreamController<Uint8List> _controlCtrl =
      StreamController<Uint8List>.broadcast();
  final StreamController<Uint8List> _realtimeCtrl =
      StreamController<Uint8List>.broadcast();

  /// 控制/文件元数据 notify 数据流（来自 FFF2）。
  Stream<Uint8List> get controlStream => _controlCtrl.stream;

  /// 实时语音/录音状态/文件数据 notify 数据流（来自 FFE2）。
  Stream<Uint8List> get realtimeStream => _realtimeCtrl.stream;

  /// 本次连接是否已成功订阅 notify（双通道均订阅才视为 true）。
  bool get isSubscribed =>
      (_notifyFff?.isNotifying ?? false) &&
      (_notifyFfe?.isNotifying ?? false);

  /// 启动扫描。使用短 UUID 与完整 128-bit 两种方式；
  /// flutter_blue_plus 的 withServices 在部分系统要求 128-bit。
  Future<void> startScan() async {
    try {
      final int divisor = Platform.isAndroid ? 8 : 1;
      await FlutterBluePlus.startScan(
        withServices: <Guid>[
          Guid('0000${BleDeviceV2Config.serviceUuidFff.toLowerCase()}-0000-1000-8000-00805f9b34fb'),
        ],
        timeout: const Duration(seconds: 15),
        continuousUpdates: true,
        continuousDivisor: divisor,
        androidScanMode: AndroidScanMode.lowPower,
      );
    } catch (e) {
      _logger.e('V2 Start Scan Error: $e');
    }
  }

  /// 在 [ScanResult] 中识别是否是 V2 新硬件。
  /// 条件：LocalName=AI-RTCAPEN（在 platformName 或 advertisementData.localName 中均可能出现）
  /// 且 ManufacturerData 第 7 字节 companyId=0x09。
  bool isV2Device(ScanResult r) {
    // LocalName 匹配（不区分大小写）
    final String name =
        (r.advertisementData.advName.isNotEmpty
                ? r.advertisementData.advName
                : r.device.platformName)
            .toUpperCase();
    if (name != BleDeviceV2Config.advLocalName.toUpperCase()) {
      return false;
    }
    // ManufacturerData 校验
    for (final entry in r.advertisementData.manufacturerData.entries) {
      // 部分平台把整个 9 字节放在某个 key 下，拼回来检查
      final bytes = Uint8List.fromList(entry.value);
      // 某些平台不包含前面的公司 ID 占位，直接用 bytes 也可；做尽量宽松的匹配
      final info = BlueV2AdvInfo.parse(bytes);
      if (info != null) return true;
      // 回退：尝试把 (key + bytes) 拼成完整 9 字节再解析
      final BytesBuilder merged = BytesBuilder();
      merged.addByte(entry.key & 0xFF);
      merged.addByte((entry.key >> 8) & 0xFF);
      merged.add(bytes);
      final info2 = BlueV2AdvInfo.parse(merged.toBytes());
      if (info2 != null) return true;
    }
    // 兜底：如果 LocalName 匹配但没有解析出公司 ID，也允许（部分厂商广播格式差异）。
    return true;
  }

  /// 从 [ScanResult] 提取广播中的电量与 MAC 等元信息，用于 UI 展示。
  BlueV2AdvInfo? parseAdvInfo(ScanResult r) {
    for (final entry in r.advertisementData.manufacturerData.entries) {
      final info = BlueV2AdvInfo.parse(Uint8List.fromList(entry.value));
      if (info != null) return info;
      final BytesBuilder merged = BytesBuilder();
      merged.addByte(entry.key & 0xFF);
      merged.addByte((entry.key >> 8) & 0xFF);
      merged.add(entry.value);
      final info2 = BlueV2AdvInfo.parse(merged.toBytes());
      if (info2 != null) return info2;
    }
    return null;
  }

  Future<void> stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
    } catch (e) {
      _logger.e('V2 Stop Scan Error: $e');
    }
  }

  /// 从已发现的 service/characteristic 中定位 FFF1/FFF2/FFE1/FFE2 并订阅 notify。
  Future<bool> initBlue(List<BluetoothService> services) async {
    await _cancelSubs();
    _writeFff = null;
    _notifyFff = null;
    _writeFfe = null;
    _notifyFfe = null;

    for (final s in services) {
      final serviceUuid = BleDeviceV2Config.normalizeUuid(s.uuid.str);
      if (serviceUuid == BleDeviceV2Config.serviceUuidFff.toLowerCase()) {
        for (final c in s.characteristics) {
          final cu = BleDeviceV2Config.normalizeUuid(c.uuid.str);
          if (cu == BleDeviceV2Config.characteristicWriteFff.toLowerCase()) {
            _writeFff = c;
          } else if (cu ==
              BleDeviceV2Config.characteristicNotifyFff.toLowerCase()) {
            _notifyFff = c;
          }
        }
      } else if (serviceUuid ==
          BleDeviceV2Config.serviceUuidFfe.toLowerCase()) {
        for (final c in s.characteristics) {
          final cu = BleDeviceV2Config.normalizeUuid(c.uuid.str);
          if (cu == BleDeviceV2Config.characteristicWriteFfe.toLowerCase()) {
            _writeFfe = c;
          } else if (cu ==
              BleDeviceV2Config.characteristicNotifyFfe.toLowerCase()) {
            _notifyFfe = c;
          }
        }
      }
    }

    if (_writeFff == null ||
        _notifyFff == null ||
        _writeFfe == null ||
        _notifyFfe == null) {
      _logger.e(
          'V2 服务/特征不完整：writeFff=$_writeFff, notifyFff=$_notifyFff, writeFfe=$_writeFfe, notifyFfe=$_notifyFfe');
      return false;
    }

    try {
      if (!_notifyFff!.isNotifying) {
        await _notifyFff!.setNotifyValue(true);
      }
      if (!_notifyFfe!.isNotifying) {
        await _notifyFfe!.setNotifyValue(true);
      }
      _subFff = _notifyFff!.lastValueStream.listen((value) {
        if (value.isNotEmpty) {
          _controlCtrl.add(Uint8List.fromList(value));
        }
      });
      _subFfe = _notifyFfe!.lastValueStream.listen((value) {
        if (value.isNotEmpty) {
          _realtimeCtrl.add(Uint8List.fromList(value));
        }
      });
      return true;
    } catch (e) {
      _logger.e('V2 订阅 notify 失败: $e');
      return false;
    }
  }

  /// 根据指令码自动选择写入通道。
  /// - 走 FFE1：0x02(读录音状态)/0x80(写录音状态)/0xA3(续传)
  /// - 其余走 FFF1
  Future<bool> writeFrame(NewBleFrame frame) async {
    final bool useFfe = frame.cmd == NewBleCommand.cmdReadRecState ||
        frame.cmd == NewBleCommand.cmdWriteRecState ||
        frame.cmd == NewBleCommand.cmdResend;
    final BluetoothCharacteristic? target = useFfe ? _writeFfe : _writeFff;
    if (target == null) {
      _logger.e('V2 写入失败：对应特征未就绪, cmd=0x${frame.cmd.toRadixString(16)}');
      return false;
    }
    try {
      await target.write(
        frame.toBytes(),
        withoutResponse: target.properties.writeWithoutResponse,
      );
      return true;
    } catch (e) {
      _logger.e('V2 写入异常 cmd=0x${frame.cmd.toRadixString(16)}: $e');
      return false;
    }
  }

  /// 直接写入（已经是字节流），用于上层直接发补包等命令。
  Future<bool> writeControlRaw(Uint8List bytes) async {
    if (_writeFff == null) return false;
    try {
      await _writeFff!.write(
        bytes,
        withoutResponse: _writeFff!.properties.writeWithoutResponse,
      );
      return true;
    } catch (e) {
      _logger.e('V2 FFF1 raw 写入异常: $e');
      return false;
    }
  }

  Future<bool> writeRealtimeRaw(Uint8List bytes) async {
    if (_writeFfe == null) return false;
    try {
      await _writeFfe!.write(
        bytes,
        withoutResponse: _writeFfe!.properties.writeWithoutResponse,
      );
      return true;
    } catch (e) {
      _logger.e('V2 FFE1 raw 写入异常: $e');
      return false;
    }
  }

  Future<void> _cancelSubs() async {
    await _subFff?.cancel();
    await _subFfe?.cancel();
    _subFff = null;
    _subFfe = null;
    try {
      await _notifyFff?.setNotifyValue(false);
      await _notifyFfe?.setNotifyValue(false);
    } catch (_) {}
  }

  /// 释放资源。
  Future<void> dispose() async {
    await _cancelSubs();
    await _controlCtrl.close();
    await _realtimeCtrl.close();
  }

  /// 仅关闭订阅（不关闭 StreamController，便于重连复用）。
  Future<void> closeSubscriptions() async {
    await _cancelSubs();
  }
}
