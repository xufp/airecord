import 'package:airecordapp/command/v2/BleDeviceV2Config.dart';
import 'package:airecordapp/command/v2/NewBleResponse.dart';
import 'package:airecordapp/controller/BlueControllerV2.dart';
import 'package:airecordapp/page/HomePage.dart';
import 'package:cupertino_battery_indicator/cupertino_battery_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// V2 新硬件设备页（已连接后）。
class DevicePageV2 extends StatefulWidget {
  const DevicePageV2({super.key});

  @override
  State<DevicePageV2> createState() => _DevicePageV2State();
}

class _DevicePageV2State extends State<DevicePageV2> {
  final BlueControllerV2 c = Get.find<BlueControllerV2>();

  @override
  void initState() {
    super.initState();
    // 首次进入查询一次文件列表
    c.refreshFileList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF333333)),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.offAll(HomePage()),
        ),
        title: const Text(
          '新款录音笔',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333)),
        ),
      ),
      body: Obx(() => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildRecordPanel(),
                const SizedBox(height: 16),
                _buildAudioLevelPanel(),
                const SizedBox(height: 16),
                _buildDownloadPanel(),
                const SizedBox(height: 16),
                _buildFileListPanel(),
                const SizedBox(height: 16),
                _buildFooter(),
              ],
            ),
          )),
    );
  }

  Widget _buildHeader() {
    final name =
        c.devName.value.isNotEmpty ? c.devName.value : BleDeviceV2Config.deviceName;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333)),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: c.isConnected.value
                  ? Colors.blue.withOpacity(0.1)
                  : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                if (c.isConnected.value && c.battery.value <= 100)
                  BatteryIndicator(
                    value: c.battery.value / 100,
                    barColor: Colors.blue,
                  ),
                const SizedBox(width: 6),
                Text(
                  !c.isConnected.value
                      ? '未连接'
                      : (c.battery.value <= 100
                          ? '${c.battery.value}%'
                          : '--'),
                  style: TextStyle(
                    fontSize: 14,
                    color: c.isConnected.value ? Colors.blue : const Color(0xFF999999),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordPanel() {
    final recording = c.isRecording.value;
    final paused = c.isPaused.value;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('录音控制',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333))),
          const SizedBox(height: 10),
          Text('当前状态: ${_stateDesc(recording, paused)}',
              style: const TextStyle(fontSize: 13, color: Color(0xFF666666))),
          if (c.currentFileId.value.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('文件ID: ${c.currentFileId.value}',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF999999))),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _actionBtn(
                  label: recording ? (paused ? '继续录音' : '暂停录音') : '开始录音',
                  color: recording ? Colors.orange : Colors.blue,
                  disabled: !c.isConnected.value,
                  onTap: () {
                    if (!recording) {
                      c.startRecord();
                    } else if (paused) {
                      c.resumeRecord();
                    } else {
                      c.pauseRecord();
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionBtn(
                  label: '停止',
                  color: Colors.red,
                  disabled: !recording,
                  onTap: c.stopRecord,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _stateDesc(bool recording, bool paused) {
    if (!recording) return '空闲';
    if (paused) return '已暂停';
    return '录音中';
  }

  Widget _buildAudioLevelPanel() {
    // 电平：-120~0 dB，归一化到 0~1
    final double lv = c.audioLevel.value.clamp(-120.0, 0.0);
    final double norm = (lv + 120) / 120;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.graphic_eq, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('实时电平: ${lv.toStringAsFixed(1)} dB',
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF666666))),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: norm,
                    minHeight: 6,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.blue),
                    backgroundColor: const Color(0xFFEFEFEF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadPanel() {
    final d = c.currentDownload.value;
    if (d == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('下载中: ${d.fileName}',
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: d.totalBytes == 0 ? null : d.receivedBytes / d.totalBytes,
            minHeight: 8,
          ),
          const SizedBox(height: 6),
          Text(
            '${d.receivedBytes}/${d.totalBytes} bytes  ·  包 ${d.receivedPkg}/${d.totalPkg}  ·  ${d.percent}%' +
                (d.completed ? '  (已完成)' : (d.failed ? '  (失败)' : '')),
            style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
          ),
        ],
      ),
    );
  }

  Widget _buildFileListPanel() {
    final list = c.audioList;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('设备文件列表',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333))),
              ),
              IconButton(
                onPressed: c.refreshFileList,
                icon: const Icon(Icons.refresh, color: Colors.blue),
                tooltip: '刷新',
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (list.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text('暂无文件',
                    style: TextStyle(
                        color: Color(0xFF999999), fontSize: 13)),
              ),
            )
          else
            ...list.map(_buildFileTile),
        ],
      ),
    );
  }

  Widget _buildFileTile(NewAudioFileInfo info) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(info.fileName,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF333333))),
                const SizedBox(height: 2),
                Text(
                  '${_fmtSize(info.size)}  ·  ${info.durationSec}s  ·  ${_fmtFmt(info.format)}',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF999999)),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => c.downloadFile(info),
            icon: const Icon(Icons.download, color: Colors.blue, size: 20),
            tooltip: '下载',
          ),
          IconButton(
            onPressed: () => c.deleteFile(info.fileName),
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            tooltip: '删除',
          ),
        ],
      ),
    );
  }

  String _fmtSize(int bytes) {
    if (bytes < 1024) return '${bytes} B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1024 / 1024).toStringAsFixed(2)} MB';
  }

  String _fmtFmt(int fmt) {
    switch (fmt) {
      case 0:
        return 'MP3';
      case 1:
        return 'WAV';
      case 2:
        return 'OPUSv1';
      case 3:
        return 'OPUSv2';
      default:
        return 'UNKNOWN';
    }
  }

  Widget _buildFooter() {
    return Row(
      children: [
        Expanded(
          child: _actionBtn(
            label: c.isConnected.value ? '断开连接' : '重新扫描',
            color: c.isConnected.value ? Colors.orange : Colors.blue,
            onTap: () async {
              if (c.isConnected.value) {
                await c.disconnect();
              }
              if (!mounted) return;
              Navigator.of(context).pop();
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _actionBtn(
            label: '移除设备',
            color: Colors.red,
            onTap: () async {
              await c.forgetDevice();
              if (!mounted) return;
              Get.offAll(HomePage());
            },
          ),
        ),
      ],
    );
  }

  Widget _actionBtn({
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool disabled = false,
  }) {
    return Opacity(
      opacity: disabled ? 0.4 : 1.0,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: disabled ? null : onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            alignment: Alignment.center,
            child: Text(
              label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
