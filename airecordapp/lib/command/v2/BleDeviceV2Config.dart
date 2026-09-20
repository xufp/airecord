/// 新硬件 V2 本地硬编码配置（暂不依赖后端 bleDeviceList 接口）。
///
/// 协议参考：docs/录音笔BLE通信协议_20251222.docx
/// - 广播 LocalName：AI-RTCAPEN
/// - 广播 ServiceUUIDs：FFF0（控制/文件元数据），FFE0（实时语音/录音状态/文件数据）
/// - 特征 UUIDs：FFF1 写 / FFF2 通知；FFE1 写 / FFE2 通知
/// - ManufacturerData 9 字节：MAC(6) + 公司ID(1=0x09) + 产品ID(1=0x01 录音笔) + 电量(1, 0~100)
class BleDeviceV2Config {
  /// 广播名，用于扫描过滤与展示（按协议约定）。
  static const String advLocalName = 'AI-RTCAPEN';

  /// 设备型号标识（不影响协议，仅用于 UI/DB 区分）。
  static const String deviceType = 'PEN_V2';

  /// 展示名（占位，待后续补充）。
  static const String deviceName = '新款录音笔';

  /// 控制/文件元数据服务及其特征。
  static const String serviceUuidFff = 'FFF0';
  static const String characteristicWriteFff = 'FFF1';
  static const String characteristicNotifyFff = 'FFF2';

  /// 实时语音/录音状态/文件数据服务及其特征。
  static const String serviceUuidFfe = 'FFE0';
  static const String characteristicWriteFfe = 'FFE1';
  static const String characteristicNotifyFfe = 'FFE2';

  /// 广播中的公司 ID（非 0x09 时过滤不展示，协议强制要求）。
  static const int advCompanyId = 0x09;

  /// 默认产品 ID（录音笔 = 0x01）。
  static const int advProductId = 0x01;

  /// 规范化 UUID 字符串到短 UUID 小写形式，用于 characteristic 匹配。
  /// flutter_blue_plus 在 iOS/Android 上可能返回完整或短 UUID，这里统一为小写。
  static String normalizeUuid(String uuid) {
    final String lower = uuid.trim().toLowerCase();
    // 若是完整 128-bit UUID 且符合标准蓝牙基础 UUID，则取其短形式
    // 例：0000fff1-0000-1000-8000-00805f9b34fb → fff1
    final RegExp base = RegExp(
        r'^0000([0-9a-f]{4})-0000-1000-8000-00805f9b34fb$');
    final m = base.firstMatch(lower);
    if (m != null) return m.group(1) ?? lower;
    return lower;
  }

  /// 判断两个 UUID 是否等价（兼容 16-bit 短 UUID 与 128-bit 长 UUID）。
  static bool uuidEquals(String a, String b) {
    return normalizeUuid(a) == normalizeUuid(b);
  }
}
