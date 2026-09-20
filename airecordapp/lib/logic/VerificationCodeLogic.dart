import 'package:airecordapp/util/LogUtil.dart';
import 'package:flutter/cupertino.dart';
import '../service/DioService.dart';
import '../../logic/BaseLogic.dart';
import '../../service/request/SmsLoginRequest.dart';

class VerificationCodeLogic extends BaseLogic {
  final logger = LogUtil.inItLog();

  // 验证码登录
  Future<bool> verifyCode(
      BuildContext context, String phone, String code) async {
    try {
      final resp = await DioService.smsLogin(
          context: context, req: SmsLoginRequest(phone: phone, code: code));
      if (resp.code == 200) {
        return true;
      }
    } catch (e) {
      logger.e('验证登录异常:$e');
    }
    return false;
  }
}
