import 'package:airecordapp/page/center/MemPage.dart';
import 'package:flutter/material.dart';
import 'GradientText.dart';
import 'package:get/get.dart';
import 'package:airecordapp/l10n/generated/l10n.dart';

class BuyRecommendWidget extends StatelessWidget {
  final bool isDialog;
  final VoidCallback? onBuyTap;

  const BuyRecommendWidget({Key? key, this.isDialog = false, this.onBuyTap})
      : super(key: key);

  static Future<void> showDialog(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: BuyRecommendWidget(isDialog: true),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDialog
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 20,
                  offset: Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部图标
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6B8CFF), Color(0xFF8B5CFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF6B8CFF).withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.workspace_premium_outlined,
              size: 32,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 24),
          
          // 标题
          GradientText(
            S.of(context).BuyRecommendWidget_k1,
            gradient: LinearGradient(
              colors: [Color(0xFF6B8CFF), Color(0xFF8B5CFF)],
            ),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          
          // 副标题
          Text(
            S.of(context).BuyRecommendWidget_k2,
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF8F95B2),
              height: 1.4,
            ),
          ),
          SizedBox(height: 28),
          
          // 功能列表
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFFF8F9FC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Color(0xFFEEF0F6),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                _buildFeatureItem(
                  Icons.auto_awesome_outlined,
                  S.of(context).BuyRecommendWidget_k3,
                  S.of(context).BuyRecommendWidget_k4,
                ),
                SizedBox(height: 20),
                _buildFeatureItem(
                  Icons.g_translate_outlined,
                  S.of(context).BuyRecommendWidget_k5,
                  S.of(context).BuyRecommendWidget_k6,
                ),
                SizedBox(height: 20),
                _buildFeatureItem(
                  Icons.summarize_outlined,
                  S.of(context).BuyRecommendWidget_k7,
                  S.of(context).BuyRecommendWidget_k8,
                ),
              ],
            ),
          ),
          SizedBox(height: 28),
          
          // 按钮
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onBuyTap ?? () {
                Get.to(MemPage());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6B8CFF),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                S.of(context).BuyRecommendWidget_k9,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          
          if (isDialog) ...[
            SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFF8F95B2),
                padding: EdgeInsets.symmetric(vertical: 8),
              ),
              child: Text(
                S.of(context).BuyRecommendWidget_k10,
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6B8CFF), Color(0xFF8B5CFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: Colors.white,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1D26),
                ),
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF8F95B2),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
