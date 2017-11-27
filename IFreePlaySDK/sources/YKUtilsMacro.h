//
//  YKUtilsMacro.h
//  Pods
//
//  Created by ifreeplay on 2017/9/20.
//
//

#ifndef YKUtilsMacro_h
#define YKUtilsMacro_h

typedef enum
{
    YKPlatformType_Facebook, // FACEBOOK
    YKPlatformType_Line,     // LINE
    YKPlatformType_Wechat    // WECHAT
} YKPlatformsType;
// 支付状态
typedef enum
{
    YKPayStatusOPEN,// 新建
    YKPayStatusPAYED,// 已支付
    YKPayStatusREFUND,// 已退款
    YKPayStatusCANCELED // 已取消
} YKPayStatus;
// 货币类型
typedef enum
{
    YKUSD,
    YKHKD,
    YKJPY,
    YKGBP,
    YKEUR
} YKCurrencyType;

#define PlatformsType(enum) [@[@"FACEBOOK",@"LINE",@"WECHAT"] objectAtIndex:enum]
#define PayStatus(enum)     [@[@"OPEN",@"PAYED",@"REFUND",@"CANCELED"] objectAtIndex:enum]
#define CurrencyType(enum)  [@[@"USD",@"HKD",@"JPY",@"GBP",@"EUR"] objectAtIndex:enum]


/* 测试域名 */
#define kIFBaseUrl     @"http://192.168.0.105:8080"
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
