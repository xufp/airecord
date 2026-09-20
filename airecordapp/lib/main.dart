import 'dart:async';
import 'package:airecordapp/logic/LoginLogic.dart';
import 'package:airecordapp/page/HomePage.dart';
import 'package:airecordapp/page/blue/PenPageList.dart';
import 'package:airecordapp/page/center/AboutPage.dart';
import 'package:airecordapp/page/center/AccountSecurityPage.dart';
import 'package:airecordapp/page/center/ConvertRecordPage.dart';
import 'package:airecordapp/page/center/FeedBackPage.dart';
import 'package:airecordapp/page/center/HelperPage.dart';
import 'package:airecordapp/page/center/MemPage.dart';
import 'package:airecordapp/page/center/PrivacyPolicyPage.dart';
import 'package:airecordapp/page/center/TradeRecordPage.dart';
import 'package:airecordapp/page/center/UserAgreementPage.dart';
import 'package:airecordapp/page/login/EmailLoginPage.dart';
import 'package:airecordapp/page/login/RegisterPage.dart';
import 'package:airecordapp/page/login/ResetPasswordPage.dart';
import 'package:airecordapp/page/record/PlayerPage.dart';
import 'package:airecordapp/page/record/RecordPage.dart';
import 'package:airecordapp/page/record/SearchFilePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/route_manager.dart';
import 'l10n/generated/l10n.dart';

void main() async {
  // 捕获所有未处理的错误
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // 设置错误处理
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('FlutterError: ${details.toString()}');
    };

    // 检查登录状态
    bool isLogin = false;
    try {
      isLogin = await LoginLogic.isToken();
    } catch (e) {
      debugPrint('Login check error: $e');
    }
    String initialRoute = isLogin ? '/index' : '/emailLogin';
    debugPrint('initialRoute: $initialRoute');

    // 锁定屏幕方向
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);

    // 运行应用
    runApp(MyAppRoot(initialRoute: initialRoute));
  }, (error, stack) {
    debugPrint('Caught error: $error');
    debugPrint('Stack trace: $stack');
  });
}

class MyAppRoot extends StatelessWidget {
  final String initialRoute;

  const MyAppRoot({
    Key? key, 
    required this.initialRoute,
  }) : super(key: key);

  /// 将系统语言解析为应用支持的语言
  Locale _resolveLocale(Locale? locale, Iterable<Locale> supportedLocales) {
    if (locale == null) return const Locale('en', 'US');
    
    // 处理中文区域
    if (locale.languageCode == 'zh') {
      if (locale.countryCode == 'TW' || locale.scriptCode == 'Hant') {
        return const Locale('zh', 'TW');
      }
      return const Locale('zh', 'CN');
    }
    
    // 处理日语
    if (locale.languageCode == 'ja') {
      return const Locale('ja', 'JP');
    }
    
    // 处理韩语
    if (locale.languageCode == 'ko') {
      return const Locale('ko', 'KR');
    }

    // 检查是否支持请求的语言区域
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return supportedLocale;
      }
    }
    
    return const Locale('en', 'US');
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      // 不设置 locale，让 Flutter 自动跟随系统语言
      // 当系统语言改变时，Flutter 会自动调用 localeListResolutionCallback 重新解析
      localeListResolutionCallback: (locales, supportedLocales) {
        // locales 是系统语言偏好列表（按优先级排序）
        if (locales != null && locales.isNotEmpty) {
          // 按照系统语言偏好列表的优先级，逐个尝试匹配
          for (var locale in locales) {
            final resolved = _resolveLocale(locale, supportedLocales);
            // 如果解析结果不是默认的英语回退，说明找到了匹配的语言
            if (resolved.languageCode != 'en' || locale.languageCode == 'en') {
              return resolved;
            }
          }
          // 如果没有找到匹配的语言，使用第一个系统语言进行解析
          return _resolveLocale(locales.first, supportedLocales);
        }
        return const Locale('en', 'US');
      },
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      theme: ThemeData(
        brightness: Brightness.light,
        splashFactory: NoSplash.splashFactory,
        splashColor: Colors.transparent,
        primaryColor: Colors.orangeAccent,
        textTheme: const TextTheme(),
      ),
      getPages: [
        GetPage(name: '/home', page: () => EmailLoginPage()),
        GetPage(name: '/emailLogin', page: () => EmailLoginPage()),
        GetPage(name: '/index', page: () => HomePage()),
        GetPage(name: '/record', page: () => RecordPage()),
        GetPage(name: '/search', page: () => SearchFilePage()),
        GetPage(name: '/player', page: () => PlayerPage()),
        GetPage(name: '/bluetooth', page: () => PenPageList()),
        GetPage(name: '/register', page: () => RegisterPage()),
        GetPage(name: '/resetPassword', page: () => ResetPasswordPage()),
        GetPage(name: '/member', page: () => MemPage()),
        GetPage(name: '/convertRecord', page: () => ConvertRecordPage()),
        GetPage(name: '/tradeRecord', page: () => TradeRecordPage()),
        GetPage(name: '/aboutUs', page: () => AboutPage()),
        GetPage(name: '/helper', page: () => HelperPage()),
        GetPage(name: '/userAgreement', page: () => UserAgreementPage()),
        GetPage(name: '/privacyPolicy', page: () => PrivacyPolicyPage()),
        GetPage(name: '/feedBack', page: () => FeedBackPage()),
        GetPage(name: '/accountSecurity', page: () => AccountSecurityPage()),
      ],
      onGenerateTitle: (context) {
        return S.of(context).app_title;
      },
    );
  }
}
