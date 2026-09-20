import 'dart:io';
import 'dart:typed_data';

import 'package:airecordapp/util/AudioUtil.dart';

class PCMToWavHandler {
  BytesBuilder opusByteBuffer = BytesBuilder(copy: false);
  BytesBuilder byteBuffer = BytesBuilder(copy: false);
  final int sampleRate;
  final int channels;

  PCMToWavHandler({
    required this.sampleRate,
    required this.channels,
  });

  void opusAppend(Uint8List data) {
    opusByteBuffer.add(data);
  }

  int get opusBufferSize {
    return opusByteBuffer.toBytes().length;
  }

  void opusClear() {
    opusByteBuffer.clear();
  }

  void append(Uint8List data) {
    byteBuffer.add(data);
  }

  // 一次转写接收音频文件
  Future<void> decodeOpus() async {
    Uint8List serializedMsg = opusByteBuffer.takeBytes();
    Uint8List pcmData = await AudioUtil.decodeOpusToPcmData(
        serializedMsg, 40, sampleRate, channels);
    append(pcmData);
    opusClear();
  }

  // 实时接收音频文件
  Future<Uint8List> realtimeDecodeOpus(Uint8List serializedMsg) async {
    Uint8List pcmData = await AudioUtil.decodeOpusToPcmData(
        serializedMsg, 40, sampleRate, channels);
    append(pcmData);
    return pcmData;
  }

  Future<void> writeToFile(String path) async {
    File file = File(path);
    if (!file.existsSync()) {
      file.createSync();
    }
    Uint8List wavData = AudioUtil.pcmToWav(
        pcmData: byteBuffer.takeBytes(),
        sampleRate: sampleRate,
        channels: channels);
    await file.writeAsBytes(wavData);
  }

  void clear() {
    byteBuffer.clear();
  }
}
