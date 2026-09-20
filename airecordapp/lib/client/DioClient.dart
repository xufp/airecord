import 'dart:convert';
import 'dart:io';

import 'package:airecordapp/config/RoutesConfig.dart';
import 'package:airecordapp/db/Cache.dart';
import 'package:airecordapp/page/login/EmailLoginPage.dart';
import 'package:airecordapp/util/CommonUtil.dart';
import 'package:airecordapp/util/LogUtil.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as GetCtr;

import '../../constant/ErrConstants.dart';
import '../service/request/BaseRequest.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DioClient {
  final Dio _dio = Dio();
  final String _baseUrl = RoutesConfig.BASE_URL;
  final logger = LogUtil.inItLog();

  DioClient({bool isAuth = true}) {
    // 设置连接和接收超时（全局默认；单次请求可通过 receiveTimeout 参数覆盖）
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest:
          (RequestOptions options, RequestInterceptorHandler handler) async {
        // 配置HttpClientAdapter来忽略SSL证书验证
        (_dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
            (client) {
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
        };
        // 登录token
        if (isAuth) {
          options.headers["Authorization"] = await Cache.authToken;
        }
        // 继续请求
        handler.next(options);
      },
      onResponse:
          (Response response, ResponseInterceptorHandler handler) async {
        // 在这里可以处理响应的数据
        handler.next(response);
      },
      onError: (DioException error, ErrorInterceptorHandler handler) async {
        // 在这里处理错误响应，比如403跳转到登录页
        if (error.response?.statusCode == 403 || error.response?.statusCode == 401) {
          // 在这里处理跳转到登录页的逻辑
          GetCtr.Get.to(EmailLoginPage());
        }
        handler.next(error);
        return Future.value(
            {"code": ErrConstants.ERR_CODE, "msg": ErrConstants.ERR_MSG});
      },
    ));
  }

  Future<Map<String, dynamic>> get(
      {required String route,
      BaseRequest? req,
      bool isAuth = true,
      Duration? receiveTimeout}) async {
    final options = Options(method: 'GET', receiveTimeout: receiveTimeout);
    String url = _baseUrl + route;
    var jsonReq = req?.toJson();
    logger.d("打印入参数:$jsonReq，请求url:$url");
    var response = null;
    try {
      response =
          await _dio.get(url, queryParameters: jsonReq, options: options);
    } catch (e) {
      logger.e('Error:$e');
      if (e is DioException) {
        DioException dioError = e;
        if (dioError.type == DioExceptionType.connectionTimeout) {
          showToast('网络连接超时');
        } else if (dioError.type == DioExceptionType.receiveTimeout) {
          showToast('接收数据超时');
        } else if (dioError.type == DioExceptionType.connectionError || dioError.type == DioExceptionType.connectionTimeout) {
          showToast('网络连接异常，请稍后重试');
        }
        if (dioError.response?.data != null && dioError.response?.data != '') {
          response = dioError.response;
        } else {
          throw e;
        }
      } else {
        showToast('未知错误');
        throw e;
      }
    }
    logger.d("打印响应结果:$response");
    if (response == null) {
      return Future.value(
          {"code": ErrConstants.SUCCESS_CODE, "msg": ErrConstants.SUCCESS_MSG});
    } else {
      return response.data ??
          Future.value({
            "code": ErrConstants.SUCCESS_CODE,
            "msg": ErrConstants.SUCCESS_MSG
          });
    }
  }

  Future<Map<String, dynamic>> jsonPost(
      {required String route,
      BaseRequest? req,
      Duration? receiveTimeout}) async {
    final options = Options(method: 'POST', receiveTimeout: receiveTimeout);
    options.headers?["Content-Type"] = 'application/json';
    String url = _baseUrl + route;
    var jsonReq = req?.toJson() ?? {};
    logger.d("打印入参数:$jsonReq，请求url:$url");
    var response = null;
    try {
      response = await _dio.request(url, data: jsonReq, options: options);
    } catch (e) {
      logger.e('Error:$e');
      if (e is DioException) {
        DioException dioError = e;
        logger.e('Error:$e');
        if (e is DioException) {
          DioException dioError = e;
          if (dioError.type == DioExceptionType.connectionTimeout) {
            showToast('网络连接超时');
          } else if (dioError.type == DioExceptionType.receiveTimeout) {
            showToast('接收数据超时');
          } else if (dioError.type == DioExceptionType.connectionError || dioError.type == DioExceptionType.connectionTimeout) {
            showToast('网络连接异常，请稍后重试');
          }
          if (dioError.response?.data != null &&
              dioError.response?.data != '') {
            response = dioError.response;
          } else {
            throw e;
          }
        } else {
          showToast('未知错误');
          throw e;
        }
        if (dioError.response?.data != null && dioError.response?.data != '') {
          response = dioError.response;
        } else {
          throw e;
        }
      } else {
        throw e;
      }
    }
    logger.d("打印响应结果:$response");
    if (response == null) {
      return Future.value(
          {"code": ErrConstants.SUCCESS_CODE, "msg": ErrConstants.SUCCESS_MSG});
    } else {
      return response.data ??
          Future.value({
            "code": ErrConstants.SUCCESS_CODE,
            "msg": ErrConstants.SUCCESS_MSG
          });
    }
  }

  // 上传文件操作
  Future<Map<String, dynamic>> uploadFile(
      {required String filePath,
      required String fileName,
      required String route,
      BaseRequest? req}) async {
    File file = File(filePath);
    // 计算文件的 SHA256
    String fileSHA256 = await CommonUtil.calculateSHA256(file);
    // 计算文件的SHA256哈希值
    //String fileSHA256 = await calculateSHA256(file);
    Map<String, dynamic> map = {'file_sign': fileSHA256};
    var jsonReq = req?.toJson();
    map.addAll(jsonReq!);
    logger.d("打印入参数:$map");

    FormData formData = FormData.fromMap({
      'meta': jsonEncode(map),
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    String uploadUrl = _baseUrl + route;
    logger.d("打印请求连接:$uploadUrl");
    Response response = await _dio.post(uploadUrl, data: formData);
    if (response.statusCode == 200) {
      logger.d('文件上传成功');
      logger.d('响应数据: ${response.data}');
    } else {
      logger.d('文件上传失败: ${response.statusMessage}');
    }
    return response.data ??
        Future.value({
          "code": ErrConstants.SUCCESS_CODE,
          "msg": ErrConstants.SUCCESS_MSG
        });
  }

  void showToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
