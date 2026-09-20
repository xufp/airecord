import 'dart:typed_data';
import 'dart:convert';

// 定义一个类表示结构体
class FileInfo {
  final int timestamp; // 时间（秒）
  final int size; // 大小（字节）
  final String fileName; // 文件名

  FileInfo(this.timestamp, this.size, this.fileName);

  @override
  String toString() {
    return 'FileInfo(timestamp: $timestamp, size: $size, fileName: $fileName)';
  }
}

class FileAudio {
  // 解析 Uint8List 数据
  List<FileInfo> fromBytes(Uint8List data) {
    List<FileInfo> files = [];
    ByteData byteData = data.buffer.asByteData();

    // 1. 读取文件数量(前2字节，大端序)
    final fileCount = byteData.getUint16(0, Endian.little);

    // 2. 计算最小需要的数据长度
    const headerSize = 2; // 文件数量占2字节
    const fileInfoSize = 24; // 每个文件信息占24字节(4+20)

    // 3. 解析每个文件信息
    int offset = headerSize; // 跳过文件数量字段

    for (int i = 0; i < fileCount; i++) {
      final currentEnd = offset + 4;
      if (currentEnd > data.length) break; // 防止读取大小越界
      // 3.1 读取文件大小(4字节，大端序)
      final size = byteData.getUint32(offset, Endian.little);
      // 检查文件名区域是否越界
      final nameEnd = offset + 24;
      if (nameEnd > data.length) break;
      int timestamp = calculateDuration(size);

      // 3.2 读取文件名(20字节)
      final nameBytes = data.sublist(offset + 4, offset + 24);
      final fileName = getFileName(nameBytes);

      // 3.3 添加到列表
      files.add(FileInfo(timestamp, size, fileName));

      // 3.4 移动偏移量到下一个文件
      offset += fileInfoSize;
    }

    return files;
  }

  int calculateDuration(int fileSizeBytes) {
    const bytesPerFrame = 40;
    const msPerFrame = 20;

    final frames = (fileSizeBytes / bytesPerFrame).ceil();
    final totalMs = frames * msPerFrame;
    return (totalMs / 1000).ceil();
  }

  // 辅助方法：安全解码文件名
  String getFileName(Uint8List nameBytes) {
    // 过滤空字节并转换为字符串
    final cleanBytes = nameBytes.where((byte) => byte != 0).toList();
    return utf8.decode(cleanBytes);
  }
}
