import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:airecordapp/util/OpusDecoderManager.dart';

void main() {
  group('OpusDecoderManager Tests', () {
    test('should initialize decoder correctly', () async {
      final manager = OpusDecoderManager.instance;
      await manager.initializeDecoder(16000, 1);
      
      Map<String, dynamic> status = manager.getStatus();
      expect(status['isInitialized'], true);
      expect(status['sampleRate'], 16000);
      expect(status['channels'], 1);
      expect(status['hasDecoder'], true);
    });

    test('should reuse decoder instance', () async {
      final manager = OpusDecoderManager.instance;
      
      // 第一次初始化
      await manager.initializeDecoder(16000, 1);
      Map<String, dynamic> status1 = manager.getStatus();
      
      // 第二次初始化相同参数
      await manager.initializeDecoder(16000, 1);
      Map<String, dynamic> status2 = manager.getStatus();
      
      // 应该复用同一个解码器
      expect(status1['isInitialized'], status2['isInitialized']);
    });

    test('should create new decoder for different parameters', () async {
      final manager = OpusDecoderManager.instance;
      
      // 第一次初始化
      await manager.initializeDecoder(16000, 1);
      Map<String, dynamic> status1 = manager.getStatus();
      
      // 第二次初始化不同参数
      await manager.initializeDecoder(44100, 2);
      Map<String, dynamic> status2 = manager.getStatus();
      
      // 应该创建新的解码器
      expect(status2['sampleRate'], 44100);
      expect(status2['channels'], 2);
    });

    test('should handle empty data gracefully', () async {
      final manager = OpusDecoderManager.instance;
      await manager.initializeDecoder(16000, 1);
      
      Uint8List emptyData = Uint8List(0);
      Uint8List result = await manager.decodeFrames(emptyData, 40, 16000, 1);
      
      expect(result.length, 0);
    });

    test('should reset decoder correctly', () {
      final manager = OpusDecoderManager.instance;
      manager.reset();
      
      Map<String, dynamic> status = manager.getStatus();
      expect(status['isInitialized'], false);
      expect(status['hasDecoder'], false);
    });
  });
}
