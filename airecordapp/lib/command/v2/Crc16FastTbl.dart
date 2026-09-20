import 'dart:typed_data';

/// CRC16 FastTbl（16 元素查表法），用于新硬件 BLE 协议。
/// 对应固件端 CRC16FastTbl 表：
///   每字节分两次处理（低 4 位、高 4 位），初值固定 0xFFFF。
///   与固件的 GetCRC16 / crc16_fast 行为一致。
const List<int> kCrc16FastTbl = <int>[
  0x0000, 0xCC01, 0xD801, 0x1400,
  0xF001, 0x3C00, 0x2800, 0xE401,
  0xA001, 0x6C00, 0x7800, 0xB401,
  0x5000, 0x9C01, 0x8801, 0x4400,
];

/// 计算 CRC16（FastTbl）。
/// - [data]：需校验的字节范围（对应协议「长度 + 命令 + 参数」区域）。
/// - [initial]：初始值，默认 0xFFFF（协议默认值）。
int crc16Fast(Uint8List data, {int initial = 0xFFFF}) {
  int crc = initial & 0xFFFF;
  for (int i = 0; i < data.length; i++) {
    final int byte = data[i] & 0xFF;
    // 处理低 4 位
    int lowNibble = byte & 0x0F;
    int index = (crc ^ lowNibble) & 0x0F;
    crc = ((crc >> 4) ^ kCrc16FastTbl[index]) & 0xFFFF;
    // 处理高 4 位
    int highNibble = (byte >> 4) & 0x0F;
    index = (crc ^ highNibble) & 0x0F;
    crc = ((crc >> 4) ^ kCrc16FastTbl[index]) & 0xFFFF;
  }
  return crc;
}
