import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:airecordapp/constant/CommonConstants.dart';
import 'package:airecordapp/util/DateUtil.dart';
import 'package:opus_dart/opus_dart.dart';
import 'package:opus_flutter/opus_flutter.dart' as opus_flutter;
import 'package:path_provider/path_provider.dart';
import 'package:airecordapp/util/OpusDecoderManager.dart';

class AudioUtil {
  static bool isInitOpus = false;

  // 初始化Opus库
  static Future<void> initOpusLibrary() async {
    if (!isInitOpus) {
      // 使用opus_flutter加载原生库，然后初始化opus_dart
      final dynamicLibrary = await opus_flutter.load();
      initOpus(dynamicLibrary);
      isInitOpus = true;
    }
  }

  static String get fileFormat {
    // 文件名后缀
    return 'wav';
  }

  static String get opusFileFormat {
    // 文件名后缀
    return 'opus';
  }

  static String get fileName {
    // 文件名
    return DateUtil.nowYmdHms + '.wav';
  }

  static String get opusFileName {
    // 文件名
    return DateUtil.nowYmdHms + '.opus';
  }

  static String get pcmFileName {
    // 文件名
    return DateUtil.nowYmdHms + '.pcm';
  }

  static Future<String> saveFilePath(String fileName) async {
    var appDir = await getApplicationDocumentsDirectory();
    return '${appDir.path}/$fileName';
  }

  // 生成固定后缀文件路径，无需文件名称输入
  static Future<String> savePcmPath() async {
    String fileName = DateUtil.nowYmdHms + '.pcm';
    var appDir = await getApplicationDocumentsDirectory();
    return '${appDir.path}/$fileName';
  }

  // 生成固定后缀文件路径，无需文件名称输入
  static Future<String> saveWavPath() async {
    String fileName = DateUtil.nowYmdHms + '.wav';
    var appDir = await getApplicationDocumentsDirectory();
    return '${appDir.path}/$fileName';
  }

  // pcm流转wav流
  static Uint8List pcmToWav(
      {required Uint8List pcmData,
        int sampleRate = CommonConstants.SAMPLE_RATE,
        int channels = CommonConstants.CHANNELS}) {
    int byteRate = sampleRate * channels * 2;
    int totalDataLen = pcmData.lengthInBytes + 36;
    int bitsPerSample = 16;
    var wavHeader = ByteData(44)
      ..setUint32(0, 0x52494646, Endian.big) // ChunkID "RIFF"
      ..setUint32(4, totalDataLen, Endian.little) // ChunkSize
      ..setUint32(8, 0x57415645, Endian.big) // Format "WAVE"
      ..setUint32(12, 0x666d7420, Endian.big) // Subchunk1ID "fmt "
      ..setUint32(16, 16, Endian.little) // Subchunk1Size
      ..setUint16(20, 1, Endian.little) // AudioFormat (PCM)
      ..setUint16(22, channels, Endian.little) // NumChannels
      ..setUint32(24, sampleRate, Endian.little) // SampleRate
      ..setUint32(28, byteRate, Endian.little) // ByteRate
      ..setUint16(32, channels * 2, Endian.little) // BlockAlign
      ..setUint16(34, bitsPerSample, Endian.little) // BitsPerSample
      ..setUint32(36, 0x64617461, Endian.big) // Subchunk2ID "data"
      ..setUint32(40, pcmData.lengthInBytes, Endian.little); // Subchunk2Size
    final wavData = Uint8List(wavHeader.lengthInBytes + pcmData.lengthInBytes);
    wavData.setRange(0, 44, wavHeader.buffer.asUint8List());
    wavData.setRange(44, wavData.length, pcmData);
    return wavData;
  }

  // 将Int16转换为Uint8List
  static Uint8List convertInt16ListToUint8List(Int16List int16List) {
    // 创建一个与 Int16List 相同长度的 Uint8List 缓冲区
    final byteData = ByteData(int16List.length * 2);
    for (int i = 0; i < int16List.length; i++) {
      // 将每个 Int16 值写入到 ByteData 中，对应两个字节
      byteData.setInt16(i * 2, int16List[i], Endian.little);
    }
    // 返回 Uint8List 视图
    return byteData.buffer.asUint8List();
  }

  // 将opus流转为pcm流
  static Future<Uint8List> decodeOpusToPcmData2(Uint8List opusData) async {
    await initOpusLibrary();
    final opusDecode = SimpleOpusDecoder(sampleRate: 16000, channels: 1);
    Int16List pcmFrame = opusDecode.decode(input: opusData);
    return convertInt16ListToUint8List(pcmFrame);
  }

  // 将opus流转为pcm流 - 使用解码器管理器
  static Future<Uint8List> decodeOpusToPcmData(
      Uint8List opusData, int frameSize, int sampleRate, int channels) async {
    try {
      // 使用解码器管理器进行解码
      return await OpusDecoderManager.instance.decodeFrames(opusData, frameSize, sampleRate, channels);
    } catch (e) {
      print('Critical error in Opus decoding: $e');
      rethrow;
    }
  }

  static Future<void> saveOpus(Uint8List opusData, String outputWavPath) async {
    try {
      // 读取opus文件数据
      print('Opus file size: ${opusData.length} bytes');

      // 使用文件实际参数：40字节/帧，20ms，16kHz
      const int FRAME_SIZE = 40; // 每帧40字节
      const int SAMPLE_RATE = 16000; // 16kHz
      List<int> allPcmData = [];

      // 创建一个持久的解码器实例，使用正确的采样率
      final decoder = SimpleOpusDecoder(
        sampleRate: SAMPLE_RATE, // 16kHz
        channels: 1, // 单声道
      );

      // 按帧解码（因为是裸流文件，不需要跳过头部）
      for (int offset = 0; offset < opusData.length; offset += FRAME_SIZE) {
        int currentFrameSize = (offset + FRAME_SIZE > opusData.length)
            ? opusData.length - offset
            : FRAME_SIZE;

        try {
          // 获取当前帧数据
          Uint8List frameData =
          opusData.sublist(offset, offset + currentFrameSize);

          // 解码当前帧
          Int16List decodedFrame = decoder.decode(input: frameData);

          // 转换解码后的数据并添加到结果中
          allPcmData
              .addAll(AudioUtil.convertInt16ListToUint8List(decodedFrame));
        } catch (e) {
          print('Frame at offset $offset failed to decode: $e');
          continue;
        }
      }

      // 将所有解码后的PCM数据合并
      final Uint8List pcmData = Uint8List.fromList(allPcmData);
      print('PCM data size: ${pcmData.length} bytes');

      // 将pcm转换为wav，使用正确的采样率
      final Uint8List wavData = AudioUtil.pcmToWav(
          pcmData: pcmData,
          sampleRate: SAMPLE_RATE, // 16kHz
          channels: 1 // 单声道
      );
      print('WAV data size: ${wavData.length} bytes');
      final File outputWavFile = File(outputWavPath);

      // 写入wav文件
      await outputWavFile.writeAsBytes(wavData);
    } catch (e, stackTrace) {
      print('Error during conversion: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // 删除音频文件
  static Future<void> deleteAudioFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
