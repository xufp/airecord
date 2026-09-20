import 'dart:typed_data';

class DateTime {
  int year; // uint16
  int month; // uint8
  int day; // uint8
  int hour; // uint8
  int minute; // uint8
  int second; // uint8

  DateTime({
    required this.year,
    required this.month,
    required this.day,
    required this.hour,
    required this.minute,
    required this.second,
  });

  // 将Date结构序列化为字节序列
  Uint8List toBytes() {
    final byteData = ByteData(
        7); // 16-bit year + 8-bit month/day/hour/minute/second = 7 bytes

    byteData.setUint16(0, year, Endian.little); // 16位年份
    byteData.setUint8(2, month); // 8位月份
    byteData.setUint8(3, day); // 8位日期
    byteData.setUint8(4, hour); // 8位小时
    byteData.setUint8(5, minute); // 8位分钟
    byteData.setUint8(6, second); // 8位秒

    return byteData.buffer.asUint8List();
  }

  // 从字节序列反序列化为Date结构
  DateTime fromBytes(Uint8List bytes) {
    final byteData = ByteData.sublistView(bytes);

    int year = byteData.getUint16(0, Endian.little); // 16位年份
    int month = byteData.getUint8(2); // 8位月份
    int day = byteData.getUint8(3); // 8位日期
    int hour = byteData.getUint8(4); // 8位小时
    int minute = byteData.getUint8(5); // 8位分钟
    int second = byteData.getUint8(6); // 8位秒

    return DateTime(
      year: year,
      month: month,
      day: day,
      hour: hour,
      minute: minute,
      second: second,
    );
  }
}
