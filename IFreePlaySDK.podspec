
Pod::Spec.new do |s|
  s.name             = 'IFreePlaySDK'
  s.version          = '1.3.0'
  s.summary          = '集成facebook登录/分享／邀请，微信登录／分享，苹果IAP内购支付并打包成静态库'

  s.description      = <<-DESC
TODO: 集成facebook登录/分享／邀请，微信登录／分享，苹果IAP内购支付并打包成静态库
                       DESC

  s.homepage         = 'https://github.com/zhengyachao/IFreePlaySDK'

  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zhengyachao' => '15038253754@163.com' }
  s.source           = { :git => 'https://github.com/zhengyachao/IFreePlaySDK.git', :tag => '1.3.0' }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'IFreePlaySDK/sources/**/*.{h,m}'

  s.public_header_files = 'IFreePlaySDK/sources/**/*.h'

  s.vendored_libraries  = 'IFreePlaySDK/libs/libWeChatSDK.a'

  s.libraries = 'c++', 'sqlite3', 'z'
  s.frameworks = 'UIKit', 'Foundation', 'Security','CoreTelephony', 'SystemConfiguration','CFNetwork','WebKit','PassKit','MobileCoreServices','AddressBook','CoreGraphics','CoreLocation','Accelerate','AudioToolbox','CoreMedia','MessageUI','SafariServices'

  s.xcconfig         = { 'OTHER_LDFLAGS' => '-lc++ -ObjC'}

  s.dependency 'FBSDKCoreKit'
  s.dependency 'FBSDKLoginKit'
  s.dependency 'FBSDKShareKit'
  s.dependency 'YTKNetwork'

end
