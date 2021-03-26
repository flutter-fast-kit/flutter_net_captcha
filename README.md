# flutter_net_captcha

[![Pub](https://img.shields.io/pub/v/flutter_net_captcha.svg)](https://pub.dartlang.org/packages/flutter_net_captcha)
[![Awesome Flutter](https://img.shields.io/badge/Awesome-Flutter-blue.svg?longCache=true&style=flat-square)]()
[![Awesome Flutter](https://img.shields.io/badge/Platform-Android_iOS-blue.svg?longCache=true&style=flat-square)]()
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](/LICENSE)

网易易盾-行为验证码，Flutter 插件！

## 使用

🔩 安装

在 `pubspec.yaml` 添加依赖

```
dependencies:
  flutter_net_captcha: <last_version>
```

⚙️ 配置

#### iOS

无需配置


#### Android

无需配置

如需要进行混淆, proguard混淆配置文件增加：

```
-keepattributes *Annotation*
-keep public class com.netease.nis.captcha.**{*;}

-keep public class android.webkit.**

-keepattributes SetJavaScriptEnabled
-keepattributes JavascriptInterface

-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
```         


🔨 使用

```dart
import 'package:flutter_net_captcha/flutter_net_captcha.dart';
```

#### 1. 配置验证码

```dart
FlutterNetCaptcha.configVerifyCode(VerifyCodeConfig);
```

VerifyCodeConfig

| 参数     | 描述              | 类型  | 默认值 |
| -------- | ----------------- | ----- | ------ |
| captchaId | 验证码id,管理后台获取 | String | Null | 
| timeoutInterval | 加载验证码的超时时间 | int | 10 | 
| mode | 验证码类型 | VerifyCodeMode | Normal | 
| openFallBack | 是否开启降级方案 | bool | true | 
| fallBackCount | 设置发生第fallBackCount次错误时，将触发降级 | int | 3 | 
| ipv6 | 是否支持ipv6 | bool | false | 
| closeButtonHidden | 是否隐藏关闭按钮 | bool | false | 
| shouldCloseByTouchBackground | 点击背景是否可以关闭验证码视图 | bool | true | 
| enableLog | 是否开启sdk日志打印 | bool | true | 

VerifyCodeMode（验证码类型)

- Normal 通用
- NoSense 无感知

#### 2. 验证

```
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
```

VerifyCodeClose (验证码窗口关闭类型)

- Manual 手动
- Auto 验证成功后自动关闭

支持的语言

```dart
enum VerifyLanguage {
  /// 中文
  ZH_CN,

  /// 英文
  EN,

  /// 繁体
  ZH_TW,

  /// 日文
  JP,

  /// 韩文
  KR,

  /// 泰文
  TL,

  /// 越南语
  VT,

  /// 法语
  FRA,

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
```

#### 3. 获取sdk版本号

```dart
String v = await FlutterNetCaptcha.getSdkVersion();
```

## Changelog

Refer to the [Changelog](CHANGELOG.md) to get all release notes.
