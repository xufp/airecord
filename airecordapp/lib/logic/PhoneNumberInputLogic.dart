import 'package:airecordapp/util/LogUtil.dart';
import 'package:flutter/material.dart';
import '../service/DioService.dart';
import '../../service/request/SmsCodeRequest.dart';

class PhoneNumberInputLogic {
  final logger = LogUtil.inItLog();

  // 验证码登录
  Future<bool> isSmsCode(BuildContext context, String phone) async {
    try {
      final resp = await DioService.smsCode(
          context: context, req: SmsCodeRequest(phone: phone));
      if (resp.code == 200) {
        return true;
      }
    } catch (e) {
      logger.e('获取验证码异常:$e');
    }
    return false;
  }
}
