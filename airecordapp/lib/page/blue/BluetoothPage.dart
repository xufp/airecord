import 'dart:async';
import 'dart:ui';

import 'package:airecordapp/controller/BlueController.dart';
import 'package:airecordapp/page/blue/DevicePage.dart';
import 'package:airecordapp/page/blue/ScanDevice.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:bluetooth_enable_fork/bluetooth_enable_fork.dart';
import 'package:airecordapp/l10n/generated/l10n.dart';

class BluetoothPage extends StatefulWidget {
  final String uuid;
  final String characteristicWrite;
  final String characteristicNotify;
  final String characteristicBatteryNotify;

  const BluetoothPage(
      {super.key,
      required this.uuid,
      required this.characteristicWrite,
      required this.characteristicNotify,
      required this.characteristicBatteryNotify});

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  final BlueController blueController = Get.find();
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;

  @override
  void initState() {
    super.initState();
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      if (state == BluetoothAdapterState.off) {
        // 弹窗开启蓝牙
        BluetoothEnable.enableBluetooth;
      } else if (state == BluetoothAdapterState.on) {
        blueController.platformName.then((devName) {
          if (devName == '') {
            // 首先监听蓝牙扫描信息
            blueController.scanListen();
            // 开始自动扫描蓝牙
            blueController.startScan(widget.uuid);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    blueController.clearScan();
    blueController.scanResults.value = [];
    blueController.isConnecting.value = false;
    _adapterStateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(70.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  offset: Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: SafeArea(
              child: AppBar(
                automaticallyImplyLeading: true,
                backgroundColor: Colors.white,
                elevation: 0,
                centerTitle: true,
                title: Text(
                  S.of(context).BluetoothPage_k1,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                iconTheme: IconThemeData(
                  color: Color(0xFF666666),
                ),
              ),
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
                    Colors.blue.withOpacity(0.1),
                    Colors.purple.withOpacity(0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.2, 0.6, 1.0],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: blueController.scanResults.isNotEmpty
                  ? _buildResult()
                  : _buildScanPage(),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildScanPage() {
    return Container(
      alignment: Alignment.topCenter,
      child: blueController.isScanIng.value
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                  ScanDevice(),
                  SizedBox(height: 32),
                  Text(
                    S.of(context).BluetoothPage_k2,
                    style: TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 24),
                  Column(
                    children: [
                      Text(
                        S.of(context).BluetoothPage_k3,
                        style: TextStyle(
                          color: Color(0xFF999999),
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        S.of(context).BluetoothPage_k4,
                        style: TextStyle(
                          color: Color(0xFF999999),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ])
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(height: 20),
                Column(
                  children: [
                    Text(
                      S.of(context).BluetoothPage_k5,
                      style: TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      S.of(context).BluetoothPage_k6,
                      style: TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue, Colors.blue.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  margin: EdgeInsets.symmetric(vertical: 50),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      TextButton(
                        onPressed: () => blueController.startScan(widget.uuid),
                        child: Text(
                          S.of(context).BluetoothPage_k6,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ButtonStyle(
                          minimumSize: MaterialStateProperty.all(Size(200, 20)),
                          padding: MaterialStateProperty.all(EdgeInsets.zero),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }

  Widget _buildResult() {
    return Container(
      child: ListView(
        children: _buildScanResultTiles(),
      ),
    );
  }

  List<Widget> _buildScanResultTiles() {
    return blueController.scanResults
        .map(
          (scanResult) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF6C63FF).withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 65,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              scanResult.device.platformName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${S.of(context).BluetoothPage_k7}: ${scanResult.rssi} dBm',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF999999),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 35,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue, Colors.blue.withOpacity(0.8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextButton(
                            onPressed: () {
                              _handleDeviceConnection(scanResult.device);
                            },
                            child: blueController.isConnecting.value
                                ? Container(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(
                                    S.of(context).BluetoothPage_k8,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  void _handleDeviceConnection(BluetoothDevice device) {
    if (blueController.isConnecting.value) return;

    blueController.isConnecting.value = true;
    
    blueController
        .handlerConnectDev(
            device,
            widget.characteristicWrite,
            widget.characteristicNotify,
            widget.characteristicBatteryNotify)
        .then((value) {
      if (value) {
        // 首次配对成功后启动蓝牙自动重连监听
        blueController.forceDeviceListen();
        blueController
            .initListen(device)
            .then((value) {
              blueController.isConnecting.value = false;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DevicePage()),
              );
            });
      } else {
        blueController.isConnecting.value = false;
        _showConnectionFailedDialog();
      }
    });

    // 设置10秒超时
    Timer(Duration(seconds: 10), () {
      if (!blueController.isConnected.value && blueController.isConnecting.value) {
        blueController.isConnecting.value = false;
        _showConnectionFailedDialog();
      }
    });
  }

  void _showConnectionFailedDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          backgroundColor: Colors.white,
          elevation: 0,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                color: Color(0xFF6C63FF),
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                S.of(context).BluetoothPage_k9,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              SizedBox(height: 8),
              Text(
                S.of(context).BluetoothPage_k10,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                blueController.startScan(widget.uuid);
              },
              child: Text(
                S.of(context).BluetoothPage_k11,
                style: TextStyle(
                  color: Color(0xFF6C63FF),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
