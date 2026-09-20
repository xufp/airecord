import 'dart:typed_data';

class BluetoothMsg {
  final int magic = 0x5A; // uint8
  int sn; // uint8
  DataContent dataContent;

  BluetoothMsg({
    required this.sn,
    required this.dataContent,
  });

  // 计算CRC-16/XMODEM
  int calculateCRC(Uint8List data) {
    int crc = 0x0000;
    for (var byte in data) {
      crc ^= byte << 8;
      for (var i = 0; i < 8; i++) {
        if ((crc & 0x8000) != 0) {
          crc = (crc << 1) ^ 0x1021;
        } else {
          crc <<= 1;
        }
      }
      crc &= 0xFFFF; // 保持CRC为16位
    }
    return crc;
  }

  Uint8List toBytes() {
    final dataContentBytes = dataContent.toBytes();
    final byteData = ByteData(6 + dataContentBytes.length);

    // 自动计算 dataLen
    int dataLen = dataContentBytes.length;

    byteData.setUint8(0, magic);
    byteData.setUint8(1, sn);
    byteData.setUint16(4, dataLen, Endian.little);
    byteData.buffer
        .asUint8List()
        .setRange(6, 6 + dataContentBytes.length, dataContentBytes);

    // 计算CRC：dataLen + dataContent
    final crcInput = byteData.buffer
        .asUint8List(4, 2 + dataContentBytes.length); // dataLen + dataContent
    int crc = calculateCRC(crcInput);

    byteData.setUint16(2, crc, Endian.little);

    return byteData.buffer.asUint8List();
  }

  static BluetoothMsg fromBytes(Uint8List bytes) {
    final byteData = ByteData.sublistView(bytes);
    int sn = byteData.getUint8(1);
    int dataLen = byteData.getUint16(4, Endian.little);

    Uint8List dataContentBytes = bytes.sublist(6, 6 + dataLen);
    DataContent dataContent = DataContent.fromBytes(dataContentBytes);
    return BluetoothMsg(
      sn: sn,
      dataContent: dataContent,
    );
  }
}

class DataContent {
  int dataType; // uint8
  int cmd; // uint8
  Uint8List data; // Uint8List to support binary data like Date

  DataContent({
    required this.dataType,
    required this.cmd,
    data,
  }) : data = data ?? Uint8List(0);

  Uint8List toBytes() {
    final byteData = ByteData(2 + data.length);
    byteData.setUint8(0, dataType);
    byteData.setUint8(1, cmd);
    byteData.buffer.asUint8List().setRange(2, 2 + data.length, data);
    return byteData.buffer.asUint8List();
  }

  static DataContent fromBytes(Uint8List bytes) {
    final byteData = ByteData.sublistView(bytes);
    int dataType = byteData.getUint8(0);
    int cmd = byteData.getUint8(1);
    Uint8List data = bytes.sublist(2);
    return DataContent(
      dataType: dataType,
      cmd: cmd,
      data: data,
    );
  }
}
