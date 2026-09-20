import 'dart:typed_data';
import 'package:opus_dart/opus_dart.dart';
import 'package:airecordapp/util/AudioUtil.dart';

class OpusDecoderManager {
  static OpusDecoderManager? _instance;
  static SimpleOpusDecoder? _decoder;
  static bool _isInitialized = false;
  static int _currentSampleRate = 0;
  static int _currentChannels = 0;
  
  // 私有构造函数
  OpusDecoderManager._();
  
  // 单例模式
  static OpusDecoderManager get instance {
    _instance ??= OpusDecoderManager._();
    return _instance!;
  }
  
  // 初始化解码器
  Future<void> initializeDecoder(int sampleRate, int channels) async {
    if (!_isInitialized || _currentSampleRate != sampleRate || _currentChannels != channels) {
      await AudioUtil.initOpusLibrary();
      
      // 如果已有解码器，先释放
      if (_decoder != null) {
        _decoder = null;
      }
      
      // 创建新的解码器
      _decoder = SimpleOpusDecoder(
        sampleRate: sampleRate,
        channels: channels,
      );
      
      _currentSampleRate = sampleRate;
      _currentChannels = channels;
      _isInitialized = true;
      
      print('Opus decoder initialized: sampleRate=$sampleRate, channels=$channels');
    }
  }
  
  // 解码单个帧
  Int16List? decodeFrame(Uint8List frameData) {
    if (_decoder == null || !_isInitialized) {
      print('Error: Decoder not initialized');
      return null;
    }
    
    try {
      return _decoder!.decode(input: frameData);
    } catch (e) {
      print('Error decoding frame: $e');
      return null;
    }
  }
  
  // 批量解码
  Future<Uint8List> decodeFrames(Uint8List opusData, int frameSize, int sampleRate, int channels) async {
    await initializeDecoder(sampleRate, channels);
    
    List<int> allPcmData = [];
    
    // 检查输入数据
    if (opusData.isEmpty) {
      print('Warning: Empty opus data received');
      return Uint8List(0);
    }
    
    // 按帧解码
    for (int offset = 0; offset < opusData.length; offset += frameSize) {
      int currentFrameSize = (offset + frameSize > opusData.length)
          ? opusData.length - offset
          : frameSize;
      
      // 只处理完整的帧
      if (currentFrameSize == frameSize) {
        Uint8List frameData = opusData.sublist(offset, offset + currentFrameSize);
        
        // 解码帧
        Int16List? decodedFrame = decodeFrame(frameData);
        
        if (decodedFrame != null && decodedFrame.isNotEmpty) {
          // 转换并添加PCM数据
          allPcmData.addAll(AudioUtil.convertInt16ListToUint8List(decodedFrame));
        } else {
          // 解码失败，添加静音帧
          int samplesPerFrame = (sampleRate * channels * 20) ~/ 1000; // 20ms帧
          List<int> silenceFrame = List.filled(samplesPerFrame * 2, 0);
          allPcmData.addAll(silenceFrame);
          print('Added silence frame at offset $offset due to decode failure');
        }
      } else {
        // 不完整的帧，跳过
        print('Skipping incomplete frame at offset $offset, size: $currentFrameSize');
      }
    }
    
    return Uint8List.fromList(allPcmData);
  }
  
  // 重置解码器
  void reset() {
    _decoder = null;
    _isInitialized = false;
    _currentSampleRate = 0;
    _currentChannels = 0;
    print('Opus decoder reset');
  }
  
  // 获取解码器状态
  Map<String, dynamic> getStatus() {
    return {
      'isInitialized': _isInitialized,
      'sampleRate': _currentSampleRate,
      'channels': _currentChannels,
      'hasDecoder': _decoder != null,
    };
  }
}
