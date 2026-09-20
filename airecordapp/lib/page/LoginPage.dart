import 'package:airecordapp/l10n/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:airecordapp/page/center/PrivacyPolicyPage.dart';
import 'package:airecordapp/page/center/UserAgreementPage.dart';

/**
 * 登录页
 * 仅支持邮箱登录
 */
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFE8E5FF),
              Color(0xFFE5F1FF),
            ],
            stops: [0.2, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF6C63FF),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF6C63FF).withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.mic,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'UNION.AI',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your Universal AI Assistant',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // 登录按钮区域
              Container(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: Column(
                  children: [
                    // 邮箱登录按钮
                    _buildLoginButton(
                      context,
                      '',
                      S.of(context).LoginPage_email,
                      () => Navigator.pushNamed(context, '/emailLogin'),
                      isEmail: true,
                      backgroundColor: Colors.white,
                      textColor: Color(0xFF1A1A1A),
                      borderColor: Color(0xFFE5E5E5),
                      hasShadow: true,
                      showTimeIcon: true,
                    ),
                    
                    // 用户协议
                    Container(
                      margin: EdgeInsets.only(top: 24),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Color(0xFFE5E5E5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info_outline, size: 16, color: Color(0xFF6C63FF)),
                          SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF666666),
                                  height: 1.5,
                                ),
                                children: [
                                  TextSpan(text: S.of(context).LoginPage_continue_operator),
                                  TextSpan(
                                    text: S.of(context).LoginPage_user_agreement,
                                    style: TextStyle(
                                      color: Color(0xFF6C63FF),
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => UserAgreementPage(),
                                          ),
                                        );
                                      },
                                  ),
                                  TextSpan(text: S.of(context).LoginPage_and),
                                  TextSpan(
                                    text: S.of(context).LoginPage_Privacy,
                                    style: TextStyle(
                                      color: Color(0xFF6C63FF),
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PrivacyPolicyPage(),
                                          ),
                                        );
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(
    BuildContext context,
    String iconPath,
    String text,
    VoidCallback onPressed, {
    bool isEmail = false,
    required Color backgroundColor,
    required Color textColor,
    required Color borderColor,
    bool showTimeIcon = false,
    bool hasShadow = false,
  }) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: backgroundColor,
        boxShadow: hasShadow ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ] : null,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: borderColor,
              width: 1,
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20),
        ),
        child: Stack(
          children: [
            // 左侧图标
            Align(
              alignment: Alignment.centerLeft,
              child: isEmail
                  ? Icon(
                      Icons.mail_outline,
                      size: 20,
                      color: textColor,
                    )
                  : Image.asset(
                      iconPath,
                      width: 20,
                      height: 20,
                    ),
            ),
            // 中间文字
            Center(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // 右侧时间图标（仅在需要时显示）
            if (showTimeIcon)
              Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.access_time,
                  size: 20,
                  color: Color(0xFF999999),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
