import 'dart:async';

import 'package:flutter/services.dart';

class FlutterNetCaptcha {
  static const MethodChannel _channel = const MethodChannel('flutter_net_captcha');
  static final _eventChannel = const EventChannel("flutter_net_captcha/event_channel");

  static bool _eventChannelReadied = false;

  static Function()? _verifyOnLoaded;
  static Function(VerifyCodeResponse)? _verifyOnVerify;
  static Function(VerifyCodeClose)? _verifyOnClose;
  static Function(String)? _verifyOnError;

  /// 配置验证码
  ///
  /// [config] 配置
  static void configVerifyCode(VerifyCodeConfig config) {
    if (_eventChannelReadied != true) {
      _eventChannel.receiveBroadcastStream().listen(_handleVerifyOnEvent);
      _eventChannelReadied = true;
    }
    _channel.invokeMethod("configVerifyCode", config.toJson());
  }

  /// 显示验证码
  ///
  /// [mode] 验证码类型
  static void showCaptcha(
      {VerifyCodeMode mode = VerifyCodeMode.Normal,
      VerifyLanguage language = VerifyLanguage.ZH_TW,
      Function()? onLoaded,
      Function(VerifyCodeResponse data)? onVerify,
      Function(VerifyCodeClose data)? onClose,
      Function(String data)? onError}) {
    _verifyOnLoaded = onLoaded;
    _verifyOnVerify = onVerify;
    _verifyOnClose = onClose;
    _verifyOnError = onError;
    _channel.invokeMethod("showCaptcha", {"mode": mode.value, "language": language.value});
  }

  /// 获取sdk版本号
  static Future<String?> getSdkVersion() {
    return _channel.invokeMethod('getSdkVersion');
  }

  static _handleVerifyOnEvent(dynamic event) {
    String method = '${event['method']}';
    dynamic data = event['data'];

    switch (method) {
      case 'onLoaded':
        if (_verifyOnLoaded != null) _verifyOnLoaded!();
        break;
      case 'onVerify':
        if (_verifyOnVerify != null) _verifyOnVerify!(VerifyCodeResponse.fromJson(data));
        break;
      case 'onError':
        if (_verifyOnError != null) _verifyOnError!(data);
        break;
      case 'onClose':
        if (_verifyOnClose != null) {
          _verifyOnClose!(data == 1 ? VerifyCodeClose.Manual : VerifyCodeClose.Auto);
        }
        break;
    }
  }
}

/// 验证码配置
class VerifyCodeConfig {
  /// 验证码id
  String captchaId;

  /// 加载验证码的超时时间,最长12s。这个时间尽量设置长一些，比如7秒以上(7-12s)
  int timeoutInterval;

  /// 验证码类型
  VerifyCodeMode mode;

  /// 设置极端情况下，当验证码服务不可用时，是否开启降级方案。
  /// 默认开启，当触发降级开关时，将直接通过验证，进入下一步。
  bool openFallBack;

  /// 设置发生第fallBackCount次错误时，将触发降级。取值范围 >=1
  /// 默认设置为3次，第三次服务器发生错误时，触发降级，直接通过验证。
  int fallBackCount;

  /// 验证码ipv6配置。
  /// 默认为 no，传 yes 表示支持ipv6网络。
  bool ipv6;

  /// 是否隐藏关闭按钮
  /// 默认不隐藏，设置为YES隐藏，NO不隐藏
  bool closeButtonHidden;

  /// 点击背景是否可以关闭验证码视图
  /// 默认可以关闭
  bool shouldCloseByTouchBackground;

  /// 是否开启sdk日志打印
  bool enableLog;

  VerifyCodeConfig(
      {required this.captchaId,
      this.timeoutInterval = 10,
      this.mode = VerifyCodeMode.Normal,
      this.openFallBack = true,
      this.fallBackCount = 3,
      this.ipv6 = false,
      this.closeButtonHidden = true,
      this.shouldCloseByTouchBackground = false,
      this.enableLog = false});

  Map<String, dynamic> toJson() {
    return {
      "captchaId": captchaId,
      "timeoutInterval": timeoutInterval,
      "mode": mode.toString(),
      "openFallBack": openFallBack,
      "fallBackCount": fallBackCount,
      "ipv6": ipv6,
      "closeButtonHidden": closeButtonHidden,
      "shouldCloseByTouchBackground": shouldCloseByTouchBackground,
      "enableLog": enableLog,
    };
  }
}

class VerifyCodeResponse {
  bool? result;
  String? validate;
  String? message;

  VerifyCodeResponse({this.result, this.validate, this.message});

  VerifyCodeResponse.fromJson(Map json) {
    if (json.containsKey('result')) {
      result = json['result'];
    } else {
      result = false;
    }

    if (json.containsKey('validate')) {
      validate = json['validate'];
    }

    if (json.containsKey('message')) {
      message = json['message'];
    }
  }

  @override
  String toString() {
    return 'VerifyCodeResponse{result: $result, validate: $validate, message: $message}';
  }
}

/// 验证码方式
enum VerifyCodeMode {
  /// 普通
  Normal,

  /// 无感知
  NoSense
}

extension VerifyCodeModeValue on VerifyCodeMode {
  String get value => ['Normal', 'NoSense'][index];
}

/// 验证码关闭的类型
enum VerifyCodeClose {
  /// 手动
  Manual,

  /// 自动
  Auto
}

/// 语言类型
enum VerifyLanguage {
  /// 中文
  ZH_CN,

  /// 英文
  EN,

  /// 繁体
  ZH_TW,

  /// 日文
  JA,

  /// 韩文
  KO,

  /// 泰文
  TL,

  /// 越南语
  VT,

  /// 法语
  FR,

  /// 俄语
  RUS,

  /// 阿拉伯语
  KSA,

  /// 德语
  DE,

  /// 意大利语
  IT,

  /// 希伯来语
  HE,

  /// 印地语
  HI,

  /// 印尼语
  ID,

  /// 缅甸语
  MY,

  /// 老挝语
  LO,

  /// 马来语
  MS,

  /// 波兰语
  PL,

  /// 葡萄牙语
  PT,

  /// 西班牙语
  ES,

  /// 土耳其语
  TR,
}

extension VerifyLanguageValue on VerifyLanguage {
  String get value => [
        'ZH_CN',
        'EN',
        'ZH_TW',
        'JA',
        'KO',
        'TL',
        'VT',
        'FR',
        'RUS',
        'KSA',
        'DE',
        'IT',
        'HE',
        'HI',
        'ID',
        'MY',
        'LO',
        'MS',
        'PL',
        'PT',
        'ES',
        'TR'
      ][index];
}
