#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_net_captcha.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_net_captcha'
  s.version          = '1.0.0'
  s.summary          = 'Net Captcha plugin for Flutter.  '
  s.description      = <<-DESC
Net Captcha plugin for Flutter.  
                       DESC
  s.homepage         = 'https://github.com/flutter-fast-kit/flutter_net_captcha'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'SimMan' => 'lunnnnul@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'NTESVerifyCode','3.3.4'
  s.platform = :ios, '8.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
