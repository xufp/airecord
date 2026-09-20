import 'dart:convert';
import 'dart:io';

import 'package:airecordapp/constant/ErrConstants.dart';
import 'package:airecordapp/service/DioService.dart';
import 'package:airecordapp/service/request/GetAsrEngineModelsRequest.dart';
import 'package:airecordapp/service/request/GetHelpManualsRequest.dart';
import 'package:airecordapp/service/request/GetPrivacyPolicyRequest.dart';
import 'package:airecordapp/service/request/GetPromptTemplatesRequest.dart';
import 'package:airecordapp/service/request/GetUserAgreementRequest.dart';
import 'package:airecordapp/service/response/GetAsrEngineModelsResponse.dart';
import 'package:airecordapp/service/response/GetHelpManualsResponse.dart';
import 'package:airecordapp/service/response/GetPrivacyPolicyResponse.dart';
import 'package:airecordapp/service/response/GetPromptTemplatesResponse.dart';
import 'package:airecordapp/service/response/GetUserAgreementResponse.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

// 加载配置信息
class LoadConfigLogic {

  final Logger log = Logger();

  BuildContext? _buildContext;

  LoadConfigLogic(BuildContext context) {
    this._buildContext = context;
  }

  // 获取系统首选语言（格式：'zh-CN'）
  String getSystemLanguage()  {
    return Localizations.localeOf(_buildContext!).languageCode;
  }

  // 获取登录token信息
  Future<bool> loadConfig() async {
    saveUserAgreement();
    savePrivacyPolicy();
    saveHelpManuals();
    return true;
  }


  // 保存用户协议
  Future<GetUserAgreementResponse> saveUserAgreement() async{
    Directory tempDir = await getApplicationDocumentsDirectory();
    //获取用户协议
    String _lang = getSystemLanguage();
    GetUserAgreementResponse userAgreementResponse = await DioService.getUserAgreement(GetUserAgreementRequest(lang:_lang));
    if (userAgreementResponse.code == ErrConstants.SUCCESS_CODE && userAgreementResponse.content != null && userAgreementResponse.content != '')    {
      String userAgreement = '${tempDir.path}/user_agreement_' + _lang + '.json';
      log.i(userAgreement);
      File userAgreementFile = File(userAgreement);
      await userAgreementFile.writeAsString(jsonEncode(userAgreementResponse.toJson()));
    }
    return userAgreementResponse;
  }

  // 保存隐私协议
  Future<GetPrivacyPolicyResponse> savePrivacyPolicy() async{
    Directory tempDir = await getApplicationDocumentsDirectory();
    //获取隐私协议
    String _lang = getSystemLanguage();
    GetPrivacyPolicyResponse privacyPolicyResponse = await DioService.getPrivacyPolicy(GetPrivacyPolicyRequest(lang: _lang));
    if (privacyPolicyResponse.code == ErrConstants.SUCCESS_CODE && privacyPolicyResponse.content != null && privacyPolicyResponse.content != '')   {
      String privacyPolicy = '${tempDir.path}/privacy_policy_' + _lang + '.json';
      File privacyPolicyFile = File(privacyPolicy);
      await privacyPolicyFile.writeAsString(jsonEncode(privacyPolicyResponse.toJson()));
    }
    return privacyPolicyResponse;
  }

  // 保存帮助手册
  Future<GetHelpManualsResponse> saveHelpManuals() async{
    Directory tempDir = await getApplicationDocumentsDirectory();
    //获取帮助手册
    String _lang = getSystemLanguage();
    GetHelpManualsResponse helpManualsResponse = await DioService.getHelpManuals(GetHelpManualsRequest(lang: _lang));
    if (helpManualsResponse.code == ErrConstants.SUCCESS_CODE && helpManualsResponse.data != null && helpManualsResponse.data!.length > 0)        {
      String helpManuals = '${tempDir.path}/help_manuals_' + _lang + '.json';
      File helpManualsFile = File(helpManuals);
      await helpManualsFile.writeAsString(jsonEncode(helpManualsResponse.toJson()));
    }
    return helpManualsResponse;
  }

  /**
   * 获取用户协议
   */
  Future<GetUserAgreementResponse> getUserAgreement() async {
    Directory tempDir = await getApplicationDocumentsDirectory();
    String _lang = getSystemLanguage();
    String userAgreement = '${tempDir.path}/user_agreement_' + _lang + '.json';
    File userAgreementFile = File(userAgreement);
    bool isExist = await userAgreementFile.exists();
    GetUserAgreementResponse userAgreementResponse = GetUserAgreementResponse(code: ErrConstants.SUCCESS_CODE, msg: ErrConstants.SUCCESS_MSG);
    if (isExist) {
      DateTime dateTime = await userAgreementFile.lastModified();
      DateTime yesterday = DateTime.now().subtract(Duration(days: 1));
      if (dateTime.isBefore(yesterday)) {
        isExist = false;
      }
    }
    if (!isExist) {
      //文件不存在就请求网络并保存到本地
      userAgreementResponse = await saveUserAgreement();
    } else {
      //文件存在就直接读本地，不存在就请求网络
      String userAgreementStr = await userAgreementFile.readAsString();
      userAgreementResponse = GetUserAgreementResponse.fromJson(jsonDecode(userAgreementStr));
    }
    return userAgreementResponse;
  }

  // 获取隐私协议
  Future<GetPrivacyPolicyResponse> getPrivacyPolicy() async {
    Directory tempDir = await getApplicationDocumentsDirectory();
    String _lang = getSystemLanguage();
    String privacyPolicy = '${tempDir.path}/privacy_policy_' + _lang + '.json';
    File privacyPolicyFile = File(privacyPolicy);
    bool isExist = await privacyPolicyFile.exists();
    GetPrivacyPolicyResponse privacyPolicyResponse = GetPrivacyPolicyResponse(code: ErrConstants.SUCCESS_CODE, msg: ErrConstants.SUCCESS_MSG);
    if (isExist) {
      DateTime dateTime = await privacyPolicyFile.lastModified();
      DateTime yesterday = DateTime.now().subtract(Duration(days: 1));
      if (dateTime.isBefore(yesterday)) {
        isExist = false;
      }
    }
    if (!isExist) {
      privacyPolicyResponse = await savePrivacyPolicy();
    } else {
      String privacyPolicyStr = await privacyPolicyFile.readAsString();
      privacyPolicyResponse = GetPrivacyPolicyResponse.fromJson(jsonDecode(privacyPolicyStr));
    }
    return privacyPolicyResponse;
  }

  // 获取帮助手册
  Future<GetHelpManualsResponse> getHelpManuals() async {
    Directory tempDir = await getApplicationDocumentsDirectory();
    String _lang = getSystemLanguage();
    String helpManuals = '${tempDir.path}/help_manuals_' + _lang + '.json';
    File helpManualsFile = File(helpManuals);
    bool isExist = await helpManualsFile.exists();
    GetHelpManualsResponse helpManualsResponse = GetHelpManualsResponse(code: ErrConstants.SUCCESS_CODE, msg: ErrConstants.SUCCESS_MSG);
    if (isExist) {
      DateTime dateTime = await helpManualsFile.lastModified();
      DateTime yesterday = DateTime.now().subtract(Duration(days: 1));
      if (dateTime.isBefore(yesterday)) {
        isExist = false;
      }
    }
    if (!isExist) {
      //文件不存在就请求网络并保存到本地
      helpManualsResponse = await saveHelpManuals();
    } else {
      String helpManualsStr = await helpManualsFile.readAsString();
      helpManualsResponse = GetHelpManualsResponse.fromJson(jsonDecode(helpManualsStr));
    }
    return helpManualsResponse;
  }

  // 保存转写引擎模型列表
  Future<GetAsrEngineModelsResponse> saveAsrEngineModels() async {
    Directory tempDir = await getApplicationDocumentsDirectory();
    String _lang = getSystemLanguage();
    GetAsrEngineModelsResponse response = await DioService.getAsrEngineModels(GetAsrEngineModelsRequest(lang: _lang));
    if (response.code == ErrConstants.SUCCESS_CODE && response.data != null && response.data!.length > 0) {
      String filePath = '${tempDir.path}/asr_engine_models_' + _lang + '.json';
      File file = File(filePath);
      await file.writeAsString(jsonEncode(response.toJson()));
    }
    return response;
  }

  // 获取转写引擎模型列表
  Future<GetAsrEngineModelsResponse> getAsrEngineModels() async {
    Directory tempDir = await getApplicationDocumentsDirectory();
    String _lang = getSystemLanguage();
    String filePath = '${tempDir.path}/asr_engine_models_' + _lang + '.json';
    File file = File(filePath);
    bool isExist = await file.exists();
    GetAsrEngineModelsResponse response = GetAsrEngineModelsResponse(code: ErrConstants.SUCCESS_CODE, msg: ErrConstants.SUCCESS_MSG);
    if (isExist) {
      DateTime dateTime = await file.lastModified();
      DateTime yesterday = DateTime.now().subtract(Duration(days: 1));
      if (dateTime.isBefore(yesterday)) {
        isExist = false;
      }
    }
    if (!isExist) {
      //文件不存在就请求网络并保存到本地
      response = await saveAsrEngineModels();
    } else {
      String fileStr = await file.readAsString();
      response = GetAsrEngineModelsResponse.fromJson(jsonDecode(fileStr));
    }
    print('asrengine response:' + response.toString());
    return response;
  }

  // 保存总结模板
  Future<GetPromptTemplatesResponse> savePromptTemplates() async {
    Directory tempDir = await getApplicationDocumentsDirectory();
    String _lang = getSystemLanguage();
    GetPromptTemplatesResponse response = await DioService.getPromptTemplates(GetPromptTemplatesRequest(lang: _lang));
    if (response.code == ErrConstants.SUCCESS_CODE && response.data != null && response.data!.length > 0) {
      String filePath = '${tempDir.path}/prompt_templates_' + _lang + '.json';
      File file = File(filePath);
      await file.writeAsString(jsonEncode(response.toJson()));
    }
    return response;
  }

  // 获取总结模板
  Future<GetPromptTemplatesResponse> getPromptTemplates() async {
    Directory tempDir = await getApplicationDocumentsDirectory();
    String _lang = getSystemLanguage();
    String filePath = '${tempDir.path}/prompt_templates_' + _lang + '.json';
    File file = File(filePath);
    bool isExist = await file.exists();
    GetPromptTemplatesResponse response = GetPromptTemplatesResponse(code: ErrConstants.SUCCESS_CODE, msg: ErrConstants.SUCCESS_MSG);
    if (isExist) {
      DateTime dateTime = await file.lastModified();
      DateTime yesterday = DateTime.now().subtract(Duration(days: 1));
      if (dateTime.isBefore(yesterday)) {
        isExist = false;
      }
    }
    if (!isExist) {
      //文件不存在就请求网络并保存到本地
      response = await savePromptTemplates();
    } else {
      String fileStr = await file.readAsString();
      response = GetPromptTemplatesResponse.fromJson(jsonDecode(fileStr));
    }
    return response;
  }
}
