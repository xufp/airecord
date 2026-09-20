import 'package:airecordapp/constant/ErrConstants.dart';

class DeviceData {
  final String deviceType;
  final String deviceName;
  final String deviceUuid;
  final String deviceImage;
  final String deviceDesc;
  final String characteristicWrite;
  final String characteristicNotify;
  final String characteristicBatteryNotify;

  DeviceData({
    required this.deviceType,
    required this.deviceName,
    required this.deviceUuid,
    required this.deviceImage,
    required this.deviceDesc,
    required this.characteristicWrite,
    required this.characteristicNotify,
    required this.characteristicBatteryNotify,
  });

  // 工厂方法：从JSON创建DeviceData对象
  factory DeviceData.fromJson(Map<String, dynamic> json) {
    return DeviceData(
      deviceType: json['device_type'],
      deviceName: json['device_name'],
      deviceUuid: json['device_uuid'],
      deviceImage: json['device_image'],
      deviceDesc: json['device_desc'],
      characteristicWrite: json['characteristic_write'],
      characteristicNotify: json['characteristic_notify'],
      characteristicBatteryNotify: json['characteristic_battery_notify'],
    );
  }

  // 成员方法：将DeviceData对象转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'device_type': deviceType,
      'device_name': deviceName,
      'device_uuid': deviceUuid,
      'device_image': deviceImage,
      'device_desc': deviceDesc,
      'characteristic_write': characteristicWrite,
      'characteristic_notify': characteristicNotify,
      'characteristic_battery_notify' : characteristicBatteryNotify
    };
  }
}

class BleDeviceResponse {
  int code;
  String msg;
  List<DeviceData> data;

  BleDeviceResponse({
    required this.code,
    required this.msg,
    required this.data,
  });

  // 工厂方法：从JSON创建ApiResponse对象
  factory BleDeviceResponse.fromJson(Map<String, dynamic> json) {
    var deviceList = json['data'] as List;
    List<DeviceData> devices =
        deviceList.map((i) => DeviceData.fromJson(i)).toList();

    return BleDeviceResponse(
      code: json['code'] ?? ErrConstants.SUCCESS_CODE,
      msg: json['msg'] ?? ErrConstants.SUCCESS_MSG,
      data: devices,
    );
  }

  // 成员方法：将ApiResponse对象转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'msg': msg,
      'data': data.map((device) => device.toJson()).toList(),
    };
  }
}
