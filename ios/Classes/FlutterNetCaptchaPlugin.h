#import <Flutter/Flutter.h>
#import <VerifyCode/NTESVerifyCodeManager.h>

@interface FlutterNetCaptchaPlugin : NSObject<FlutterPlugin, FlutterStreamHandler, NTESVerifyCodeManagerDelegate>
@end
