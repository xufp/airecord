import 'dart:convert';
import 'dart:io';

import 'package:airecordapp/constant/CommonConstants.dart';
import 'package:airecordapp/enum/EngineTypeEnum.dart';
import 'package:airecordapp/util/LogUtil.dart';
import '../../service/request/MediaConvertStatusRequest.dart';
import '../../service/request/MediaUploadAckRequest.dart';
import '../../service/response/MediaConvertStatusResponse.dart';
import '../../service/response/MediaUploadAckResponse.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos_transfer_manger.dart';
import 'package:tencentcloud_cos_sdk_plugin/fetch_credentials.dart';
import 'package:tencentcloud_cos_sdk_plugin/pigeon.dart';
import 'package:tencentcloud_cos_sdk_plugin/transfer_task.dart';

import '../service/DioService.dart';
import '../constant/ErrConstants.dart';
import '../db/entity/Recording.dart';
import '../enum/MediaStateEnum.dart';
import '../../service/request/MediaUploadCredentialRequest.dart';
import '../../service/response/MediaConvertResponse.dart';
import '../../service/response/MediaUploadCredentialResponse.dart';
import '../service/RecordingService.dart';
import '../util/CommonUtil.dart';
import '../util/DateUtil.dart';
import 'RadioLogic.dart';

class MediaTransfer {
  final Recording _recording;

  final String enginType;

  RecordingService recordingService = RecordingService();
  RadioLogic radioLogic = RadioLogic();

  MediaTransfer(this._recording, this.enginType);

  int? mediaId;
  Function(int, String, String, int)? _transferCallback;

  Future<void> _uploadedCallback(
      int code, String msg, int uploadMediaId) async {
    if (code != ErrConstants.SUCCESS_CODE) {
      print("上传失败：$code,$msg");
      return;
    }
    mediaId = uploadMediaId;
    // 执行转写
    _execTransfer(mediaId!, transferCallback: _transferCallback);
  }

  /**
   * 执行转写
   */
  Future<void> _execTransfer(int mediaId,
      {dynamic Function(int, String, String, int)? transferCallback}) async {
    //todo：语言由前端传入
    MediaConvertResponse response = await radioLogic.mediaConvert(
        mediaId: mediaId, engineType: enginType);
    if (response.code != ErrConstants.SUCCESS_CODE) {
      print("转写失败：$response");
      return;
    }
    int i = 0;
    int startTime = DateTime.now().millisecondsSinceEpoch;
    //如果150次都没拉到转写结果，则提示用户
    while (i < 150) {
      MediaConvertStatusRequest request =
          MediaConvertStatusRequest(mediaId: mediaId, detail: true);
      MediaConvertStatusResponse response =
          await DioService.mediaConvertStatus(request);
      if (response.code != ErrConstants.SUCCESS_CODE) {
        print("拉取转写结果失败：$response");
        return;
      }
      // 结果正常
      if (response.state == 2) {
        int endTime = DateTime.now().millisecondsSinceEpoch;
        print("转写耗时：${endTime - startTime}");
        var transText = json.encode(response.sentenceDetailList);
        // 更新转写文案到数据库
        recordingService.updateTransText(
            _recording.id!, MediaStateEnum.TRANSLATED.state, transText);

        if (transferCallback != null) {
          transferCallback(
              ErrConstants.SUCCESS_CODE, "success", transText, mediaId);
          return;
        }
        break;
      }
      await Future.delayed(const Duration(seconds: 2));
      i++;
    }
    // 超过300次，打印日志
    print("pull convert result more then 5 minutes");
  }

  Future<int> mediaUpload({
    dynamic Function(int, String, String, int)? transferCallback,
  }) async {
    _transferCallback = transferCallback;
    // 未上传，执行上传
    return await CosMediaFile(_recording).uploadFile(
      uploadedCallback: _uploadedCallback,
    );
  }

  Future<void> mediaTransfer({
    dynamic Function(int, String, String, int)? transferCallback,
  }) async {
    if (_recording.isUpload == MediaStateEnum.TRANSLATED.state) {
      // 执行转写
      _execTransfer(mediaId!, transferCallback: _transferCallback);
    } else {
      // 提示文件没有上传，先执行文件上传操作
    }
  }
}

class FetchCredentials implements IFetchCredentials {
  @override
  Future<SessionQCloudCredentials> fetchSessionCredentials() async {
    // 从内存获取临时秘钥
    final prefs = await SharedPreferences.getInstance();
    String? credentialjson = prefs.getString("credential");
    Credential credential =
        Credential.fromJson(json.decode(credentialjson ?? "{}"));

    try {
      // 最后返回临时密钥信息对象
      return SessionQCloudCredentials(
        secretId: credential.tmpSecretId, // 临时密钥 SecretId
        secretKey: credential.tmpSecretKey, // 临时密钥 SecretKey
        token: credential.sessionToken, // 临时密钥 Token
        startTime: credential.startTime, //临时密钥有效起始时间，单位是秒
        expiredTime: credential.expiredTime, //临时密钥有效截止时间戳，单位是秒
      );
    } catch (e) {
      throw ArgumentError();
    }
  }
}

class CosMediaFile {
  final Recording _recording;
  RecordingService recordingService = RecordingService();
  final logger = LogUtil.inItLog();

  CosMediaFile(this._recording);

  int uploadStartTime = 0;
  int uploadEndTime = 0;

  Future<int> uploadFile({
    dynamic Function(int, String, int)? uploadedCallback,
  }) async {
    // 使用 split 分割字符串
    List<String> parts = _recording.filePath.split('.');
    String fileFormat = parts.isNotEmpty ? parts.last : '';

    File file = File(_recording.filePath);
    int fileSize = 1;
    String fileSign = "";
    try {
      // 计算文件的 SHA256
      fileSign = await CommonUtil.calculateSHA256(file);
      fileSize = await file.length();
    } catch (e) {
      logger.e('获取文件信息失败: $e');
    }

    MediaUploadCredentialRequest request = MediaUploadCredentialRequest(
        mediaName: _recording.mediaName,
        fileFormat: fileFormat,
        fileSize: fileSize,
        recordTime: DateUtil.formatMillisecondToStd(_recording.createdAt),
        duration: Duration(seconds: _recording.timeLong).inMilliseconds,
        fileSign: fileSign,
        recordAddress: _recording.address ?? '',
        deviceId: _recording.deviceId ?? '');
    //返回上传的状态
    MediaUploadCredentialResponse response =
        await DioService.mediaUploadCredential(request);

    // 调用获取音频上传秘钥失败
    if (response.code != ErrConstants.SUCCESS_CODE &&
        response.code != ErrConstants.REPEAT_UPLOAD_CODE) {
      return response.code;
    }

    // 保存临时秘钥到内存
    String credentialJson = json.encode(response.credential);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('credential', credentialJson);

    // 更新media_id
    int uploadMediaId = response.mediaId ?? 0;
    recordingService.updateMediaId(_recording.id ?? 1, uploadMediaId);
    // 重复上传场景，直接返回成功
    if (response.state != 0) {
      //代表重复上传，直接返回成功
      if (uploadedCallback != null) {
        uploadedCallback(ErrConstants.SUCCESS_CODE, "success", uploadMediaId);
      }
      return ErrConstants.SUCCESS_CODE;
    }

    // cos秘钥初始化
    Cos().initWithSessionCredential(FetchCredentials());

    // 存储桶所在地域简称，例如广州地区是 ap-guangzhou
    // 创建 CosXmlServiceConfig 对象，根据需要修改默认的配置参数
    CosXmlServiceConfig serviceConfig = CosXmlServiceConfig(
      region: response.credential!.region,
      isDebuggable: true,
      isHttps: true,
    );
    // 创建 TransferConfig 对象，根据需要修改默认的配置参数
    // TransferConfig 可以设置智能分块阈值 默认对大于或等于10M的文件自动进行分块上传，可以通过如下代码修改分块阈值
    TransferConfig transferConfig = TransferConfig(
      forceSimpleUpload: false,
      enableVerification: true,
      divisionForUpload: 10485760, // 设置大于等于 10M 的文件进行分块上传
      sliceSizeForUpload: 2097152, //设置默认分块大小为 2M
    );
    // 注册默认 COS TransferManger
    await Cos().registerDefaultTransferManger(serviceConfig, transferConfig);

    // 获取 TransferManager
    CosTransferManger transferManager = Cos().getDefaultTransferManger();
    //CosTransferManger transferManager = Cos().getTransferManger("newRegion");
    // 存储桶名称，由 bucketname-appid 组成，appid 必须填入，可以在 COS 控制台查看存储桶名称。 https://console.cloud.tencent.com/cos5/bucket
    String bucket = response.credential!.bucket;
    String cosPath = response.credential!.objectName; //对象在存储桶中的位置标识符，即称对象键
    String srcPath = _recording.filePath; //本地文件的绝对路径
    //若存在初始化分块上传的 UploadId，则赋值对应的 uploadId 值用于续传；否则，赋值 null
    String? _uploadId;

    // 上传成功回调
    successCallBack(Map<String?, String?>? header, CosXmlResult? result) async {
      print("--------上传成功： $result");
      uploadEndTime = DateTime.now().millisecondsSinceEpoch;
      print("--------上传耗时： ${uploadEndTime - uploadStartTime}");
      // todo 上传成功后的逻辑
      // 上传完成，强制秘钥失效
      Cos().forceInvalidationCredential();

      // 文件上传完成确认
      MediaUploadAckRequest request = MediaUploadAckRequest(uploadMediaId);
      MediaUploadAckResponse response =
          await DioService.mediaUploadAck(request);
      if (response.code == ErrConstants.SUCCESS_CODE) {
        //状态确认成功，更新上传状态
        recordingService.updateUploadStatus(
            _recording.id ?? 1, CommonConstants.UPLOADED);
        if (uploadedCallback != null) {
          uploadedCallback(ErrConstants.SUCCESS_CODE, "success", uploadMediaId);
        }
      } else {
        //状态确认失败，或状态不明;
        print("--------上传失败： $response");
        //if (uploadedCallback != null) {
        //  uploadedCallback(response.code, response.msg, 0);
        //}
        return;
      }
    }

    //上传失败回调
    failCallBack(clientException, serviceException) {
      // todo 上传失败后的逻辑
      if (clientException != null) {}
      if (serviceException != null) {}

      // 上传失败，强制秘钥失效
      Cos().forceInvalidationCredential();
      if (uploadedCallback != null) {
        uploadedCallback(ErrConstants.ERR_CODE, "upload error", uploadMediaId);
      }
    }

    //上传状态回调, 可以查看任务过程
    stateCallback(state) {
      // todo notify transfer state
      print("--------上传状态： $state");
    }

    //上传进度回调
    progressCallBack(complete, target) {
      // todo Do something to update progress...
      logger.d(
          "--------上传进度： ${NumberFormat('0.00').format(complete / target * 100)}%");
    }

    //初始化分块完成回调
    initMultipleUploadCallback(String bucket, String cosKey, String uploadId) {
      //用于下次续传上传的 uploadId
      print("--------初始化分块上传成功，uploadId: $uploadId");
      _uploadId = uploadId;
    }

    uploadStartTime = DateTime.now().millisecondsSinceEpoch;
    //开始上传
    TransferTask transferTask = await transferManager.upload(bucket, cosPath,
        filePath: srcPath,
        uploadId: _uploadId,
        resultListener: ResultListener(successCallBack, failCallBack),
        stateCallback: stateCallback,
        progressCallBack: progressCallBack,
        initMultipleUploadCallback: initMultipleUploadCallback);

    //暂停任务
    //transferTask.pause();
    //恢复任务
    //transferTask.resume();
    //取消任务
    //transferTask.cancel();

    return ErrConstants.SUCCESS_CODE;
  }
}
