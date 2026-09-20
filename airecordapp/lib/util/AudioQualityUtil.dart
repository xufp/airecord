import 'dart:typed_data';
import 'dart:math';

class AudioQualityUtil {
  // 音频质量检测阈值
  static const int SILENCE_THRESHOLD = 100; // 静音检测阈值
  static const int CLIPPING_THRESHOLD = 32000; // 削波检测阈值
  static const int MIN_VALID_SAMPLES = 100; // 最小有效样本数
  
  // 检测音频数据质量
  static AudioQualityResult checkAudioQuality(Uint8List pcmData, int sampleRate) {
    if (pcmData.isEmpty) {
      return AudioQualityResult(
        isValid: false,
        reason: 'Empty audio data',
        sampleCount: 0,
        duration: 0.0,
      );
    }
    
    // 检查数据长度是否为偶数（16位采样）
    if (pcmData.length % 2 != 0) {
      return AudioQualityResult(
        isValid: false,
        reason: 'Invalid data length (odd number of bytes)',
        sampleCount: pcmData.length ~/ 2,
        duration: (pcmData.length ~/ 2) / sampleRate,
      );
    }
    
    int sampleCount = pcmData.length ~/ 2;
    double duration = sampleCount / sampleRate;
    
    // 分析音频样本
    int validSamples = 0;
    int silentSamples = 0;
    int clippedSamples = 0;
    double maxAmplitude = 0.0;
    double rms = 0.0;
    
    for (int i = 0; i < pcmData.length; i += 2) {
      if (i + 1 < pcmData.length) {
        int sample = (pcmData[i + 1] << 8) | pcmData[i]; // 小端序
        double amplitude = sample.abs().toDouble();
        
        maxAmplitude = amplitude > maxAmplitude ? amplitude : maxAmplitude;
        rms += amplitude * amplitude;
        
        if (amplitude > SILENCE_THRESHOLD) {
          validSamples++;
        } else {
          silentSamples++;
        }
        
        if (amplitude > CLIPPING_THRESHOLD) {
          clippedSamples++;
        }
      }
    }
    
    rms = sqrt(rms / sampleCount);
    
    // 判断音频质量
    bool isValid = true;
    var reason = 'Valid audio';
    
    if (validSamples < MIN_VALID_SAMPLES) {
      isValid = false;
      reason = 'Too few valid samples ($validSamples < $MIN_VALID_SAMPLES)';
    } else if (silentSamples > sampleCount * 0.95) {
      isValid = false;
      reason = 'Too much silence (${(silentSamples / sampleCount * 100).toStringAsFixed(1)}%)';
    } else if (clippedSamples > sampleCount * 0.1) {
      isValid = false;
      reason = 'Too much clipping (${(clippedSamples / sampleCount * 100).toStringAsFixed(1)}%)';
    }
    
    return AudioQualityResult(
      isValid: isValid,
      reason: reason,
      sampleCount: sampleCount,
      duration: duration,
      validSamples: validSamples,
      silentSamples: silentSamples,
      clippedSamples: clippedSamples,
      maxAmplitude: maxAmplitude,
      rms: rms,
    );
  }
  
  // 修复音频数据
  static Uint8List repairAudioData(Uint8List pcmData) {
    if (pcmData.isEmpty) {
      return Uint8List(0);
    }
    
    // 确保数据长度为偶数
    if (pcmData.length % 2 != 0) {
      pcmData = pcmData.sublist(0, pcmData.length - 1);
    }
    
    // 移除异常值
    List<int> repairedData = [];
    for (int i = 0; i < pcmData.length; i += 2) {
      if (i + 1 < pcmData.length) {
        int sample = (pcmData[i + 1] << 8) | pcmData[i];
        
        // 限制样本值在有效范围内
        if (sample > 32767) sample = 32767;
        if (sample < -32768) sample = -32768;
        
        // 重新打包为字节
        repairedData.add(sample & 0xFF);
        repairedData.add((sample >> 8) & 0xFF);
      }
    }
    
    return Uint8List.fromList(repairedData);
  }
  
  // 音频数据标准化
  static Uint8List normalizeAudio(Uint8List pcmData, double targetRms) {
    if (pcmData.isEmpty) {
      return Uint8List(0);
    }
    
    // 计算当前RMS
    double currentRms = 0.0;
    int sampleCount = pcmData.length ~/ 2;
    
    for (int i = 0; i < pcmData.length; i += 2) {
      if (i + 1 < pcmData.length) {
        int sample = (pcmData[i + 1] << 8) | pcmData[i];
        currentRms += sample * sample;
      }
    }
    currentRms = sqrt(currentRms / sampleCount);
    
    if (currentRms == 0.0) {
      return pcmData;
    }
    
    // 计算增益
    double gain = targetRms / currentRms;
    
    // 应用增益
    List<int> normalizedData = [];
    for (int i = 0; i < pcmData.length; i += 2) {
      if (i + 1 < pcmData.length) {
        int sample = (pcmData[i + 1] << 8) | pcmData[i];
        int normalizedSample = (sample * gain).round();
        
        // 限制范围
        if (normalizedSample > 32767) normalizedSample = 32767;
        if (normalizedSample < -32768) normalizedSample = -32768;
        
        normalizedData.add(normalizedSample & 0xFF);
        normalizedData.add((normalizedSample >> 8) & 0xFF);
      }
    }
    
    return Uint8List.fromList(normalizedData);
  }
  
  // 检测音频连续性
  static bool checkAudioContinuity(List<Uint8List> audioChunks) {
    if (audioChunks.isEmpty) return false;
    
    int totalSamples = 0;
    for (Uint8List chunk in audioChunks) {
      totalSamples += chunk.length ~/ 2;
    }
    
    // 检查是否有足够的音频数据
    return totalSamples > MIN_VALID_SAMPLES;
  }
}

// 音频质量结果类
class AudioQualityResult {
  final bool isValid;
  final String reason;
  final int sampleCount;
  final double duration;
  final int validSamples;
  final int silentSamples;
  final int clippedSamples;
  final double maxAmplitude;
  final double rms;
  
  AudioQualityResult({
    required this.isValid,
    required this.reason,
    required this.sampleCount,
    required this.duration,
    this.validSamples = 0,
    this.silentSamples = 0,
    this.clippedSamples = 0,
    this.maxAmplitude = 0.0,
    this.rms = 0.0,
  });
  
  @override
  String toString() {
    return 'AudioQualityResult{'
        'isValid: $isValid, '
        'reason: $reason, '
        'sampleCount: $sampleCount, '
        'duration: ${duration.toStringAsFixed(2)}s, '
        'validSamples: $validSamples, '
        'silentSamples: $silentSamples, '
        'clippedSamples: $clippedSamples, '
        'maxAmplitude: ${maxAmplitude.toStringAsFixed(1)}, '
        'rms: ${rms.toStringAsFixed(1)}'
        '}';
  }
}
