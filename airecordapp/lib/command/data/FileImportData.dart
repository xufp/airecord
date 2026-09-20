import 'dart:typed_data';
import 'dart:convert';

// 定义 FileData 类，用于封装文件名和偏移量
class FileImportData {
  final int offset;
  final List<String> fileNames;

  FileImportData({required this.offset, required this.fileNames});

  // 方法将 FileData 对象转换为 Uint8List 格式
  Uint8List toBytes() {
    // 初始化一个字节缓冲区
    BytesBuilder bytesBuilder = BytesBuilder();

    // 写入每个文件名（每个文件名占用20字节）
    for (var fileName in fileNames) {
      // 写入偏移量（大小为4字节）
      bytesBuilder.add(_int32ToBytes(offset));
      bytesBuilder.add(_stringToFixedBytes(fileName, 20));
    }

    return bytesBuilder.toBytes();
  }

  // 辅助方法：将 int 转换为 4 字节数组
  List<int> _int32ToBytes(int value) {
    var byteData = ByteData(4);
    byteData.setInt32(0, value, Endian.little); // 使用小端序
    return byteData.buffer.asUint8List().toList();
  }

  // 辅助方法：将字符串转换为固定长度的字节数组（长度不够时补0）
  List<int> _stringToFixedBytes(String value, int length) {
    List<int> bytes = utf8.encode(value);
    if (bytes.length > length) {
      // 字符串太长，截取所需长度
      bytes = bytes.sublist(0, length);
    } else if (bytes.length < length) {
      // 字符串太短，补0到所需长度
      bytes += List.filled(length - bytes.length, 0);
    }
    return bytes;
  }
}
