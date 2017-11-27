Pod::Spec.new do |s|
  s.name = "IFreePlaySDK"
  s.version = "1.0.9"
  s.summary = "\u{96c6}\u{6210}facebook\u{767b}\u{5f55}\u{ff0c}line\u{767b}\u{5f55}\u{ff0c}\u{5fae}\u{4fe1}\u{767b}\u{5f55}\u{ff0c}\u{5e76}\u{6253}\u{5305}\u{6210}\u{9759}\u{6001}\u{5e93}"
  s.license = {"type"=>"MIT", "file"=>"LICENSE"}
  s.authors = {"zhengyachao"=>"15038253754@163.com"}
  s.homepage = "https://github.com/zhengyachao/IFreePlaySDK"
  s.description = "TODO: \u{5bf9}Facebook\u{767b}\u{5f55}\u{548c}line\u{767b}\u{5f55}\u{4ee5}\u{53ca}\u{5fae}\u{4fe1}\u{767b}\u{5f55}\u{505a}\u{4e00}\u{6b21}\u{5c01}\u{88c5}"
  s.frameworks = ["UIKit", "Foundation", "Security", "CoreTelephony", "SystemConfiguration", "CFNetwork"]
  s.libraries = ["c++", "sqlite3", "z"]
  s.requires_arc = true
  s.source = { :path => '.' }

  s.ios.deployment_target    = '8.0'
  s.ios.vendored_framework   = 'ios/IFreePlaySDK.framework'
end
