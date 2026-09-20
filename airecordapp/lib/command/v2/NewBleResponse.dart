import 'dart:convert';
import 'dart:typed_data';

import 'package:airecordapp/command/v2/Crc16FastTbl.dart';
import 'package:airecordapp/command/v2/NewBleCommand.dart';
import 'package:airecordapp/command/v2/NewBleFrame.dart';
import 'package:airecordapp/util/LogUtil.dart';

/// 新硬件音频文件元数据（对应协议 5.18）。
class NewAudioFileInfo {
  final String fileName;
  final int format; // 00 MP3 / 01 WAV / 02 OPUSV1 / 03 OPUSV2
  final int timestamp; // 大端 4B，单位秒
  final int size; // 大端 4B，单位字节
  final int durationSec; // 大端 4B，单位秒
  final int fileCrc; // 2B

  NewAudioFileInfo({
    required this.fileName,
    required this.format,
    required this.timestamp,
    required this.size,
    required this.durationSec,
    required this.fileCrc,
  });

  @override
  String toString() =>
      'NewAudioFileInfo(name=$fileName, fmt=$format, size=$size, dur=${durationSec}s)';
}

/// 新硬件录音状态应答（对应协议 4.2/5.2）。
class NewRecStateResult {
  /// 0x00 失败 / 0x01 成功 / 0xFF 内存已满 / 0xFE 电量不足
  final int result;

  /// 0 关 / 1 开 / 2 暂停 / 3 恢复
  final int state;

  /// 文件唯一 ID：13 字节，前 6 字节为 MAC(BCD)，后 7 字节为时间（如 20241122210923）
  final String fileUniqueId;

  NewRecStateResult({
    required this.result,
    required this.state,
    required this.fileUniqueId,
  });

  bool get success => result == 0x01;
  bool get memFull => result == 0xFF;
  bool get lowBattery => result == 0xFE;
}

/// 文件下载请求应答（对应协议 5.19）。
class NewFileDownloadAck {
  final String fileName;
  final bool exist;
  final int errorCode;
  final int totalPkgCount; // 文件总包数
  final int syncResult; // 0 开始/1 取消/2 暂停/3 继续/0xFF 失败

  NewFileDownloadAck({
    required this.fileName,
    required this.exist,
    required this.errorCode,
    required this.totalPkgCount,
    required this.syncResult,
  });
}

/// 文件数据包（对应协议 5.20）。FFE0 服务上的纯数据帧。
/// 帧结构：0xFFFFFF(3B) + pkgIndex(3B) + data(240 or 320) + CRC16(2B)
class NewFileDataPacket {
  final int pkgIndex;
  final Uint8List data;

  NewFileDataPacket({required this.pkgIndex, required this.data});
}

/// 语音识别内容上报（对应协议 6.1）3 包拼装结果。
class NewTranscribeChunk {
  final Uint8List data;

  NewTranscribeChunk(this.data);
}

/// 响应解析器。由 BlueServiceV2 将原始 notify 字节交给此类解析。
///
/// 内部维护三类有状态的重组：
/// 1. 文件列表分包（0xFF 包头 + 续包 0x1d / 尾包 0x2d）。
/// 2. 文件下载数据包（5.20）。
/// 3. 语音识别 0x90 三段大包（6.1）。
class NewBleResponse {
  final _logger = LogUtil.inItLog();

  // ---- 文件列表分包重组 ----
  final BytesBuilder _fileListBuffer = BytesBuilder();
  bool _fileListInProgress = false;

  // ---- 语音 0x90 三段重组 ----
  final BytesBuilder _voiceBuffer = BytesBuilder();
  int _voiceChunkCount = 0;

  // =================== 通用入口 ===================

  /// 尝试将输入的一段通知字节解析为帧。
  /// 不包含业务状态；业务状态由具体响应方法处理。
  NewBleFrame? parseFrame(Uint8List raw) {
    final frame = NewBleFrame.tryParse(raw);
    if (frame == null) {
      _logger.d(
          'v2 notify 解析失败，长度=${raw.length} prefix=${_hexPrefix(raw, 16)}');
    }
    return frame;
  }

  // =================== 4.1 电量应答 ===================
  int? parseBattery(NewBleFrame frame) {
    if (frame.cmd != NewBleCommand.cmdQel) return null;
    if (frame.params.isEmpty) return null;
    return frame.params[0] & 0xFF;
  }

  // =================== 4.2 / 5.2 录音状态 ===================
  NewRecStateResult? parseRecState(NewBleFrame frame) {
    if (frame.cmd != NewBleCommand.cmdWriteRecState &&
        frame.cmd != NewBleCommand.cmdReadRecState) {
      return null;
    }
    if (frame.params.length < 1 + 1 + 13) return null;
    final int state = frame.params[0] & 0xFF;
    final int result = frame.params[1] & 0xFF;
    final Uint8List idBytes = frame.params.sublist(2, 15);
    return NewRecStateResult(
      result: result,
      state: state,
      fileUniqueId: _bcdToString(idBytes),
    );
  }

  // =================== 5.18 文件列表（含分包）===================

  /// 处理一条可能与文件列表相关的帧。
  /// - 若是文件列表的开头 / 续包 / 尾包，吸收进内部 buffer。
  /// - 当整个列表拼装完毕，返回解析后的 [NewAudioFileInfo] 列表。
  /// - 若传入帧不属于文件列表，返回 null。
  List<NewAudioFileInfo>? feedFileList(Uint8List raw) {
    // 文件列表的每一包都以 0xFF 作为第一个字节开始
    if (raw.isEmpty || (raw[0] & 0xFF) != 0xFF) {
      return null;
    }
    // 取数据长度（2B，先发高字节）
    if (raw.length < 3) return null;
    final int dataLen = ((raw[1] & 0xFF) << 8) | (raw[2] & 0xFF);

    // 首包：0xFF | len(2) | 0x13 | count(2) | 文件列表...
    // 续包/尾包：0xFF | len(2) | 0x1d/0x2d | 文件列表...
    if (raw.length < 4) return null;
    final int thirdByte = raw[3] & 0xFF;

    if (thirdByte == NewBleCommand.cmdFileList) {
      // 首包
      _fileListBuffer.clear();
      _fileListInProgress = true;
      // 首包内已包含 count + 部分文件项
      // 取 count(2B, 先高后低)
      if (raw.length < 6) return null;
      final int count = ((raw[4] & 0xFF) << 8) | (raw[5] & 0xFF);
      // 暂存 count 之后的文件条目原始字节（不含 0xFF/len/0x13/count）
      const int payloadStart = 6;
      final int payloadEnd = 3 + dataLen; // 0xFF + 2B len 之后 dataLen 字节
      if (raw.length < payloadEnd) return null;
      _fileListBuffer.add(raw.sublist(payloadStart, payloadEnd));

      // 如果声明长度跟包实际长度一致，则此包即是全部
      // 通常需等待 0x1d 续包或 0x2d 尾包
      // 首包后面若没有续包也没有尾包，按"count 推断是否完整"兜底
      final res = _tryDecodeFileList(expectedCount: count);
      if (res != null) {
        _resetFileList();
        return res;
      }
      return null;
    }

    if (!_fileListInProgress) return null;

    if (thirdByte == 0x1D || thirdByte == 0x2D) {
      const int payloadStart = 4;
      final int payloadEnd = 3 + dataLen;
      if (raw.length < payloadEnd) return null;
      _fileListBuffer.add(raw.sublist(payloadStart, payloadEnd));
      if (thirdByte == 0x2D) {
        // 尾包
        final res = _tryDecodeFileList();
        _resetFileList();
        return res ?? <NewAudioFileInfo>[];
      }
      // 续包，继续等待
      return null;
    }

    // 不是文件列表相关分包
    return null;
  }

  List<NewAudioFileInfo>? _tryDecodeFileList({int? expectedCount}) {
    final Uint8List bytes = _fileListBuffer.toBytes();
    final List<NewAudioFileInfo> result = <NewAudioFileInfo>[];
    int offset = 0;
    while (offset < bytes.length) {
      if (offset + 1 > bytes.length) break;
      final int nameLen = bytes[offset] & 0xFF;
      offset += 1;
      if (offset + nameLen + 1 + 1 + 4 + 4 + 4 + 2 > bytes.length) {
        return null; // 数据尚未收全
      }
      final String name =
          ascii.decode(bytes.sublist(offset, offset + nameLen));
      offset += nameLen;
      final int format = bytes[offset] & 0xFF;
      offset += 1;
      // reserved
      offset += 1;
      final int timestamp = _readUint32BE(bytes, offset);
      offset += 4;
      final int size = _readUint32BE(bytes, offset);
      offset += 4;
      final int duration = _readUint32BE(bytes, offset);
      offset += 4;
      final int crc = ((bytes[offset] & 0xFF) << 8) | (bytes[offset + 1] & 0xFF);
      offset += 2;
      result.add(NewAudioFileInfo(
        fileName: name,
        format: format,
        timestamp: timestamp,
        size: size,
        durationSec: duration,
        fileCrc: crc,
      ));
    }

    if (expectedCount != null && result.length < expectedCount) {
      return null; // 还不够，等待续包
    }
    return result;
  }

  void _resetFileList() {
    _fileListBuffer.clear();
    _fileListInProgress = false;
  }

  // =================== 5.19 文件下载请求应答 ===================
  NewFileDownloadAck? parseFileDownloadAck(NewBleFrame frame) {
    if (frame.cmd != NewBleCommand.cmdFileDownload) return null;
    if (frame.params.length < 1 + 1 + 3 + 1) return null;
    // 文件状态(1) + 文件名(变长) + 错误码(1) + 包数(3, 高字节先) + 同步结果(1)
    // 由于文件名变长，需要"后向定位"：最后 1 字节同步结果，再前 3 字节包数，再前 1 字节错误码
    // 往前还有 1 字节文件状态；剩下中间是 ASCII 文件名
    final int total = frame.params.length;
    final int exist = frame.params[0] & 0xFF;
    final int syncResult = frame.params[total - 1] & 0xFF;
    final int pkgCount = ((frame.params[total - 4] & 0xFF) << 16) |
        ((frame.params[total - 3] & 0xFF) << 8) |
        (frame.params[total - 2] & 0xFF);
    final int errorCode = frame.params[total - 5] & 0xFF;
    final Uint8List nameBytes = frame.params.sublist(1, total - 5);
    final String name = ascii.decode(nameBytes, allowInvalid: true);
    return NewFileDownloadAck(
      fileName: name,
      exist: exist == 0x01,
      errorCode: errorCode,
      totalPkgCount: pkgCount,
      syncResult: syncResult,
    );
  }

  // =================== 5.20 文件数据包（FFE0 通道）===================

  /// 解析 FFE0 通道上文件下载的数据包。
  /// 帧结构：0xFFFFFF(3B) + pkgIndex(3B) + data(240 or 320) + CRC16(2B)
  NewFileDataPacket? parseFileDataPacket(Uint8List raw) {
    if (raw.length < 3 + 3 + 2 + 1) return null;
    if ((raw[0] & 0xFF) != 0xFF ||
        (raw[1] & 0xFF) != 0xFF ||
        (raw[2] & 0xFF) != 0xFF) {
      return null;
    }
    final int pkgIndex =
        ((raw[3] & 0xFF) << 16) | ((raw[4] & 0xFF) << 8) | (raw[5] & 0xFF);
    // 尝试 OPUSv1 (240) 和 OPUSv2 (320) 两种 data 长度匹配：
    // 校验 CRC 覆盖 "包头开始 到 音频原始数据结尾"（协议 5.20 备注）
    for (final int dataLen in const [320, 240]) {
      final int total = 3 + 3 + dataLen + 2;
      if (raw.length < total) continue;
      final Uint8List crcRange = Uint8List.fromList(raw.sublist(0, 6 + dataLen));
      final int calcCrc = crc16Fast(crcRange);
      final int recvCrc =
          ((raw[6 + dataLen + 1] & 0xFF) << 8) | (raw[6 + dataLen] & 0xFF);
      if (calcCrc == recvCrc) {
        return NewFileDataPacket(
          pkgIndex: pkgIndex,
          data: Uint8List.fromList(raw.sublist(6, 6 + dataLen)),
        );
      }
    }
    // CRC 未匹配：日志记录但仍然返回一个保守结果（不带 CRC 校验）。
    // 这里选择返回 null，让上层触发续传 0xA3。
    _logger.d('v2 文件数据包 CRC 不匹配或长度未知，length=${raw.length}');
    return null;
  }

  // =================== 5.23 实时电平（FFE0 通道）===================

  /// 解析 0xA8 实时电平。返回 -120~0 的 Float 值。
  double? parseAudioLevel(NewBleFrame frame) {
    if (frame.cmd != 0xA8) return null;
    if (frame.params.length < 4) return null;
    final bd =
        ByteData.sublistView(frame.params, 0, 4);
    return bd.getFloat32(0, Endian.little);
  }

  // =================== 6.1 语音识别内容上报（0x90）===================

  /// 接收一个 0x90 语音上报帧；每三包拼成一个完整 chunk 返回。
  NewTranscribeChunk? feedVoicePacket(NewBleFrame frame) {
    if (frame.cmd != 0x90) return null;
    _voiceBuffer.add(frame.params);
    _voiceChunkCount += 1;
    if (_voiceChunkCount >= 3) {
      final bytes = _voiceBuffer.toBytes();
      _voiceBuffer.clear();
      _voiceChunkCount = 0;
      return NewTranscribeChunk(bytes);
    }
    return null;
  }

  /// 中断时重置内部状态。
  void reset() {
    _resetFileList();
    _voiceBuffer.clear();
    _voiceChunkCount = 0;
  }

  // =================== 辅助 ===================

  static int _readUint32BE(Uint8List data, int offset) {
    return ((data[offset] & 0xFF) << 24) |
        ((data[offset + 1] & 0xFF) << 16) |
        ((data[offset + 2] & 0xFF) << 8) |
        (data[offset + 3] & 0xFF);
  }

  static String _bcdToString(Uint8List data) {
    final buf = StringBuffer();
    for (final int b in data) {
      buf.write((b & 0xFF).toRadixString(16).padLeft(2, '0').toUpperCase());
    }
    return buf.toString();
  }

  static String _hexPrefix(Uint8List data, int max) {
    final int n = data.length > max ? max : data.length;
    return data
        .sublist(0, n)
        .map((e) => e.toRadixString(16).padLeft(2, '0'))
        .join(' ');
  }
}
