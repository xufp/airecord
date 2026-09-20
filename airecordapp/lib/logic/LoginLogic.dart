import 'package:airecordapp/constant/ErrConstants.dart';
import 'package:airecordapp/db/Cache.dart';
import 'package:airecordapp/service/DioService.dart';
import 'package:airecordapp/service/request/EmailLoginRequest.dart';
import 'package:airecordapp/service/request/GetCodeRequest.dart';
import 'package:airecordapp/service/request/ResetPasswordRequest.dart';
import 'package:airecordapp/service/request/VerifyCodeRequest.dart';
import 'package:airecordapp/service/response/EmailLoginResponse.dart';
import 'package:airecordapp/service/response/GetCodeResponse.dart';
import 'package:airecordapp/service/response/ResetPasswordResponse.dart';
import 'package:airecordapp/service/response/VerifyCodeResponse.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class LoginLogic {
  final Logger log = Logger();

  // 获取登录token信息
  static Future<bool> isToken() async {
    String strToken = await Cache.token;
    if (strToken == "") {
      return false;
    }
    return true;
  }

  // 获取登录token信息
  static Future<bool> removeToken() async {
    bool isSucc = await Cache.removeToken();
    if (isSucc) {
      return true;
    } else {
      return false;
    }
  }

  // 获取所有缓存信息
  static Future<bool> removeAll() async {
    bool isSucc = await Cache.removeAll();
    if (isSucc) {
      return true;
    } else {
      return false;
    }
  }

  // 邮箱登录
  Future<EmailLoginResponse?> emailLogin(
      BuildContext context, String email, String password) async {
    EmailLoginResponse? response = null;
    try {
      response = await DioService.emailLogin(
          context: context,
          req: EmailLoginRequest(email: email, password: password));
      if (response.code == ErrConstants.SUCCESS_CODE &&
          response.accessToken != null) {
        // 设置登录token
        await Cache.saveToken(response.accessToken ?? "", email);
        //showSnackBarSuccess(context, '登录成功了');
      } else {
        log.e('emailLogin business error:$response');
      }
    } catch (e) {
      log.d('emailLogin unknown error: $e');
    }
    return response;
  }

  // 邮箱注册
  Future<EmailLoginResponse?> emailRegister(
      BuildContext context, String email, String password) async {
    EmailLoginResponse? response = null;
    try {
      response = await DioService.emailRegister(
          context: context,
          req: EmailLoginRequest(
              email: email, password: password, register: true));
    } catch (e) {
      log.d('emailRegister error: $e');
    }
    return response;
  }

  // 获取验证码
  Future<GetCodeResponse?> getCode(BuildContext context, String email) async {
    GetCodeResponse? response = null;
    try {
      response = await DioService.getCode(
          context: context, req: GetCodeRequest(email: email));
    } catch (e) {
      log.d('getCode error: $e');
    }
    return response;
  }

  // 验证码验证流程
  Future<VerifyCodeResponse?> verifyCode(
      BuildContext context, String email, String code) async {
    VerifyCodeResponse? response = null;
    try {
      response = await DioService.verifyCode(
          context: context, req: VerifyCodeRequest(email: email, code: code));
    } catch (e) {
      log.d('verifyCode error: $e');
    }
    return response;
  }

  // 密码重置第一阶段：获取验证码
  Future<ResetPasswordResponse?> sendCodeByResetPassword(
      BuildContext context, String email) async {
    ResetPasswordResponse? response;
    try {
      response = await DioService.sendCodeByResetPassword(
          context: context, req: ResetPasswordRequest(email: email));
    } catch (e) {
      log.d('send verify code error: $e');
    }
    return response;
  }

  // 密码重置第二阶段：重置密码
  Future<ResetPasswordResponse?> resetPassword(BuildContext context,
      String email, String newPassword, String code) async {
    ResetPasswordResponse? response;
    try {
      response = await DioService.resetPassword(
          context: context,
          req: ResetPasswordRequest(
              email: email, newPassword: newPassword, code: code));
    } catch (e) {
      log.d('reset password error: $e');
    }
    return response;
  }
}
