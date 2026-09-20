import 'package:airecordapp/l10n/generated/l10n.dart';
import 'package:airecordapp/logic/BleDeviceLogic.dart';
import 'package:airecordapp/page/blue/BluetoothPage.dart';
import 'package:airecordapp/page/blue/v2/BluetoothPageV2.dart';
import 'package:airecordapp/service/response/BleDeviceResponse.dart';
import 'package:flutter/material.dart';

/// 设备列表页：并列展示现款（远端下发）与新款（V2 本地硬编码）两种硬件卡片。
/// 用户点击后按设备类型路由到各自扫描页。
class PenPageList extends StatefulWidget {
  @override
  _PenPageListState createState() => _PenPageListState();
}

class _PenPageListState extends State<PenPageList> {
  final BleDeviceLogic bleDeviceLogic = BleDeviceLogic();

  /// 是否展示 V2（新款）设备卡片。
  /// 当前一期仅上架 V1 设备，V2 相关代码全部保留，待后续放开时把此开关改为 true 即可。
  static const bool _showV2 = false;

  /// V1（现款）设备信息：来自远端 bleDeviceList 接口
  DeviceData? v1Device;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDevice();
  }

  Future<void> loadDevice() async {
    setState(() => isLoading = true);
    try {
      final DeviceData? device = await bleDeviceLogic.bleDevice();
      setState(() {
        v1Device = device;
        isLoading = false;
      });
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;
    final contentMaxWidth = isWideScreen ? 600.0 : screenWidth;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          S.of(context).PenPageList_k1,
          style: TextStyle(
            color: Colors.black87,
            fontSize: isWideScreen ? 20 : 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (!isLoading)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black87),
              onPressed: loadDevice,
            ),
        ],
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  Colors.blue.withOpacity(0.08),
                  Colors.purple.withOpacity(0.08),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          isLoading
              ? _buildLoading(context)
              : Center(
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(maxWidth: contentMaxWidth),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                          horizontal: isWideScreen ? 32 : 16,
                          vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (v1Device != null) _buildV1Card(v1Device!),
                          // V2 设备本期暂不上架，开关打开后自动恢复展示
                          if (_showV2 && v1Device != null)
                            const SizedBox(height: 16),
                          if (_showV2) _buildV2Card(),
                        ],
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          const SizedBox(height: 16),
          Text(
            S.of(context).PenPageList_k2,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ============= V1 卡片（现款录音笔，走 bleDeviceList）=============
  // 注：title / desc 使用本地国际化文案覆盖远端下发字段，便于产品快速调整文案
  Widget _buildV1Card(DeviceData d) {
    return _DeviceCard(
      title: S.of(context).PenPageList_v1_title,
      desc: S.of(context).PenPageList_v1_desc,
      // 设备照片统一使用本地资源，避免远端图片加载失败/不一致
      imageUrl: 'assets/images/voiceimg.jpg',
      isLocalAsset: true,
      buttonText: S.of(context).PenPageList_k23,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BluetoothPage(
              uuid: d.deviceUuid,
              characteristicWrite: d.characteristicWrite,
              characteristicNotify: d.characteristicNotify,
              characteristicBatteryNotify: d.characteristicBatteryNotify,
            ),
          ),
        );
      },
    );
  }

  // ============= V2 卡片（新款录音笔，本地硬编码）=============
  Widget _buildV2Card() {
    return _DeviceCard(
      title: S.of(context).PenPageList_v2_title,
      desc: S.of(context).PenPageList_v2_desc,
      imageUrl: 'assets/images/voiceimg.jpg',
      isLocalAsset: true,
      buttonText: S.of(context).PenPageList_v2_connect,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BluetoothPageV2()),
        );
      },
    );
  }
}

/// 通用设备卡片（V1/V2 共用）。
class _DeviceCard extends StatelessWidget {
  final String title;
  final String desc;
  final String imageUrl;
  final bool isLocalAsset;
  final String buttonText;
  final VoidCallback onTap;

  const _DeviceCard({
    required this.title,
    required this.desc,
    required this.imageUrl,
    required this.isLocalAsset,
    required this.buttonText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 160,
            child: _buildImage(),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style:
                const TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.5),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (imageUrl.isEmpty) {
      // 兜底：无图时使用渐变色占位
      return Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFEAF2FF), Color(0xFFF4EAFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(Icons.mic, size: 56, color: Colors.blueAccent),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: isLocalAsset
          ? Image.asset(
              imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFF7F7F7),
                child: const Center(
                  child: Icon(Icons.image_not_supported,
                      size: 48, color: Colors.grey),
                ),
              ),
            )
          : Image.network(
              imageUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loading) {
                if (loading == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFF7F7F7),
                child: const Center(
                  child: Icon(Icons.image_not_supported,
                      size: 48, color: Colors.grey),
                ),
              ),
            ),
    );
  }
}
