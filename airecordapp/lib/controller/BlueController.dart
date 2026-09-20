import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:airecordapp/command/data/FileAudio.dart';
import 'package:airecordapp/constant/CommonConstants.dart';
import 'package:airecordapp/constant/ErrConstants.dart';
import 'package:airecordapp/controller/RecordingController.dart';
import 'package:airecordapp/db/Cache.dart';
import 'package:airecordapp/db/entity/Recording.dart';
import 'package:airecordapp/enum/EngineTypeEnum.dart';
import 'package:airecordapp/enum/ImportStateEnum.dart';
import 'package:airecordapp/enum/MediaStateEnum.dart';
import 'package:airecordapp/enum/RecordSourceEnum.dart';
import 'package:airecordapp/enum/SliceTypeEnum.dart';
import 'package:airecordapp/l10n/generated/l10n.dart';
import 'package:airecordapp/logic/MediaTransferLogic.dart';
import 'package:airecordapp/logic/RadioLogic.dart';
import 'package:airecordapp/page/HomePage.dart';
import 'package:airecordapp/service/BlueService.dart';
import 'package:airecordapp/service/RecordingService.dart';
import 'package:airecordapp/service/WebSocketService.dart';
import 'package:airecordapp/service/handler/PCMToWavHandler.dart';
import 'package:airecordapp/service/response/MediaConvertStatusResponse.dart';
import 'package:airecordapp/service/response/MediaResponse.dart';
import 'package:airecordapp/util/AudioUtil.dart';
import 'package:airecordapp/util/CommonUtil.dart';
import 'package:airecordapp/util/LogUtil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get.dart';

class BlueController extends GetxController {
  final logger = LogUtil.inItLog();
  final RecordingController dataController = Get.find<RecordingController>();
  BlueService blueService = BlueService();
  final RecordingService recordingService = RecordingService(); // 初始化服务
  final WebSocketService webSocketService = WebSocketService(); // websocket服务
  final RadioLogic radioLogic = RadioLogic();
  final pcmToWavHandler = PCMToWavHandler(
      sampleRate: CommonConstants.OPUS_SAMPLE_RATE,
      channels: CommonConstants.OPUS_CHANNELS);
  late StreamSubscription<List<ScanResult>>
      _scanResultsSubscription; // 扫描设备监听信息
  late StreamSubscription<bool> _isScanningSubscription; // 设备扫描状态监听信息
  StreamSubscription<BluetoothConnectionState>?
      _connectionStateSubscription; // 设备连接流信息
  StreamSubscription<List<int>>? _lastBlueWriteSubscription; // 蓝牙读模块监听信息
  StreamSubscription<List<int>>? _lastBlueNotifySubscription; // 蓝牙写模块监听信息
  StreamSubscription<List<int>>?
      _lastBlueBatteryNotifySubscription; // 电池蓝牙写模块监听信息
  bool _isDeviceListenInitialized = false; // 标记是否已初始化监听
  Timer? _blueTimer; // 蓝牙扫描定时器
  Duration _bluePeriod = const Duration(seconds: 5);
  Timer? _syncMediaTimer; // 同步音频文件扫描定时器
  Duration _syncMediaPeriod = const Duration(seconds: 15);

  final int controlType = 0; // 控制指令类型
  final int tranType = 1; // 实时转写类型
  final int fileType = 2; // 文件操作类型
  final int ackType = 3; // ACK类型
  final FileAudio fileAudio = FileAudio();
  Map<String, FileInfo> _audioMap = {};
  FileInfo? inputFileInfo;
  List<FileInfo> _audioAllList = [];
  List<FileInfo> _audioList = [];
  RxList<FileInfo> audioList = <FileInfo>[].obs;
  var inputProgressMap = <String, int>{}.obs;
  BluetoothDevice? _device; // 设备信息

  var _tranFileName;
  var _recordFileName;
  var _tranFilePath;
  var _isAddTranHeader = false;
  var _isEndTran = false;
  var transIngSkText = ''.obs;
  var isTransSkErr = false.obs;
  int _socketMediaId = 0;
  bool isSyncMedia = false;

  // 扫描设备信息监听
  var scanResults = <ScanResult>[].obs; // 扫描到的蓝牙设备
  var devName = ''.obs; // 设备名称
  var isScanIng = true.obs; // 是否在扫描;
  // 设备连接信息监听
  var isConnected = false.obs; // 设备是否连接
  var isConnecting = false.obs; // 是否正在连接
  var isConnectionStateListen = false.obs; // 设备连接状态是否已监听
  // 设备服务模块信息监听
  var isDataListen = false.obs; // 是否已经成功监听蓝牙下发数据
  // 设备文件操作监听
  var importState = 0.obs; // 音频文件是否开始导入
  var importFileName = ''.obs; // 正在导入的音频文件
  var importFileSize = 0.obs; // 导入音频文件大小
  var hasImportFileSize = 0.obs; // 已导入文件大小
  var importFileSp = 0.obs; // 导入音频文件进度
  var isRecording = false.obs; // 是否开始录音
  var isPaused = false.obs; // 暂停录音
  var sentenceDetailList = <SentenceDetail>[].obs;
  RxInt lastAddedIndex = (-1).obs;
  RxInt recordingDurationMs = 0.obs;

  // 设备电量信息
  var qel = 0.obs;

  // 转写引擎
  var engineType = "";

  /**
   * 设备扫描
   */
  startScan(String uuid) {
    logger.d('开始扫描设备');
    blueService.startScan(uuid);
  }

  // 设备扫描监听
  scanListen() {
    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      scanResults.value = results;
    }, onError: (error) {
      logger.e('Scan Error:$error');
    });
    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      isScanIng.value = state;
    });
  }

  /**
   * 设备扫描停止
   */
  Future<void> stopScan() async {
    scanResults.value = [];
    FlutterBluePlus.stopScan();
  }

  /**
   * 清理设备扫描信息
   */
  clearScan() {
    if (scanResults.isNotEmpty) {
      _scanResultsSubscription.cancel();
      _isScanningSubscription.cancel();
    }
    isScanIng.value = false;
    scanResults.value = [];
  }

  /**
   * 蓝牙设备自动监听
   * 仅在有缓存设备时才启动蓝牙状态监听（避免首次启动就触发蓝牙权限弹窗）
   * 无缓存设备时，等用户主动连接设备时通过 forceDeviceListen() 触发
   */
  deviceListen() async {
    // 避免重复初始化监听
    if (_isDeviceListenInitialized) return;

    // 先检查是否有缓存的设备信息，没有则不启动蓝牙监听
    String remoteId = await _remoteId;
    if (remoteId.isEmpty) {
      return;
    }

    _isDeviceListenInitialized = true;

    // 根据蓝牙开启状态自动连接并扫描导入文件
    FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) async {
      await _autoConnectByBlueState(state);
    });
    // 定时扫描设备状态，并自动连接
    await _startTimerBlue();
  }

  /**
   * 强制启动蓝牙设备监听（用户主动连接设备后调用）
   */
  forceDeviceListen() async {
    if (_isDeviceListenInitialized) return;
    _isDeviceListenInitialized = true;

    FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) async {
      await _autoConnectByBlueState(state);
    });
    await _startTimerBlue();
  }

  Future _startTimerBlue() async {
    // 第一次连接5秒扫描连上
    _blueTimer = Timer.periodic(_bluePeriod, (timer) async {
      BluetoothAdapterState state = await FlutterBluePlus.adapterState.first;
      await _autoConnectByBlueState(state);
      _modifyTimerBlue();
    });
  }

  void _modifyTimerBlue() {
    if (_blueTimer != null) {
      _blueTimer!.cancel(); // 取消当前定时器
      _blueTimer = null;
      _bluePeriod = Duration(seconds: 30);
      _startTimerBlue(); // 用新周期重新启动定时器
    }
  }

  // 判断蓝牙设备状态自动连接设备，并启动导入音频文件监听
  Future<void> _autoConnectByBlueState(BluetoothAdapterState state) async {
    if (state == BluetoothAdapterState.on) {
      var device = await _cacheDev;
      if (device != null) {
        connectDev(device).then((value) {
          if (value) {
            initListen(device);
          }
        });
      }
    }
  }

  Future<void> cmdQuel() async {
    await blueService.qel();
  }

  /**
   * 初始化设备信息
   */
  Future<void> initListen(BluetoothDevice device) async {
    if (isConnectionStateListen.value) {
      return;
    }
    
    // 取消旧的连接状态监听（防止断连重连时产生重复订阅）
    _connectionStateSubscription?.cancel();
    _connectionStateSubscription = null;
    
    _device = device;
    _connectionStateSubscription = device.connectionState.listen((state) async {
      // 设备连接状态监听已成功
      isConnectionStateListen.value = true;
      if (state == BluetoothConnectionState.connected) {
        isConnected.value = true; // 设备已连接
        // 发现服务列表
        List<BluetoothService> services = await device.discoverServices();
        List<BluetoothCharacteristic> characteristics =
            services.expand((service) => service.characteristics).toList();
        // 初始化蓝牙模块信息
        await _initListen(characteristics);
        // 同步系统时间
        await blueService.syncTime();
        // 获取设备电量信息
        await blueService.qel();
        // 同步音频文件
        //autoImportFile();
      }
      // 设备未连接（断连处理）- 使用轻量级清理，保持定时器和连接状态监听
      if (state == BluetoothConnectionState.disconnected) {
        logger.d('设备已断连');
        isConnected.value = false;
        bool isExceptionDisconnected = _isExceptionDisconnected();

        // 轻量级清理：只重置业务状态，保留基础设施（定时器、监听）用于自动重连
        _onDisconnected();

        if (isExceptionDisconnected) {
          _disconnectedExceptionHandler();
        }
      }
    });
  }

  // 是否为异常断连
  bool _isExceptionDisconnected() {
    // 是否在录音，是否在导入文件
    return isRecording.value ||
        isPaused.value ||
        !ImportStateEnum.closeSync(importState.value);
  }

  // 设备操作中异常处理
  _disconnectedExceptionHandler() {
    // 跳转到首页
    // 提示设备断连，并跳转到首页
    // 显示Toast消息
    Fluttertoast.showToast(
      msg: S.current.BlueController_device_disconnected_jump_home,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
    Get.to(HomePage());
  }

  // 存储设备信息
  _saveDevInfo(String platformName, String remoteId, String characteristicWrite,
      String characteristicNotify, String characteristicBatteryNotify) async {
    await Cache.saveDevInfo(platformName, remoteId, characteristicWrite,
        characteristicNotify, characteristicBatteryNotify);
  }

  /**
   * 获取设备名称
   */
  Future<String> get platformName async {
    String cachePlatformName = await Cache.platformName;
    devName.value = cachePlatformName;
    return cachePlatformName;
  }

  // 获取设备ID
  Future<String> get _remoteId async {
    String cacheRemoteId = await Cache.remoteId;
    return cacheRemoteId;
  }

  // 获取缓存设备信息
  Future<BluetoothDevice?> get _cacheDev async {
    // 判断是否有设备存储设备信息
    String remoteId = await _remoteId;
    if (remoteId == '') {
      // 无设备信息
      return null;
    }
    var device = BluetoothDevice.fromId(remoteId);
    return device;
  }

  /**
   * 通过设备ID连接
   */
  Future<BluetoothDevice?> connectDevRemoteId() async {
    var device = BluetoothDevice.fromId(await _remoteId);
    bool connected = await connectDev(device);
    if (connected) {
      return device;
    }
    return null;
  }

  /**
   * 设备连接
   */
  Future<bool> connectDev(BluetoothDevice device) async {
    logger.d('发起设备连接了...');
    if (_device?.isConnected ?? false || device.isConnected) {
      logger.d('已经连接成功了...');
      // 如果设备已连接，确保连接状态正确
      if (device.isConnected) {
        isConnected.value = true;
      }
      return true;
    }
    try {
      await device.connect();
      if (device.isConnected) {
        logger.d('设备连接成功了...');
        // 立即更新连接状态，不需要等待监听回调
        isConnected.value = true;
        // 获取设备信息
        await platformName;
        // 更新设备信息到缓存，确保设备名称正确存储
        String characteristicWrite = await Cache.characteristicWrite;
        String characteristicNotify = await Cache.characteristicNotify;
        String characteristicBatteryNotify = await Cache.characteristicBatteryNotify;
        logger.d('缓存特征UUID - write: $characteristicWrite, notify: $characteristicNotify, battery: $characteristicBatteryNotify');
        
        // 优先使用设备的实际名称，如果设备名称为空，则使用缓存中的名称
        String deviceName = device.platformName;
        if (deviceName.isEmpty) {
          deviceName = await Cache.platformName;
          logger.d('设备名称为空，使用缓存中的名称: $deviceName');
        }
        
        if (characteristicWrite.isNotEmpty && characteristicNotify.isNotEmpty && characteristicBatteryNotify.isNotEmpty) {
          await _saveDevInfo(
              deviceName,
              device.remoteId.toString(),
              characteristicWrite,
              characteristicNotify,
              characteristicBatteryNotify);
          logger.d('设备信息已更新到缓存: $deviceName');
        } else {
          logger.d('缓存特征UUID不完整，无法更新设备信息');
        }
      }
    } catch (e) {
      logger.d('设备连接异常e:$e');
      return false;
    } finally {
      isConnecting.value = false;
    }
    return true;
  }

  /**
   * 手动设备连接
   */
  Future<bool> handlerConnectDev(
      BluetoothDevice device,
      String characteristicWrite,
      String characteristicNotify,
      String characteristicBatteryNotify) async {
    logger.d('开始手动连接设备');
    // 设备正在连接中
    isConnecting.value = true;
    if (_device?.isConnected ?? false) {
      isConnecting.value = false;
      // 如果设备已连接，确保连接状态正确
      isConnected.value = true;
      return true;
    }
    try {
      await device.connect(timeout: Duration(seconds: 10));
      logger.d('手动发起连接完毕');
      if (device.isConnected) {
        logger.d('手动发起连接成功');
        // 立即更新连接状态
        isConnected.value = true;
        // 存储设备信息到缓存
        // 优先使用设备的实际名称，如果设备名称为空，则使用缓存中的名称
        String deviceName = device.platformName;
        if (deviceName.isEmpty) {
          deviceName = await Cache.platformName;
          logger.d('手动连接：设备名称为空，使用缓存中的名称: $deviceName');
        }
        await _saveDevInfo(
            deviceName,
            device.remoteId.toString(),
            characteristicWrite,
            characteristicNotify,
            characteristicBatteryNotify);
        // 获取设备信息
        await platformName;
      }
    } catch (e) {
      logger.d('设备连接异常e:$e');
      return false;
    } finally {
      isConnecting.value = false;
    }
    return true;
  }

  /**
   * 设备断连
   */
  Future<void> disconnectDev(BluetoothDevice device) async {
    if (_device?.isDisconnected ?? false) {
      isConnected.value = false;
      return;
    }
    await device.disconnect();
    isConnected.value = false;
  }

  /**
   * 设备断连并删除缓存
   */
  Future<void> disconnectDevCache() async {
    // 查询设备缓存
    BluetoothDevice? dev = await _cacheDev;
    // 删除设备缓存
    if (_device?.isDisconnected ?? false) {
      isConnected.value = false;
      return;
    }
    dev?.disconnect();
    isConnected.value = false;
    await delDevCache();
    logger.d('设备缓存已删除');
    // 清理设备监听信息
    _clearConnectListen();
  }

  // 轻量级断连清理（被动断连/设备掉线时调用）
  // 只重置业务状态，保留定时器和连接状态监听用于自动重连
  void _onDisconnected() {
    logger.d('断连轻量级清理 - 保留基础设施');

    // ====== 1. 重置连接状态标记（必须重置，否则 initListen 会直接 return）======
    isConnectionStateListen.value = false;   // 关键！允许下次重新 initListen
    isDataListen.value = false;
    isConnected.value = false;

    // ====== 2. 取消数据监听订阅（不是连接状态订阅）======
    _lastBlueNotifySubscription?.cancel();
    _lastBlueNotifySubscription = null;
    _lastBlueWriteSubscription?.cancel();
    _lastBlueWriteSubscription = null;
    _lastBlueBatteryNotifySubscription?.cancel();
    _lastBlueBatteryNotifySubscription = null;

    // ====== 3. 清理 BlueService 特征缓存（下次连接时会重新发现）======
    blueService.clearServiceCache();

    // ====== 4. 清理录音/实时转写状态 ======
    clearTranSocket();
    clearTranFile();
    isRecording.value = false;
    isPaused.value = false;
    recordingDurationMs.value = 0;
    sentenceDetailList.clear();
    lastAddedIndex.value = -1;
    transIngSkText.value = '';
    isTransSkErr.value = false;
    _isEndTran = false;
    _tranFileName = null;
    _recordFileName = null;
    _tranFilePath = null;
    _socketMediaId = 0;

    // ====== 5. 清理导入文件相关状态 ======
    _clearAudioList();
    inputFileInfo = null;
    importFileName.value = '';
    importFileSize.value = 0;
    hasImportFileSize.value = 0;
    importFileSp.value = 0;

    // ====== 6. 重置电量 ======
    qel.value = 0;

    // 注意：以下内容不在此清理（保留给自动重连使用）
    // - _connectionStateSubscription (当前正在执行的回调)
    // - _blueTimer (自动重连需要)
    // - _isDeviceListenInitialized (避免重复初始化)
    // - _device (重连时需要引用)
    // - _syncMediaTimer / isSyncMedia
  }

  // 完整清理（主动断连/用户点击断开时调用）
  void _clearConnectListen() {
    logger.d('完整清理 - 主动断连');

    // ====== 1. 连接状态标记全部重置 ======
    isConnectionStateListen.value = false;   // 允许下次重新 initListen
    isDataListen.value = false;
    isConnected.value = false;
    isConnecting.value = false;

    // ====== 2. 取消所有 StreamSubscription（包括连接状态）======
    _connectionStateSubscription?.cancel();
    _connectionStateSubscription = null;

    _lastBlueNotifySubscription?.cancel();
    _lastBlueNotifySubscription = null;
    _lastBlueWriteSubscription?.cancel();
    _lastBlueWriteSubscription = null;
    _lastBlueBatteryNotifySubscription?.cancel();
    _lastBlueBatteryNotifySubscription = null;

    // ====== 3. 停止所有定时器 ======
    _blueTimer?.cancel();
    _blueTimer = null;
    _syncMediaTimer?.cancel();
    _syncMediaTimer = null;

    // ====== 4. 清空设备引用和基本信息 ======
    _device = null;
    devName.value = '';
    qel.value = 0;
    _isDeviceListenInitialized = false;     // 允许重新初始化蓝牙监听

    // ====== 5. 清理录音/实时转写状态 ======
    isRecording.value = false;
    isPaused.value = false;
    recordingDurationMs.value = 0;
    sentenceDetailList.clear();
    lastAddedIndex.value = -1;
    transIngSkText.value = '';
    isTransSkErr.value = false;

    // 转写内部变量
    _isEndTran = false;
    _isAddTranHeader = false;
    _tranFileName = null;
    _recordFileName = null;
    _tranFilePath = null;
    _socketMediaId = 0;

    // 关闭 WebSocket
    clearTranSocket();

    // ====== 6. 清理导入文件相关状态 ======
    importState.value = ImportStateEnum.STATRT_NO_AUDIO.state;
    importFileName.value = '';
    importFileSize.value = 0;
    hasImportFileSize.value = 0;
    importFileSp.value = 0;
    inputProgressMap.clear();

    // 音频列表
    _audioAllList.clear();
    _audioList.clear();
    _audioMap.clear();
    audioList.clear();
    inputFileInfo = null;

    // 同步媒体标记
    isSyncMedia = false;

    // ====== 7. 清理 BlueService 内部状态 ======
    blueService.clearServiceCache();
  }

  /**
   * 删除设备
   */
  Future<void> delDevCache() async {
    await Cache.removeDevCache();
    devName.value = '';
    scanResults.value = [];
  }

  /**
   * 初始化蓝牙模块信息
   */
  Future<void> _initListen(
      List<BluetoothCharacteristic> characteristics) async {
    // 初始化模块信息
    await blueService.initBlue(characteristics);
    if (isDataListen.value) {
      return;
    }
    // 开始发起监听
    _listenAll();
    isDataListen.value = true;
  }

  _listenAll() {
    _lastBlueWriteSubscription =
        blueService.blueWrite!.lastValueStream.listen((value) {
      if (value.isNotEmpty) {
        _listen(Uint8List.fromList(value));
      }
    });
    _lastBlueNotifySubscription =
        blueService.blueNotify!.lastValueStream.listen((value) {
      if (value.isNotEmpty) {
        _listen(Uint8List.fromList(value));
      }
    });
    _lastBlueBatteryNotifySubscription =
        blueService.blueBatteryNotify!.lastValueStream.listen((value) {
      if (value.isNotEmpty) {
        _listenBattery(Uint8List.fromList(value));
      }
    });
  }

  // 监听处理数据蓝牙逻辑
  _listen(serializedMsg) {
    // 读取设备下发监听数据
    Map<String, dynamic> listenData = blueService.listen(serializedMsg);
    int dataType = listenData['dataType'];
    int cmd = listenData['cmd'];
    Uint8List data = listenData['data'];
    // 实时音频解析
    if (dataType == tranType) {
      // 实时转写文件名
      if (cmd == 0) {
        // data不为空
        _setRecordFileName(data);
      }
      // 实时转写音频数据
      if (cmd == 1) {
        logger.d('实时转写音频监听数据');
        _handleTranAudioData(data);
      }
      // 处理转写设备停止、暂停、继续
      if (cmd == 4) {
        _handleTranDevState(data);
      }
    }
    // 读取蓝牙音频列表
    if (dataType == fileType) {
      // 获取音频列表
      if (cmd == 1) {
        _audioAllList.addAll(_getAudioList(data));
      }
      // 音频文件列表读取完毕
      if (cmd == 18) {
        _initImportFile();
      }
      // 开始导入的音频文件信息
      if (cmd == 3) {
        _setInputFileInfo(data);
      }
      // 导入的音频文件Uint8List数据
      if (cmd == 4) {
        _handleImportAudioData(data);
      }
      // 文件传输结束
      if (cmd == 5) {
        _handleImportFile(data);
      }
    }
    // // 设备操作app
    // if (dataType == ackType) {
    //   logger.d('小机器控制111111');
    //   // 开始录音
    //   if (cmd == 1) {
    //     logger.d('小机器控制......');
    //     // app正式发起录音
    //     startRecordSuccess();
    //     // data不为空
    //     if (data.length > 0) {
    //       _recordFileName = fileAudio.getFileName(data);
    //
    //     }
    //   }
    //   // 保存录音
    //   if (cmd == 3) {
    //     saveRecordSuccess();
    //   }
    //   // 暂停录音
    //   if (cmd == 5) {
    //     pauseRecordSuccess();
    //   }
    //   // 继续录音
    //   if (cmd == 7) {
    //     resumeRecordSuccess();
    //   }
    // }
  }

  // 监听电量数
  _listenBattery(serializedMsg) {
    // 读取设备下发监听数据
    Map<String, dynamic> listenData = blueService.listenBattery(serializedMsg);
    int dataType = listenData['dataType'];
    int cmd = listenData['cmd'];
    Uint8List data = listenData['data'];
    // 音频电量处理
    if (dataType == controlType) {
      if (cmd == 4) {
        ByteData byteData = data.buffer.asByteData();
        qel.value = byteData.getUint8(0);
      }
    }
    // 设备操作app
    if (dataType == ackType) {
      // 开始录音
      if (cmd == 1) {
        // app正式发起录音
        startRecordSuccess();
        // data不为空
        if (data.length > 0) {
          _recordFileName = fileAudio.getFileName(data);

        }
      }
      // 保存录音
      if (cmd == 3) {
        saveRecordSuccess();
      }
      // 暂停录音
      if (cmd == 5) {
        pauseRecordSuccess();
      }
      // 继续录音
      if (cmd == 7) {
        resumeRecordSuccess();
      }
    }
  }

  // 开始导入文件
  Future<void> autoImportFile() async {
    _clearAudioList();
    //clearTranFile();
    await blueService.scanAudioList();
  }

  // 终止导入音频文件
  Future importAudioStop() async {
    await blueService.importAudioStop();
    _clearAudioList();
  }

  // 清空需要导入的音频列表数据
  _clearAudioList() {
    // 导入状态恢复初始值
    importState.value = ImportStateEnum.STATRT_NO_AUDIO.state;
    _audioAllList.clear();
    _audioList.clear();
    _audioMap.clear();
    audioList.clear();
    inputProgressMap.clear();
  }

  // 开始实时转写
  Future<void> startTran() async {
    clearTranFile();
    // 发起实时转写
    if (!await blueService.startTran()) {
      _handlerException();
    }
    isPaused.value = false;
    isRecording.value = true;
  }

  // 设备主动暂停实时转写
  Future<void> devTranPause() async {
    isPaused.value = true;
    webSocketService.webSocketChannel?.sink.add('<PAUSE>');
  }

  // 暂停实时转写
  Future<void> tranPause() async {
    // 发起实时转写
    if (!await blueService.tranPause()) {
      _handlerException();
    }
    isPaused.value = true;
    webSocketService.webSocketChannel?.sink.add('<PAUSE>');
  }

  // 设备主动继续实时转写
  Future<void> devTranResume() async {
    isPaused.value = false;
    webSocketService.webSocketChannel?.sink.add('<RESUME>');
    // 添加音频文件头
    _addSocketHeader();
  }

  // 继续实时转写
  Future<void> tranResume() async {
    isPaused.value = false;
    // 发起实时转写
    if (!await blueService.tranResume()) {
      _handlerException();
      return;
    }
    webSocketService.webSocketChannel?.sink.add('<RESUME>');
    // 添加音频文件头
    _addSocketHeader();
  }

  // 设备结束实时转写
  Future<void> _devTranCancel() async {
    if (!isRecording.value) return; // APP停止了录音，不做处理下面逻辑
    webSocketService.webSocketChannel?.sink.add('<EOF>');
    logger.d('开始保存实时音频文件');
    // 保存实时转写音频记录
    await _saveAudioRecord();
    // 停止录音
    isRecording.value = false;
    // 停止继续录音
    isPaused.value = false;
    logger.d('实时音频开始插入数据库');
    await _insertTranFile();
    await dataController.getAllList();
    // 实时转写结束
    _isEndTran = true;
    recordingDurationMs.value = 0;
    logger.d('实时音频插入数据库结束2');
    // 录制结束后回到列表页，清空整个导航栈：
    // - 避免系统返回键回退到实时转写页（已结束、状态脏，复用会异常）
    // - 列表页作为 Tab 容器属于应用根页面，再次返回应直接退出 App
    Get.offAllNamed('/index');
  }

  // 手动发送实时转写
  Future<void> tranCancel() async {
    print("结束实时转写");
    // 发送实时转写命令
    bool cmdSuccess = await blueService.tranCancel();
    if (!cmdSuccess) {
      // 打印日志
      _handlerException();
    }
    // 兜底延迟1秒处理以下命令，正常会被dataType=1,cmd=4处理
    // 插入音频数据
    await Future.delayed(Duration(seconds: 1), () {
      print('开始存储实时音频文件');
      _devTranCancel();
    });
    // // 停止录音
    // isRecording.value = false;
    // // 停止继续录音
    // isPaused.value = false;
    // // 实时转写结束
    // _isEndTran = true;
    // recordingDurationMs.value = 0;
    //
    // webSocketService.webSocketChannel?.sink.add('<EOF>');
    // // 保存实时转写音频记录
    // await _saveAudioRecord();
  }

  // app开始录音成功
  Future<void> startRecordSuccess() async {
    logger.d('小机器控制');
    clearTranFile();
    // 进入实时转写页时使用 offNamed：把当前页（通常是列表页/设备页）替换成 /record
    // 配合 _devTranCancel() 中的 offAllNamed('/index')，可避免栈中叠多个 /record
    if (Get.currentRoute != '/record') {
      Get.offNamed('/record');
    }
    // // 发起录音成功响应命令
    // if (!await blueService.startRecordSuccess()) {
    //   _handlerException();
    // }
    // isPaused.value = false;
    // isRecording.value = true;
  }

  // app保存录音成功
  Future<void> saveRecordSuccess() async {
    // 停止录音
    // isRecording.value = false;
    // // 停止继续录音
    // isPaused.value = false;
    // // 实时转写结束
    // _isEndTran = true;
    // recordingDurationMs.value = 0;
    // 保存录音成功响应命令
    if (!await blueService.saveRecordSuccess()) {
      _handlerException();
    }
    // webSocketService.webSocketChannel?.sink.add('<EOF>');
    // 保存实时转写音频记录
    // 插入音频数据
    await Future.delayed(Duration(seconds: 1), () {
      print('小机开始存储实时音频文件');
      _devTranCancel();
    });
  }

  // 处理硬件录音暂停
  Future<void> pauseRecordSuccess() async {
    // 暂停录音成功响应命令
    if (!await blueService.pauseRecordSuccess()) {
      _handlerException();
    }
    devTranPause();
  }

  // 处理硬件录音继续
  Future<void> resumeRecordSuccess() async {
    // 继续录音成功响应命令
    if (!await blueService.resumeRecordSuccess()) {
      _handlerException();
    }
    devTranResume();
  }

  // 处理设备异常情况
  _handlerException() {
    if (!(_device?.isConnected ?? false)) {
      logger.e('设备未连接异常');
    }
  }

  // 处理实时转写音频开始websocket文件流
  Future _handleTranAudioData(Uint8List serializedMsg) async {
    if (_isEndTran) {
      return;
    }
    // 添加转写文件头信息
    await _addTranHeader();
    // 根据消息长度计算录音时长，每40长度对应20ms
    recordingDurationMs.value += (serializedMsg.length / 40).ceil() * 20;
    // 处理opus流转成pcm
    Uint8List pcmData = await pcmToWavHandler.realtimeDecodeOpus(serializedMsg);
    // 添加转写文件流
    webSocketService.webSocketChannel?.sink.add(pcmData);
  }

  // 添加实时转写文件头
  Future<void> _addTranHeader() async {
    if (_isAddTranHeader) {
      return;
    }
    // 添加文件头
    _isAddTranHeader = true;
    // 文件名
    _tranFileName = AudioUtil.fileName;
    // 文件格式
    String fileFormat = AudioUtil.fileFormat;
    // 连接webSocket
    await webSocketService
        .setMediaSpeechUrl(
            mediaName: _tranFileName,
            fileFormat: fileFormat,
            engineType: engineType)
        .initializeWebSocket();
    // 添加音频头
    _addSocketHeader();
    // 监听文案转写
    _transText();
  }

  // 添加录音音频文件头
  _addSocketHeader() {
    Uint8List firstData = AudioUtil.pcmToWav(
        pcmData: Uint8List(0),
        sampleRate: CommonConstants.OPUS_SAMPLE_RATE,
        channels: CommonConstants.OPUS_CHANNELS);
    webSocketService.webSocketChannel?.sink.add(firstData);
  }

  // 文案转写逻辑
  void _transText() {
    // 开始转写
    isTransSkErr.value = false;
    // 监听文案转写
    webSocketService.webSocketChannel?.stream.listen((message) {
      MediaResponse mediaResponse = radioLogic.media(message);
      logger.d('转写响应内容$message');
      if (mediaResponse.msg == '<RESUME>') {
        // 发起继续录音
        tranResume();
        return;
      }
      // 判断文案是否在识别中
      int type = mediaResponse.result?.sliceType ?? 0;
      String text = mediaResponse.result?.text ?? '';

      // 解析转写内容
      SentenceDetail? detail;
      if (type == SliceTypeEnum.IDENTIFY_DOING.type ||
          type == SliceTypeEnum.IDENTIFY_COMPLETED.type) {
        detail = SentenceDetail(
            index: mediaResponse.result!.index ?? sentenceDetailList.length,
            startTime: mediaResponse.result!.startTime ?? 0,
            endTime: mediaResponse.result!.endTime ?? 0,
            text: mediaResponse.result!.text ?? "",
            speakId: 0);
      }

      if (mediaResponse.code == ErrConstants.SUCCESS_SOCKET_CODE) {
        if (mediaResponse.mediaId != 0) {
          _socketMediaId = mediaResponse.mediaId ?? 0;
        }
        isTransSkErr.value = false;
        if (type == SliceTypeEnum.IDENTIFY_COMPLETED.type) {
          // 表明识别完成
          lastAddedIndex.value = sentenceDetailList.length;
          // 表明识别完成
          sentenceDetailList.add(detail!);
          transIngSkText.value = '';
        } else {
          // 表示不稳定识别结果
          transIngSkText.value = '$text...';
        }
      } else {
        // 转写失败了
        isTransSkErr.value = true;
        // 需要关闭连接
        webSocketService.webSocketChannel?.sink.add('<EOF>'); // socket结束
      }
    });
  }

  // 处理实时转写设备部状态
  Future _handleTranDevState(Uint8List content) async {
    final byteData = ByteData.sublistView(content);
    int state = byteData.getUint8(0);
    // 继续
    if (state == 0) {
      devTranResume();
    }
    // 暂停
    if (state == 1) {
      devTranPause();
    }
    // 停止
    if (state == 2) {
      _devTranCancel();
    }
  }

  // 保存实时转写音频
  Future<void> _saveAudioRecord() async {
    _tranFilePath = await AudioUtil.saveWavPath();
    pcmToWavHandler.writeToFile(_tranFilePath);
    pcmToWavHandler.clear();
    clearTranSocket();
  }

  // 插入转写音频文件
  _insertTranFile() async {
    // 获取输入音频文件名
    List<String>? parts = _recordFileName.split('.');
    String fileName = parts!.first + '.wav';
    // 录音信息入库
    await recordingService.insertTrans(
        timeLong: (recordingDurationMs.value ~/ 1000).ceil(),
        mediaName: _tranFileName,
        fileName: fileName,
        originalFileName: fileName,
        filePath: _tranFilePath,
        mediaId: _socketMediaId,
        transText: jsonEncode(sentenceDetailList),
        isTranslated: MediaStateEnum.TRANSLATED.state,
        source: RecordSourceEnum.PEN.source,
        isUpload: CommonConstants.UPLOADED);
    clearTranFile();
  }

  // 清空实时转写socket
  clearTranSocket() {
    _isAddTranHeader = false;
    if (webSocketService.webSocketChannel?.sink != null) {
      webSocketService.webSocketChannel?.sink.add('<EOF>'); // socket结束
    }
    webSocketService.closeWebSocket(); // 关闭socket连接
  }

  // 清空转写文件信息
  clearTranFile() {
    _isEndTran = false;
    transIngSkText.value = '';
    sentenceDetailList.value = [];
    _tranFilePath = null;
    _tranFileName = null;
    recordingDurationMs.value = 0;
    isPaused.value = false;
    isRecording.value = false;
  }

  // 设置文件名称
  _setRecordFileName(Uint8List data) {
    // 随机文件名称
    _recordFileName = AudioUtil.opusFileName;
    logger.d('实时转写随机音频文件名' + _recordFileName);
    if (data.length > 0) {
      _recordFileName = fileAudio.getFileName(data);
      logger.d('实时转写下发音频文件名' + _recordFileName);
    }
  }

  // 监听解析获取音频文件列表
  List<FileInfo> _getAudioList(data) {
    List<FileInfo> audioList = fileAudio.fromBytes(data);
    return audioList;
  }

  // 初始化导入音频信息
  _initImportFile() async {
    int audioAllLength = _audioAllList.length;
    if (audioAllLength > 0) {
      for (int i = 0; i < audioAllLength; i++) {
        FileInfo fileInfo = _audioAllList[i];
        // 获取输入音频文件名
        bool isHasFile = await _hasRecordByFileName(fileInfo.fileName);
        if (!isHasFile) {
          _audioList.add(fileInfo);
          audioList.add(fileInfo);
          _audioMap[fileInfo.fileName] = fileInfo;
        }
      }
    }
    _audioAllList.clear();
    // 音频文件导入
    _sendImportFile();
  }

  // 发送传输音频命令
  _sendImportFile() async {
    if (_audioList.length <= 0) {
      // 提示语，音频文件传输完毕
      Fluttertoast.showToast(
        msg: S.current.BlueController_audio_sync_completed,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }
    FileInfo fileInfo = _audioList.removeAt(0);
    // 开始传输音频文件
    importState.value = ImportStateEnum.START_SEND.state;
    await blueService.importFile([fileInfo.fileName]);
  }

  //设置导入的文件信息
  void _setInputFileInfo(Uint8List data) {
    // 清除导入文件信息
    _clearInputFileInfo();
    // 初始化清除音频转写信息
    pcmToWavHandler.opusClear();
    pcmToWavHandler.clear();
    // 将 Uint8List 转换为 List<int>
    List<int> bytes = data.toList();
    // 使用 utf8 解码为字符串
    String fileName = utf8.decode(bytes);
    // 获取输入音频文件名
    List<String> parts = fileName.split('.');
    inputFileInfo = _audioMap[fileName];
    importFileName.value = parts.first + '.wav';
    importFileSize.value = inputFileInfo?.size ?? 0;
  }

  // 处理导入音频文件流
  Future<void> _handleImportAudioData(Uint8List serializedMsg) async {
    importState.value = ImportStateEnum.IS_SENDING.state;
    pcmToWavHandler.opusAppend(serializedMsg);
    hasImportFileSize.value = pcmToWavHandler.opusBufferSize;
    importFileSp.value = CommonUtil.divideAndPercentage(
        hasImportFileSize.value, importFileSize.value);
    inputProgressMap[importFileName.value] = importFileSp.value;
  }

  // 开始存储文件，或者处理文件导入状态
  Future _handleImportFile(Uint8List content) async {
    importFileSp.value = 100;
    inputProgressMap[importFileName.value] = importFileSp.value;
    final byteData = ByteData.sublistView(content);
    int state = byteData.getUint8(0);
    if (state == 0) {
      _decodeAndSaveAudioFile();
    }
  }

  // 解码导入音频并存储
  Future _decodeAndSaveAudioFile() async {
    // 二次判断是否存在已经导入的文件，防止并发存在问题
    bool isHasFile = await _hasRecordByFileName(importFileName.value);
    if (isHasFile) {
      logger.d('二次判断存在相同音频文件' + importFileName.value);
      _nextImportAudioFile();
      return;
    }

    // 开始解码音频文件
    importState.value = ImportStateEnum.START_DECODE.state;
    // 转写opus音频
    await pcmToWavHandler.decodeOpus();
    // 音频文件解码成功
    importState.value = ImportStateEnum.DECODE_COMPLETED.state;
    String inputFilePath = await AudioUtil.saveWavPath();
    await pcmToWavHandler.writeToFile(inputFilePath);
    pcmToWavHandler.clear();
    // 将文件入库存储
    await _saveAudioFile(inputFilePath);
    importState.value = ImportStateEnum.SAVE_COMPLETED.state;
    await dataController.getAllList();
    await _nextImportAudioFile();
  }

  // 持续传输音频文件
  Future _nextImportAudioFile() async {
    // 持续传输音频文件
    if (_audioList.length > 0) {
      importState.value = ImportStateEnum.NEXT_SEND.state;
      await Future.delayed(Duration(seconds: 1), () {
        _sendImportFile();
      });
    } else {
      importState.value = ImportStateEnum.ALL_COMPLETED.state;
    }
  }

  // 存储导入音频文件
  Future _saveAudioFile(String inputFilePath) async {
    // 文件信息不存在
    if (inputFileInfo == null) {
      return;
    }
    // 录音信息入库
    await recordingService.insertTrans(
        timeLong: inputFileInfo?.timestamp ?? 0,
        fileName: importFileName.value,
        originalFileName: importFileName.value,
        filePath: inputFilePath,
        mediaId: 0,
        mediaName: AudioUtil.fileName,
        transText: '',
        isTranslated: 0,
        source: RecordSourceEnum.PEN.source);
    // 清除导入文件信息
    _clearInputFileInfo();
  }

  // 清除导入文件信息
  _clearInputFileInfo() {
    inputFileInfo = null;
    hasImportFileSize.value = 0;
    importFileSize.value = 0;
    importFileSp.value = 0;
  }

  // 判断是否有此音频文件
  Future<bool> _hasRecordByFileName(String fileName) async {
    // 获取输入音频文件名
    List<String> parts = fileName.split('.');
    Recording? recordInfo =
        await recordingService.getRecordingByFileName(parts.first + '.wav');
    if (recordInfo?.fileName != null) {
      return true;
    }
    return false;
  }

  Future<void> deleteAllRecording() async {
    await recordingService.deleteAll();
  }

  // 循环上传已同步设备文件
  Future<void> syncUpload() async {
    // 第一次连接5秒同步一次文件
    _syncMediaTimer = Timer.periodic(_syncMediaPeriod, (timer) async {
      _syncUpload();
    });
  }

  Future<void> _syncUpload() async {
    // 正在上传音频文件，稍后再上传
    if (isSyncMedia) {
      _modifyTimerUpload();
      return;
    }
    List<Recording> recordList =
        await recordingService.findPenRecordingsNotUploadByPage(1, 1);
    if (recordList.isNotEmpty) {
      Recording _recording = recordList.first;
      isSyncMedia = true;
      try {
        // 开始上传
        int code =
            await MediaTransfer(_recording, EngineTypeEnum.MULTI_LANG.type)
                .mediaUpload();
        if (code != ErrConstants.SUCCESS_CODE) {
          if (_recording.id != null) {
            //上传失败，上传次数+1，往后面延迟执行任务
            await recordingService.updateUploadCount(
                _recording.id ?? 0, _recording.uploadCount);
            // 延迟30s时间
            _modifyTimerUpload();
          }
        }
      } catch (e) {
        // 延迟30s时间
        _modifyTimerUpload();
      }
      isSyncMedia = false;
    } else {
      // 延迟30s时间
      _modifyTimerUpload();
    }
  }

  void _modifyTimerUpload() {
    if (_syncMediaTimer != null) {
      _syncMediaTimer!.cancel(); // 取消当前定时器
      _syncMediaTimer = null;
      _syncMediaPeriod = Duration(seconds: 30);
      syncUpload(); // 用新周期重新启动定时器
    }
  }

  // 删除录音笔音频文件
  void delFile(List<Recording> recordList) {
    if (!isConnected.value) return;
    // 取出来源为录音笔文件，使用Set去重
    Set<String> fileSet = {};
    for (Recording record in recordList) {
      if (record.source == RecordSourceEnum.PEN.source)
        fileSet.add(record.originalFileName);
    }
    if (fileSet.isNotEmpty) blueService.delFile(fileSet.toList());
  }
}
