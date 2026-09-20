// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `YiguoAi`
  String get app_title {
    return Intl.message(
      'YiguoAi',
      name: 'app_title',
      desc: '',
      args: [],
    );
  }

  /// `邮箱地址`
  String get EmailLoginPage_email_address {
    return Intl.message(
      '邮箱地址',
      name: 'EmailLoginPage_email_address',
      desc: '',
      args: [],
    );
  }

  /// `邮箱地址不能为空`
  String get EmailLoginPage_email_empty_error {
    return Intl.message(
      '邮箱地址不能为空',
      name: 'EmailLoginPage_email_empty_error',
      desc: '',
      args: [],
    );
  }

  /// `请输入正确的邮箱地址`
  String get EmailLoginPage_email_format_error {
    return Intl.message(
      '请输入正确的邮箱地址',
      name: 'EmailLoginPage_email_format_error',
      desc: '',
      args: [],
    );
  }

  /// `密码`
  String get EmailLoginPage_password {
    return Intl.message(
      '密码',
      name: 'EmailLoginPage_password',
      desc: '',
      args: [],
    );
  }

  /// `密码不能为空`
  String get EmailLoginPage_password_empty_error {
    return Intl.message(
      '密码不能为空',
      name: 'EmailLoginPage_password_empty_error',
      desc: '',
      args: [],
    );
  }

  /// `请输入8到16位密码`
  String get EmailLoginPage_password_format_error {
    return Intl.message(
      '请输入8到16位密码',
      name: 'EmailLoginPage_password_format_error',
      desc: '',
      args: [],
    );
  }

  /// `账号或密码错误，请重新输入`
  String get EmailLoginPage_login_error {
    return Intl.message(
      '账号或密码错误，请重新输入',
      name: 'EmailLoginPage_login_error',
      desc: '',
      args: [],
    );
  }

  /// `网络异常，请重试`
  String get EmailLoginPage_network_error {
    return Intl.message(
      '网络异常，请重试',
      name: 'EmailLoginPage_network_error',
      desc: '',
      args: [],
    );
  }

  /// `该邮箱没有注册，请点击立即注册`
  String get EmailLoginPage_user_not_found {
    return Intl.message(
      '该邮箱没有注册，请点击立即注册',
      name: 'EmailLoginPage_user_not_found',
      desc: '',
      args: [],
    );
  }

  /// `密码错误，请重新输入`
  String get EmailLoginPage_password_uncorrect {
    return Intl.message(
      '密码错误，请重新输入',
      name: 'EmailLoginPage_password_uncorrect',
      desc: '',
      args: [],
    );
  }

  /// `该账号不存在`
  String get EmailLoginPage_account_deactivated {
    return Intl.message(
      '该账号不存在',
      name: 'EmailLoginPage_account_deactivated',
      desc: '',
      args: [],
    );
  }

  /// `未知错误,请重试`
  String get EmailLoginPage_unknown_error {
    return Intl.message(
      '未知错误,请重试',
      name: 'EmailLoginPage_unknown_error',
      desc: '',
      args: [],
    );
  }

  /// `登录`
  String get EmailLoginPage_login {
    return Intl.message(
      '登录',
      name: 'EmailLoginPage_login',
      desc: '',
      args: [],
    );
  }

  /// `立即注册`
  String get EmailLoginPage_register {
    return Intl.message(
      '立即注册',
      name: 'EmailLoginPage_register',
      desc: '',
      args: [],
    );
  }

  /// `忘记密码`
  String get EmailLoginPage_find_password {
    return Intl.message(
      '忘记密码',
      name: 'EmailLoginPage_find_password',
      desc: '',
      args: [],
    );
  }

  /// `继续操作即表示您已阅读并同意《用户协议》和《隐私政策》`
  String get EmailLoginPage_user_agreement {
    return Intl.message(
      '继续操作即表示您已阅读并同意《用户协议》和《隐私政策》',
      name: 'EmailLoginPage_user_agreement',
      desc: '',
      args: [],
    );
  }

  /// `邮箱登录`
  String get EmailLoginPage_k1 {
    return Intl.message(
      '邮箱登录',
      name: 'EmailLoginPage_k1',
      desc: '',
      args: [],
    );
  }

  /// `欢迎回来`
  String get EmailLoginPage_k2 {
    return Intl.message(
      '欢迎回来',
      name: 'EmailLoginPage_k2',
      desc: '',
      args: [],
    );
  }

  /// `请登录您的账号`
  String get EmailLoginPage_k3 {
    return Intl.message(
      '请登录您的账号',
      name: 'EmailLoginPage_k3',
      desc: '',
      args: [],
    );
  }

  /// `登录即代表您已同意`
  String get EmailLoginPage_k4 {
    return Intl.message(
      '登录即代表您已同意',
      name: 'EmailLoginPage_k4',
      desc: '',
      args: [],
    );
  }

  /// `《用户协议》`
  String get EmailLoginPage_k5 {
    return Intl.message(
      '《用户协议》',
      name: 'EmailLoginPage_k5',
      desc: '',
      args: [],
    );
  }

  /// `和`
  String get EmailLoginPage_k6 {
    return Intl.message(
      '和',
      name: 'EmailLoginPage_k6',
      desc: '',
      args: [],
    );
  }

  /// `《隐私政策》`
  String get EmailLoginPage_k7 {
    return Intl.message(
      '《隐私政策》',
      name: 'EmailLoginPage_k7',
      desc: '',
      args: [],
    );
  }

  /// `邮箱地址`
  String get RegisterPage_email_address {
    return Intl.message(
      '邮箱地址',
      name: 'RegisterPage_email_address',
      desc: '',
      args: [],
    );
  }

  /// `验证码`
  String get RegisterPage_verification_code {
    return Intl.message(
      '验证码',
      name: 'RegisterPage_verification_code',
      desc: '',
      args: [],
    );
  }

  /// `获取验证码`
  String get RegisterPage_send_verifycode {
    return Intl.message(
      '获取验证码',
      name: 'RegisterPage_send_verifycode',
      desc: '',
      args: [],
    );
  }

  /// `密码`
  String get RegisterPage_password {
    return Intl.message(
      '密码',
      name: 'RegisterPage_password',
      desc: '',
      args: [],
    );
  }

  /// `确认密码`
  String get RegisterPage_verify_password {
    return Intl.message(
      '确认密码',
      name: 'RegisterPage_verify_password',
      desc: '',
      args: [],
    );
  }

  /// `下一步`
  String get RegisterPage_register {
    return Intl.message(
      '下一步',
      name: 'RegisterPage_register',
      desc: '',
      args: [],
    );
  }

  /// `该邮箱已注册，即将跳转到登录页`
  String get RegisterPage_user_exist {
    return Intl.message(
      '该邮箱已注册，即将跳转到登录页',
      name: 'RegisterPage_user_exist',
      desc: '',
      args: [],
    );
  }

  /// `立即注册`
  String get RegisterPage_k1 {
    return Intl.message(
      '立即注册',
      name: 'RegisterPage_k1',
      desc: '',
      args: [],
    );
  }

  /// `创建账号`
  String get RegisterPage_k2 {
    return Intl.message(
      '创建账号',
      name: 'RegisterPage_k2',
      desc: '',
      args: [],
    );
  }

  /// `请填写以下信息完成注册`
  String get RegisterPage_k3 {
    return Intl.message(
      '请填写以下信息完成注册',
      name: 'RegisterPage_k3',
      desc: '',
      args: [],
    );
  }

  /// `注册即代表您已同意`
  String get RegisterPage_k4 {
    return Intl.message(
      '注册即代表您已同意',
      name: 'RegisterPage_k4',
      desc: '',
      args: [],
    );
  }

  /// `《用户协议》`
  String get RegisterPage_k5 {
    return Intl.message(
      '《用户协议》',
      name: 'RegisterPage_k5',
      desc: '',
      args: [],
    );
  }

  /// `和`
  String get RegisterPage_k6 {
    return Intl.message(
      '和',
      name: 'RegisterPage_k6',
      desc: '',
      args: [],
    );
  }

  /// `《隐私政策》`
  String get RegisterPage_k7 {
    return Intl.message(
      '《隐私政策》',
      name: 'RegisterPage_k7',
      desc: '',
      args: [],
    );
  }

  /// `忘记密码`
  String get ResetPasswordPage_reset_password {
    return Intl.message(
      '忘记密码',
      name: 'ResetPasswordPage_reset_password',
      desc: '',
      args: [],
    );
  }

  /// `请输入验证码`
  String get ResetPasswordPage_verifyCode_empty {
    return Intl.message(
      '请输入验证码',
      name: 'ResetPasswordPage_verifyCode_empty',
      desc: '',
      args: [],
    );
  }

  /// `两次密码输入不一致，请检查`
  String get ResetPasswordPage_password_error {
    return Intl.message(
      '两次密码输入不一致，请检查',
      name: 'ResetPasswordPage_password_error',
      desc: '',
      args: [],
    );
  }

  /// `确认密码不能为空`
  String get ResetPasswordPage_confirm_password_empty_error {
    return Intl.message(
      '确认密码不能为空',
      name: 'ResetPasswordPage_confirm_password_empty_error',
      desc: '',
      args: [],
    );
  }

  /// `确认密码不能为空`
  String get ResetPasswordPage_confirm_password_format_error {
    return Intl.message(
      '确认密码不能为空',
      name: 'ResetPasswordPage_confirm_password_format_error',
      desc: '',
      args: [],
    );
  }

  /// `开始使用`
  String get ResetPasswordPage_form_commit {
    return Intl.message(
      '开始使用',
      name: 'ResetPasswordPage_form_commit',
      desc: '',
      args: [],
    );
  }

  /// `验证码发送失败，请重新获取`
  String get ResetPasswordPage_verifyCode_send_error {
    return Intl.message(
      '验证码发送失败，请重新获取',
      name: 'ResetPasswordPage_verifyCode_send_error',
      desc: '',
      args: [],
    );
  }

  /// `重新发送`
  String get ResetPasswordPage_verifyCode_resend {
    return Intl.message(
      '重新发送',
      name: 'ResetPasswordPage_verifyCode_resend',
      desc: '',
      args: [],
    );
  }

  /// `密码重置失败，请重新操作`
  String get ResetPasswordPage_commit_error {
    return Intl.message(
      '密码重置失败，请重新操作',
      name: 'ResetPasswordPage_commit_error',
      desc: '',
      args: [],
    );
  }

  /// `请输入正确的邮箱地址`
  String get ResetPasswordPage_user_not_found {
    return Intl.message(
      '请输入正确的邮箱地址',
      name: 'ResetPasswordPage_user_not_found',
      desc: '',
      args: [],
    );
  }

  /// `验证码发送成功，请登录到邮箱内查看`
  String get ResetPasswordPage_verifyCode_send_success {
    return Intl.message(
      '验证码发送成功，请登录到邮箱内查看',
      name: 'ResetPasswordPage_verifyCode_send_success',
      desc: '',
      args: [],
    );
  }

  /// `密码重置成功，即将跳转到登录页`
  String get ResetPasswordPage_success {
    return Intl.message(
      '密码重置成功，即将跳转到登录页',
      name: 'ResetPasswordPage_success',
      desc: '',
      args: [],
    );
  }

  /// `重置密码`
  String get ResetPasswordPage_k1 {
    return Intl.message(
      '重置密码',
      name: 'ResetPasswordPage_k1',
      desc: '',
      args: [],
    );
  }

  /// `请填写以下信息完成密码重置`
  String get ResetPasswordPage_k2 {
    return Intl.message(
      '请填写以下信息完成密码重置',
      name: 'ResetPasswordPage_k2',
      desc: '',
      args: [],
    );
  }

  /// `秒`
  String get ResetPasswordPage_k3 {
    return Intl.message(
      '秒',
      name: 'ResetPasswordPage_k3',
      desc: '',
      args: [],
    );
  }

  /// `重新发送`
  String get VerifyCodePage_resend_code_1 {
    return Intl.message(
      '重新发送',
      name: 'VerifyCodePage_resend_code_1',
      desc: '',
      args: [],
    );
  }

  /// `没收到验证码`
  String get VerifyCodePage_resend_code_2 {
    return Intl.message(
      '没收到验证码',
      name: 'VerifyCodePage_resend_code_2',
      desc: '',
      args: [],
    );
  }

  /// `验证码已失效，请点击重送发送`
  String get VerifyCodePage_code_invalidate {
    return Intl.message(
      '验证码已失效，请点击重送发送',
      name: 'VerifyCodePage_code_invalidate',
      desc: '',
      args: [],
    );
  }

  /// `验证码确认`
  String get VerifyCodePage_k1 {
    return Intl.message(
      '验证码确认',
      name: 'VerifyCodePage_k1',
      desc: '',
      args: [],
    );
  }

  /// `输入验证码`
  String get VerifyCodePage_k2 {
    return Intl.message(
      '输入验证码',
      name: 'VerifyCodePage_k2',
      desc: '',
      args: [],
    );
  }

  /// `已发送验证码到邮箱`
  String get VerifyCodePage_k3 {
    return Intl.message(
      '已发送验证码到邮箱',
      name: 'VerifyCodePage_k3',
      desc: '',
      args: [],
    );
  }

  /// `秒`
  String get VerifyCodePage_k4 {
    return Intl.message(
      '秒',
      name: 'VerifyCodePage_k4',
      desc: '',
      args: [],
    );
  }

  /// `继续操作即表示您已同意`
  String get VerifyCodePage_k5 {
    return Intl.message(
      '继续操作即表示您已同意',
      name: 'VerifyCodePage_k5',
      desc: '',
      args: [],
    );
  }

  /// `《用户协议》`
  String get VerifyCodePage_k6 {
    return Intl.message(
      '《用户协议》',
      name: 'VerifyCodePage_k6',
      desc: '',
      args: [],
    );
  }

  /// `和`
  String get VerifyCodePage_k7 {
    return Intl.message(
      '和',
      name: 'VerifyCodePage_k7',
      desc: '',
      args: [],
    );
  }

  /// `《隐私政策》`
  String get VerifyCodePage_k8 {
    return Intl.message(
      '《隐私政策》',
      name: 'VerifyCodePage_k8',
      desc: '',
      args: [],
    );
  }

  /// `邮箱登录`
  String get LoginPage_email {
    return Intl.message(
      '邮箱登录',
      name: 'LoginPage_email',
      desc: '',
      args: [],
    );
  }

  /// `Google 账号登录`
  String get LoginPage_google {
    return Intl.message(
      'Google 账号登录',
      name: 'LoginPage_google',
      desc: '',
      args: [],
    );
  }

  /// `Apple 账号登录`
  String get LoginPage_apple {
    return Intl.message(
      'Apple 账号登录',
      name: 'LoginPage_apple',
      desc: '',
      args: [],
    );
  }

  /// `继续操作即表示您已阅读并同意`
  String get LoginPage_continue_operator {
    return Intl.message(
      '继续操作即表示您已阅读并同意',
      name: 'LoginPage_continue_operator',
      desc: '',
      args: [],
    );
  }

  /// `《用户协议》`
  String get LoginPage_user_agreement {
    return Intl.message(
      '《用户协议》',
      name: 'LoginPage_user_agreement',
      desc: '',
      args: [],
    );
  }

  /// `和`
  String get LoginPage_and {
    return Intl.message(
      '和',
      name: 'LoginPage_and',
      desc: '',
      args: [],
    );
  }

  /// `《隐私政策》`
  String get LoginPage_Privacy {
    return Intl.message(
      '《隐私政策》',
      name: 'LoginPage_Privacy',
      desc: '',
      args: [],
    );
  }

  /// `连接`
  String get ListPage_bluetooth_connected {
    return Intl.message(
      '连接',
      name: 'ListPage_bluetooth_connected',
      desc: '',
      args: [],
    );
  }

  /// `文件`
  String get ListPage_menu_name {
    return Intl.message(
      '文件',
      name: 'ListPage_menu_name',
      desc: '',
      args: [],
    );
  }

  /// `录音AI转写`
  String get ListPage_k1 {
    return Intl.message(
      '录音AI转写',
      name: 'ListPage_k1',
      desc: '',
      args: [],
    );
  }

  /// `转写神器 准确率高达98%`
  String get ListPage_k2 {
    return Intl.message(
      '转写神器 准确率高达98%',
      name: 'ListPage_k2',
      desc: '',
      args: [],
    );
  }

  /// `连接硬件`
  String get ListPage_k3 {
    return Intl.message(
      '连接硬件',
      name: 'ListPage_k3',
      desc: '',
      args: [],
    );
  }

  /// `导入音频`
  String get ListPage_k4 {
    return Intl.message(
      '导入音频',
      name: 'ListPage_k4',
      desc: '',
      args: [],
    );
  }

  /// `设备未连接，请连接设备后再使用`
  String get ListPage_k5 {
    return Intl.message(
      '设备未连接，请连接设备后再使用',
      name: 'ListPage_k5',
      desc: '',
      args: [],
    );
  }

  /// `开始录音`
  String get ListPage_k6 {
    return Intl.message(
      '开始录音',
      name: 'ListPage_k6',
      desc: '',
      args: [],
    );
  }

  /// `文件`
  String get ListPage_k7 {
    return Intl.message(
      '文件',
      name: 'ListPage_k7',
      desc: '',
      args: [],
    );
  }

  /// `链接设备 智能操控`
  String get ListPage_k8 {
    return Intl.message(
      '链接设备 智能操控',
      name: 'ListPage_k8',
      desc: '',
      args: [],
    );
  }

  /// `批量导入 快速提取`
  String get ListPage_k9 {
    return Intl.message(
      '批量导入 快速提取',
      name: 'ListPage_k9',
      desc: '',
      args: [],
    );
  }

  /// `录转同步 实时核数`
  String get ListPage_k10 {
    return Intl.message(
      '录转同步 实时核数',
      name: 'ListPage_k10',
      desc: '',
      args: [],
    );
  }

  /// `取消`
  String get ListPage_k11 {
    return Intl.message(
      '取消',
      name: 'ListPage_k11',
      desc: '',
      args: [],
    );
  }

  /// `连接`
  String get ListPage_k12 {
    return Intl.message(
      '连接',
      name: 'ListPage_k12',
      desc: '',
      args: [],
    );
  }

  /// `格式不支持`
  String get AudioFilePickerPage_k1 {
    return Intl.message(
      '格式不支持',
      name: 'AudioFilePickerPage_k1',
      desc: '',
      args: [],
    );
  }

  /// `当前文件: `
  String get AudioFilePickerPage_k2 {
    return Intl.message(
      '当前文件: ',
      name: 'AudioFilePickerPage_k2',
      desc: '',
      args: [],
    );
  }

  /// `仅支持以下格式：`
  String get AudioFilePickerPage_k3 {
    return Intl.message(
      '仅支持以下格式：',
      name: 'AudioFilePickerPage_k3',
      desc: '',
      args: [],
    );
  }

  /// `我知道了`
  String get AudioFilePickerPage_k4 {
    return Intl.message(
      '我知道了',
      name: 'AudioFilePickerPage_k4',
      desc: '',
      args: [],
    );
  }

  /// `模拟器不支持`
  String get AudioFilePickerPage_k5 {
    return Intl.message(
      '模拟器不支持',
      name: 'AudioFilePickerPage_k5',
      desc: '',
      args: [],
    );
  }

  /// `iOS 模拟器不支持文件选择功能，请在真机上测试此功能。`
  String get AudioFilePickerPage_k6 {
    return Intl.message(
      'iOS 模拟器不支持文件选择功能，请在真机上测试此功能。',
      name: 'AudioFilePickerPage_k6',
      desc: '',
      args: [],
    );
  }

  /// `我知道了`
  String get AudioFilePickerPage_k7 {
    return Intl.message(
      '我知道了',
      name: 'AudioFilePickerPage_k7',
      desc: '',
      args: [],
    );
  }

  /// `导入音频文件失败，请重试`
  String get AudioFilePickerPage_k8 {
    return Intl.message(
      '导入音频文件失败，请重试',
      name: 'AudioFilePickerPage_k8',
      desc: '',
      args: [],
    );
  }

  /// `导入音频文件`
  String get AudioFilePickerPage_k9 {
    return Intl.message(
      '导入音频文件',
      name: 'AudioFilePickerPage_k9',
      desc: '',
      args: [],
    );
  }

  /// `从文件导入`
  String get AudioFilePickerPage_k10 {
    return Intl.message(
      '从文件导入',
      name: 'AudioFilePickerPage_k10',
      desc: '',
      args: [],
    );
  }

  /// `支持批量导入本地音频文件`
  String get AudioFilePickerPage_k11 {
    return Intl.message(
      '支持批量导入本地音频文件',
      name: 'AudioFilePickerPage_k11',
      desc: '',
      args: [],
    );
  }

  /// `从相册导入`
  String get AudioFilePickerPage_k12 {
    return Intl.message(
      '从相册导入',
      name: 'AudioFilePickerPage_k12',
      desc: '',
      args: [],
    );
  }

  /// `支持从相册中选择音频文件`
  String get AudioFilePickerPage_k13 {
    return Intl.message(
      '支持从相册中选择音频文件',
      name: 'AudioFilePickerPage_k13',
      desc: '',
      args: [],
    );
  }

  /// `文件要求`
  String get AudioFilePickerPage_k14 {
    return Intl.message(
      '文件要求',
      name: 'AudioFilePickerPage_k14',
      desc: '',
      args: [],
    );
  }

  /// `支持格式：MP3、M4A、WAV、AMR、FLAC、AAC`
  String get AudioFilePickerPage_k15 {
    return Intl.message(
      '支持格式：MP3、M4A、WAV、AMR、FLAC、AAC',
      name: 'AudioFilePickerPage_k15',
      desc: '',
      args: [],
    );
  }

  /// `文件限制：单个文件时长 < 5小时，大小 < 1G`
  String get AudioFilePickerPage_k16 {
    return Intl.message(
      '文件限制：单个文件时长 < 5小时，大小 < 1G',
      name: 'AudioFilePickerPage_k16',
      desc: '',
      args: [],
    );
  }

  /// `格式不支持`
  String get AudioImportPage_k1 {
    return Intl.message(
      '格式不支持',
      name: 'AudioImportPage_k1',
      desc: '',
      args: [],
    );
  }

  /// `当前文件：`
  String get AudioImportPage_k2 {
    return Intl.message(
      '当前文件：',
      name: 'AudioImportPage_k2',
      desc: '',
      args: [],
    );
  }

  /// `仅支持以下格式：`
  String get AudioImportPage_k3 {
    return Intl.message(
      '仅支持以下格式：',
      name: 'AudioImportPage_k3',
      desc: '',
      args: [],
    );
  }

  /// `我知道了`
  String get AudioImportPage_k4 {
    return Intl.message(
      '我知道了',
      name: 'AudioImportPage_k4',
      desc: '',
      args: [],
    );
  }

  /// `从微信、QQ、录音机等导入`
  String get AudioImportPage_k5 {
    return Intl.message(
      '从微信、QQ、录音机等导入',
      name: 'AudioImportPage_k5',
      desc: '',
      args: [],
    );
  }

  /// `1. 在软件中打开音频后，点击"↗"或"⋯"，\n   在弹窗中点击"用其他应用打开"。`
  String get AudioImportPage_k6 {
    return Intl.message(
      '1. 在软件中打开音频后，点击"↗"或"⋯"，\\n   在弹窗中点击"用其他应用打开"。',
      name: 'AudioImportPage_k6',
      desc: '',
      args: [],
    );
  }

  /// `左侧示例图`
  String get AudioImportPage_k7 {
    return Intl.message(
      '左侧示例图',
      name: 'AudioImportPage_k7',
      desc: '',
      args: [],
    );
  }

  /// `右侧示例图`
  String get AudioImportPage_k8 {
    return Intl.message(
      '右侧示例图',
      name: 'AudioImportPage_k8',
      desc: '',
      args: [],
    );
  }

  /// `2. 在弹窗中点击"YiGuo Voice"导入即可。`
  String get AudioImportPage_k9 {
    return Intl.message(
      '2. 在弹窗中点击"YiGuo Voice"导入即可。',
      name: 'AudioImportPage_k9',
      desc: '',
      args: [],
    );
  }

  /// `底部示例图`
  String get AudioImportPage_k10 {
    return Intl.message(
      '底部示例图',
      name: 'AudioImportPage_k10',
      desc: '',
      args: [],
    );
  }

  /// `选择音频文件失败，请重试`
  String get AudioImportPage_k11 {
    return Intl.message(
      '选择音频文件失败，请重试',
      name: 'AudioImportPage_k11',
      desc: '',
      args: [],
    );
  }

  /// `导入要转写的文件`
  String get AudioImportPage_k12 {
    return Intl.message(
      '导入要转写的文件',
      name: 'AudioImportPage_k12',
      desc: '',
      args: [],
    );
  }

  /// `从本地导入`
  String get AudioImportPage_k13 {
    return Intl.message(
      '从本地导入',
      name: 'AudioImportPage_k13',
      desc: '',
      args: [],
    );
  }

  /// `支持批量导入本地音频文件`
  String get AudioImportPage_k14 {
    return Intl.message(
      '支持批量导入本地音频文件',
      name: 'AudioImportPage_k14',
      desc: '',
      args: [],
    );
  }

  /// `从微信、QQ、录音机等导入`
  String get AudioImportPage_k15 {
    return Intl.message(
      '从微信、QQ、录音机等导入',
      name: 'AudioImportPage_k15',
      desc: '',
      args: [],
    );
  }

  /// `支持从其他应用分享音频到本应用`
  String get AudioImportPage_k16 {
    return Intl.message(
      '支持从其他应用分享音频到本应用',
      name: 'AudioImportPage_k16',
      desc: '',
      args: [],
    );
  }

  /// `从相册导入`
  String get AudioImportPage_k17 {
    return Intl.message(
      '从相册导入',
      name: 'AudioImportPage_k17',
      desc: '',
      args: [],
    );
  }

  /// `支持从相册中选择音频文件`
  String get AudioImportPage_k18 {
    return Intl.message(
      '支持从相册中选择音频文件',
      name: 'AudioImportPage_k18',
      desc: '',
      args: [],
    );
  }

  /// `文件要求`
  String get AudioImportPage_k19 {
    return Intl.message(
      '文件要求',
      name: 'AudioImportPage_k19',
      desc: '',
      args: [],
    );
  }

  /// `支持格式：MP3、M4A、WAV、AMR、FLAC、AAC`
  String get AudioImportPage_k20 {
    return Intl.message(
      '支持格式：MP3、M4A、WAV、AMR、FLAC、AAC',
      name: 'AudioImportPage_k20',
      desc: '',
      args: [],
    );
  }

  /// `文件限制：单个文件时长 < 5小时，大小 < 1G`
  String get AudioImportPage_k21 {
    return Intl.message(
      '文件限制：单个文件时长 < 5小时，大小 < 1G',
      name: 'AudioImportPage_k21',
      desc: '',
      args: [],
    );
  }

  /// `文件`
  String get HomePage_menu_filelist {
    return Intl.message(
      '文件',
      name: 'HomePage_menu_filelist',
      desc: '',
      args: [],
    );
  }

  /// `我`
  String get HomePage_menu_usercenter {
    return Intl.message(
      '我',
      name: 'HomePage_menu_usercenter',
      desc: '',
      args: [],
    );
  }

  /// `在所有文件中搜索`
  String get OperateFilePage_k1 {
    return Intl.message(
      '在所有文件中搜索',
      name: 'OperateFilePage_k1',
      desc: '',
      args: [],
    );
  }

  /// `完成`
  String get OperateFilePage_k2 {
    return Intl.message(
      '完成',
      name: 'OperateFilePage_k2',
      desc: '',
      args: [],
    );
  }

  /// `重命名`
  String get OperateFilePage_k3 {
    return Intl.message(
      '重命名',
      name: 'OperateFilePage_k3',
      desc: '',
      args: [],
    );
  }

  /// `删除`
  String get OperateFilePage_k4 {
    return Intl.message(
      '删除',
      name: 'OperateFilePage_k4',
      desc: '',
      args: [],
    );
  }

  /// `重命名`
  String get OperateFilePage_k5 {
    return Intl.message(
      '重命名',
      name: 'OperateFilePage_k5',
      desc: '',
      args: [],
    );
  }

  /// `请输入文件名`
  String get OperateFilePage_k6 {
    return Intl.message(
      '请输入文件名',
      name: 'OperateFilePage_k6',
      desc: '',
      args: [],
    );
  }

  /// `取消`
  String get OperateFilePage_k7 {
    return Intl.message(
      '取消',
      name: 'OperateFilePage_k7',
      desc: '',
      args: [],
    );
  }

  /// `保存`
  String get OperateFilePage_k8 {
    return Intl.message(
      '保存',
      name: 'OperateFilePage_k8',
      desc: '',
      args: [],
    );
  }

  /// `文件名不能为空`
  String get OperateFilePage_k9 {
    return Intl.message(
      '文件名不能为空',
      name: 'OperateFilePage_k9',
      desc: '',
      args: [],
    );
  }

  /// `确定要删除选中的文件吗？`
  String get OperateFilePage_k10 {
    return Intl.message(
      '确定要删除选中的文件吗？',
      name: 'OperateFilePage_k10',
      desc: '',
      args: [],
    );
  }

  /// `删除后将无法恢复`
  String get OperateFilePage_k11 {
    return Intl.message(
      '删除后将无法恢复',
      name: 'OperateFilePage_k11',
      desc: '',
      args: [],
    );
  }

  /// `同时删除设备文件`
  String get OperateFilePage_k12 {
    return Intl.message(
      '同时删除设备文件',
      name: 'OperateFilePage_k12',
      desc: '',
      args: [],
    );
  }

  /// `取消`
  String get OperateFilePage_k13 {
    return Intl.message(
      '取消',
      name: 'OperateFilePage_k13',
      desc: '',
      args: [],
    );
  }

  /// `删除`
  String get OperateFilePage_k14 {
    return Intl.message(
      '删除',
      name: 'OperateFilePage_k14',
      desc: '',
      args: [],
    );
  }

  /// `暂无文件`
  String get ItemWidget_k1 {
    return Intl.message(
      '暂无文件',
      name: 'ItemWidget_k1',
      desc: '',
      args: [],
    );
  }

  /// `连接设备导入文件`
  String get ItemWidget_k2 {
    return Intl.message(
      '连接设备导入文件',
      name: 'ItemWidget_k2',
      desc: '',
      args: [],
    );
  }

  /// `删除`
  String get ItemWidget_k3 {
    return Intl.message(
      '删除',
      name: 'ItemWidget_k3',
      desc: '',
      args: [],
    );
  }

  /// `重命名`
  String get ItemWidget_k4 {
    return Intl.message(
      '重命名',
      name: 'ItemWidget_k4',
      desc: '',
      args: [],
    );
  }

  /// `分享`
  String get ItemWidget_k5 {
    return Intl.message(
      '分享',
      name: 'ItemWidget_k5',
      desc: '',
      args: [],
    );
  }

  /// `AI分析`
  String get ItemWidget_AI {
    return Intl.message(
      'AI分析',
      name: 'ItemWidget_AI',
      desc: '',
      args: [],
    );
  }

  /// `在所有文件中搜索`
  String get SearchFilePage_k1 {
    return Intl.message(
      '在所有文件中搜索',
      name: 'SearchFilePage_k1',
      desc: '',
      args: [],
    );
  }

  /// `取消`
  String get SearchFilePage_k2 {
    return Intl.message(
      '取消',
      name: 'SearchFilePage_k2',
      desc: '',
      args: [],
    );
  }

  /// `同步音频文件列表`
  String get BlueAudioFileList_k1 {
    return Intl.message(
      '同步音频文件列表',
      name: 'BlueAudioFileList_k1',
      desc: '',
      args: [],
    );
  }

  /// `已完成`
  String get BlueAudioFileList_k2 {
    return Intl.message(
      '已完成',
      name: 'BlueAudioFileList_k2',
      desc: '',
      args: [],
    );
  }

  /// `暂无同步音频文件`
  String get BlueAudioFileList_k3 {
    return Intl.message(
      '暂无同步音频文件',
      name: 'BlueAudioFileList_k3',
      desc: '',
      args: [],
    );
  }

  /// `重新同步音频`
  String get BlueAudioFileList_k5 {
    return Intl.message(
      '重新同步音频',
      name: 'BlueAudioFileList_k5',
      desc: '',
      args: [],
    );
  }

  /// `设备连接`
  String get BluetoothPage_k1 {
    return Intl.message(
      '设备连接',
      name: 'BluetoothPage_k1',
      desc: '',
      args: [],
    );
  }

  /// `正在扫描设备...`
  String get BluetoothPage_k2 {
    return Intl.message(
      '正在扫描设备...',
      name: 'BluetoothPage_k2',
      desc: '',
      args: [],
    );
  }

  /// `请确保设备已开机且蓝牙已开启`
  String get BluetoothPage_k3 {
    return Intl.message(
      '请确保设备已开机且蓝牙已开启',
      name: 'BluetoothPage_k3',
      desc: '',
      args: [],
    );
  }

  /// `扫描过程中请保持设备在有效范围内`
  String get BluetoothPage_k4 {
    return Intl.message(
      '扫描过程中请保持设备在有效范围内',
      name: 'BluetoothPage_k4',
      desc: '',
      args: [],
    );
  }

  /// `如果设备已开启但仍未找到，请点击下方按钮重新扫描`
  String get BluetoothPage_k5 {
    return Intl.message(
      '如果设备已开启但仍未找到，请点击下方按钮重新扫描',
      name: 'BluetoothPage_k5',
      desc: '',
      args: [],
    );
  }

  /// `重新扫描设备`
  String get BluetoothPage_k6 {
    return Intl.message(
      '重新扫描设备',
      name: 'BluetoothPage_k6',
      desc: '',
      args: [],
    );
  }

  /// `信号强度`
  String get BluetoothPage_k7 {
    return Intl.message(
      '信号强度',
      name: 'BluetoothPage_k7',
      desc: '',
      args: [],
    );
  }

  /// `连接设备`
  String get BluetoothPage_k8 {
    return Intl.message(
      '连接设备',
      name: 'BluetoothPage_k8',
      desc: '',
      args: [],
    );
  }

  /// `连接失败`
  String get BluetoothPage_k9 {
    return Intl.message(
      '连接失败',
      name: 'BluetoothPage_k9',
      desc: '',
      args: [],
    );
  }

  /// `请检查设备是否已开启并处于可连接状态`
  String get BluetoothPage_k10 {
    return Intl.message(
      '请检查设备是否已开启并处于可连接状态',
      name: 'BluetoothPage_k10',
      desc: '',
      args: [],
    );
  }

  /// `重新扫描`
  String get BluetoothPage_k11 {
    return Intl.message(
      '重新扫描',
      name: 'BluetoothPage_k11',
      desc: '',
      args: [],
    );
  }

  /// `设备管理`
  String get DevicePage_k1 {
    return Intl.message(
      '设备管理',
      name: 'DevicePage_k1',
      desc: '',
      args: [],
    );
  }

  /// `充电中...`
  String get DevicePage_k2 {
    return Intl.message(
      '充电中...',
      name: 'DevicePage_k2',
      desc: '',
      args: [],
    );
  }

  /// `未连接`
  String get DevicePage_k3 {
    return Intl.message(
      '未连接',
      name: 'DevicePage_k3',
      desc: '',
      args: [],
    );
  }

  /// `设备说明`
  String get DevicePage_k4 {
    return Intl.message(
      '设备说明',
      name: 'DevicePage_k4',
      desc: '',
      args: [],
    );
  }

  /// `• 首次使用需要手动连接设备\n• 连接成功后会自动同步录音文件\n• 支持实时查看设备电量\n• 支持远程控制录音功能`
  String get DevicePage_k5 {
    return Intl.message(
      '• 首次使用需要手动连接设备\n• 连接成功后会自动同步录音文件\n• 支持实时查看设备电量\n• 支持远程控制录音功能',
      name: 'DevicePage_k5',
      desc: '',
      args: [],
    );
  }

  /// `连接设备`
  String get DevicePage_k6 {
    return Intl.message(
      '连接设备',
      name: 'DevicePage_k6',
      desc: '',
      args: [],
    );
  }

  /// `正在连接设备...`
  String get DevicePage_k7 {
    return Intl.message(
      '正在连接设备...',
      name: 'DevicePage_k7',
      desc: '',
      args: [],
    );
  }

  /// `请确保设备已开启并处于可连接状态`
  String get DevicePage_k8 {
    return Intl.message(
      '请确保设备已开启并处于可连接状态',
      name: 'DevicePage_k8',
      desc: '',
      args: [],
    );
  }

  /// `连接失败`
  String get DevicePage_k9 {
    return Intl.message(
      '连接失败',
      name: 'DevicePage_k9',
      desc: '',
      args: [],
    );
  }

  /// `设备连接超时，请检查：\n• 设备是否已开启\n• 设备是否在有效范围内\n• 设备是否被其他应用占用\n• 蓝牙功能是否正常`
  String get DevicePage_k10 {
    return Intl.message(
      '设备连接超时，请检查：\n• 设备是否已开启\n• 设备是否在有效范围内\n• 设备是否被其他应用占用\n• 蓝牙功能是否正常',
      name: 'DevicePage_k10',
      desc: '',
      args: [],
    );
  }

  /// `取消`
  String get DevicePage_k11 {
    return Intl.message(
      '取消',
      name: 'DevicePage_k11',
      desc: '',
      args: [],
    );
  }

  /// `重试`
  String get DevicePage_k12 {
    return Intl.message(
      '重试',
      name: 'DevicePage_k12',
      desc: '',
      args: [],
    );
  }

  /// `连接成功`
  String get DevicePage_k13 {
    return Intl.message(
      '连接成功',
      name: 'DevicePage_k13',
      desc: '',
      args: [],
    );
  }

  /// `确定`
  String get DevicePage_k14 {
    return Intl.message(
      '确定',
      name: 'DevicePage_k14',
      desc: '',
      args: [],
    );
  }

  /// `断开连接`
  String get DevicePage_k15 {
    return Intl.message(
      '断开连接',
      name: 'DevicePage_k15',
      desc: '',
      args: [],
    );
  }

  /// `删除设备`
  String get DevicePage_k16 {
    return Intl.message(
      '删除设备',
      name: 'DevicePage_k16',
      desc: '',
      args: [],
    );
  }

  /// `确认删除设备吗？`
  String get DevicePage_k17 {
    return Intl.message(
      '确认删除设备吗？',
      name: 'DevicePage_k17',
      desc: '',
      args: [],
    );
  }

  /// `删除后将无法恢复设备信息`
  String get DevicePage_k18 {
    return Intl.message(
      '删除后将无法恢复设备信息',
      name: 'DevicePage_k18',
      desc: '',
      args: [],
    );
  }

  /// `确定断开连接吗？`
  String get DevicePage_k19 {
    return Intl.message(
      '确定断开连接吗？',
      name: 'DevicePage_k19',
      desc: '',
      args: [],
    );
  }

  /// `断开连接后需要重新配对设备`
  String get DevicePage_k20 {
    return Intl.message(
      '断开连接后需要重新配对设备',
      name: 'DevicePage_k20',
      desc: '',
      args: [],
    );
  }

  /// `取消`
  String get DevicePage_k25 {
    return Intl.message(
      '取消',
      name: 'DevicePage_k25',
      desc: '',
      args: [],
    );
  }

  /// `确定`
  String get DevicePage_k26 {
    return Intl.message(
      '确定',
      name: 'DevicePage_k26',
      desc: '',
      args: [],
    );
  }

  /// `使用说明`
  String get PenPage_k1 {
    return Intl.message(
      '使用说明',
      name: 'PenPage_k1',
      desc: '',
      args: [],
    );
  }

  /// `设备首次连接需要手动点击连接，连接成功后，后续每次设备会都自动连接，无需任何手动操作。`
  String get PenPage_k2 {
    return Intl.message(
      '设备首次连接需要手动点击连接，连接成功后，后续每次设备会都自动连接，无需任何手动操作。',
      name: 'PenPage_k2',
      desc: '',
      args: [],
    );
  }

  /// `若发现设备未连接，请检查：`
  String get PenPage_k3 {
    return Intl.message(
      '若发现设备未连接，请检查：',
      name: 'PenPage_k3',
      desc: '',
      args: [],
    );
  }

  /// `蓝牙是否已开启`
  String get PenPage_k4 {
    return Intl.message(
      '蓝牙是否已开启',
      name: 'PenPage_k4',
      desc: '',
      args: [],
    );
  }

  /// `设备是否已开机`
  String get PenPage_k5 {
    return Intl.message(
      '设备是否已开机',
      name: 'PenPage_k5',
      desc: '',
      args: [],
    );
  }

  /// `下一步`
  String get PenPage_k6 {
    return Intl.message(
      '下一步',
      name: 'PenPage_k6',
      desc: '',
      args: [],
    );
  }

  /// `智能录音笔`
  String get PenPageList_k1 {
    return Intl.message(
      '智能录音笔',
      name: 'PenPageList_k1',
      desc: '',
      args: [],
    );
  }

  /// `正在加载设备信息...`
  String get PenPageList_k2 {
    return Intl.message(
      '正在加载设备信息...',
      name: 'PenPageList_k2',
      desc: '',
      args: [],
    );
  }

  /// `获取设备信息失败，请重试`
  String get PenPageList_k3 {
    return Intl.message(
      '获取设备信息失败，请重试',
      name: 'PenPageList_k3',
      desc: '',
      args: [],
    );
  }

  /// `重试`
  String get PenPageList_k4 {
    return Intl.message(
      '重试',
      name: 'PenPageList_k4',
      desc: '',
      args: [],
    );
  }

  /// `未能获取设备信息`
  String get PenPageList_k5 {
    return Intl.message(
      '未能获取设备信息',
      name: 'PenPageList_k5',
      desc: '',
      args: [],
    );
  }

  /// `请点击刷新按钮重新获取`
  String get PenPageList_k6 {
    return Intl.message(
      '请点击刷新按钮重新获取',
      name: 'PenPageList_k6',
      desc: '',
      args: [],
    );
  }

  /// `重新加载`
  String get PenPageList_k7 {
    return Intl.message(
      '重新加载',
      name: 'PenPageList_k7',
      desc: '',
      args: [],
    );
  }

  /// `图片加载失败`
  String get PenPageList_k8 {
    return Intl.message(
      '图片加载失败',
      name: 'PenPageList_k8',
      desc: '',
      args: [],
    );
  }

  /// `智能录音笔配备AI语音识别技术，支持实时转写、多语种识别等功能，让您的会议记录和学习笔记更加便捷高效。`
  String get PenPageList_k9 {
    return Intl.message(
      '智能录音笔配备AI语音识别技术，支持实时转写、多语种识别等功能，让您的会议记录和学习笔记更加便捷高效。',
      name: 'PenPageList_k9',
      desc: '',
      args: [],
    );
  }

  /// `核心功能`
  String get PenPageList_k10 {
    return Intl.message(
      '核心功能',
      name: 'PenPageList_k10',
      desc: '',
      args: [],
    );
  }

  /// `录音转文字`
  String get PenPageList_k11 {
    return Intl.message(
      '录音转文字',
      name: 'PenPageList_k11',
      desc: '',
      args: [],
    );
  }

  /// `高效准确的语音转写`
  String get PenPageList_k12 {
    return Intl.message(
      '高效准确的语音转写',
      name: 'PenPageList_k12',
      desc: '',
      args: [],
    );
  }

  /// `实时转写`
  String get PenPageList_k13 {
    return Intl.message(
      '实时转写',
      name: 'PenPageList_k13',
      desc: '',
      args: [],
    );
  }

  /// `边录音边显示文字`
  String get PenPageList_k14 {
    return Intl.message(
      '边录音边显示文字',
      name: 'PenPageList_k14',
      desc: '',
      args: [],
    );
  }

  /// `实时转写编辑`
  String get PenPageList_k15 {
    return Intl.message(
      '实时转写编辑',
      name: 'PenPageList_k15',
      desc: '',
      args: [],
    );
  }

  /// `随时编辑转写内容`
  String get PenPageList_k16 {
    return Intl.message(
      '随时编辑转写内容',
      name: 'PenPageList_k16',
      desc: '',
      args: [],
    );
  }

  /// `小语种识别`
  String get PenPageList_k17 {
    return Intl.message(
      '小语种识别',
      name: 'PenPageList_k17',
      desc: '',
      args: [],
    );
  }

  /// `支持多国语言识别`
  String get PenPageList_k18 {
    return Intl.message(
      '支持多国语言识别',
      name: 'PenPageList_k18',
      desc: '',
      args: [],
    );
  }

  /// `AI会议总结`
  String get PenPageList_k19 {
    return Intl.message(
      'AI会议总结',
      name: 'PenPageList_k19',
      desc: '',
      args: [],
    );
  }

  /// `智能生成会议要点`
  String get PenPageList_k20 {
    return Intl.message(
      '智能生成会议要点',
      name: 'PenPageList_k20',
      desc: '',
      args: [],
    );
  }

  /// `AI问一问`
  String get PenPageList_k21 {
    return Intl.message(
      'AI问一问',
      name: 'PenPageList_k21',
      desc: '',
      args: [],
    );
  }

  /// `智能问答助手`
  String get PenPageList_k22 {
    return Intl.message(
      '智能问答助手',
      name: 'PenPageList_k22',
      desc: '',
      args: [],
    );
  }

  /// `立即连接录音笔`
  String get PenPageList_k23 {
    return Intl.message(
      '立即连接录音笔',
      name: 'PenPageList_k23',
      desc: '',
      args: [],
    );
  }

  /// `录音机V1`
  String get PenPageList_v1_title {
    return Intl.message(
      '录音机V1',
      name: 'PenPageList_v1_title',
      desc: '',
      args: [],
    );
  }

  /// `广播名GSS-01，支持实时转写与AI分析`
  String get PenPageList_v1_desc {
    return Intl.message(
      '广播名GSS-01，支持实时转写与AI分析',
      name: 'PenPageList_v1_desc',
      desc: '',
      args: [],
    );
  }

  /// `录音机V2`
  String get PenPageList_v2_title {
    return Intl.message(
      '录音机V2',
      name: 'PenPageList_v2_title',
      desc: '',
      args: [],
    );
  }

  /// `广播名AI-RTCAPEN，支持实时转写与AI分析`
  String get PenPageList_v2_desc {
    return Intl.message(
      '广播名AI-RTCAPEN，支持实时转写与AI分析',
      name: 'PenPageList_v2_desc',
      desc: '',
      args: [],
    );
  }

  /// `立即连接`
  String get PenPageList_v2_connect {
    return Intl.message(
      '立即连接',
      name: 'PenPageList_v2_connect',
      desc: '',
      args: [],
    );
  }

  /// `设备服务`
  String get MemPage_k1 {
    return Intl.message(
      '设备服务',
      name: 'MemPage_k1',
      desc: '',
      args: [],
    );
  }

  /// `Pro版`
  String get MemPage_k2 {
    return Intl.message(
      'Pro版',
      name: 'MemPage_k2',
      desc: '',
      args: [],
    );
  }

  /// `绑定设备解锁全部功能`
  String get MemPage_k3 {
    return Intl.message(
      '绑定设备解锁全部功能',
      name: 'MemPage_k3',
      desc: '',
      args: [],
    );
  }

  /// `时长余额`
  String get MemPage_k4 {
    return Intl.message(
      '时长余额',
      name: 'MemPage_k4',
      desc: '',
      args: [],
    );
  }

  /// `分钟`
  String get MemPage_k5 {
    return Intl.message(
      '分钟',
      name: 'MemPage_k5',
      desc: '',
      args: [],
    );
  }

  /// `到期时间`
  String get MemPage_k6 {
    return Intl.message(
      '到期时间',
      name: 'MemPage_k6',
      desc: '',
      args: [],
    );
  }

  /// `设备功能特权`
  String get MemPage_k7 {
    return Intl.message(
      '设备功能特权',
      name: 'MemPage_k7',
      desc: '',
      args: [],
    );
  }

  /// `专业总结模板`
  String get MemPage_k8 {
    return Intl.message(
      '专业总结模板',
      name: 'MemPage_k8',
      desc: '',
      args: [],
    );
  }

  /// `专业模版设计，提高您的工作效率。根据行业需求量身定制。`
  String get MemPage_k9 {
    return Intl.message(
      '专业模版设计，提高您的工作效率。根据行业需求量身定制。',
      name: 'MemPage_k9',
      desc: '',
      args: [],
    );
  }

  /// `Ask AI`
  String get MemPage_k10 {
    return Intl.message(
      'Ask AI',
      name: 'MemPage_k10',
      desc: '',
      args: [],
    );
  }

  /// `从录音中智能挖掘更深入信息，一键生成数据表格、关键讨论结论、To Do、汇报邮件等格式内容。`
  String get MemPage_k11 {
    return Intl.message(
      '从录音中智能挖掘更深入信息，一键生成数据表格、关键讨论结论、To Do、汇报邮件等格式内容。',
      name: 'MemPage_k11',
      desc: '',
      args: [],
    );
  }

  /// `音频导入`
  String get MemPage_k12 {
    return Intl.message(
      '音频导入',
      name: 'MemPage_k12',
      desc: '',
      args: [],
    );
  }

  /// `可以轻松从本地或第三方应用导入音频文件，如语言备忘录、Google云端硬盘等。`
  String get MemPage_k13 {
    return Intl.message(
      '可以轻松从本地或第三方应用导入音频文件，如语言备忘录、Google云端硬盘等。',
      name: 'MemPage_k13',
      desc: '',
      args: [],
    );
  }

  /// `多种格式导出`
  String get MemPage_k14 {
    return Intl.message(
      '多种格式导出',
      name: 'MemPage_k14',
      desc: '',
      args: [],
    );
  }

  /// `导出您的音频录音、转录文本和摘要为各种格式（TXT、DOCX、PDF、JPEG），以满足您的需求。`
  String get MemPage_k15 {
    return Intl.message(
      '导出您的音频录音、转录文本和摘要为各种格式（TXT、DOCX、PDF、JPEG），以满足您的需求。',
      name: 'MemPage_k15',
      desc: '',
      args: [],
    );
  }

  /// `升级为Pro会员`
  String get MemPage_k16 {
    return Intl.message(
      '升级为Pro会员',
      name: 'MemPage_k16',
      desc: '',
      args: [],
    );
  }

  /// `立即升级`
  String get MemPage_k17 {
    return Intl.message(
      '立即升级',
      name: 'MemPage_k17',
      desc: '',
      args: [],
    );
  }

  /// `购买更多转写时长`
  String get MemPage_k18 {
    return Intl.message(
      '购买更多转写时长',
      name: 'MemPage_k18',
      desc: '',
      args: [],
    );
  }

  /// `通用时长适用于所有转写场景，您可以用来做声文速记、同声传译、也可以用来导入文件转写和音频精转。`
  String get MemPage_k19 {
    return Intl.message(
      '通用时长适用于所有转写场景，您可以用来做声文速记、同声传译、也可以用来导入文件转写和音频精转。',
      name: 'MemPage_k19',
      desc: '',
      args: [],
    );
  }

  /// `增值服务为虚拟时长资源，您一旦购买成功，将不予转让，不予退换，不予延期。`
  String get MemPage_k20 {
    return Intl.message(
      '增值服务为虚拟时长资源，您一旦购买成功，将不予转让，不予退换，不予延期。',
      name: 'MemPage_k20',
      desc: '',
      args: [],
    );
  }

  /// `通用时长套餐充值之日起365天内有效，超过有效期自动作废，请适量购买。`
  String get MemPage_k21 {
    return Intl.message(
      '通用时长套餐充值之日起365天内有效，超过有效期自动作废，请适量购买。',
      name: 'MemPage_k21',
      desc: '',
      args: [],
    );
  }

  /// `选择支付方式`
  String get MemPage_k22 {
    return Intl.message(
      '选择支付方式',
      name: 'MemPage_k22',
      desc: '',
      args: [],
    );
  }

  /// `微信支付`
  String get MemPage_k23 {
    return Intl.message(
      '微信支付',
      name: 'MemPage_k23',
      desc: '',
      args: [],
    );
  }

  /// `PayPal`
  String get MemPage_k24 {
    return Intl.message(
      'PayPal',
      name: 'MemPage_k24',
      desc: '',
      args: [],
    );
  }

  /// `用户协议`
  String get UserAgreementPage_k1 {
    return Intl.message(
      '用户协议',
      name: 'UserAgreementPage_k1',
      desc: '',
      args: [],
    );
  }

  /// `加载中...`
  String get UserAgreementPage_k2 {
    return Intl.message(
      '加载中...',
      name: 'UserAgreementPage_k2',
      desc: '',
      args: [],
    );
  }

  /// `隐私政策`
  String get PrivacyPolicyPage_k1 {
    return Intl.message(
      '隐私政策',
      name: 'PrivacyPolicyPage_k1',
      desc: '',
      args: [],
    );
  }

  /// `加载中...`
  String get PrivacyPolicyPage_k2 {
    return Intl.message(
      '加载中...',
      name: 'PrivacyPolicyPage_k2',
      desc: '',
      args: [],
    );
  }

  /// `设备服务`
  String get ProfilePage_k1 {
    return Intl.message(
      '设备服务',
      name: 'ProfilePage_k1',
      desc: '',
      args: [],
    );
  }

  /// `转写记录`
  String get ProfilePage_k2 {
    return Intl.message(
      '转写记录',
      name: 'ProfilePage_k2',
      desc: '',
      args: [],
    );
  }

  /// `订单记录`
  String get ProfilePage_k3 {
    return Intl.message(
      '订单记录',
      name: 'ProfilePage_k3',
      desc: '',
      args: [],
    );
  }

  /// `用户反馈`
  String get ProfilePage_k4 {
    return Intl.message(
      '用户反馈',
      name: 'ProfilePage_k4',
      desc: '',
      args: [],
    );
  }

  /// `帮助中心`
  String get ProfilePage_k5 {
    return Intl.message(
      '帮助中心',
      name: 'ProfilePage_k5',
      desc: '',
      args: [],
    );
  }

  /// `清除缓存`
  String get ProfilePage_k6 {
    return Intl.message(
      '清除缓存',
      name: 'ProfilePage_k6',
      desc: '',
      args: [],
    );
  }

  /// `关于我们`
  String get ProfilePage_k7 {
    return Intl.message(
      '关于我们',
      name: 'ProfilePage_k7',
      desc: '',
      args: [],
    );
  }

  /// `绑定您的设备`
  String get ProfilePage_k8 {
    return Intl.message(
      '绑定您的设备',
      name: 'ProfilePage_k8',
      desc: '',
      args: [],
    );
  }

  /// `输入随设备附带的绑定码进行绑定`
  String get ProfilePage_k9 {
    return Intl.message(
      '输入随设备附带的绑定码进行绑定',
      name: 'ProfilePage_k9',
      desc: '',
      args: [],
    );
  }

  /// `绑定`
  String get ProfilePage_k10 {
    return Intl.message(
      '绑定',
      name: 'ProfilePage_k10',
      desc: '',
      args: [],
    );
  }

  /// `确定退出吗？`
  String get ProfilePage_k11 {
    return Intl.message(
      '确定退出吗？',
      name: 'ProfilePage_k11',
      desc: '',
      args: [],
    );
  }

  /// `取消`
  String get ProfilePage_k12 {
    return Intl.message(
      '取消',
      name: 'ProfilePage_k12',
      desc: '',
      args: [],
    );
  }

  /// `退出异常`
  String get ProfilePage_k13 {
    return Intl.message(
      '退出异常',
      name: 'ProfilePage_k13',
      desc: '',
      args: [],
    );
  }

  /// `退出`
  String get ProfilePage_k14 {
    return Intl.message(
      '退出',
      name: 'ProfilePage_k14',
      desc: '',
      args: [],
    );
  }

  /// `请输入设备绑定码`
  String get ProfilePage_k15 {
    return Intl.message(
      '请输入设备绑定码',
      name: 'ProfilePage_k15',
      desc: '',
      args: [],
    );
  }

  /// `取消`
  String get ProfilePage_k16 {
    return Intl.message(
      '取消',
      name: 'ProfilePage_k16',
      desc: '',
      args: [],
    );
  }

  /// `设备绑定码无效或不存在，请联系客服!`
  String get ProfilePage_k17 {
    return Intl.message(
      '设备绑定码无效或不存在，请联系客服!',
      name: 'ProfilePage_k17',
      desc: '',
      args: [],
    );
  }

  /// `该设备绑定码已被使用!`
  String get ProfilePage_k18 {
    return Intl.message(
      '该设备绑定码已被使用!',
      name: 'ProfilePage_k18',
      desc: '',
      args: [],
    );
  }

  /// `绑定失败,请重试!`
  String get ProfilePage_k19 {
    return Intl.message(
      '绑定失败,请重试!',
      name: 'ProfilePage_k19',
      desc: '',
      args: [],
    );
  }

  /// `绑定`
  String get ProfilePage_k20 {
    return Intl.message(
      '绑定',
      name: 'ProfilePage_k20',
      desc: '',
      args: [],
    );
  }

  /// `帮助中心`
  String get HelperPage_k1 {
    return Intl.message(
      '帮助中心',
      name: 'HelperPage_k1',
      desc: '',
      args: [],
    );
  }

  /// `常见问题`
  String get HelperPage_k2 {
    return Intl.message(
      '常见问题',
      name: 'HelperPage_k2',
      desc: '',
      args: [],
    );
  }

  /// `如何使用录音笔？`
  String get HelperPage_k3 {
    return Intl.message(
      '如何使用录音笔？',
      name: 'HelperPage_k3',
      desc: '',
      args: [],
    );
  }

  /// `如何导入音频文件？`
  String get HelperPage_k4 {
    return Intl.message(
      '如何导入音频文件？',
      name: 'HelperPage_k4',
      desc: '',
      args: [],
    );
  }

  /// `如何导出转写结果？`
  String get HelperPage_k5 {
    return Intl.message(
      '如何导出转写结果？',
      name: 'HelperPage_k5',
      desc: '',
      args: [],
    );
  }

  /// `支持哪些音频格式？`
  String get HelperPage_k6 {
    return Intl.message(
      '支持哪些音频格式？',
      name: 'HelperPage_k6',
      desc: '',
      args: [],
    );
  }

  /// `如何升级会员？`
  String get HelperPage_k7 {
    return Intl.message(
      '如何升级会员？',
      name: 'HelperPage_k7',
      desc: '',
      args: [],
    );
  }

  /// `意见反馈`
  String get FeedBackPage_k1 {
    return Intl.message(
      '意见反馈',
      name: 'FeedBackPage_k1',
      desc: '',
      args: [],
    );
  }

  /// `请描述您遇到的问题`
  String get FeedBackPage_k2 {
    return Intl.message(
      '请描述您遇到的问题',
      name: 'FeedBackPage_k2',
      desc: '',
      args: [],
    );
  }

  /// `问题描述（必填）`
  String get FeedBackPage_k3 {
    return Intl.message(
      '问题描述（必填）',
      name: 'FeedBackPage_k3',
      desc: '',
      args: [],
    );
  }

  /// `联系方式（选填）`
  String get FeedBackPage_k4 {
    return Intl.message(
      '联系方式（选填）',
      name: 'FeedBackPage_k4',
      desc: '',
      args: [],
    );
  }

  /// `提交`
  String get FeedBackPage_k5 {
    return Intl.message(
      '提交',
      name: 'FeedBackPage_k5',
      desc: '',
      args: [],
    );
  }

  /// `请输入问题描述`
  String get FeedBackPage_k6 {
    return Intl.message(
      '请输入问题描述',
      name: 'FeedBackPage_k6',
      desc: '',
      args: [],
    );
  }

  /// `提交成功`
  String get FeedBackPage_k7 {
    return Intl.message(
      '提交成功',
      name: 'FeedBackPage_k7',
      desc: '',
      args: [],
    );
  }

  /// `感谢您的反馈，我们会尽快处理`
  String get FeedBackPage_k8 {
    return Intl.message(
      '感谢您的反馈，我们会尽快处理',
      name: 'FeedBackPage_k8',
      desc: '',
      args: [],
    );
  }

  /// `反馈内容`
  String get FeedBackPage_k9 {
    return Intl.message(
      '反馈内容',
      name: 'FeedBackPage_k9',
      desc: '',
      args: [],
    );
  }

  /// `联系方式`
  String get FeedBackPage_k10 {
    return Intl.message(
      '联系方式',
      name: 'FeedBackPage_k10',
      desc: '',
      args: [],
    );
  }

  /// `清理缓存`
  String get ClearCachePage_k1 {
    return Intl.message(
      '清理缓存',
      name: 'ClearCachePage_k1',
      desc: '',
      args: [],
    );
  }

  /// `缓存大小`
  String get ClearCachePage_k2 {
    return Intl.message(
      '缓存大小',
      name: 'ClearCachePage_k2',
      desc: '',
      args: [],
    );
  }

  /// `清理`
  String get ClearCachePage_k3 {
    return Intl.message(
      '清理',
      name: 'ClearCachePage_k3',
      desc: '',
      args: [],
    );
  }

  /// `清理成功`
  String get ClearCachePage_k4 {
    return Intl.message(
      '清理成功',
      name: 'ClearCachePage_k4',
      desc: '',
      args: [],
    );
  }

  /// `转写记录`
  String get ConvertRecordPage_k1 {
    return Intl.message(
      '转写记录',
      name: 'ConvertRecordPage_k1',
      desc: '',
      args: [],
    );
  }

  /// `暂无记录`
  String get ConvertRecordPage_k2 {
    return Intl.message(
      '暂无记录',
      name: 'ConvertRecordPage_k2',
      desc: '',
      args: [],
    );
  }

  /// `转写时长`
  String get ConvertRecordPage_k3 {
    return Intl.message(
      '转写时长',
      name: 'ConvertRecordPage_k3',
      desc: '',
      args: [],
    );
  }

  /// `转写时间`
  String get ConvertRecordPage_k4 {
    return Intl.message(
      '转写时间',
      name: 'ConvertRecordPage_k4',
      desc: '',
      args: [],
    );
  }

  /// `分钟`
  String get ConvertRecordPage_k5 {
    return Intl.message(
      '分钟',
      name: 'ConvertRecordPage_k5',
      desc: '',
      args: [],
    );
  }

  /// `关于YiGuo Voice`
  String get AboutPage_k1 {
    return Intl.message(
      '关于YiGuo Voice',
      name: 'AboutPage_k1',
      desc: '',
      args: [],
    );
  }

  /// `版本更新`
  String get AboutPage_k2 {
    return Intl.message(
      '版本更新',
      name: 'AboutPage_k2',
      desc: '',
      args: [],
    );
  }

  /// `访问官方网站`
  String get AboutPage_k3 {
    return Intl.message(
      '访问官方网站',
      name: 'AboutPage_k3',
      desc: '',
      args: [],
    );
  }

  /// `在Facebook上关注我们`
  String get AboutPage_k4 {
    return Intl.message(
      '在Facebook上关注我们',
      name: 'AboutPage_k4',
      desc: '',
      args: [],
    );
  }

  /// `在Instagram上关注我们`
  String get AboutPage_k5 {
    return Intl.message(
      '在Instagram上关注我们',
      name: 'AboutPage_k5',
      desc: '',
      args: [],
    );
  }

  /// `在Tiktok上关注我们`
  String get AboutPage_k6 {
    return Intl.message(
      '在Tiktok上关注我们',
      name: 'AboutPage_k6',
      desc: '',
      args: [],
    );
  }

  /// `用户协议`
  String get AboutPage_k7 {
    return Intl.message(
      '用户协议',
      name: 'AboutPage_k7',
      desc: '',
      args: [],
    );
  }

  /// `隐私政策`
  String get AboutPage_k8 {
    return Intl.message(
      '隐私政策',
      name: 'AboutPage_k8',
      desc: '',
      args: [],
    );
  }

  /// `交易记录`
  String get TradeRecordPage_k1 {
    return Intl.message(
      '交易记录',
      name: 'TradeRecordPage_k1',
      desc: '',
      args: [],
    );
  }

  /// `暂无记录`
  String get TradeRecordPage_k2 {
    return Intl.message(
      '暂无记录',
      name: 'TradeRecordPage_k2',
      desc: '',
      args: [],
    );
  }

  /// `支付金额`
  String get TradeRecordPage_k3 {
    return Intl.message(
      '支付金额',
      name: 'TradeRecordPage_k3',
      desc: '',
      args: [],
    );
  }

  /// `支付时间`
  String get TradeRecordPage_k4 {
    return Intl.message(
      '支付时间',
      name: 'TradeRecordPage_k4',
      desc: '',
      args: [],
    );
  }

  /// `支付状态`
  String get TradeRecordPage_k5 {
    return Intl.message(
      '支付状态',
      name: 'TradeRecordPage_k5',
      desc: '',
      args: [],
    );
  }

  /// `支付成功`
  String get TradeRecordPage_k6 {
    return Intl.message(
      '支付成功',
      name: 'TradeRecordPage_k6',
      desc: '',
      args: [],
    );
  }

  /// `支付失败`
  String get TradeRecordPage_k7 {
    return Intl.message(
      '支付失败',
      name: 'TradeRecordPage_k7',
      desc: '',
      args: [],
    );
  }

  /// `支付取消`
  String get TradeRecordPage_k8 {
    return Intl.message(
      '支付取消',
      name: 'TradeRecordPage_k8',
      desc: '',
      args: [],
    );
  }

  /// `音频文件正在同步中`
  String get SyncAudioWidget_k1 {
    return Intl.message(
      '音频文件正在同步中',
      name: 'SyncAudioWidget_k1',
      desc: '',
      args: [],
    );
  }

  /// `音频文件传输完毕！`
  String get BlueController_audio_sync_completed {
    return Intl.message(
      '音频文件传输完毕！',
      name: 'BlueController_audio_sync_completed',
      desc: '',
      args: [],
    );
  }

  /// `设备连接已断开，正在返回首页…`
  String get BlueController_device_disconnected_jump_home {
    return Intl.message(
      '设备连接已断开，正在返回首页…',
      name: 'BlueController_device_disconnected_jump_home',
      desc: '',
      args: [],
    );
  }

  /// `正在从远程同步音频到本地,可查看进度>>>`
  String get CloudAudioWidget_k1 {
    return Intl.message(
      '正在从远程同步音频到本地,可查看进度>>>',
      name: 'CloudAudioWidget_k1',
      desc: '',
      args: [],
    );
  }

  /// `录音笔录音`
  String get RecordPenWidget_k1 {
    return Intl.message(
      '录音笔录音',
      name: 'RecordPenWidget_k1',
      desc: '',
      args: [],
    );
  }

  /// `选择识别语言`
  String get RecordPenWidget_k2 {
    return Intl.message(
      '选择识别语言',
      name: 'RecordPenWidget_k2',
      desc: '',
      args: [],
    );
  }

  /// `选择识别语言`
  String get LocalRecordWidget_k1 {
    return Intl.message(
      '选择识别语言',
      name: 'LocalRecordWidget_k1',
      desc: '',
      args: [],
    );
  }

  /// `本地录音`
  String get LocalRecordWidget_k2 {
    return Intl.message(
      '本地录音',
      name: 'LocalRecordWidget_k2',
      desc: '',
      args: [],
    );
  }

  /// `需要麦克风权限`
  String get LocalRecordWidget_k10 {
    return Intl.message(
      '需要麦克风权限',
      name: 'LocalRecordWidget_k10',
      desc: '',
      args: [],
    );
  }

  /// `录音功能需要麦克风权限。请在设置中开启麦克风权限，否则无法使用录音功能。`
  String get LocalRecordWidget_k11 {
    return Intl.message(
      '录音功能需要麦克风权限。请在设置中开启麦克风权限，否则无法使用录音功能。',
      name: 'LocalRecordWidget_k11',
      desc: '',
      args: [],
    );
  }

  /// `取消`
  String get LocalRecordWidget_k12 {
    return Intl.message(
      '取消',
      name: 'LocalRecordWidget_k12',
      desc: '',
      args: [],
    );
  }

  /// `去设置`
  String get LocalRecordWidget_k13 {
    return Intl.message(
      '去设置',
      name: 'LocalRecordWidget_k13',
      desc: '',
      args: [],
    );
  }

  /// `需要麦克风权限才能进行录音`
  String get LocalRecordWidget_k14 {
    return Intl.message(
      '需要麦克风权限才能进行录音',
      name: 'LocalRecordWidget_k14',
      desc: '',
      args: [],
    );
  }

  /// `清除缓存将删除应用内的临时文件，包括下载的音频文件、转写记录等。清除后可能需要重新下载相关文件。`
  String get LocalRecordWidget_k15 {
    return Intl.message(
      '清除缓存将删除应用内的临时文件，包括下载的音频文件、转写记录等。清除后可能需要重新下载相关文件。',
      name: 'LocalRecordWidget_k15',
      desc: '',
      args: [],
    );
  }

  /// `转写文本`
  String get TransTextWidget_k1 {
    return Intl.message(
      '转写文本',
      name: 'TransTextWidget_k1',
      desc: '',
      args: [],
    );
  }

  /// `暂无转写文本`
  String get TransTextWidget_k2 {
    return Intl.message(
      '暂无转写文本',
      name: 'TransTextWidget_k2',
      desc: '',
      args: [],
    );
  }

  /// `请先开始录音或导入音频文件`
  String get TransTextWidget_k3 {
    return Intl.message(
      '请先开始录音或导入音频文件',
      name: 'TransTextWidget_k3',
      desc: '',
      args: [],
    );
  }

  /// `复制文本`
  String get TransTextWidget_k4 {
    return Intl.message(
      '复制文本',
      name: 'TransTextWidget_k4',
      desc: '',
      args: [],
    );
  }

  /// `文本已复制到剪贴板`
  String get TransTextWidget_k5 {
    return Intl.message(
      '文本已复制到剪贴板',
      name: 'TransTextWidget_k5',
      desc: '',
      args: [],
    );
  }

  /// `设备服务`
  String get BuyRecommendWidget_k1 {
    return Intl.message(
      '设备服务',
      name: 'BuyRecommendWidget_k1',
      desc: '',
      args: [],
    );
  }

  /// `绑定设备解锁全部高级功能`
  String get BuyRecommendWidget_k2 {
    return Intl.message(
      '绑定设备解锁全部高级功能',
      name: 'BuyRecommendWidget_k2',
      desc: '',
      args: [],
    );
  }

  /// `无限次数AI转写`
  String get BuyRecommendWidget_k3 {
    return Intl.message(
      '无限次数AI转写',
      name: 'BuyRecommendWidget_k3',
      desc: '',
      args: [],
    );
  }

  /// `快速准确的语音识别`
  String get BuyRecommendWidget_k4 {
    return Intl.message(
      '快速准确的语音识别',
      name: 'BuyRecommendWidget_k4',
      desc: '',
      args: [],
    );
  }

  /// `实时同声传译`
  String get BuyRecommendWidget_k5 {
    return Intl.message(
      '实时同声传译',
      name: 'BuyRecommendWidget_k5',
      desc: '',
      args: [],
    );
  }

  /// `多语言实时翻译`
  String get BuyRecommendWidget_k6 {
    return Intl.message(
      '多语言实时翻译',
      name: 'BuyRecommendWidget_k6',
      desc: '',
      args: [],
    );
  }

  /// `专业会议总结`
  String get BuyRecommendWidget_k7 {
    return Intl.message(
      '专业会议总结',
      name: 'BuyRecommendWidget_k7',
      desc: '',
      args: [],
    );
  }

  /// `智能生成会议要点`
  String get BuyRecommendWidget_k8 {
    return Intl.message(
      '智能生成会议要点',
      name: 'BuyRecommendWidget_k8',
      desc: '',
      args: [],
    );
  }

  /// `绑定设备`
  String get BuyRecommendWidget_k9 {
    return Intl.message(
      '绑定设备',
      name: 'BuyRecommendWidget_k9',
      desc: '',
      args: [],
    );
  }

  /// `暂不绑定`
  String get BuyRecommendWidget_k10 {
    return Intl.message(
      '暂不绑定',
      name: 'BuyRecommendWidget_k10',
      desc: '',
      args: [],
    );
  }

  /// `全选`
  String get OperateItemWidget_k1 {
    return Intl.message(
      '全选',
      name: 'OperateItemWidget_k1',
      desc: '',
      args: [],
    );
  }

  /// `取消全选`
  String get OperateItemWidget_k2 {
    return Intl.message(
      '取消全选',
      name: 'OperateItemWidget_k2',
      desc: '',
      args: [],
    );
  }

  /// `已选择`
  String get OperateItemWidget_k3 {
    return Intl.message(
      '已选择',
      name: 'OperateItemWidget_k3',
      desc: '',
      args: [],
    );
  }

  /// `个文件`
  String get OperateItemWidget_k4 {
    return Intl.message(
      '个文件',
      name: 'OperateItemWidget_k4',
      desc: '',
      args: [],
    );
  }

  /// `操作菜单`
  String get PopupMenuWidget_k1 {
    return Intl.message(
      '操作菜单',
      name: 'PopupMenuWidget_k1',
      desc: '',
      args: [],
    );
  }

  /// `删除`
  String get PopupMenuWidget_k2 {
    return Intl.message(
      '删除',
      name: 'PopupMenuWidget_k2',
      desc: '',
      args: [],
    );
  }

  /// `重命名`
  String get PopupMenuWidget_k3 {
    return Intl.message(
      '重命名',
      name: 'PopupMenuWidget_k3',
      desc: '',
      args: [],
    );
  }

  /// `分享`
  String get PopupMenuWidget_k4 {
    return Intl.message(
      '分享',
      name: 'PopupMenuWidget_k4',
      desc: '',
      args: [],
    );
  }

  /// `摘要`
  String get SummaryTextWidget_k1 {
    return Intl.message(
      '摘要',
      name: 'SummaryTextWidget_k1',
      desc: '',
      args: [],
    );
  }

  /// `生成中...`
  String get SummaryTextWidget_k2 {
    return Intl.message(
      '生成中...',
      name: 'SummaryTextWidget_k2',
      desc: '',
      args: [],
    );
  }

  /// `暂无摘要`
  String get SummaryTextWidget_k3 {
    return Intl.message(
      '暂无摘要',
      name: 'SummaryTextWidget_k3',
      desc: '',
      args: [],
    );
  }

  /// `搜索`
  String get TopMenuWidget_k1 {
    return Intl.message(
      '搜索',
      name: 'TopMenuWidget_k1',
      desc: '',
      args: [],
    );
  }

  /// `排序`
  String get TopMenuWidget_k2 {
    return Intl.message(
      '排序',
      name: 'TopMenuWidget_k2',
      desc: '',
      args: [],
    );
  }

  /// `筛选`
  String get TopMenuWidget_k3 {
    return Intl.message(
      '筛选',
      name: 'TopMenuWidget_k3',
      desc: '',
      args: [],
    );
  }

  /// `多选`
  String get TopMenuWidget_k4 {
    return Intl.message(
      '多选',
      name: 'TopMenuWidget_k4',
      desc: '',
      args: [],
    );
  }

  /// `批量录音`
  String get RecordBatchWidget_k1 {
    return Intl.message(
      '批量录音',
      name: 'RecordBatchWidget_k1',
      desc: '',
      args: [],
    );
  }

  /// `开始录音`
  String get RecordBatchWidget_k2 {
    return Intl.message(
      '开始录音',
      name: 'RecordBatchWidget_k2',
      desc: '',
      args: [],
    );
  }

  /// `停止录音`
  String get RecordBatchWidget_k3 {
    return Intl.message(
      '停止录音',
      name: 'RecordBatchWidget_k3',
      desc: '',
      args: [],
    );
  }

  /// `点击转文字`
  String get PlayerPage_k1 {
    return Intl.message(
      '点击转文字',
      name: 'PlayerPage_k1',
      desc: '',
      args: [],
    );
  }

  /// `获取高精度文字结果`
  String get PlayerPage_k2 {
    return Intl.message(
      '获取高精度文字结果',
      name: 'PlayerPage_k2',
      desc: '',
      args: [],
    );
  }

  /// `转文字中...`
  String get PlayerPage_k3 {
    return Intl.message(
      '转文字中...',
      name: 'PlayerPage_k3',
      desc: '',
      args: [],
    );
  }

  /// `更多`
  String get PlayerPage_k4 {
    return Intl.message(
      '更多',
      name: 'PlayerPage_k4',
      desc: '',
      args: [],
    );
  }

  /// `选择语言`
  String get PlayerPage_k5 {
    return Intl.message(
      '选择语言',
      name: 'PlayerPage_k5',
      desc: '',
      args: [],
    );
  }

  /// `选择模板`
  String get PlayerPage_k6 {
    return Intl.message(
      '选择模板',
      name: 'PlayerPage_k6',
      desc: '',
      args: [],
    );
  }

  /// `提交转写`
  String get PlayerPage_k7 {
    return Intl.message(
      '提交转写',
      name: 'PlayerPage_k7',
      desc: '',
      args: [],
    );
  }

  /// `提交转写成功，等待后台转写完成！`
  String get PlayerPage_k8 {
    return Intl.message(
      '提交转写成功，等待后台转写完成！',
      name: 'PlayerPage_k8',
      desc: '',
      args: [],
    );
  }

  /// `编辑文件名`
  String get PlayerPage_k9 {
    return Intl.message(
      '编辑文件名',
      name: 'PlayerPage_k9',
      desc: '',
      args: [],
    );
  }

  /// `请输入文件名`
  String get PlayerPage_k10 {
    return Intl.message(
      '请输入文件名',
      name: 'PlayerPage_k10',
      desc: '',
      args: [],
    );
  }

  /// `取消`
  String get PlayerPage_k11 {
    return Intl.message(
      '取消',
      name: 'PlayerPage_k11',
      desc: '',
      args: [],
    );
  }

  /// `保存`
  String get PlayerPage_k12 {
    return Intl.message(
      '保存',
      name: 'PlayerPage_k12',
      desc: '',
      args: [],
    );
  }

  /// `文件名不能为空`
  String get PlayerPage_k13 {
    return Intl.message(
      '文件名不能为空',
      name: 'PlayerPage_k13',
      desc: '',
      args: [],
    );
  }

  /// `文件名修改成功`
  String get PlayerPage_k14 {
    return Intl.message(
      '文件名修改成功',
      name: 'PlayerPage_k14',
      desc: '',
      args: [],
    );
  }

  /// `分享`
  String get PlayerPage_k15 {
    return Intl.message(
      '分享',
      name: 'PlayerPage_k15',
      desc: '',
      args: [],
    );
  }

  /// `导出音频文件`
  String get PlayerPage_k16 {
    return Intl.message(
      '导出音频文件',
      name: 'PlayerPage_k16',
      desc: '',
      args: [],
    );
  }

  /// `导出转写`
  String get PlayerPage_k17 {
    return Intl.message(
      '导出转写',
      name: 'PlayerPage_k17',
      desc: '',
      args: [],
    );
  }

  /// `导出总结`
  String get PlayerPage_k18 {
    return Intl.message(
      '导出总结',
      name: 'PlayerPage_k18',
      desc: '',
      args: [],
    );
  }

  /// `导出为`
  String get PlayerPage_k19 {
    return Intl.message(
      '导出为',
      name: 'PlayerPage_k19',
      desc: '',
      args: [],
    );
  }

  /// `导出`
  String get PlayerPage_k20 {
    return Intl.message(
      '导出',
      name: 'PlayerPage_k20',
      desc: '',
      args: [],
    );
  }

  /// `带时间戳`
  String get PlayerPage_k21 {
    return Intl.message(
      '带时间戳',
      name: 'PlayerPage_k21',
      desc: '',
      args: [],
    );
  }

  /// `Hi 我是您的AI助手`
  String get PlayerPage_k22 {
    return Intl.message(
      'Hi 我是您的AI助手',
      name: 'PlayerPage_k22',
      desc: '',
      args: [],
    );
  }

  /// `请点击重新总结以显示总结内容`
  String get PlayerPage_k23 {
    return Intl.message(
      '请点击重新总结以显示总结内容',
      name: 'PlayerPage_k23',
      desc: '',
      args: [],
    );
  }

  /// `未找到转写内容，请先提交转写`
  String get PlayerPage_k24 {
    return Intl.message(
      '未找到转写内容，请先提交转写',
      name: 'PlayerPage_k24',
      desc: '',
      args: [],
    );
  }

  /// `按修改时间排序`
  String get PlayerPage_k25 {
    return Intl.message(
      '按修改时间排序',
      name: 'PlayerPage_k25',
      desc: '',
      args: [],
    );
  }

  /// `按创建时间排序`
  String get PlayerPage_k26 {
    return Intl.message(
      '按创建时间排序',
      name: 'PlayerPage_k26',
      desc: '',
      args: [],
    );
  }

  /// `筛选已转写文件`
  String get PlayerPage_k27 {
    return Intl.message(
      '筛选已转写文件',
      name: 'PlayerPage_k27',
      desc: '',
      args: [],
    );
  }

  /// `批量上传云端，功能实现中...`
  String get PlayerPage_k28 {
    return Intl.message(
      '批量上传云端，功能实现中...',
      name: 'PlayerPage_k28',
      desc: '',
      args: [],
    );
  }

  /// `批量上传云端`
  String get PlayerPage_k29 {
    return Intl.message(
      '批量上传云端',
      name: 'PlayerPage_k29',
      desc: '',
      args: [],
    );
  }

  /// `云端文件同步`
  String get PlayerPage_k30 {
    return Intl.message(
      '云端文件同步',
      name: 'PlayerPage_k30',
      desc: '',
      args: [],
    );
  }

  /// `音频加载失败，请检查文件是否存在或格式是否正确`
  String get PlayerPage_k31 {
    return Intl.message(
      '音频加载失败，请检查文件是否存在或格式是否正确',
      name: 'PlayerPage_k31',
      desc: '',
      args: [],
    );
  }

  /// `服务器异常，请重试`
  String get PlayerPage_k32 {
    return Intl.message(
      '服务器异常，请重试',
      name: 'PlayerPage_k32',
      desc: '',
      args: [],
    );
  }

  /// `正在转写中，请不要离开！`
  String get PlayerPage_k33 {
    return Intl.message(
      '正在转写中，请不要离开！',
      name: 'PlayerPage_k33',
      desc: '',
      args: [],
    );
  }

  /// `AI精转`
  String get PlayerPage_k34 {
    return Intl.message(
      'AI精转',
      name: 'PlayerPage_k34',
      desc: '',
      args: [],
    );
  }

  /// `音频的语言`
  String get PlayerPage_k35 {
    return Intl.message(
      '音频的语言',
      name: 'PlayerPage_k35',
      desc: '',
      args: [],
    );
  }

  /// `智能总结模板`
  String get PlayerPage_k36 {
    return Intl.message(
      '智能总结模板',
      name: 'PlayerPage_k36',
      desc: '',
      args: [],
    );
  }

  /// `音频没有转写，请先转写音频再提问。`
  String get PlayerPage_k37 {
    return Intl.message(
      '音频没有转写，请先转写音频再提问。',
      name: 'PlayerPage_k37',
      desc: '',
      args: [],
    );
  }

  /// `正在生成回复...`
  String get PlayerPage_k38 {
    return Intl.message(
      '正在生成回复...',
      name: 'PlayerPage_k38',
      desc: '',
      args: [],
    );
  }

  /// `AI总结`
  String get PlayerPage_k39 {
    return Intl.message(
      'AI总结',
      name: 'PlayerPage_k39',
      desc: '',
      args: [],
    );
  }

  /// `问一问`
  String get PlayerPage_k40 {
    return Intl.message(
      '问一问',
      name: 'PlayerPage_k40',
      desc: '',
      args: [],
    );
  }

  /// `请输入提问内容`
  String get PlayerPage_k41 {
    return Intl.message(
      '请输入提问内容',
      name: 'PlayerPage_k41',
      desc: '',
      args: [],
    );
  }

  /// `重新总结`
  String get SummaryPage_regenerate {
    return Intl.message(
      '重新总结',
      name: 'SummaryPage_regenerate',
      desc: '',
      args: [],
    );
  }

  /// `重新总结中...`
  String get SummaryPage_regenerating {
    return Intl.message(
      '重新总结中...',
      name: 'SummaryPage_regenerating',
      desc: '',
      args: [],
    );
  }

  /// `重新总结失败，请稍后再试`
  String get SummaryPage_regenerateFailed {
    return Intl.message(
      '重新总结失败，请稍后再试',
      name: 'SummaryPage_regenerateFailed',
      desc: '',
      args: [],
    );
  }

  /// `帮我总结一下会议的核心要点`
  String get AskAiPage_promptSummary {
    return Intl.message(
      '帮我总结一下会议的核心要点',
      name: 'AskAiPage_promptSummary',
      desc: '',
      args: [],
    );
  }

  /// `请整理一下会议的待办事项`
  String get AskAiPage_promptTodo {
    return Intl.message(
      '请整理一下会议的待办事项',
      name: 'AskAiPage_promptTodo',
      desc: '',
      args: [],
    );
  }

  /// `为我书写一份正式规范的会议纪要`
  String get AskAiPage_promptMinutes {
    return Intl.message(
      '为我书写一份正式规范的会议纪要',
      name: 'AskAiPage_promptMinutes',
      desc: '',
      args: [],
    );
  }

  /// `请从文中提炼出优秀的精彩的语句`
  String get AskAiPage_promptHighlight {
    return Intl.message(
      '请从文中提炼出优秀的精彩的语句',
      name: 'AskAiPage_promptHighlight',
      desc: '',
      args: [],
    );
  }

  /// `对音频提问`
  String get AskAiPage_dialogAudio {
    return Intl.message(
      '对音频提问',
      name: 'AskAiPage_dialogAudio',
      desc: '',
      args: [],
    );
  }

  /// `通用问题`
  String get AskAiPage_dialogGeneral {
    return Intl.message(
      '通用问题',
      name: 'AskAiPage_dialogGeneral',
      desc: '',
      args: [],
    );
  }

  /// `已复制到剪贴板`
  String get PlayerPage_k42 {
    return Intl.message(
      '已复制到剪贴板',
      name: 'PlayerPage_k42',
      desc: '',
      args: [],
    );
  }

  /// `复制转写`
  String get PlayerPage_k43 {
    return Intl.message(
      '复制转写',
      name: 'PlayerPage_k43',
      desc: '',
      args: [],
    );
  }

  /// `内容为空，请完成转写和总结`
  String get PlayerPage_k44 {
    return Intl.message(
      '内容为空，请完成转写和总结',
      name: 'PlayerPage_k44',
      desc: '',
      args: [],
    );
  }

  /// `复制总结`
  String get PlayerPage_k45 {
    return Intl.message(
      '复制总结',
      name: 'PlayerPage_k45',
      desc: '',
      args: [],
    );
  }

  /// `内容为空，请完成转写和总结`
  String get PlayerPage_k46 {
    return Intl.message(
      '内容为空，请完成转写和总结',
      name: 'PlayerPage_k46',
      desc: '',
      args: [],
    );
  }

  /// `分享内容`
  String get PlayerPage_k47 {
    return Intl.message(
      '分享内容',
      name: 'PlayerPage_k47',
      desc: '',
      args: [],
    );
  }

  /// `更多`
  String get PlayerPage_k48 {
    return Intl.message(
      '更多',
      name: 'PlayerPage_k48',
      desc: '',
      args: [],
    );
  }

  /// `第 {pageNumber} 页，共 {pagesCount} 页`
  String PlayerPage_k49(Object pageNumber, Object pagesCount) {
    return Intl.message(
      '第 $pageNumber 页，共 $pagesCount 页',
      name: 'PlayerPage_k49',
      desc: '',
      args: [pageNumber, pagesCount],
    );
  }

  /// `网络连接超时`
  String get DioClient_network_timeout {
    return Intl.message(
      '网络连接超时',
      name: 'DioClient_network_timeout',
      desc: '',
      args: [],
    );
  }

  /// `接收数据超时`
  String get DioClient_receive_timeout {
    return Intl.message(
      '接收数据超时',
      name: 'DioClient_receive_timeout',
      desc: '',
      args: [],
    );
  }

  /// `网络连接异常，请稍后重试`
  String get DioClient_network_error {
    return Intl.message(
      '网络连接异常，请稍后重试',
      name: 'DioClient_network_error',
      desc: '',
      args: [],
    );
  }

  /// `未知错误`
  String get DioClient_unknown_error {
    return Intl.message(
      '未知错误',
      name: 'DioClient_unknown_error',
      desc: '',
      args: [],
    );
  }

  /// `录音笔`
  String get RecordSourceEnum_pen {
    return Intl.message(
      '录音笔',
      name: 'RecordSourceEnum_pen',
      desc: '',
      args: [],
    );
  }

  /// `导入`
  String get RecordSourceEnum_import {
    return Intl.message(
      '导入',
      name: 'RecordSourceEnum_import',
      desc: '',
      args: [],
    );
  }

  /// `账号与安全`
  String get ProfilePage_k21 {
    return Intl.message(
      '账号与安全',
      name: 'ProfilePage_k21',
      desc: '',
      args: [],
    );
  }

  /// `账号与安全`
  String get AccountSecurityPage_k1 {
    return Intl.message(
      '账号与安全',
      name: 'AccountSecurityPage_k1',
      desc: '',
      args: [],
    );
  }

  /// `删除账号`
  String get AccountSecurityPage_k2 {
    return Intl.message(
      '删除账号',
      name: 'AccountSecurityPage_k2',
      desc: '',
      args: [],
    );
  }

  /// `确认删除账号`
  String get AccountSecurityPage_k3 {
    return Intl.message(
      '确认删除账号',
      name: 'AccountSecurityPage_k3',
      desc: '',
      args: [],
    );
  }

  /// `删除账号后，您的所有数据将被清除且无法恢复。确定要继续吗？`
  String get AccountSecurityPage_k4 {
    return Intl.message(
      '删除账号后，您的所有数据将被清除且无法恢复。确定要继续吗？',
      name: 'AccountSecurityPage_k4',
      desc: '',
      args: [],
    );
  }

  /// `取消`
  String get AccountSecurityPage_k5 {
    return Intl.message(
      '取消',
      name: 'AccountSecurityPage_k5',
      desc: '',
      args: [],
    );
  }

  /// `确认删除`
  String get AccountSecurityPage_k6 {
    return Intl.message(
      '确认删除',
      name: 'AccountSecurityPage_k6',
      desc: '',
      args: [],
    );
  }

  /// `删除账号失败，请稍后重试`
  String get AccountSecurityPage_k7 {
    return Intl.message(
      '删除账号失败，请稍后重试',
      name: 'AccountSecurityPage_k7',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'zh'),
      Locale.fromSubtags(languageCode: 'ar'),
      Locale.fromSubtags(languageCode: 'de'),
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'es'),
      Locale.fromSubtags(languageCode: 'fil'),
      Locale.fromSubtags(languageCode: 'fr'),
      Locale.fromSubtags(languageCode: 'hi'),
      Locale.fromSubtags(languageCode: 'id'),
      Locale.fromSubtags(languageCode: 'ja'),
      Locale.fromSubtags(languageCode: 'ko'),
      Locale.fromSubtags(languageCode: 'ms'),
      Locale.fromSubtags(languageCode: 'pt'),
      Locale.fromSubtags(languageCode: 'th'),
      Locale.fromSubtags(languageCode: 'tr'),
      Locale.fromSubtags(languageCode: 'vi'),
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'TW'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
