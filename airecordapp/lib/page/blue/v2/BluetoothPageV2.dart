import 'dart:async';

import 'package:airecordapp/command/v2/BleDeviceV2Config.dart';
import 'package:airecordapp/controller/BlueControllerV2.dart';
import 'package:airecordapp/page/blue/ScanDevice.dart';
import 'package:airecordapp/page/blue/v2/DevicePageV2.dart';
import 'package:bluetooth_enable_fork/bluetooth_enable_fork.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

/// V2 新硬件扫描页。
class BluetoothPageV2 extends StatefulWidget {
  const BluetoothPageV2({super.key});

  @override
  State<BluetoothPageV2> createState() => _BluetoothPageV2State();
}

class _BluetoothPageV2State extends State<BluetoothPageV2> {
  final BlueControllerV2 controller = Get.find<BlueControllerV2>();
  StreamSubscription<BluetoothAdapterState>? _adapterSub;

  @override
  void initState() {
    super.initState();
    _adapterSub = FlutterBluePlus.adapterState.listen((state) {
      if (state == BluetoothAdapterState.off) {
        BluetoothEnable.enableBluetooth;
      } else if (state == BluetoothAdapterState.on) {
        controller.startScan();
      }
    });
  }

  @override
  void dispose() {
    controller.stopScan();
    controller.clearScan();
    _adapterSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            iconTheme: const IconThemeData(color: Color(0xFF666666)),
            title: Text(
              '${BleDeviceV2Config.deviceName} · 扫描',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
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
              Padding(
                padding: const EdgeInsets.all(16),
                child: controller.scanResults.isNotEmpty
                    ? _buildResult()
                    : _buildScanHint(),
              ),
            ],
          ),
        ));
  }

  Widget _buildScanHint() {
    return Center(
      child: controller.isScanning.value
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScanDevice(),
                const SizedBox(height: 28),
                const Text(
                  '正在搜索新款录音笔...',
                  style: TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Text(
                  '请确认设备已开机、蓝牙广播名为 ${BleDeviceV2Config.advLocalName}',
                  style:
                      const TextStyle(color: Color(0xFF999999), fontSize: 13),
                ),
              ],
            )
          : _buildRescanButton(),
    );
  }

  Widget _buildRescanButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '未发现设备',
          style: TextStyle(color: Color(0xFF666666), fontSize: 16),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () => controller.startScan(),
          icon: const Icon(Icons.refresh, color: Colors.white),
          label: const Text('重新扫描',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          style: TextButton.styleFrom(
            backgroundColor: Colors.blue,
            padding:
                const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResult() {
    return ListView.separated(
      itemCount: controller.scanResults.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final r = controller.scanResults[i];
        final adv = (() {
          // 轻量内联解析：仅用于 UI 展示电量
          for (final e in r.advertisementData.manufacturerData.entries) {
            final bytes = e.value;
            if (bytes.length >= 9 && bytes[6] == BleDeviceV2Config.advCompanyId) {
              return bytes[8];
            }
          }
          return null;
        })();
        final displayName = r.advertisementData.advName.isNotEmpty
            ? r.advertisementData.advName
            : r.device.platformName;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C63FF).withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName.isEmpty
                          ? BleDeviceV2Config.deviceName
                          : displayName,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '信号: ${r.rssi} dBm' +
                          (adv != null ? '  ·  电量: $adv%' : ''),
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF999999)),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => _onConnect(r.device),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: controller.isConnecting.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('连接',
                        style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onConnect(BluetoothDevice device) async {
    if (controller.isConnecting.value) return;
    await controller.stopScan();
    final ok = await controller.connectAndInit(device);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DevicePageV2()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('连接失败，请重试'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
