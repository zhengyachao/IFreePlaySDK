//
//  YKUtilsMacro.h
//  Pods
//
//  Created by ifreeplay on 2017/9/20.
//
//

#ifndef YKUtilsMacro_h
#define YKUtilsMacro_h

// 微信相关
#define kWxApp_id      @"wx5c8698af4ea9d013"
#define kWxApp_Secret  @"6404466b271ee9732f15da181ed15ad1"

// Paypal沙箱测试ID
#define kPaypalClientID  @"ATdJEC70AgF4ae_jIaK8WiVMzxBiarr-Whf1dJMAWbGm8IVQG57o28GA_5hLKvNFIH9vIoPqG13MLQ8T"

/* 测试域名 */
#define kIFBaseUrl     @"http://192.168.0.114:8081"
/* 根据微信返回的code获取accessToken和openId接口 */
#define kWechatGetToken                       @"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code"
/* 根据微信返回的accessToken和openId来获取用户信息接口 */
#define kWechatGetUserInfo                    @"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@"
/* 本地的登录接口 */
#define kIFSDKLogin                           @"/auth/login"
/* 本地根据gameId、productId 获取订单的接口 */
#define kIFSDKGetProductsOrder                @"/order"
/* 本地获取支付订单详情信息接口 (这里指微信)*/
#define kIFSDKGetPayInfo                      @"/payment/wechat"
/* 通过gameId来获取商品信息 */
#define kIFSDKGetProduct                      @"/product/findByGameId"
/* 通过gameId来获取商品信息 */
#define kIFSDKPaypal                          @"/payment/paypal"
/* 本地获取苹果支付订单凭证接口*/
#define kIAPPayInfo                           @"/payment/apple/orderVerify"

#endif /* YKUtilsMacro_h */
