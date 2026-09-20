import 'dart:typed_data';
import 'package:airecordapp/command/BluetoothMsg.dart';
import 'package:airecordapp/command/data/DateTime.dart' as BtDateTime;
import 'package:airecordapp/command/data/FileImportData.dart';

class BluetoothCommand {
  final int sn = 0x00; // 默认起始包
  final int controlType = 0; // 控制指令类型
  final int tranType = 1; // 实时转写类型
  final int fileType = 2; // 文件操作类型
  final int ackType = 3; // ACK类型

  // 同步系统时间
  Uint8List syncTime() {
    // 使用 Dart 内置 DateTime 获取手机当前时间
    var now = DateTime.now();
    // 创建自定义 Date 对象
    BtDateTime.DateTime date = BtDateTime.DateTime(
        year: now.year, month: now.month, day: now.day,
        hour: now.hour, minute: now.minute, second: now.second);
    // 创建DataContent对象，并将Date的toBytes作为data
    DataContent dataContent =
        DataContent(dataType: controlType, cmd: 0, data: date.toBytes());
    // 创建BluetoothMsg对象
    BluetoothMsg msg = BluetoothMsg(sn: sn, dataContent: dataContent);
    // 序列化
    Uint8List serializedMsg = msg.toBytes();
    return serializedMsg;
  }

  // 获取电量百分比
  Uint8List qel() {
    DataContent dataContent = DataContent(dataType: controlType, cmd: 3);
    // 创建BluetoothMsg对象
    BluetoothMsg msg = BluetoothMsg(sn: sn, dataContent: dataContent);
    // 序列化
    Uint8List serializedMsg = msg.toBytes();
    return serializedMsg;
  }

  // app发起绑定成功
  Uint8List devBind() {
    DataContent dataContent = DataContent(dataType: controlType, cmd: 16);
    // 创建BluetoothMsg对象
    BluetoothMsg msg = BluetoothMsg(sn: sn, dataContent: dataContent);
    // 序列化
    Uint8List serializedMsg = msg.toBytes();
    return serializedMsg;
  }

  // App告知设备解绑
  Uint8List devUnbind() {
    DataContent dataContent = DataContent(dataType: controlType, cmd: 17);
    // 创建BluetoothMsg对象
    BluetoothMsg msg = BluetoothMsg(sn: sn, dataContent: dataContent);
    // 序列化
    Uint8List serializedMsg = msg.toBytes();
    return serializedMsg;
  }

  // 开始实时转写
  Uint8List startTran() {
    DataContent dataContent = DataContent(dataType: tranType, cmd: 0);
    // 创建BluetoothMsg对象
    BluetoothMsg msg = BluetoothMsg(sn: sn, dataContent: dataContent);
    // 序列化
    Uint8List serializedMsg = msg.toBytes();
    return serializedMsg;
  }

  // 结束实时转写
  Uint8List tranCancel() {
    DataContent dataContent = DataContent(dataType: tranType, cmd: 2);
    // 创建BluetoothMsg对象
    BluetoothMsg msg = BluetoothMsg(sn: sn, dataContent: dataContent);
    // 序列化
    Uint8List serializedMsg = msg.toBytes();
    return serializedMsg;
  }

  // 继续转写
  Uint8List tranResume() {
    DataContent dataContent =
        DataContent(dataType: tranType, cmd: 3, data: Uint8List.fromList([0]));
    // 创建BluetoothMsg对象
    BluetoothMsg msg = BluetoothMsg(sn: sn, dataContent: dataContent);
    // 序列化
    Uint8List serializedMsg = msg.toBytes();
    return serializedMsg;
  }

  // 暂停转写
  Uint8List tranPause() {
    DataContent dataContent =
        DataContent(dataType: tranType, cmd: 3, data: Uint8List.fromList([1]));
    // 创建BluetoothMsg对象
    BluetoothMsg msg = BluetoothMsg(sn: sn, dataContent: dataContent);
    // 序列化
    Uint8List serializedMsg = msg.toBytes();
    return serializedMsg;
  }

  // 设备音频列表
  Uint8List fileAudioList() {
    DataContent dataContent = DataContent(dataType: fileType, cmd: 0);
    // 创建BluetoothMsg对象
    BluetoothMsg msg = BluetoothMsg(sn: sn, dataContent: dataContent);
    // 序列化
    Uint8List serializedMsg = msg.toBytes();
    return serializedMsg;
  }

  // 删除全部文件
  Uint8List fileDelAll() {
    DataContent dataContent = DataContent(dataType: fileType, cmd: 9);
    // 创建BluetoothMsg对象
    BluetoothMsg msg = BluetoothMsg(sn: sn, dataContent: dataContent);
    // 序列化
    Uint8List serializedMsg = msg.toBytes();
    return serializedMsg;
  }

  // 根据音频文件删除对应音频文件
  Uint8List delFile(List<String> fileNames) {
    FileImportData fileImportData =
        FileImportData(offset: 0, fileNames: fileNames);
    DataContent dataContent =
        DataContent(dataType: fileType, cmd: 8, data: fileImportData.toBytes());
    // 创建BluetoothMsg对象
    BluetoothMsg msg = BluetoothMsg(sn: sn, dataContent: dataContent);
    // 序列化
    Uint8List serializedMsg = msg.toBytes();
    return serializedMsg;
  }

  // 请求导入文件
  Uint8List import(List<String> fileNames) {
    FileImportData fileImportData =
        FileImportData(offset: 0, fileNames: fileNames);
    DataContent dataContent =
        DataContent(dataType: fileType, cmd: 2, data: fileImportData.toBytes());
    // 创建BluetoothMsg对象
    BluetoothMsg msg = BluetoothMsg(sn: sn, dataContent: dataContent);
    // 序列化
    Uint8List serializedMsg = msg.toBytes();
    return serializedMsg;
  }

  // 导入文件继续
  Uint8List importAudioResume() {
    DataContent dataContent =
        DataContent(dataType: fileType, cmd: 10, data: Uint8List.fromList([0]));
    BluetoothMsg msg = BluetoothMsg(sn: sn, dataContent: dataContent);
    // 序列化
    Uint8List serializedMsg = msg.toBytes();
    return serializedMsg;
  }

  // 导入文件暂停
  Uint8List importAudioPause() {
    DataContent dataContent =
        DataContent(dataType: fileType, cmd: 10, data: Uint8List.fromList([1]));
    BluetoothMsg msg = BluetoothMsg(sn: sn, dataContent: dataContent);
    // 序列化
    Uint8List serializedMsg = msg.toBytes();
    return serializedMsg;
  }

  // 导入文件终止
  Uint8List importAudioStop() {
    DataContent dataContent =
        DataContent(dataType: fileType, cmd: 10, data: Uint8List.fromList([2]));
    BluetoothMsg msg = BluetoothMsg(sn: sn, dataContent: dataContent);
    // 序列化
    Uint8List serializedMsg = msg.toBytes();
    return serializedMsg;
  }

  // 开始录音响应成功
  Uint8List startRecordSuccess() {
    DataContent dataContent = DataContent(dataType: ackType, cmd: 2, data: Uint8List.fromList([1]));
    // 创建BluetoothMsg对象
    BluetoothMsg msg = BluetoothMsg(sn: sn, dataContent: dataContent);
    // 序列化
    Uint8List serializedMsg = msg.toBytes();
    return serializedMsg;
  }

  // 开始录音响应失败
  Uint8List startRecordFail() {
    DataContent dataContent = DataContent(dataType: ackType, cmd: 2, data: Uint8List.fromList([2]));
    // 创建BluetoothMsg对象
    BluetoothMsg msg = BluetoothMsg(sn: sn, dataContent: dataContent);
    // 序列化
    Uint8List serializedMsg = msg.toBytes();
    return serializedMsg;
  }

  // 保存录音响应成功
  Uint8List saveRecordSuccess() {
    DataContent dataContent = DataContent(dataType: ackType, cmd: 4, data: Uint8List.fromList([1]));
    // 创建BluetoothMsg对象
    BluetoothMsg msg = BluetoothMsg(sn: sn, dataContent: dataContent);
    // 序列化
    Uint8List serializedMsg = msg.toBytes();
    return serializedMsg;
  }

  // 保存录音响应失败
  Uint8List saveRecordFail() {
    DataContent dataContent = DataContent(dataType: ackType, cmd: 4, data: Uint8List.fromList([2]));
    // 创建BluetoothMsg对象
    BluetoothMsg msg = BluetoothMsg(sn: sn, dataContent: dataContent);
    // 序列化
    Uint8List serializedMsg = msg.toBytes();
    return serializedMsg;
  }

  // 暂停录音成功
  Uint8List pauseRecordSuccess() {
    DataContent dataContent = DataContent(dataType: ackType, cmd: 6, data: Uint8List.fromList([1]));
    // 创建BluetoothMsg对象
    BluetoothMsg msg = BluetoothMsg(sn: sn, dataContent: dataContent);
    // 序列化
    Uint8List serializedMsg = msg.toBytes();
    return serializedMsg;
  }

  // 暂停录音失败
  Uint8List pauseRecordFail() {
    DataContent dataContent = DataContent(dataType: ackType, cmd: 6, data: Uint8List.fromList([2]));
    // 创建BluetoothMsg对象
    BluetoothMsg msg = BluetoothMsg(sn: sn, dataContent: dataContent);
    // 序列化
    Uint8List serializedMsg = msg.toBytes();
    return serializedMsg;
  }

  // 继续录音成功
  Uint8List resumeRecordSuccess() {
    DataContent dataContent = DataContent(dataType: ackType, cmd: 8, data: Uint8List.fromList([1]));
    // 创建BluetoothMsg对象
    BluetoothMsg msg = BluetoothMsg(sn: sn, dataContent: dataContent);
    // 序列化
    Uint8List serializedMsg = msg.toBytes();
    return serializedMsg;
  }

  // 继续录音失败
  Uint8List resumeRecordFail() {
    DataContent dataContent = DataContent(dataType: ackType, cmd: 8, data: Uint8List.fromList([2]));
    // 创建BluetoothMsg对象
    BluetoothMsg msg = BluetoothMsg(sn: sn, dataContent: dataContent);
    // 序列化
    Uint8List serializedMsg = msg.toBytes();
    return serializedMsg;
  }
}
