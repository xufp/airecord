import 'dart:async';
import 'dart:ui';

import 'package:airecordapp/controller/BlueController.dart';
import 'package:airecordapp/page/HomePage.dart';
import 'package:cupertino_battery_indicator/cupertino_battery_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:bluetooth_enable_fork/bluetooth_enable_fork.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:airecordapp/l10n/generated/l10n.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({super.key});

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  final BlueController blueController = Get.find();
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  bool _allowPop = false; // 标记是否允许返回

  @override
  void initState() {
    super.initState();
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      if (state == BluetoothAdapterState.off) {
        BluetoothEnable.enableBluetooth;
      }
    });
  }

  connectDev() {
    blueController.connectDevRemoteId().then((device) {
      if (device != null) {
        blueController.initListen(device);
      }
    });
  }

  @override
  void dispose() {
    _adapterStateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
      return PopScope(
        canPop: _allowPop,  // 删除设备后允许正常返回
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          // 连接成功后按返回键直接回到主页列表
          if (_allowPop) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => HomePage()),
              (route) => false,
            );
          } else {
            Get.offAll(HomePage());
          }
        },
        child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.close, color: Colors.black87),
            onPressed: () {
              if (mounted) setState(() => _allowPop = true);
              Future.delayed(Duration(milliseconds: 100), () {
                if (!mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => HomePage()),
                  (route) => false,
                );
              });
            },
          ),
          title: Text(
            S.of(context).DevicePage_k1,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'PingFang SC-Semibold',
              color: Color(0xFF333333),
            ),
          ),
          centerTitle: true,
          iconTheme: IconThemeData(color: Color(0xFF333333)),
        ),
        body: _buildResult(),
      ),
    );
  }

  Widget _buildResult() {
    return Obx(() => Container(
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // 设备信息区域
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 设备名称和状态
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Color(0xFFEEEEEE),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                blueController.devName.value,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF333333),
                                ),
                              ),
                            ),
                            if (blueController.isConnected.value) ...[
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    blueController.qel.value <= 100
                                        ? BatteryIndicator(
                                            value:
                                                blueController.qel.value / 100,
                                            barColor: Colors.blue,
                                          )
                                        : Container(),
                                    SizedBox(width: 8),
                                    Text(
                                      blueController.qel.value <= 100
                                          ? '${blueController.qel.value}%'
                                          : S.of(context).DevicePage_k2,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  S.of(context).DevicePage_k3,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF999999),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24),

                      // 设备说明
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Color(0xFFEEEEEE),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              S.of(context).DevicePage_k4,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF333333),
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              S.of(context).DevicePage_k5,
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF666666),
                                height: 1.8,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24),

                      // 设备操作区域
                      _buildHasDev(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  _buildHasDev() {
    return Column(
      children: [
        blueController.isConnected.value ? Container() : _buildReconnect(),
        SizedBox(height: 16),
        blueController.isConnected.value
            ? _buildDisconnectButton()
            : _buildDeleteButton(),
      ],
    );
  }

  Widget _buildReconnect() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(0xFFEEEEEE),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  if (!blueController.isConnecting.value) {
                    connectDev();
                    _showConnectingDialog();
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: blueController.isConnecting.value
                        ? Container(
                            width: 24,
                            height: 24,
                            child: LoadingIndicator(
                              indicatorType: Indicator.ballClipRotate,
                              colors: const [Colors.white],
                              strokeWidth: 2,
                              backgroundColor: Colors.transparent,
                              pathBackgroundColor: Colors.transparent,
                            ),
                          )
                        : Text(
                            S.of(context).DevicePage_k6,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showConnectingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          backgroundColor: Colors.white,
          elevation: 0,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                child: LoadingIndicator(
                  indicatorType: Indicator.ballClipRotate,
                  colors: const [Colors.blue],
                  strokeWidth: 2,
                  backgroundColor: Colors.transparent,
                  pathBackgroundColor: Colors.transparent,
                ),
              ),
              SizedBox(height: 16),
              Text(
                S.of(context).DevicePage_k7,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              SizedBox(height: 12),
              Text(
                S.of(context).DevicePage_k8,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
        );
      },
    );

    // 设置10秒超时
    Timer(Duration(seconds: 10), () {
      if (!blueController.isConnected.value) {
        Navigator.of(context).pop(); // 关闭连接中对话框
        _showConnectionFailedDialog();
      }
    });

    // 监听连接状态变化
    ever(blueController.isConnected, (connected) {
      if (connected) {
        Navigator.of(context).pop(); // 关闭连接中对话框
        _showSuccessDialog();
      } else if (!blueController.isConnecting.value) {
        Navigator.of(context).pop(); // 关闭连接中对话框
        _showErrorDialog();
      }
    });
  }

  void _showConnectionFailedDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          backgroundColor: Colors.white,
          elevation: 0,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bluetooth_disabled,
                color: Colors.red,
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                S.of(context).DevicePage_k9,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              SizedBox(height: 12),
              Text(
                S.of(context).DevicePage_k10,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                  height: 1.6,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            Divider(height: 1, color: Color(0xFFEEEEEE)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        blueController.isConnecting.value = false;
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        S.of(context).DevicePage_k11,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF666666),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 24,
                    width: 1,
                    color: Color(0xFFEEEEEE),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        blueController.isConnecting.value = false;
                        connectDev();
                        _showConnectingDialog();
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        S.of(context).DevicePage_k12,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          backgroundColor: Colors.white,
          elevation: 0,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                S.of(context).DevicePage_k13,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            Divider(height: 1, color: Color(0xFFEEEEEE)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  S.of(context).DevicePage_k14,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          backgroundColor: Colors.white,
          elevation: 0,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                S.of(context).DevicePage_k15,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              SizedBox(height: 12),
              Text(
                S.of(context).DevicePage_k16,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            Divider(height: 1, color: Color(0xFFEEEEEE)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  S.of(context).DevicePage_k17,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDisconnectButton() {
    return Container(
      width: double.infinity,
      child: TextButton(
        onPressed: () {
          _showCancelDialog();
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          S.of(context).DevicePage_k18,
          style: TextStyle(
            fontSize: 16,
            color: Colors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return Container(
      width: double.infinity,
      child: TextButton(
        onPressed: () {
          _showDeleteDialog();
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          S.of(context).DevicePage_k19,
          style: TextStyle(
            fontSize: 16,
            color: Colors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          backgroundColor: Colors.white,
          elevation: 0,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                S.of(context).DevicePage_k20,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              SizedBox(height: 12),
              Text(
                '删除后将无法恢复设备信息',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            Divider(height: 1, color: Color(0xFFEEEEEE)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(false);
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        S.of(context).DevicePage_k25,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF666666),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 24,
                    width: 1,
                    color: Color(0xFFEEEEEE),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        // 1. 关闭删除确认弹窗
                        Navigator.of(dialogContext).pop();
                        // 2. 删除设备缓存
                        await blueController.delDevCache();
                        // 3. 允许 pop（更新 PopScope 状态）
                        if (mounted) setState(() => _allowPop = true);
                        // 4. 延迟一帧确保状态生效，然后彻底替换导航栈
                        Future.delayed(Duration(milliseconds: 100), () {
                          if (!mounted) return;
                          // 清空所有路由，只保留新的首页
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => HomePage()),
                            (route) => false,
                          );
                        });
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        S.of(context).DevicePage_k26,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          backgroundColor: Colors.white,
          elevation: 0,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                S.of(context).DevicePage_k19,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              SizedBox(height: 12),
              Text(
                S.of(context).DevicePage_k20,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            Divider(height: 1, color: Color(0xFFEEEEEE)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(false);
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        S.of(context).DevicePage_k25,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF666666),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 24,
                    width: 1,
                    color: Color(0xFFEEEEEE),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        blueController.disconnectDevCache().then((_) {
                          if (mounted) setState(() => _allowPop = true);
                          Future.delayed(Duration(milliseconds: 100), () {
                            if (!mounted) return;
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => HomePage()),
                              (route) => false,
                            );
                          });
                        });
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        S.of(context).DevicePage_k26,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
