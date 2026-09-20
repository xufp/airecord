import 'package:airecordapp/l10n/generated/l10n.dart';
import 'package:airecordapp/logic/LoginLogic.dart';
import 'package:airecordapp/page/HomePage.dart';
import 'package:airecordapp/page/center/PrivacyPolicyPage.dart';
import 'package:airecordapp/page/center/UserAgreementPage.dart';
import 'package:airecordapp/page/login/VerifyCodePage.dart';
import 'package:airecordapp/service/response/EmailLoginResponse.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';

/**
 * 登录页
 */
class EmailLoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _EmailLoginPageState();
  }
}

class _EmailLoginPageState extends State<EmailLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _emailError = "";
  String _passwordError = "";
  bool _obscureText = true;
  bool _validate = false;
  String _errorMsg = "";
  LoginLogic _loginLogic = LoginLogic();

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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _validateInputs() {
    if (_formKey.currentState!.validate()) {
      if(_emailError == '' && _passwordError == '') {
      setState(() {
        _validate = true;
        _errorMsg = '';
      });
    } else {
        setState(() {
          _validate = false;
        });
      }
    } else {
      setState(() {
        _validate = false;
      });
    }
  }

  void _commitLogin() {
    if (_validate) {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();
      
      Future<EmailLoginResponse?> result =
          _loginLogic.emailLogin(context, email, password);
      result.then((value) {
        if (value == null) {
          setState(() {
            _errorMsg = S.of(context).EmailLoginPage_network_error;
          });
        } else if (value.code == 10001202) {
          setState(() {
            _errorMsg = S.of(context).EmailLoginPage_user_not_found;
          });
        } else if (value.code == 10001203) {
          setState(() {
            _errorMsg = S.of(context).EmailLoginPage_password_uncorrect;
          });
        } else if (value.code == 10001206) {
          setState(() {
            _errorMsg = S.of(context).EmailLoginPage_account_deactivated;
          });
        } else if (value.code == 200 && value.state == 1) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => VerifyCodePage(
                      email: email, password: password, origin: 'login')));
        } else if (value.code == 200 && value.state == 2) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
            ModalRoute.withName('/index'),
          );
        } else {
          setState(() {
            _errorMsg = S.of(context).EmailLoginPage_unknown_error;
          });
        }
      });
    }
  }

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      setState(() {
      _emailError = S.of(context).EmailLoginPage_email_empty_error;
      });
      return null;
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      setState(() {
      _emailError = S.of(context).EmailLoginPage_email_format_error;
      });
      return null;
    }
    setState(() {
    _emailError = '';
    });
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      setState(() {
      _passwordError = S.of(context).EmailLoginPage_password_empty_error;
      });
      return null;
    } else if (value.length < 8 || value.length > 16) {
      setState(() {
      _passwordError = S.of(context).EmailLoginPage_password_format_error;
      });
      return null;
    }
    setState(() {
    _passwordError = '';
    });
    return null;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 56,
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
            obscureText: isPassword ? _obscureText : false,
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
                        _obscureText ? Icons.visibility_off : Icons.visibility,
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
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
              errorStyle: TextStyle(height: 0, fontSize: 0),
              isDense: true,
            ),
          ),
        ),
      ],
    );
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
                        /*Container(
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
                        ),*/
                        SizedBox(width: 16),
                        Text(
                          S.of(context).EmailLoginPage_k1,
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
                      S.of(context).EmailLoginPage_k2,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      S.of(context).EmailLoginPage_k3,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF666666),
                      ),
                    ),
                    SizedBox(height: 40),
                    
                    // 登录表单
                    Form(
                      key: _formKey,
                      onChanged: _validateInputs,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField(
                            controller: _emailController,
                            hintText: S.of(context).EmailLoginPage_email_address,
                            icon: Icons.email_outlined,
                            validator: _emailValidator,
                          ),
                          if (_emailError.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(top: 4, left: 16),
                              child: Text(
                                _emailError,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          SizedBox(height: _emailError.isEmpty ? 16 : 12),
                          _buildTextField(
                            controller: _passwordController,
                            hintText: S.of(context).EmailLoginPage_password,
                            icon: Icons.lock_outline,
                            isPassword: true,
                            validator: _passwordValidator,
                          ),
                          if (_passwordError.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(top: 4, left: 16),
                              child: Text(
                                _passwordError,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          SizedBox(height: _passwordError.isEmpty ? 24 : 20),
                          if (_errorMsg.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(bottom: 16, left: 16),
                      child: Text(
                        _errorMsg,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          SizedBox(height: 24),
                          
                          // 登录按钮
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: _validate ? [
                                BoxShadow(
                                  color: Color(0xFF6C63FF).withOpacity(0.3),
                                  offset: Offset(0, 4),
                                  blurRadius: 12,
                                ),
                              ] : [],
                            ),
                            child: ElevatedButton(
                              onPressed: _validate ? _commitLogin : null,
                      style: ElevatedButton.styleFrom(
                                backgroundColor: _validate ? Color(0xFF6C63FF) : Color(0xFFE5E5E5),
                                foregroundColor: _validate ? Colors.white : Color(0xFF666666),
                        shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                S.of(context).EmailLoginPage_login,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          
                          SizedBox(height: 24),
                          
                          // 底部链接
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                              TextButton(
                                onPressed: () => Navigator.pushNamed(context, '/register'),
                          child: Text(
                            S.of(context).EmailLoginPage_register,
                            style: TextStyle(
                                    color: Color(0xFF6C63FF),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pushNamed(context, '/resetPassword'),
                          child: Text(
                            S.of(context).EmailLoginPage_find_password,
                            style: TextStyle(
                                    color: Color(0xFF6C63FF),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
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
                                  TextSpan(text: S.of(context).EmailLoginPage_k4),
                                  TextSpan(
                                    text: S.of(context).EmailLoginPage_k5,
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
                                  TextSpan(text: S.of(context).EmailLoginPage_k6),
                                  TextSpan(
                                    text: S.of(context).EmailLoginPage_k7,
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
            ),
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
