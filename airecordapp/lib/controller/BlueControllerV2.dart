import 'dart:async';
import 'dart:typed_data';

import 'package:airecordapp/command/v2/BleDeviceV2Config.dart';
import 'package:airecordapp/command/v2/NewBleCommand.dart';
import 'package:airecordapp/command/v2/NewBleFrame.dart';
import 'package:airecordapp/command/v2/NewBleResponse.dart';
import 'package:airecordapp/constant/CommonConstants.dart';
import 'package:airecordapp/controller/RecordingController.dart';
import 'package:airecordapp/db/Cache.dart';
import 'package:airecordapp/enum/MediaStateEnum.dart';
import 'package:airecordapp/enum/RecordSourceEnum.dart';
import 'package:airecordapp/service/BlueServiceV2.dart';
import 'package:airecordapp/service/RecordingService.dart';
import 'package:airecordapp/service/WebSocketService.dart';
import 'package:airecordapp/service/handler/PCMToWavHandler.dart';
import 'package:airecordapp/util/AudioUtil.dart';
import 'package:airecordapp/util/LogUtil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

/// 文件下载状态，用于对外暴露 UI。
class V2FileDownloadState {
  final String fileName;
  final int totalBytes;
  int receivedBytes;
  int totalPkg;
  int receivedPkg;
  bool completed;
  bool failed;

  V2FileDownloadState({
    required this.fileName,
    required this.totalBytes,
    this.receivedBytes = 0,
    this.totalPkg = 0,
    this.receivedPkg = 0,
    this.completed = false,
    this.failed = false,
  });

  int get percent => totalBytes <= 0
      ? 0
      : ((receivedBytes / totalBytes) * 100).clamp(0, 100).toInt();
}

/// 新硬件 V2 全局控制器。与现有 [BlueController] 完全隔离。
///
/// 职责：
/// - 扫描结果筛选（仅 V2 设备）、连接/断连管理、自动重连。
/// - 指令发送（电量、录音状态、文件列表、下载、删除、续传、实时转录开关）。
/// - Notify 解析：FFF2 走控制/文件元数据；FFE2 走录音状态/实时电平/语音/文件数据。
/// - 实时转录：把 0x90 语音 chunk 推到 WebSocketService（复用现有链路）。
/// - 文件下载：维护包序号顺序缓冲，收齐后解码 OPUS → WAV 入库。
class BlueControllerV2 extends GetxController {
  final _logger = LogUtil.inItLog();

  final BlueServiceV2 _ble = BlueServiceV2();
  final NewBleCommand _cmd = NewBleCommand();
  final NewBleResponse _resp = NewBleResponse();
  final WebSocketService _ws = WebSocketService();
  final RecordingService _recordingSvc = RecordingService();
  final PCMToWavHandler _pcm = PCMToWavHandler(
    sampleRate: CommonConstants.OPUS_SAMPLE_RATE,
    channels: CommonConstants.OPUS_CHANNELS,
  );

  // ===== Obs =====
  final RxList<ScanResult> scanResults = <ScanResult>[].obs;
  final RxBool isScanning = false.obs;
  final RxBool isConnecting = false.obs;
  final RxBool isConnected = false.obs;
  final RxString devName = ''.obs;
  final RxInt battery = 0.obs; // 0~100

  // 录音状态
  final RxBool isRecording = false.obs;
  final RxBool isPaused = false.obs;
  // 文件唯一 ID（MAC+时间 BCD）
  final RxString currentFileId = ''.obs;
  final RxDouble audioLevel = 0.0.obs; // dB -120~0

  // 文件列表
  final RxList<NewAudioFileInfo> audioList = <NewAudioFileInfo>[].obs;
  // 当前下载
  final Rx<V2FileDownloadState?> currentDownload =
      Rx<V2FileDownloadState?>(null);

  BluetoothDevice? _device;
  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<bool>? _scanStateSub;
  StreamSubscription<BluetoothConnectionState>? _connSub;
  StreamSubscription<Uint8List>? _fffSub;
  StreamSubscription<Uint8List>? _ffeSub;

  // 文件下载上下文
  final Map<int, Uint8List> _pkgBuffer = <int, Uint8List>{};
  int _nextExpectedPkg = 0;
  NewAudioFileInfo? _downloadingFileInfo;

  // 实时转录
  bool _wsAdded = false;
  String _tranFileName = '';
  int _recordingDurationMs = 0;

  // =================== 扫描 ===================

  Future<void> startScan() async {
    // 监听扫描结果
    _scanSub ??= FlutterBluePlus.scanResults.listen((results) {
      // 仅保留 V2 设备
      scanResults.value =
          results.where((r) => _ble.isV2Device(r)).toList(growable: false);
    }, onError: (e) {
      _logger.e('V2 Scan Error: $e');
    });
    _scanStateSub ??= FlutterBluePlus.isScanning.listen((s) {
      isScanning.value = s;
    });
    await _ble.startScan();
  }

  Future<void> stopScan() async {
    await _ble.stopScan();
  }

  void clearScan() {
    _scanSub?.cancel();
    _scanStateSub?.cancel();
    _scanSub = null;
    _scanStateSub = null;
    scanResults.value = [];
    isScanning.value = false;
  }

  // =================== 连接 ===================

  Future<bool> connectAndInit(BluetoothDevice device) async {
    if (isConnecting.value) return false;
    isConnecting.value = true;
    try {
      if (!device.isConnected) {
        await device.connect(timeout: const Duration(seconds: 10));
      }
      final services = await device.discoverServices();
      final ok = await _ble.initBlue(services);
      if (!ok) {
        _logger.e('V2 特征发现失败');
        isConnecting.value = false;
        return false;
      }
      _device = device;
      await _saveDevInfoIfNeeded(device);
      _attachStreams();
      _attachConnectionState(device);
      isConnected.value = true;
      devName.value = device.platformName;
      // 主动读电量
      await queryBattery();
      return true;
    } catch (e) {
      _logger.e('V2 连接异常: $e');
      return false;
    } finally {
      isConnecting.value = false;
    }
  }

  Future<void> _saveDevInfoIfNeeded(BluetoothDevice device) async {
    final String exist = await Cache.v2RemoteId;
    if (exist.isNotEmpty) return;
    await Cache.saveDevInfoV2(
      platformName: device.platformName,
      remoteId: device.remoteId.toString(),
      writeFff: BleDeviceV2Config.characteristicWriteFff,
      notifyFff: BleDeviceV2Config.characteristicNotifyFff,
      writeFfe: BleDeviceV2Config.characteristicWriteFfe,
      notifyFfe: BleDeviceV2Config.characteristicNotifyFfe,
    );
  }

  void _attachConnectionState(BluetoothDevice device) {
    _connSub?.cancel();
    _connSub = device.connectionState.listen((state) {
      if (state == BluetoothConnectionState.disconnected) {
        isConnected.value = false;
        _logger.d('V2 设备已断开');
        // 实时转录链路清理
        _cleanupWebSocket();
      }
    });
  }

  void _attachStreams() {
    _fffSub?.cancel();
    _ffeSub?.cancel();
    _fffSub = _ble.controlStream.listen(_onFffNotify);
    _ffeSub = _ble.realtimeStream.listen(_onFfeNotify);
  }

  Future<void> disconnect() async {
    try {
      await _device?.disconnect();
    } catch (_) {}
    isConnected.value = false;
  }

  Future<void> forgetDevice() async {
    await disconnect();
    await _ble.closeSubscriptions();
    await Cache.removeDevCacheV2();
    devName.value = '';
    battery.value = 0;
  }

  Future<BluetoothDevice?> get cachedDevice async {
    final id = await Cache.v2RemoteId;
    if (id.isEmpty) return null;
    return BluetoothDevice.fromId(id);
  }

  // =================== Notify 分发 ===================

  void _onFffNotify(Uint8List raw) {
    // 尝试作为文件列表分包处理
    final fileList = _resp.feedFileList(raw);
    if (fileList != null) {
      audioList.assignAll(fileList);
      _logger.d('V2 文件列表到达，共 ${fileList.length} 项');
      return;
    }

    // 普通帧解析
    final frame = _resp.parseFrame(raw);
    if (frame == null) return;

    switch (frame.cmd) {
      case NewBleCommand.cmdQel:
        final b = _resp.parseBattery(frame);
        if (b != null) {
          battery.value = b;
        }
        break;
      case NewBleCommand.cmdFileDownload:
        final ack = _resp.parseFileDownloadAck(frame);
        if (ack != null) _onDownloadAck(ack);
        break;
      case NewBleCommand.cmdFileDelete:
        _logger.d('V2 文件删除应答：${_hex(frame.params)}');
        break;
      case NewBleCommand.cmdTranscribeSwitch:
        _logger.d('V2 转录开关应答：${_hex(frame.params)}');
        break;
      default:
        _logger.d('V2 FFF2 未处理帧 cmd=0x${frame.cmd.toRadixString(16)}');
    }
  }

  void _onFfeNotify(Uint8List raw) {
    // 1) 文件数据包（包头 0xFFFFFF）
    if (raw.length >= 3 &&
        (raw[0] & 0xFF) == 0xFF &&
        (raw[1] & 0xFF) == 0xFF &&
        (raw[2] & 0xFF) == 0xFF) {
      final pkt = _resp.parseFileDataPacket(raw);
      if (pkt != null) {
        _onFileDataPacket(pkt);
      } else {
        _logger.e('V2 文件数据包解析失败，length=${raw.length}');
      }
      return;
    }

    final frame = _resp.parseFrame(raw);
    if (frame == null) return;

    switch (frame.cmd) {
      case NewBleCommand.cmdWriteRecState:
      case NewBleCommand.cmdReadRecState:
        final st = _resp.parseRecState(frame);
        if (st != null) _onRecState(st);
        break;
      case 0xA8:
        final lv = _resp.parseAudioLevel(frame);
        if (lv != null) audioLevel.value = lv;
        break;
      case 0x90:
        final chunk = _resp.feedVoicePacket(frame);
        if (chunk != null) _handleVoiceChunk(chunk.data);
        break;
      default:
        _logger.d('V2 FFE2 未处理帧 cmd=0x${frame.cmd.toRadixString(16)}');
    }
  }

  // =================== 电量 ===================

  Future<void> queryBattery() async {
    await _ble.writeFrame(NewBleFrame(cmd: NewBleCommand.cmdQel));
  }

  // =================== 录音控制 ===================

  Future<bool> startRecord() async {
    final ok = await _writeCmd(_cmd.recStart());
    if (ok) {
      isRecording.value = true;
      isPaused.value = false;
    }
    return ok;
  }

  Future<bool> stopRecord() async {
    final ok = await _writeCmd(_cmd.recStop());
    if (ok) {
      isRecording.value = false;
      isPaused.value = false;
      await _finishRealtimeTranscribe();
    }
    return ok;
  }

  Future<bool> pauseRecord() async {
    final ok = await _writeCmd(_cmd.recPause());
    if (ok) isPaused.value = true;
    return ok;
  }

  Future<bool> resumeRecord() async {
    final ok = await _writeCmd(_cmd.recResume());
    if (ok) isPaused.value = false;
    return ok;
  }

  void _onRecState(NewRecStateResult st) {
    if (st.memFull) {
      _toast('设备内存已满，请清理后再试');
      return;
    }
    if (st.lowBattery) {
      _toast('设备电量不足，请充电后再试');
      return;
    }
    // state: 0 关 / 1 开 / 2 暂停 / 3 恢复
    switch (st.state) {
      case 0:
        isRecording.value = false;
        isPaused.value = false;
        break;
      case 1:
        isRecording.value = true;
        isPaused.value = false;
        break;
      case 2:
        isPaused.value = true;
        break;
      case 3:
        isPaused.value = false;
        break;
    }
    currentFileId.value = st.fileUniqueId;
    _logger.d('V2 录音状态 state=${st.state} id=${st.fileUniqueId}');
  }

  // =================== 实时转录 ===================

  Future<bool> enableTranscribe() async =>
      _writeCmd(_cmd.transcribeOn());

  Future<bool> disableTranscribe() async =>
      _writeCmd(_cmd.transcribeOff());

  Future<void> _handleVoiceChunk(Uint8List opusChunk) async {
    // 录音时长按帧推算：每 40B 对应 20ms（与 V1 一致）
    _recordingDurationMs += (opusChunk.length / 40).ceil() * 20;
    try {
      // 实时解码 OPUS → PCM → 推到 WebSocket
      if (!_wsAdded) {
        _tranFileName = AudioUtil.fileName;
        await _ws
            .setMediaSpeechUrl(
              mediaName: _tranFileName,
              fileFormat: AudioUtil.fileFormat,
            )
            .initializeWebSocket();
        // 追加 WAV 头占位
        final header = AudioUtil.pcmToWav(
          pcmData: Uint8List(0),
          sampleRate: CommonConstants.OPUS_SAMPLE_RATE,
          channels: CommonConstants.OPUS_CHANNELS,
        );
        _ws.webSocketChannel?.sink.add(header);
        _wsAdded = true;
      }
      final pcm = await _pcm.realtimeDecodeOpus(opusChunk);
      _ws.webSocketChannel?.sink.add(pcm);
    } catch (e) {
      _logger.e('V2 实时转录解码异常: $e');
    }
  }

  Future<void> _finishRealtimeTranscribe() async {
    if (!_wsAdded) return;
    try {
      _ws.webSocketChannel?.sink.add('<EOF>');
      // 保存转录音频
      final path = await AudioUtil.saveWavPath();
      await _pcm.writeToFile(path);
      _pcm.clear();
      // 入库
      final timeLong = (_recordingDurationMs / 1000).ceil();
      await _recordingSvc.insertTrans(
        timeLong: timeLong,
        mediaName: _tranFileName,
        fileName: _tranFileName,
        originalFileName: _tranFileName,
        filePath: path,
        mediaId: 0,
        transText: '',
        isTranslated: MediaStateEnum.TRANSLATED.state,
        source: RecordSourceEnum.PEN_V2.source,
        isUpload: CommonConstants.UPLOADED,
      );
      try {
        final rc = Get.find<RecordingController>();
        await rc.getAllList();
      } catch (_) {}
    } catch (e) {
      _logger.e('V2 转录收尾异常: $e');
    } finally {
      _cleanupWebSocket();
      _recordingDurationMs = 0;
    }
  }

  void _cleanupWebSocket() {
    try {
      _ws.closeWebSocket();
    } catch (_) {}
    _wsAdded = false;
    _tranFileName = '';
  }

  // =================== 文件同步 ===================

  Future<void> refreshFileList() async {
    audioList.clear();
    _resp.reset();
    await _writeCmd(_cmd.fileList());
  }

  Future<void> downloadFile(NewAudioFileInfo info) async {
    _pkgBuffer.clear();
    _nextExpectedPkg = 0;
    _downloadingFileInfo = info;
    _pcm.opusClear();
    _pcm.clear();
    currentDownload.value = V2FileDownloadState(
      fileName: info.fileName,
      totalBytes: info.size,
    );
    await _writeCmd(_cmd.fileDownload(fileName: info.fileName));
  }

  Future<void> cancelDownload() async {
    if (_downloadingFileInfo == null) return;
    await _writeCmd(_cmd.fileDownload(
      fileName: _downloadingFileInfo!.fileName,
      syncOp: NewBleCommand.syncOpCancel,
    ));
    _resetDownload();
  }

  Future<void> deleteFile(String fileName) async {
    await _writeCmd(_cmd.fileDelete(fileName));
    audioList.removeWhere((e) => e.fileName == fileName);
  }

  void _onDownloadAck(NewFileDownloadAck ack) {
    final st = currentDownload.value;
    if (st == null) return;
    if (!ack.exist) {
      st.failed = true;
      currentDownload.refresh();
      _logger.e('V2 下载失败：文件不存在 ${ack.fileName}');
      _resetDownload();
      return;
    }
    st.totalPkg = ack.totalPkgCount;
    currentDownload.refresh();
  }

  void _onFileDataPacket(NewFileDataPacket pkt) {
    final st = currentDownload.value;
    if (st == null || _downloadingFileInfo == null) return;
    _pkgBuffer[pkt.pkgIndex] = pkt.data;
    // 顺序 flush
    while (_pkgBuffer.containsKey(_nextExpectedPkg)) {
      final data = _pkgBuffer.remove(_nextExpectedPkg)!;
      _pcm.opusAppend(data);
      st.receivedBytes += data.length;
      st.receivedPkg += 1;
      _nextExpectedPkg += 1;
    }
    currentDownload.refresh();
    // 判定收齐：按文件大小
    if (st.receivedBytes >= st.totalBytes && st.totalBytes > 0) {
      _completeDownload();
    }
  }

  Future<void> _completeDownload() async {
    final info = _downloadingFileInfo;
    final st = currentDownload.value;
    if (info == null || st == null) return;
    try {
      await _pcm.decodeOpus();
      final path = await AudioUtil.saveWavPath();
      await _pcm.writeToFile(path);
      _pcm.clear();
      // 入库（以 OPUS 源文件名为 originalFileName，便于后续按名匹配删除）
      final String wavName = _replaceExt(info.fileName, 'wav');
      await _recordingSvc.insertTrans(
        timeLong: info.durationSec,
        fileName: wavName,
        originalFileName: info.fileName,
        filePath: path,
        mediaId: 0,
        mediaName: wavName,
        transText: '',
        isTranslated: 0,
        source: RecordSourceEnum.PEN_V2.source,
      );
      st.completed = true;
      currentDownload.refresh();
      try {
        final rc = Get.find<RecordingController>();
        await rc.getAllList();
      } catch (_) {}
    } catch (e) {
      _logger.e('V2 下载后解码/入库异常: $e');
    } finally {
      _resetDownload();
    }
  }

  void _resetDownload() {
    _pkgBuffer.clear();
    _nextExpectedPkg = 0;
    _downloadingFileInfo = null;
  }

  // 触发补包（上层可按需调用；默认不自动触发）。
  Future<void> resendFrom(int startPkg) async {
    await _ble.writeRealtimeRaw(_cmd.resendFrom(startPkg));
  }

  // =================== 工具 ===================

  Future<bool> _writeCmd(Uint8List frameBytes) async {
    // 通过解析 cmd 字节判断路由
    if (frameBytes.length < 3) return false;
    final int cmd = frameBytes[2] & 0xFF;
    final bool useFfe = cmd == NewBleCommand.cmdReadRecState ||
        cmd == NewBleCommand.cmdWriteRecState ||
        cmd == NewBleCommand.cmdResend;
    return useFfe
        ? _ble.writeRealtimeRaw(frameBytes)
        : _ble.writeControlRaw(frameBytes);
  }

  void _toast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 14,
    );
  }

  String _replaceExt(String fileName, String newExt) {
    final idx = fileName.lastIndexOf('.');
    if (idx <= 0) return '$fileName.$newExt';
    return '${fileName.substring(0, idx)}.$newExt';
  }

  String _hex(Uint8List d) {
    final n = d.length > 16 ? 16 : d.length;
    return d.sublist(0, n).map((e) => e.toRadixString(16).padLeft(2, '0')).join(' ');
  }

  @override
  void onClose() {
    _scanSub?.cancel();
    _scanStateSub?.cancel();
    _connSub?.cancel();
    _fffSub?.cancel();
    _ffeSub?.cancel();
    _ble.dispose();
    super.onClose();
  }
}
