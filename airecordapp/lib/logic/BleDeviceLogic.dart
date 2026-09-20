import 'package:airecordapp/constant/ErrConstants.dart';
import 'package:airecordapp/service/DioService.dart';
import 'package:airecordapp/service/response/BleDeviceResponse.dart';
import 'package:airecordapp/util/LogUtil.dart';

class BleDeviceLogic {
  final logger = LogUtil.inItLog();

  // 获取设备列表
  Future<List<DeviceData>> bleDeviceList() async {
    try {
      final resp = await DioService.bleDeviceList();
      if (resp.code == ErrConstants.SUCCESS_CODE) {
        return resp.data;
      }
    } catch (e) {
      logger.e('获取设备列表异常:$e');
    }
    return [];
  }

  // 获取设备信息
  Future<DeviceData?> bleDevice() async {
    try {
      final resp = await DioService.bleDeviceList();
      if (resp.code == ErrConstants.SUCCESS_CODE) {
        return resp.data[0];
      }
    } catch (e) {
      logger.e('获取设备列表异常:$e');
    }
    return null;
  }
}
