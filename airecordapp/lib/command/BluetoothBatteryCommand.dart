import 'dart:typed_data';
import 'package:airecordapp/command/BluetoothBatteryMsg.dart';

class BluetoothBatteryCommand {
  final int sn = 0x00; // 默认起始包
  final int controlType = 0; // 控制指令类型

  // 获取电量百分比
  Uint8List qel() {
    DataContent dataContent = DataContent(dataType: controlType, cmd: 3);
    // 创建BluetoothMsg对象
    BluetoothBatteryMsg msg = BluetoothBatteryMsg(sn: sn, dataContent: dataContent);
    // 序列化
    Uint8List serializedMsg = msg.toBytes();
    return serializedMsg;
  }
}
