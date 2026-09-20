import 'dart:async';
import 'package:airecordapp/logic/LoginLogic.dart';
import 'package:airecordapp/page/center/PrivacyPolicyPage.dart';
import 'package:airecordapp/page/center/UserAgreementPage.dart';
import 'package:airecordapp/page/login/VerifyCodePage.dart';
import 'package:airecordapp/service/response/EmailLoginResponse.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:airecordapp/l10n/generated/l10n.dart';

/**
 * 立即注册页
 */
class RegisterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RegisterPageState();
  }
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  bool _obscureTextPassword = true; //初始状态为隐藏密码
  bool _validate = false;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String _errorMsg = "";
  LoginLogic _loginLogic = LoginLogic();
  bool _isSubmitting = false;

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

  void _togglePasswordVisibility() {
    setState(() {
      _obscureTextPassword = !_obscureTextPassword; // 切换密码显示状态
    });
  }

  void _validateInputs() {
    String _emailText = _emailController.text.trim();
    String? _emailValidatorResult = _emailValidator(_emailText);
    if (_emailValidatorResult != null) {
      //邮箱校验不通过
      setState(() {
        _validate = false;
        _errorMsg = _emailValidatorResult;
      });
      return;
    } else {
      setState(() {
        _errorMsg = '';
      });
    }

    String _passworText = _passwordController.text.trim();
    String? _passwordValidatorResult = _passwordValidator(_passworText);
    if (_passwordValidatorResult != null) {
      //密码验证不通过
      setState(() {
        _validate = false;
        _errorMsg = _passwordValidatorResult;
      });
      return;
    } else {
      setState(() {
        _errorMsg = '';
      });
    }
    //所有校验通过后，可以点击确定按钮
    setState(() {
      _validate = true;
      _errorMsg = '';
    });
  }

  /**
   * 校验邮箱
   */
  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return S.of(context).EmailLoginPage_email_empty_error;
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      // 邮箱格式不正确
      return S.of(context).EmailLoginPage_email_format_error;
    }
    return null;
  }

  //校验通过提交后台注册
  void _commitRegister() async {
    if (_validate && !_isSubmitting) {
      setState(() {
        _isSubmitting = true;
      });

      //校验通过
      String _email = _emailController.text.trim();
      String _password = _passwordController.text.trim();

      //执行注册函数，设置15秒超时
      Future<EmailLoginResponse?> result =
          _loginLogic.emailRegister(context, _email, _password)
              .timeout(Duration(seconds: 15), onTimeout: () => null);
      result.then((value) {
        if (!mounted) return;
        setState(() {
          _isSubmitting = false;
        });
        if (value == null) {
          //网络异常或超时，请重试
          setState(() {
            _errorMsg = S.of(context).EmailLoginPage_network_error;
          });
        } else if (value.code == 10001207) {
          //用户名已存在
          showDialog(
              context: context,
              barrierColor: Colors.black.withOpacity(0.5),
              builder: (dialogContext) {
                return Dialog(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Color(0xFF6C63FF).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.info_outline,
                            color: Color(0xFF6C63FF),
                            size: 24,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          S.of(context).RegisterPage_user_exist,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF2D3142),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
          //3秒跳转到登录页
          Future.delayed(Duration(seconds: 3), () {
            Navigator.of(context).pushNamed('/emailLogin');
          });
        } else if (value.code == 200 && value.state == 1) {
          //调用成功了，跳转到验证码页面
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      VerifyCodePage(email: _email, password: _password, origin: 'register',)));
        } else {
          //未知错误
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

  /**
   * 校验密码
   */
  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return S.of(context).EmailLoginPage_password_empty_error;
    } else if (value.length < 8 || value.length > 16) {
      //长度为6～16位
      return S.of(context).EmailLoginPage_password_format_error;
    }
    return null;
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
            child: Stack(
              children: [
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
              ],
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
                    Row(
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
                          S.of(context).RegisterPage_k1,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                    
                    // 欢迎文本
                    Text(
                      S.of(context).RegisterPage_k2,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      S.of(context).RegisterPage_k3,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF666666),
                      ),
                    ),
                    SizedBox(height: 40),
                    
                    // 注册表单
                    Form(
                      key: _formKey,
                      onChanged: _validateInputs,
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _emailController,
                            hintText: S.of(context).RegisterPage_email_address,
                            icon: Icons.email_outlined,
                            validator: _emailValidator,
                          ),
                          SizedBox(height: 16),
                          _buildTextField(
                            controller: _passwordController,
                            hintText: S.of(context).RegisterPage_password,
                            icon: Icons.lock_outline,
                            isPassword: true,
                            validator: _passwordValidator,
                          ),
                          if (_errorMsg.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(top: 8, left: 4),
                              child: Text(
                                _errorMsg,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          SizedBox(height: 24),
                          
                          // 注册按钮
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
                              onPressed: (_validate && !_isSubmitting) ? _commitRegister : null,
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
                                      S.of(context).RegisterPage_register,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                          
                          SizedBox(height: 24),
                          
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
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.info_outline, size: 16, color: Color(0xFF6C63FF)),
                                  SizedBox(width: 8),
                                  Flexible(
                                    child: RichText(
                                      text: TextSpan(
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF666666),
                                        height: 1.5,
                                      ),
                                      children: [
                                        TextSpan(text: S.of(context).RegisterPage_k4),
                                        TextSpan(
                                          text: S.of(context).RegisterPage_k5,
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
                                        TextSpan(text: S.of(context).RegisterPage_k6),
                                        TextSpan(
                                          text: S.of(context).RegisterPage_k7,
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
                          ),
                        ],
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color(0xFFE5E5E5),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        cursorColor: Color(0xFF6C63FF),
        obscureText: isPassword ? _obscureTextPassword : false,
        validator: validator,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Color(0xFF9BA0B3),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: Color(0xFF9BA0B3),
            size: 20,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureTextPassword ? Icons.visibility_off : Icons.visibility,
                    color: Color(0xFF9BA0B3),
                    size: 20,
                  ),
                  onPressed: _togglePasswordVisibility,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
