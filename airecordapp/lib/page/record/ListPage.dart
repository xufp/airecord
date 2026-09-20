import 'package:airecordapp/controller/BlueController.dart';
import 'package:airecordapp/controller/RecordingController.dart';
import 'package:airecordapp/enum/ImportStateEnum.dart';
import 'package:airecordapp/l10n/generated/l10n.dart';
import 'package:airecordapp/logic/PackageLogic.dart';
import 'package:airecordapp/page/blue/DevicePage.dart';
import 'package:airecordapp/page/blue/PenPageList.dart';
import 'package:airecordapp/page/record/OperateFilePage.dart';
import 'package:airecordapp/page/record/SearchFilePage.dart';
import 'package:airecordapp/page/widget/BuyRecommendWidget.dart';
import 'package:airecordapp/page/widget/CloudAudioWidget.dart';
import 'package:airecordapp/page/widget/ItemWidget.dart';
import 'package:airecordapp/page/widget/RecordPenWidget.dart';
import 'package:airecordapp/page/widget/SyncAudioWidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter/services.dart';

class ListPage extends StatefulWidget {
  GlobalKey<ScaffoldState> _scaffoldKey;

  ListPage(this._scaffoldKey);

  @override
  State<ListPage> createState() => _ListState(_scaffoldKey);
}

class _ListState extends State<ListPage> {
  final RecordingController dataController = Get.find();
  final BlueController blueController = Get.find();
  PackageLogic packageLogic = PackageLogic();
  bool _isTransLoading = false;

  GlobalKey<ScaffoldState> _scaffoldKey;

  _ListState(this._scaffoldKey);

  @override
  void initState() {
    super.initState();
    // 设置状态栏文字颜色为深色
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
    // 预先初始化 OperateFilePage 的 controller
    if (!Get.isRegistered<RecordingController>(tag: 'operatePageController')) {
      Get.put(RecordingController(getAll: true),
          tag: 'operatePageController', permanent: true);
    }
    // 使用 addPostFrameCallback 确保在构建完成后加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dataController.getAllList();
    });
  }

  /**
   * 连接录音笔
   */
  _connectRecordPen() {
    // 同时检查设备是否已连接和设备名称
    if (blueController.isConnected.value) {
      // 设备已连接，直接跳转到设备页面
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => DevicePage()));
    } else {
      blueController.platformName.then((devName) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => devName == '' ? PenPageList() : DevicePage()));
      });
    }
  }

  /**
   * 判断是否有套餐
   */
  Future<void> _handleTranscriptionTap() async {
    if (_isTransLoading) return;
    setState(() {
      _isTransLoading = true;
    });
    try {
      if (await packageLogic.isHasTrans()) {
        if (!blueController.isConnected.value) {
          showAlertDialog(S.of(context).ListPage_k5);
          return;
        }
        Get.to(RecordPenWidget());
      } else {
        BuyRecommendWidget.showDialog(context);
      }
    } finally {
      setState(() {
        _isTransLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _refreshData() async {
    // 如果已连接录音笔，先同步录音笔文件
    if (blueController.isConnected.value) {
      await blueController.autoImportFile();
    }
    // 再刷新数据列表
    await dataController.reloadData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;
    final horizontalPadding = isWideScreen ? 24.0 : 16.0;
    final cardPadding = isWideScreen ? 20.0 : 12.0;

    return Obx(() {
      return Scaffold(
        backgroundColor: Color(0xFFF5F7FA),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(isWideScreen ? 260.0 : 230.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(horizontalPadding, 12, horizontalPadding, 0),
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            S.of(context).ListPage_k1,
                            style: TextStyle(
                              fontSize: isWideScreen ? 26 : 22,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 10),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            S.of(context).ListPage_k2,
                            style: TextStyle(
                              fontSize: isWideScreen ? 14 : 12,
                              color: Color(0xFF666666),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: cardPadding),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildFeatureButton(
                            icon: Icons.devices_other,
                            label: S.of(context).ListPage_k3,
                            onTap: _connectRecordPen,
                            isWideScreen: isWideScreen),
                        SizedBox(width: isWideScreen ? 16 : 4),
                        _buildFeatureButton(
                          icon: Icons.mic_none,
                          label: S.of(context).ListPage_k6,
                          onTap: _handleTranscriptionTap,
                          isWideScreen: isWideScreen,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    color: Color(0xFFF5F7FA),
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(
                              S.of(context).ListPage_k7,
                              style: TextStyle(
                                fontSize: isWideScreen ? 17 : 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            SizedBox(width: 6),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: Color(0xFFE3F2FD),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${dataController.dataList.length}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF2196F3),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            _buildIconButton(
                              icon: Icons.search,
                              onPressed: () => Get.to(SearchFilePage()),
                            ),
                            SizedBox(width: 6),
                            Obx(() => blueController.isConnected.value
                                ? _buildSyncButton()
                                : SizedBox.shrink()),
                            SizedBox(width: 6),
                            _buildIconButton(
                              icon:
                                  HugeIcons.strokeRoundedLeftToRightListBullet,
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => OperateFilePage(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              SyncAudioWidget(),
              CloudAudioWidget(),
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: ItemWidget(
                    refreshData: _refreshData,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildFeatureButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isWideScreen = false,
  }) {
    final bgColor = label == S.of(context).ListPage_k3
        ? Color(0xFF2196F3)
        : label == S.of(context).ListPage_k4
            ? Color(0xFF4CAF50)
            : Color(0xFF00BCD4);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isWideScreen ? 16 : 12),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: isWideScreen ? 16 : 12,
            horizontal: isWideScreen ? 12 : 6,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(isWideScreen ? 16 : 12),
            boxShadow: [
              BoxShadow(
                color: bgColor.withOpacity(0.2),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isWideScreen ? 18 : 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Text(
                label == S.of(context).ListPage_k3
                    ? S.of(context).ListPage_k8
                    : label == S.of(context).ListPage_k4
                        ? S.of(context).ListPage_k9
                        : S.of(context).ListPage_k10,
                style: TextStyle(
                  fontSize: isWideScreen ? 13 : 10,
                  color: Colors.white.withOpacity(0.85),
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSyncButton() {
    return Obx(() {
      bool isSyncing =
          ImportStateEnum.closeSync(blueController.importState.value);
      IconData buttonIcon = isSyncing ? Icons.sync : Icons.sync;
      return Container(
        width: 32,
        height: 32,
        child: TextButton(
          onPressed: blueController.autoImportFile,
          child: Icon(buttonIcon,
              color: isSyncing ? Color(0xFF2196F3) : Color(0xFF666666),
              size: 18),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: isSyncing ? Color(0xFFE3F2FD) : Color(0xFFF5F5F5),
          ),
        ),
      );
    });
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 32,
      height: 32,
      child: TextButton(
        onPressed: onPressed,
        child: Icon(icon, color: Color(0xFF666666), size: 18),
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: Color(0xFFF5F5F5),
        ),
      ),
    );
  }

  void showAlertDialog(String msg) {
    showDialog(
        context: context,
        builder: (dialogContext) {
          AlertDialog alertDialog = AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            backgroundColor: Colors.white,
            elevation: 0,
            content: Text(
              msg,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF1A1A1A),
              ),
            ),
            actionsPadding: EdgeInsets.zero,
            actions: <Widget>[
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.of(dialogContext).pop(false),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Color(0xFFF5F5F5)),
                            right: BorderSide(color: Color(0xFFF5F5F5)),
                          ),
                        ),
                        child: Text(
                          S.of(context).ListPage_k11,
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: _connectRecordPen,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Color(0xFFF5F5F5)),
                            left: BorderSide(color: Color(0xFFF5F5F5)),
                          ),
                        ),
                        child: Text(
                          S.of(context).ListPage_k12,
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF2196F3),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          );
          return alertDialog;
        });
  }
}
