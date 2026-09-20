import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:airecordapp/util/AudioQualityUtil.dart';

void main() {
  group('AudioQualityUtil Tests', () {
    test('should detect empty audio data', () {
      Uint8List emptyData = Uint8List(0);
      AudioQualityResult result = AudioQualityUtil.checkAudioQuality(emptyData, 16000);
      
      expect(result.isValid, false);
      expect(result.reason, 'Empty audio data');
      expect(result.sampleCount, 0);
    });

    test('should detect invalid data length', () {
      Uint8List oddLengthData = Uint8List(3); // 奇数长度
      AudioQualityResult result = AudioQualityUtil.checkAudioQuality(oddLengthData, 16000);
      
      expect(result.isValid, false);
      expect(result.reason, 'Invalid data length (odd number of bytes)');
    });

    test('should detect too much silence', () {
      // 创建几乎全是静音的音频数据
      List<int> silentData = [];
      for (int i = 0; i < 1000; i += 2) {
        silentData.add(0); // 低字节
        silentData.add(0); // 高字节
      }
      Uint8List audioData = Uint8List.fromList(silentData);
      
      AudioQualityResult result = AudioQualityUtil.checkAudioQuality(audioData, 16000);
      
      expect(result.isValid, false);
      expect(result.reason.contains('Too much silence'), true);
    });

    test('should validate good audio data', () {
      // 创建有效的音频数据
      List<int> validData = [];
      for (int i = 0; i < 1000; i += 2) {
        int sample = (i % 1000) - 500; // 生成有变化的音频样本
        validData.add(sample & 0xFF); // 低字节
        validData.add((sample >> 8) & 0xFF); // 高字节
      }
      Uint8List audioData = Uint8List.fromList(validData);
      
      AudioQualityResult result = AudioQualityUtil.checkAudioQuality(audioData, 16000);
      
      expect(result.isValid, true);
      expect(result.reason, 'Valid audio');
      expect(result.sampleCount, 500);
    });

    test('should repair audio data', () {
      // 创建包含异常值的音频数据
      List<int> corruptedData = [];
      for (int i = 0; i < 100; i += 2) {
        int sample = 40000; // 超出范围的样本值
        corruptedData.add(sample & 0xFF);
        corruptedData.add((sample >> 8) & 0xFF);
      }
      Uint8List audioData = Uint8List.fromList(corruptedData);
      
      Uint8List repairedData = AudioQualityUtil.repairAudioData(audioData);
      
      // 验证修复后的数据
      for (int i = 0; i < repairedData.length; i += 2) {
        if (i + 1 < repairedData.length) {
          int sample = (repairedData[i + 1] << 8) | repairedData[i];
          expect(sample, lessThanOrEqualTo(32767));
          expect(sample, greaterThanOrEqualTo(-32768));
        }
      }
    });

    test('should normalize audio data', () {
      // 创建低音量的音频数据
      List<int> lowVolumeData = [];
      for (int i = 0; i < 1000; i += 2) {
        int sample = (i % 100) - 50; // 低音量样本
        lowVolumeData.add(sample & 0xFF);
        lowVolumeData.add((sample >> 8) & 0xFF);
      }
      Uint8List audioData = Uint8List.fromList(lowVolumeData);
      
      Uint8List normalizedData = AudioQualityUtil.normalizeAudio(audioData, 1000.0);
      
      // 验证标准化后的数据
      AudioQualityResult result = AudioQualityUtil.checkAudioQuality(normalizedData, 16000);
      expect(result.isValid, true);
    });

    test('should check audio continuity', () {
      List<Uint8List> audioChunks = [];
      
      // 添加一些音频块
      for (int i = 0; i < 5; i++) {
        List<int> chunkData = [];
        for (int j = 0; j < 200; j += 2) {
          int sample = (j % 100) - 50;
          chunkData.add(sample & 0xFF);
          chunkData.add((sample >> 8) & 0xFF);
        }
        audioChunks.add(Uint8List.fromList(chunkData));
      }
      
      bool isContinuous = AudioQualityUtil.checkAudioContinuity(audioChunks);
      expect(isContinuous, true);
    });

    test('should detect insufficient audio data', () {
      List<Uint8List> smallChunks = [];
      
      // 添加很小的音频块
      for (int i = 0; i < 3; i++) {
        List<int> chunkData = [];
        for (int j = 0; j < 20; j += 2) {
          int sample = (j % 20) - 10;
          chunkData.add(sample & 0xFF);
          chunkData.add((sample >> 8) & 0xFF);
        }
        smallChunks.add(Uint8List.fromList(chunkData));
      }
      
      bool isContinuous = AudioQualityUtil.checkAudioContinuity(smallChunks);
      expect(isContinuous, false);
    });
  });
}
