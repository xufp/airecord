import 'dart:typed_data';
import 'dart:convert';
import 'package:airecordapp/command/BluetoothMsg.dart';
import 'package:airecordapp/command/data/FileAudio.dart';

class BluetoothResponse {
  final int sn = 0x00; // 默认起始包
  static const controlType = 0; // 控制指令类型
  static const tranType = 1; // 实时转写类型
  static const fileType = 2; // 文件操作类型
  static const ackType = 3; // ACK类型

  // 监听设备是否发起解绑
  bool isDevUnbind(Uint8List serializedMsg) {
    BluetoothMsg deserializedMsg = BluetoothMsg.fromBytes(serializedMsg);
    // 没有命中命令，代表无音频数据
    if (deserializedMsg.dataContent.dataType == controlType &&
        deserializedMsg.dataContent.cmd == 15) {
      return true;
    }
    return false;
  }

  // 监听实时转写音频数据
  Uint8List tranAudio(Uint8List serializedMsg) {
    BluetoothMsg deserializedMsg = BluetoothMsg.fromBytes(serializedMsg);
    // 没有命中命令，代表无音频数据
    if (deserializedMsg.dataContent.dataType != tranType ||
        deserializedMsg.dataContent.cmd != 1) {
      return Uint8List(0);
    }
    return deserializedMsg.dataContent.data;
  }

  // 监听设备状态
  int devState(Uint8List serializedMsg) {
    BluetoothMsg deserializedMsg = BluetoothMsg.fromBytes(serializedMsg);
    // 没有命中命令，代表无音频数据
    if (deserializedMsg.dataContent.dataType != tranType ||
        deserializedMsg.dataContent.cmd != 4) {
      return -1;
    }
    Uint8List content = deserializedMsg.dataContent.data;
    final byteData = ByteData.sublistView(content);
    return byteData.getUint8(0);
  }

  // 监听解析获取音频文件
  List<FileInfo> audioList(Uint8List serializedMsg) {
    BluetoothMsg deserializedMsg = BluetoothMsg.fromBytes(serializedMsg);
    // 没有命中命令，代表无文件
    if (deserializedMsg.dataContent.dataType != fileType ||
        deserializedMsg.dataContent.cmd != 1) {
      return <FileInfo>[];
    }

    List<FileInfo> audioList =
        FileAudio().fromBytes(deserializedMsg.dataContent.data);
    return audioList;
  }

  // 监听开始导入的文件
  String extractFileName(Uint8List serializedMsg) {
    BluetoothMsg deserializedMsg = BluetoothMsg.fromBytes(serializedMsg);
    // 没有命中命令，代表无文件
    if (deserializedMsg.dataContent.dataType != fileType ||
        deserializedMsg.dataContent.cmd != 3) {
      return '';
    }
    // 将 Uint8List 转换为 List<int>
    List<int> bytes = deserializedMsg.dataContent.data.toList();
    // 使用 utf8 解码为字符串
    String fileName = utf8.decode(bytes);
    return fileName;
  }

  // 监听导入的音频数据
  Uint8List audioData(Uint8List serializedMsg) {
    BluetoothMsg deserializedMsg = BluetoothMsg.fromBytes(serializedMsg);
    // 没有命中命令，代表无音频数据
    if (deserializedMsg.dataContent.dataType != fileType ||
        deserializedMsg.dataContent.cmd != 4) {
      return Uint8List(0);
    }
    return deserializedMsg.dataContent.data;
  }

  // 监听当前导入文件进度以及异常
  int progress(Uint8List serializedMsg) {
    BluetoothMsg deserializedMsg = BluetoothMsg.fromBytes(serializedMsg);
    // 没有命中命令，代表无音频数据
    if (deserializedMsg.dataContent.dataType != fileType ||
        deserializedMsg.dataContent.cmd != 5) {
      return -1;
    }
    Uint8List content = deserializedMsg.dataContent.data;
    final byteData = ByteData.sublistView(content);
    return byteData.getUint8(0);
  }

  // 监听设备是否终止导入
  bool isStopImport(Uint8List serializedMsg) {
    BluetoothMsg deserializedMsg = BluetoothMsg.fromBytes(serializedMsg);
    // 没有命中命令，代表无音频数据
    if (deserializedMsg.dataContent.dataType != fileType &&
        deserializedMsg.dataContent.cmd != 11) {
      return true;
    }
    return false;
  }
}
