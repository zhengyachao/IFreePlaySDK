# IFreePlaySDK
包括微信、Facebook、line登录，Paypal、微信，Apple内购支付等功能。

# 集成方式
强烈建议使用cocoapods来集成，集成cocoapods请自行百度
vim Podfile
platform :ios, '8.0'
pod 'IFreePlaySDK', '~> 1.1'
pod install
demo地址:https://github.com/zhengyachao/IFreePlaySdk.git
demo中的Facebook登录和line登录均需要设置翻墙代理(建议下载蓝灯如果您有别的代理软件或者代理服务器更好)

# 集成前准备
需要到微信、Facebook、line、PayPal、Apple这些第三方的开发者中心申请注册相关的资料比如微信的appid AppSecret, facebook的应用编号等demo里面都已集成完毕。
需要在info.plist中加入我们已经申请好的资料将一下的代码粘贴到info.plist中（右键找到open AS->Source Code打开粘贴）
<key>CFBundleURLTypes</key>
<array>
<dict>
<key>CFBundleURLSchemes</key>
<array>
<string>fb1968115763476877</string>
</array>
</dict>
<dict>
<key>CFBundleTypeRole</key>
<string>Editor</string>
<key>CFBundleURLSchemes</key>
<array>
<string>line3rdp.$(PRODUCT_BUNDLE_IDENTIFIER)</string>
</array>
</dict>
<dict>
<key>CFBundleTypeRole</key>
<string>Editor</string>
<key>CFBundleURLName</key>
<string>weixin</string>
<key>CFBundleURLSchemes</key>
<array>
<string>wx5c8698af4ea9d013</string>
</array>
</dict>
<dict/>
</array>
<key>CFBundleVersion</key>
<string>1</string>
<key>FacebookAppID</key>
<string>1968115763476877</string>
<key>FacebookDisplayName</key>
<string>IFreePlaySDK</string>
<key>LSApplicationQueriesSchemes</key>
<array>
<string>fbapi</string>
<string>fb-messenger-api</string>
<string>fbauth2</string>
<string>fbshareextension</string>
<string>lineauth</string>
<string>line3rdp.$(PRODUCT_BUNDLE_IDENTIFIER)</string>
<string>weixin</string>
<string>wechat</string>
<string>com.paypal.ppclient.touch.v1</string>
<string>com.paypal.ppclient.touch.v2</string>
<string>org-appextension-feature-password-management</string>
</array>
<key>NSPhotoLibraryUsageDescription</key>
<string>需要您的同意，才能访问相册。</string>
<key>LSRequiresIPhoneOS</key>
<true/>
<key>LineSDKConfig</key>
<dict>
<key>ChannelID</key>
<string>1529112421</string>
</dict>
<key>NSAppTransportSecurity</key>
<dict>
<key>NSAllowsArbitraryLoads</key>
<true/>
<key>NSExceptionDomains</key>
<dict>
<key>facebook.com</key>
<dict>
<key>NSExceptionAllowsInsecureHTTPLoads</key>
<true/>
<key>NSExceptionRequiresForwardSecrecy</key>
<false/>
<key>NSIncludesSubdomains</key>
<true/>
</dict>
<key>fbcdn.net</key>
<dict>
<key>NSExceptionAllowsInsecureHTTPLoads</key>
<true/>
<key>NSExceptionRequiresForwardSecrecy</key>
<false/>
<key>NSIncludesSubdomains</key>
<true/>
</dict>
</dict>
</dict>

需要在target的info下的URL types中添加相应的URL schemes

# 使用方式
1、在AppDelegate.m中的：
需要导入头文件 
#import <IFreePlaySDK/YKSDKManager.h>

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
// 初始化SDK
// appId参数是指申请的微信的appid  clientId参数指的是PayPal的客户id由于涉及到支付该id区分正式环境和沙箱测试环境下的id,此   
// demo给的是沙箱下的id
[[YKSDKManager shareManager] initSDKForApplication:application launchOptions:launchOptions appId:@"wx5c8698af4ea9d013" clientId:@"ATdJEC70AgF4ae_jIaK8WiVMzxBiarr-Whf1dJMAWbGm8IVQG57o28GA_5hLKvNFIH9vIoPqG13MLQ8T"];
}

唤起第三方app包括微信，Facebook，line
/* iOS 9.0之前 */
- (BOOL)application:(UIApplication *)application
openURL:(NSURL *)url
sourceApplication:(NSString *)sourceApplication
annotation:(id)annotation
{
return [[YKSDKManager shareManager] application:application
openURL:url
sourceApplication:sourceApplication
annotation:annotation];
}

//如果发现弹出的登录无法关闭，请将添加下面这个，注释上面那个
//解决方案来源：http://stackoverflow.com/questions/32299271/facebook-sdk-login-never-calls-back-my-application-on-ios-9
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary *)options
{
return  [[YKSDKManager shareManager] application:app openURL:url options:options];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
return [[YKSDKManager shareManager] application:application handleOpenURL:url];
}


2、使用登录功能，如下实例 使用微信登录、Facebook登录和line功能：
需要导入
#import <IFreePlaySDK/YKSDKManager.h>
//2.1  使用微信第三方登录：
[[YKSDKManager shareManager] loginWechatGetUserInfoVc:self
GameId:@"1"
Type:PlatformsType(YKPlatformType_Wechat)
success:^(NSDictionary *data)
{
// 这里可以拿到回调之后得到的个人信息有关的数据
}
failure:^(NSError *error)
{
// 这里回调可以查看失败的原因
}];
//2.2  使用Facebook第三方登录调用此方法：
[[YKSDKManager shareManager] loginFacebookVC:self
GameId:@"1"
Type:PlatformsType(YKPlatformType_Facebook)
success:^(NSDictionary *data)
{

} failure:^(NSError *error)
{

}];

//2.3  使用line第三方登录调用此方法：
[[YKSDKManager shareManager] startLoginToLineGameId:@"1" Type:PlatformsType(YKPlatformType_Line)
success:^(NSDictionary *data)
{
} failure:^(NSError *error)
{

}];

3、获取商品列表页面
需要导入
#import <IFreePlaySDK/YKSDKManager.h>
#import <IFreePlaySDK/YKLoginRequest.h>
#import <IFreePlaySDK/YKUtilsMacro.h>
这里使用了猿题库的网络框架来做网络请求 
// 
YKGameIdRequest *request = [[YKGameIdRequest alloc] initGameId:@"3"];

[request startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
NSDictionary *result = request.responseObject;
NSArray *data = [result objectForKey:@"data"];
if (data.count > 0 ) {
[data enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
[self.productListArray addObject:obj];
}];
}
dispatch_async(dispatch_get_main_queue(), ^{
[self.tableView reloadData];
});
} failure:^(__kindof YTKBaseRequest * _Nonnull request) {
NSLog(@"%@",request.error);
}];

4、生成订单获取订单orderId
NSDictionary *dict = self.productListArray[indexPath.row];
NSDictionary *params = @{@"productId":[dict objectForKey:@"id"],
@"playerId":@"1",
@"currencyTypes":CurrencyType(YKCNY),
@"spbillCreateIp":[self getIPAddress:YES]
};
// 这里的spbillCreateIp是获取本机的IP地址 具体的方法实现demo中有[self getIPAddress:YES]

[[YKSDKManager shareManager] getOrderInfoWithParams:params
success:^(NSDictionary *result)
{
// 回调结果里面的id即是orderId 拿到订单id后可发起支付。
}
failure:^(NSError *error)
{
}];

5、支付（包括微信支付，Paypal和AppleIAP内购支付）
//5.1 发起微信支付 通过上面获取到的orderId来发起支付
[[YKSDKManager shareManager] lunchWechatPayWithOrderId:self.orderId viewController:self];

//5.2 苹果内购交易结束之后把订单凭证上传给后台
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
NSLog(@"交易结束");
NSData *data = [NSData dataWithContentsOfFile:[[[NSBundle mainBundle] appStoreReceiptURL] path]];
NSString *receiptData = [[NSString alloc] initWithData:[GTMBase64 encodeData:data] encoding:NSUTF8StringEncoding];
NSLog(@"%@",receiptData);
[[YKSDKManager shareManager] verifyAppleIAPWithOrderId:self.orderId receiptData:receiptData verifyEnvironment:@"Sandbox"];
[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

//5.3 Paypal支付
NSString *paypalId = [[completedPayment.confirmation objectForKey:@"response"] objectForKey:@"id"];
[[YKSDKManager shareManager] verifyPaypalWithPaypalId:paypalId orderId:self.orderId];
[self dismissViewControllerAnimated:YES completion:nil];

# 关于我
有任何使用问题，可以给我发邮件：
Author：郑亚超 (Poppy)
E-mail：1120043690@qq.com
