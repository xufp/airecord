import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:airecordapp/l10n/generated/l10n.dart';

class StartUpPage extends StatefulWidget {
  String? initialRoute;
  StartUpPage(String initialRoute) {
    this.initialRoute = initialRoute;
  }
  @override
  _StartUpState createState() => _StartUpState(initialRoute!);
}

class _StartUpState extends State<StartUpPage> {
  String initialRoute = '/home';
  _StartUpState(String initialRoute) {
    this.initialRoute = initialRoute;
  }
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushNamedAndRemoveUntil(context, initialRoute, (Route<dynamic> route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/mainlogo.png',
              width: 250,
              height: 250,
            ),
            TyperAnimatedTextKit(
              text: [S.of(context).app_title],
              textStyle:
                  TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, fontFamily: 'PingFang SC'),
              speed: Duration(milliseconds: 200),
              onTap: () {},
              displayFullTextOnTap: true,
              isRepeatingAnimation: false,
              repeatForever: true,
              //animation: TypewriterAnimation(),
            ),
          ],
        ),
      ),
    );
  }
}
