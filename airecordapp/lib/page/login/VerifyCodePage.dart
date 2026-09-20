import 'package:airecordapp/db/Cache.dart';
import 'package:airecordapp/logic/LoginLogic.dart';
import 'package:airecordapp/logic/PackageLogic.dart';
import 'package:airecordapp/page/center/PrivacyPolicyPage.dart';
import 'package:airecordapp/page/center/UserAgreementPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:airecordapp/l10n/generated/l10n.dart';
import 'dart:async';
import 'package:flutter/gestures.dart';

/**
 * 验证码
 */
class VerifyCodePage extends StatefulWidget {
  String email;
  String password;
  String origin; //来源：login-登录页，register-注册页

  VerifyCodePage(
      {required this.email, required this.password, required this.origin});

  @override
  State<StatefulWidget> createState() {
    return _VerifyCodePageState(
        email: email, password: password, origin: origin);
  }
}

class _VerifyCodePageState extends State<VerifyCodePage> {
  String email;
  String password;
  String origin; //来源：login-登录页，register-注册页

  _VerifyCodePageState(
      {required this.email, required this.password, required this.origin}) {
    _countdown();
  }

  final _formKey = GlobalKey<FormState>();
  LoginLogic _loginLogic = LoginLogic();

  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());
  final List<TextEditingController> controllers =
      List.generate(6, (_) => TextEditingController());

  bool _validate = false; //是否校验通过
  bool _isSubmitting = false; //是否正在提交中
  //置灰：发送中倒计时和邮箱框校验不通过，置黑：邮箱校验通过
  String _errorMsg = "";
  Timer? _timer;

  //倒计时
  int _start = 60;
  bool _showTime = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _countdown() {
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
          _showTime = false;
        });
        _start = 60;
      } else {
        setState(() {
          _start--;
          _showTime = true;
        });
      }
    });
  }

  void _getCode() {
    _loginLogic.getCode(context, email).then((value) {
      if (value == null) {
        //网络异常，请重试
        setState(() {
          _errorMsg = S.of(context).EmailLoginPage_network_error;
        });
      } else if (value.code == 200) {
        //验证码发送成功
        _countdown();
      } else {
        //未知错误
        setState(() {
          _errorMsg = S.of(context).EmailLoginPage_unknown_error;
        });
      }
    });
  }

  //校验验证码
  void _validateInputs(index, value) {
    //控制焦点位置
    if (value.length == 1) {
      // 输入完成，跳转到下一个输入框
      if (index < controllers.length - 1) {
        FocusScope.of(context).requestFocus(focusNodes[index + 1]);
      }
    } else if (value.isEmpty && index > 0) {
      // 删除操作，跳转到上一个输入框
      FocusScope.of(context).requestFocus(focusNodes[index - 1]);
    }
    // 校验是否可以提交验证操作
    bool isEmpty = false;
    controllers.forEach((element) {
      if (element.text.isEmpty) {
        isEmpty = true;
        return;
      }
      ;
    });
    setState(() {
      _validate = !isEmpty;
    });
  }

  /// 注册成功后：保存 token → 静默领取新用户免费套餐 → 跳回登录页
  ///
  /// 注意事项：
  /// - 领取接口依赖 Authorization header（forceAuth=true），必须先 saveToken；
  /// - 领取过程静默、幂等，失败也不阻塞用户回到登录页；
  /// - 领取完成后为避免误用注册流程产生的临时会话，主动清除 token，
  ///   让用户在登录页正常输入密码登录（与原逻辑保持一致）。
  Future<void> _grantFreePackageAndBack(String? accessToken) async {
    try {
      if (accessToken != null && accessToken.isNotEmpty) {
        await Cache.saveToken(accessToken, email);
        await PackageLogic()
            .giveFreePackage(PackageLogic.NEW_USER_FREE_PACKAGE_ID);
        // 清除注册流程临时 token，让用户在登录页显式登录
        await Cache.removeToken();
      }
    } catch (_) {
      // 静默：任何异常都不影响用户回到登录页
    }
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
        context, "/emailLogin", (route) => false);
  }

  /**
   * 提交表单
   */
  void _commitForm() {
    if (_validate && !_isSubmitting) {
      setState(() {
        _isSubmitting = true;
      });

      String verifyCode = "";
      controllers.forEach((element) {
        verifyCode += element.text.trim();
      });
      _loginLogic.verifyCode(context, email, verifyCode)
          .timeout(Duration(seconds: 15), onTimeout: () => null)
          .then((value) {
        if (!mounted) return;
        setState(() {
          _isSubmitting = false;
        });
        if (value == null) {
          setState(() {
            _errorMsg = S.of(context).EmailLoginPage_network_error;
          });
        } else if (value.code == 10001205) {
          setState(() {
            _errorMsg = S.of(context).VerifyCodePage_code_invalidate;
          });
        } else if (value.code == 200 && value.state == 2) {
          if (origin == 'login') {
            Cache.saveToken(value.accessToken ?? "", email);
            Navigator.pushNamed(context, "/index");
          } else if (origin == 'register') {
            // 注册成功：先保存 token（服务端在 verify_code 成功后已返回 access_token），
            // 再静默领取新用户免费体验套餐包（限领一次，失败/已领取都不影响主流程），
            // 最后跳回登录页让用户重新登录。
            _grantFreePackageAndBack(value.accessToken);
          }
        } else {
          setState(() {
            _errorMsg = S.of(context).EmailLoginPage_unknown_error;
          });
        }
      }).catchError((e) {
        if (!mounted) return;
        setState(() {
          _isSubmitting = false;
          _errorMsg = S.of(context).EmailLoginPage_network_error;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 背景装饰
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  Color(0xFFE8E5FF),
                  Color(0xFFE5F1FF),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.2, 0.6, 1.0],
              ),
            ),
          ),
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF6C63FF).withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF4CAF50).withOpacity(0.1),
              ),
            ),
          ),
          
          // 主要内容
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 顶部导航栏
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Color(0xFFE5E5E5),
                                width: 1,
                              ),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.arrow_back_ios, size: 18),
                              color: Color(0xFF1A1A1A),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          SizedBox(width: 16),
                          Text(
                            S.of(context).VerifyCodePage_k1,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 48),
                    
                    // 标题文本
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            S.of(context).VerifyCodePage_k2,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            S.of(context).VerifyCodePage_k3,
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF666666),
                              height: 1.5,
                            ),
                          ),
                          Text(
                            email,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6C63FF),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 48),
                    
                    // 验证码输入框
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(6, (index) {
                                return Container(
                                  width: 44,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Color(0xFFE5E5E5),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFF6C63FF).withOpacity(0.04),
                                        offset: Offset(0, 4),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: TextField(
                                    controller: controllers[index],
                                    focusNode: focusNodes[index],
                                    keyboardType: TextInputType.number,
                                    maxLength: 1,
                                    cursorColor: Color(0xFF6C63FF),
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2D3142),
                                    ),
                                    decoration: InputDecoration(
                                      counterText: '',
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    textAlign: TextAlign.center,
                                    onChanged: (value) => _validateInputs(index, value),
                                  ),
                                );
                              }),
                            ),
                          ),
                          SizedBox(height: 24),
                          
                          // 重发验证码
                          Container(
                            alignment: Alignment.center,
                            child: _showTime
                                ? Text(
                                    '${S.of(context).VerifyCodePage_resend_code_1} $_start' + S.of(context).VerifyCodePage_k4,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF9BA0B3),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        S.of(context).VerifyCodePage_resend_code_2,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF9BA0B3),
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      GestureDetector(
                                        onTap: _getCode,
                                        child: Text(
                                          S.of(context).VerifyCodePage_resend_code_1,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF6C63FF),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                          
                          if (_errorMsg.isNotEmpty)
                            Container(
                              margin: EdgeInsets.only(top: 16),
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 16,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMsg,
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          
                          SizedBox(height: 48),
                          
                          // 确认按钮
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: (_validate && !_isSubmitting) ? [
                                BoxShadow(
                                  color: Color(0xFF6C63FF).withOpacity(0.3),
                                  offset: Offset(0, 4),
                                  blurRadius: 12,
                                ),
                              ] : [],
                            ),
                            child: ElevatedButton(
                              onPressed: (_validate && !_isSubmitting) ? _commitForm : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: (_validate && !_isSubmitting) ? Color(0xFF6C63FF) : Color(0xFFE5E5E5),
                                foregroundColor: (_validate && !_isSubmitting) ? Colors.white : Color(0xFF666666),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: _isSubmitting
                                  ? SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF666666)),
                                      ),
                                    )
                                  : Text(
                                      S.of(context).ResetPasswordPage_form_commit,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 48),
                    
                    // 用户协议
                    Container(
                      margin: EdgeInsets.only(top: 40),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Color(0xFFE5E5E5),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.info_outline, size: 16, color: Color(0xFF6C63FF)),
                            SizedBox(width: 8),
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF666666),
                                  height: 1.5,
                                ),
                                children: [
                                  TextSpan(text: S.of(context).VerifyCodePage_k5),
                                  TextSpan(
                                    text:  S.of(context).VerifyCodePage_k6,
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
                                  TextSpan(text: S.of(context).VerifyCodePage_k7),
                                  TextSpan(
                                    text: S.of(context).VerifyCodePage_k8,
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
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
