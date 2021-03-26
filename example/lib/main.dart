import 'package:flutter/material.dart';
import 'package:flutter_net_captcha/flutter_net_captcha.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  String? sdkVersion;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              Text("sdk版本号: $sdkVersion"),
              ElevatedButton(
                onPressed: () {
                  FlutterNetCaptcha.configVerifyCode(VerifyCodeConfig(captchaId: ''));
                  FlutterNetCaptcha.showCaptcha(
                      mode: VerifyCodeMode.Normal,
                      language: VerifyLanguage.ZH_TW,
                      onLoaded: () {
                        print('onLoaded...');
                      },
                      onVerify: (VerifyCodeResponse response) {
                        print(response);
                      },
                      onError: (String message) {
                        print(message);
                      },
                      onClose: (VerifyCodeClose close) {
                        print('close: $close');
                      });
                },
                child: Text('配置验证码'),
              ),
              ElevatedButton(
                onPressed: () {
                  // FlutterNetCaptcha.showCaptcha();
                },
                child: Text('显示验证码'),
              ),
              ElevatedButton(
                onPressed: () async {
                  String? v = await FlutterNetCaptcha.getSdkVersion();
                  setState(() {
                    sdkVersion = v;
                  });
                },
                child: Text('获取版本号'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
