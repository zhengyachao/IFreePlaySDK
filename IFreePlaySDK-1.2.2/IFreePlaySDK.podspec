Pod::Spec.new do |s|
  s.name = "IFreePlaySDK"
  s.version = "1.2.2"
  s.summary = "\u{96c6}\u{6210}facebook\u{767b}\u{5f55}\u{ff0c}line\u{767b}\u{5f55}\u{ff0c}\u{5fae}\u{4fe1}\u{767b}\u{5f55}\u{ff0c}\u{5fae}\u{4fe1}\u{652f}\u{4ed8}\u{ff0c}paypal\u{652f}\u{4ed8}\u{ff0c}\u{82f9}\u{679c}IAP\u{5185}\u{8d2d}\u{652f}\u{4ed8}\u{5e76}\u{6253}\u{5305}\u{6210}\u{9759}\u{6001}\u{5e93}"
  s.license = {"type"=>"MIT", "file"=>"LICENSE"}
  s.authors = {"zhengyachao"=>"15038253754@163.com"}
  s.homepage = "https://github.com/zhengyachao/IFreePlaySDK"
  s.description = "TODO: \u{96c6}\u{6210}facebook\u{767b}\u{5f55}\u{ff0c}line\u{767b}\u{5f55}\u{ff0c}\u{5fae}\u{4fe1}\u{767b}\u{5f55}\u{ff0c}\u{5fae}\u{4fe1}\u{652f}\u{4ed8}\u{ff0c}paypal\u{652f}\u{4ed8}\u{ff0c}\u{82f9}\u{679c}IAP\u{5185}\u{8d2d}\u{652f}\u{4ed8}\u{5e76}\u{6253}\u{5305}\u{6210}\u{9759}\u{6001}\u{5e93}"
  s.frameworks = ["UIKit", "Foundation", "Security", "CoreTelephony", "SystemConfiguration", "CFNetwork", "WebKit", "PassKit", "MobileCoreServices", "AddressBook", "CoreGraphics", "CoreLocation", "Accelerate", "AudioToolbox", "CoreMedia", "MessageUI", "SafariServices"]
  s.libraries = ["c++", "sqlite3", "z"]
  s.requires_arc = true
  s.xcconfig = {"OTHER_LDFLAGS"=>"-lc++ -ObjC"}
  s.source = { :path => '.' }

  s.ios.deployment_target    = '8.0'
  s.ios.vendored_framework   = 'ios/IFreePlaySDK.framework'
end
