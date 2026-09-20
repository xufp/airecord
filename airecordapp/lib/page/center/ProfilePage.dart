import 'package:airecordapp/db/Cache.dart';
import 'package:airecordapp/logic/LoginLogic.dart';
import 'package:airecordapp/logic/ProfileLogic.dart';
import 'package:airecordapp/page/login/EmailLoginPage.dart';
import 'package:airecordapp/page/center/ClearCachePage.dart';
import 'package:airecordapp/service/response/ActivateMemberResponse.dart';
import 'package:airecordapp/service/response/UserInfoResponse.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:airecordapp/l10n/generated/l10n.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  ProfileLogic logic = ProfileLogic();
  UserInfoResponse? userInfoResponse;
  int packageConvertUsed = 0;
  int packageConvertTotal = 0;
  int packageStorageUsed = 0;
  int packageStorageTotal = 0;
  String userId = '';

  @override
  void initState() {
    super.initState();
    // 设置状态栏样式
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Color(0xFFF5F7FA),  // 设置为与背景相同的颜色
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
    _initializeData();
  }

  Future<void> _initializeData() async {
    // 优先从缓存获取用户信息
    userInfoResponse = await Cache.userInfo;
    userId = await Cache.userId;
    setState(() {}); // 立即更新UI显示缓存数据

    // 异步获取最新数据
    _refreshUserInfo();
    _refreshPackageInfo();
  }

  Future<void> _refreshUserInfo() async {
    logic.isChanged().then((value) async {
      if (value) {
        var userInfo = await Cache.userInfo;
        setState(() {
          userInfoResponse = userInfo;
        });
      }
    });
  }

  Future<void> _refreshPackageInfo() async {
    logic.userPackage().then((value) {
      setState(() {
        packageConvertUsed = value.convert?.used ?? 0;
        packageConvertTotal = value.convert?.total ?? 0;
        packageStorageUsed = value.storage?.used ?? 0;
        packageStorageTotal = value.storage?.total ?? 0;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      body: Column(
        children: [
          // 添加状态栏占位
          Container(
            height: MediaQuery.of(context).padding.top,
            color: Color(0xFFF5F7FA),
          ),
          // 用户信息区域
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF2196F3),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF2196F3).withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.person,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              userInfoResponse?.nickName ?? "",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            SizedBox(width: 8),
                            _buildMemberIcon(userInfoResponse?.membershipLevel ?? 0),
                          ],
                        ),
                        Text(
                          userId,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => confirmLogout(),
                  icon: Icon(Icons.logout, color: Color(0xFF666666)),
                ),
              ],
            ),
          ),
          // 列表内容
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 12),
              children: [
                _buildSection(
                  children: [
                    _buildMenuItem(
                      title: S.of(context).ProfilePage_k1,
                      icon: Icons.devices,
                      onTap: () => Get.toNamed('/member'),
                    ),
                    _buildDivider(),
                    _buildMemberCard(),
                  ],
                ),
                _buildSection(
                  children: [
                    _buildMenuItem(
                      title: S.of(context).ProfilePage_k2,
                      icon: Icons.history,
                      onTap: () => Get.toNamed('/convertRecord'),
                    ),
                  ],
                ),
                _buildSection(
                  children: [
                    _buildMenuItem(
                      title: S.of(context).ProfilePage_k4,
                      icon: Icons.feedback,
                      onTap: () => Get.toNamed('/feedBack'),
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      title: S.of(context).ProfilePage_k5,
                      icon: Icons.help_outline,
                      onTap: () => Get.toNamed('/helper'),
                    ),
                    /*_buildDivider(),
                    _buildMenuItem(
                      title: S.of(context).ProfilePage_k6,
                      icon: Icons.cleaning_services,
                      onTap: () => Get.to(ClearCachePage()),
                    ),*/
                    _buildDivider(),
                    _buildMenuItem(
                      title: S.of(context).ProfilePage_k7,
                      icon: Icons.info_outline,
                      onTap: () => Get.toNamed('/aboutUs'),
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      title: S.of(context).ProfilePage_k21,
                      icon: Icons.security,
                      onTap: () => Get.toNamed('/accountSecurity'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required List<Widget> children}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Color(0xFF666666), size: 20),
            SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF1A1A1A),
              ),
            ),
            Spacer(),
            Icon(Icons.chevron_right, color: Color(0xFFCCCCCC)),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Color(0xFFF5F5F5));
  }

  Widget _buildMemberCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).ProfilePage_k8,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  S.of(context).ProfilePage_k9,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
              SizedBox(width: 12),
              ElevatedButton(
                onPressed: activeMember,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Color(0xFF2196F3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size(0, 32),
                ),
                child: Text(
                  S.of(context).ProfilePage_k10,
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMemberIcon(int level) {
    // 设备等级为0时不显示图标
    if (level == 0) {
      return SizedBox.shrink();
    }

    IconData icon;
    Color color;
    double size;
    
    switch (level) {
      case 1:
        icon = Icons.workspace_premium;
        color = Color(0xFFBDBDBD); // 灰色
        size = 20;
        break;
      case 2:
        icon = Icons.workspace_premium;
        color = Color(0xFFFFD700); // 明亮的金色
        size = 20;
        break;
      default:
        icon = Icons.workspace_premium;
        color = Color(0xFFBDBDBD);
        size = 18;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: size, color: color),
    );
  }

  void confirmLogout() {
    showDialog(
        context: context,
        builder: (dialogContext) {
          AlertDialog alertDialog = AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(
                color: Colors.white.withOpacity(0.5),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            backgroundColor: Colors.white,
            elevation: 10,
            alignment: Alignment.center,
            content: Container(
              alignment: Alignment.center,
              height: 70,
              child: Text(
                S.of(context).ProfilePage_k11,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            actionsPadding:
                const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            // 缩小底部间距
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(dialogContext).pop(false);
                      },
                      child: Container(
                        padding: EdgeInsets.all(5),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey, width: 1.0),
                            right: BorderSide(color: Colors.grey, width: 0.5),
                          ),
                        ),
                        child: Text(
                          S.of(context).ProfilePage_k12,
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        bool logout = await LoginLogic.removeAll();
                        if (!logout) {
                          Navigator.of(dialogContext).pop(false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(S.of(context).ProfilePage_k13)),
                          );
                        } else {
                          // 取消返回主页面
                          Navigator.of(dialogContext).pop(false);
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EmailLoginPage()),
                            ModalRoute.withName('/home'),
                          );
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(5),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey, width: 1.0),
                            left: BorderSide(color: Colors.grey, width: 0.5),
                          ),
                        ),
                        child: Text(
                          S.of(context).ProfilePage_k14,
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                              fontWeight: FontWeight.w600),
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

  //绑定设备
  TextEditingController _activationCodeController = TextEditingController();

  void activeMember() {
    showDialog(
        context: context,
        builder: (dialogContext) {
          AlertDialog alertDialog = AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(
                color: Colors.white.withOpacity(0.5),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            backgroundColor: Colors.white,
            elevation: 10,
            alignment: Alignment.center,
            content: Container(
              alignment: Alignment.center,
              height: 70,
              child: TextField(
                controller: _activationCodeController,
                decoration: InputDecoration(
                  label: Text(S.of(context).ProfilePage_k15),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
            ),
            actionsPadding:
                const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            // 缩小底部间距
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(dialogContext).pop(false);
                      },
                      child: Container(
                        padding: EdgeInsets.all(5),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey, width: 1.0),
                            right: BorderSide(color: Colors.grey, width: 0.5),
                          ),
                        ),
                        child: Text(
                          S.of(context).ProfilePage_k16,
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        Navigator.of(dialogContext).pop(false);
                        ActivateMemberResponse result = await logic
                            .activateMember(_activationCodeController.text);
                        if (result.code == 200) {
                          //绑定成功
                          var userInfo = await Cache.userInfo;
                          setState(() {
                            userInfoResponse = userInfo;
                          });
                        } else if (result.code == 10001307) {
                          _showDialog(S.of(context).ProfilePage_k17);
                        } else if (result.code == 10001308) {
                          _showDialog(S.of(context).ProfilePage_k18);
                        } else {
                          _showDialog(S.of(context).ProfilePage_k19);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(5),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey, width: 1.0),
                            left: BorderSide(color: Colors.grey, width: 0.5),
                          ),
                        ),
                        child: Text(
                          S.of(context).ProfilePage_k20,
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                              fontWeight: FontWeight.w600),
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

  void _showDialog(String message) {
    showDialog(
        context: context,
        builder: (dialogContext) {
          AlertDialog alertDialog = AlertDialog(
            backgroundColor: Colors.black.withOpacity(0.5),
            alignment: Alignment.center,
            //title: Text(''),
            content: Container(
              alignment: Alignment.center,
              height: 25,
              width: 120,
              child: Text(
                message,
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
          //提示框显示1秒后关闭
          Future.delayed(Duration(seconds: 4), () {
            Navigator.of(dialogContext).pop();
          });
          return alertDialog;
        });
  }
}
