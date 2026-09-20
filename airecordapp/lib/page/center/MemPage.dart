import 'package:airecordapp/logic/ProfileLogic.dart';
import 'package:airecordapp/service/response/UserInfoResponse.dart';
import 'package:airecordapp/util/CommonUtil.dart';
import 'package:flutter/material.dart';
import 'package:airecordapp/l10n/generated/l10n.dart';

class MemPage extends StatefulWidget {
  @override
  State<MemPage> createState() => MemPageState();
}

class MemPageState extends State<MemPage> {
  ProfileLogic logic = ProfileLogic();
  UserInfoResponse? userInfoResponse;
  int packageConvertUsed = 0;
  int packageConvertTotal = 0;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    // 设置用户信息
    logic.userInfo().then((value) {
      setState(() {
        userInfoResponse = value;
      });
    });
    // 设置套餐信息
    logic.userPackage().then((value) {
      setState(() {
        packageConvertUsed = value.convert?.used ?? 0;
        packageConvertTotal = value.convert?.total ?? 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Color(0xFF1A1A1A),
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          S.of(context).MemPage_k1,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                _buildProMemberCard(),
                SizedBox(height: 16),
                _buildProFeatures(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProMemberCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF2196F3).withOpacity(0.8),
            Color(0xFF1976D2).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF2196F3).withOpacity(0.2),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                S.of(context).MemPage_k2,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            S.of(context).MemPage_k3,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildUsageItem(
                icon: Icons.timer,
                label: S.of(context).MemPage_k4,
                value: '$packageConvertUsed/$packageConvertTotal ${S.of(context).MemPage_k5}',
              ),
              if (userInfoResponse?.membershipLevel == 2 && userInfoResponse?.membershipExpireTime != null)
                _buildUsageItem(
                  icon: Icons.calendar_today,
                  label: S.of(context).MemPage_k6,
                  value: CommonUtil.formatDate(userInfoResponse!.membershipExpireTime!),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsageItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 16),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProFeatures() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).MemPage_k7,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          _buildFeatureItem(
            icon: 'assets/images/template.png',
            title: S.of(context).MemPage_k8,
            description: S.of(context).MemPage_k9,
            isHighlight: true,
          ),
          SizedBox(height: 16),
          _buildFeatureItem(
            icon: 'assets/images/askai.png',
            title: S.of(context).MemPage_k10,
            description: S.of(context).MemPage_k11,
            isHighlight: true,
          ),
          SizedBox(height: 16),
          _buildFeatureItem(
            icon: 'assets/images/media_import.png',
            title: S.of(context).MemPage_k12,
            description: S.of(context).MemPage_k13,
            isHighlight: true,
          ),
          SizedBox(height: 16),
          _buildFeatureItem(
            icon: 'assets/images/format_export.png',
            title: S.of(context).MemPage_k14,
            description: S.of(context).MemPage_k15,
            isHighlight: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required String icon,
    required String title,
    required String description,
    bool isHighlight = false,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isHighlight ? Color(0xFF2196F3).withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isHighlight ? Color(0xFF2196F3).withOpacity(0.2) : Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(
              icon,
              width: 32,
              height: 32,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isHighlight ? FontWeight.w600 : FontWeight.w500,
                    color: isHighlight ? Colors.white : Colors.white.withOpacity(0.9),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isHighlight ? Colors.white.withOpacity(0.8) : Colors.white.withOpacity(0.6),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDialog(BuildContext context, String message) {
    showDialog(
        context: context,
        builder: (dialogContext) {
          AlertDialog alertDialog = AlertDialog(
            backgroundColor: Colors.black.withOpacity(0.8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
          Future.delayed(Duration(seconds: 2), () {
            Navigator.of(dialogContext).pop();
          });
          return alertDialog;
        });
  }
}
