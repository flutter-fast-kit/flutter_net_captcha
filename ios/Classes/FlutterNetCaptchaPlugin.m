#import "FlutterNetCaptchaPlugin.h"

@implementation FlutterNetCaptchaPlugin {
    NTESVerifyCodeManager *manager;
    FlutterEventSink _eventSink;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_net_captcha"
            binaryMessenger:[registrar messenger]];
    FlutterNetCaptchaPlugin* instance = [[FlutterNetCaptchaPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];

    FlutterEventChannel* eventChannel =
        [FlutterEventChannel eventChannelWithName:@"flutter_net_captcha/event_channel"
                                  binaryMessenger:[registrar messenger]];
        [eventChannel setStreamHandler:instance];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"showCaptcha" isEqualToString:call.method]) {
      [self showCaptcha:call.arguments result:result];
  } else if ([@"configVerifyCode" isEqualToString:call.method]){
      [self configVerifyCode:call.arguments result:result];
  } else if ([@"getSdkVersion" isEqualToString:call.method]) {
      [self getSdkVersion:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (NTESVerifyCodeMode) getNTESVerifyCodeModeByString:(NSString *)mode {
    if ([mode containsString:@"Normal"]) {
        return NTESVerifyCodeNormal;
    } else if ([mode containsString:@"NoSense"]) {
        return NTESVerifyCodeBind;
    }

    return NTESVerifyCodeNormal;
}

- (void) showCaptcha:(id)args result:(FlutterResult)result {

    NSAssert(self->manager != nil, @"请先调用 configVerifyCode 配置验证码");

    self->manager.mode = [self getNTESVerifyCodeModeByString:args[@"mode"]];
    self->manager.lang = [self convertLanguage:args[@"language"]];
    [self->manager openVerifyCodeView:nil];

    result([NSNumber numberWithBool:YES]);
}

// 配置验证码
- (void) configVerifyCode:(id)arguments result:(FlutterResult)result {
    NTESVerifyCodeManager *manager = [NTESVerifyCodeManager getInstance];
    self->manager = manager;

    NSDictionary *args = (NSDictionary *)arguments;

    [self->manager configureVerifyCode:args[@"captchaId"] timeout:[args[@"timeoutInterval"] doubleValue]];
    self->manager.openFallBack = args[@"openFallBack"];
    self->manager.fallBackCount = [args[@"fallBackCount"] intValue];
    self->manager.ipv6 = args[@"ipv6"];
    self->manager.closeButtonHidden = args[@"closeButtonHidden"];
    self->manager.shouldCloseByTouchBackground = args[@"shouldCloseByTouchBackground"];
    [self->manager enableLog:args[@"enableLog"]];
    self->manager.delegate = self;

    result([NSNumber numberWithBool:YES]);
}

// 获取sdk版本号
- (void) getSdkVersion:(FlutterResult)result {
    result([NTESVerifyCodeManager getInstance].getSDKVersion);
}


#pragma mark - FlutterStreamHandlerDelete
- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    _eventSink = eventSink;
    return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
    _eventSink = nil;
    return nil;
}

#pragma mark - NTESVerifyCodeManagerDelegate
/**
 * 验证码组件初始化完成
 */
- (void) verifyCodeInitFinish {
    NSDictionary<NSString *, id> *eventData = @{
        @"method": @"onLoaded",
    };
    if (self->_eventSink) {
        self->_eventSink(eventData);
    }
}

/**
 * 验证码组件初始化出错
 *
 * @param message 错误信息
 */
- (void) verifyCodeInitFailed:(NSString *)message {
    NSDictionary<NSString *, id> *eventData = @{
        @"method": @"onError",
        @"data": message
    };
    if (self->_eventSink) {
        self->_eventSink(eventData);
    }
}

/**
 * 完成验证之后的回调
 *
 * @param result 验证结果 BOOL:YES/NO
 * @param validate 二次校验数据，如果验证结果为false，validate返回空
 * @param message 结果描述信息
 *
 */
- (void) verifyCodeValidateFinish:(BOOL)result validate:(NSString *)validate message:(NSString *)message {
    NSDictionary *dict = @{@"result":@(result),@"validate":validate ? : @"",@"msg":message ? : @""};

    NSDictionary<NSString *, id> *eventData = @{
        @"method": @"onVerify",
        @"data": dict
    };

    if (self->_eventSink) {
        self->_eventSink(eventData);
    }
}

- (void) verifyCodeCloseWindow:(NTESVerifyCodeClose)close {
    NSDictionary<NSString *, id> *eventData = @{
        @"method": @"onClose",
        @"data": @(close)
    };

    if (self->_eventSink) {
        self->_eventSink(eventData);
    }
}


- (NTESVerifyCodeLang) convertLanguage:(NSString *)language {
  if ([language containsString:@"ZH_CN"]) {
    return NTESVerifyCodeLangCN;
  } else if ([language containsString:@"ZH_TW"]) {
    return NTESVerifyCodeLangTW;
  }else if ([language containsString:@"EN"]) {
    return NTESVerifyCodeLangEN;
  }else if ([language containsString:@"KO"]) {
    return NTESVerifyCodeLangKR;
  }else if ([language containsString:@"JA"]) {
    return NTESVerifyCodeLangJP;
  }else if ([language containsString:@"FR"]) {
    return NTESVerifyCodeLangFRA;
  }else if ([language containsString:@"ES"]) {
    return NTESVerifyCodeLangES;
  }
  return NTESVerifyCodeLangTW;
}

@end
