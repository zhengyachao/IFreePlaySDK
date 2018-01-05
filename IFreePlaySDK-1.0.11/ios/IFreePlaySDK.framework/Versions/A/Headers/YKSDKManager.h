//
//  YKSDKManager.h
//  ZYCTestDemo
//
//  Created by ifreeplay on 2017/8/7.
//  Copyright © 2017年 ifreeplay. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

// 三方登录的平台类型
typedef enum
{
    YKPlatformType_Facebook, // FACEBOOK
    YKPlatformType_Line,     // LINE
    YKPlatformType_Wechat    // WECHAT
} YKPlatformsType;

/**
 *  分享回调状态
 */
typedef NS_ENUM(NSUInteger, YKResponseState)
{
    /* 分享成功 */
    SSDKResponseStateSuccess    = 0,
    
    /* 分享失败 */
    SSDKResponseStateFail       = 1,
    
    /* 取消分享 */
    SSDKResponseStateCancel     = 2
};

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
    YKCNY,        // 人民币
    YKUSD,        // 美元
    YKHKD,        // 港币
    YKJPY,        // 日元
    YKGBP,        // 英镑
    YKEUR         // 欧元
} YKCurrencyType;

// 货币类型
typedef enum
{
    YKSceneSession = 0,        // 发送给好友
    YKSceneTimeline = 1        // 发送到朋友圈
} YKWechatScene;

#define PlatformsType(enum) [@[@"FACEBOOK",@"LINE",@"WECHAT"] objectAtIndex:enum]
#define PayStatus(enum)     [@[@"OPEN",@"PAYED",@"REFUND",@"CANCELED"] objectAtIndex:enum]
#define CurrencyType(enum)  [@[@"CNY",@"USD",@"HKD",@"JPY",@"GBP",@"EUR"] objectAtIndex:enum]

typedef void (^YKSDKManagerRequestSuccess)(NSDictionary *data);
typedef void (^YKSDKManagerRequestFailed)(NSError *error);
typedef void (^YKShareStateChangedHandler)(YKResponseState state, NSError *error);

@interface YKSDKManager : NSObject

+ (instancetype)shareManager;

#pragma mark -- FaceBook登录
/* 初始化*/
- (void)initSDKForApplication:(UIApplication *)application
                launchOptions:(NSDictionary *)launchOptions
                        appId:(NSString *)appId
                     clientId:(NSString *)clientIds;

/* 记录APP激活数据统计 */
+ (void)activateApp;

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation;

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary *)options;

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url;

/* 登录Facebook读取用户权限 */
- (void)loginFacebookVC:(UIViewController *)vc
                 GameId:(NSString *)gameId
                   Type:(NSString *)type
                success:(void (^)(NSDictionary *))successBlock
                failure:(void (^)(NSError *))failureBlock;

#pragma mark -- Facebook分享
/**
 *  分享内容
 *  @param url   分享的链接
 *  @param vc    分享所在页面的控制器
 *  @param stateChangedHandler    状态变更回调处理
 */
- (void)YKSetupShareParamsByUrl:(NSURL *)url currentVc:(UIViewController *)vc handler:(YKShareStateChangedHandler)stateChangedHandler;

- (void)YKSetupInviteParamsByUrl:(NSURL *)url currentVc:(UIViewController *)vc handler:(YKShareStateChangedHandler)stateChangedHandler;

#pragma mark -- 微信登录&微信支付
/* WXApi的成员函数，向微信终端程序注册第三方应用 */
- (void)registerAppForWechat:(NSString *)wxAppid;

/* 处理微信通过URL启动App时传递的数据 */
- (BOOL)handleOpenURLForWechat:(NSURL *)url;

/* 登录微信获取用户信息 */
- (void)loginWechatGetUserInfoVc:(UIViewController *)vc
                          GameId:(NSString *)gameId
                            Type:(NSString *)type
                         success:(void (^)(NSDictionary *))successBlock
                         failure:(void (^)(NSError *))failureBlock;
/* 获取orderId
 * params对象包括productId、playerId、CurrencyType、spbillCreateIp四个参数
 * productId   商品id
 * playerId    玩家id
 * CurrencyType 货币类型
 * spbillCreateIp  终端的设备IP地址
 */
- (void)getOrderInfoWithParams:(NSDictionary *)params
                       success:(void (^)(NSDictionary *))successBlock
                       failure:(void (^)(NSError *))failureBlock;


#pragma mark -- 微信分享朋友 && 朋友圈
/**
 *  分享内容
 *  @param title   分享的标题
 *  @param description   分享的描述
 *  @param image   分享的缩略图
 *  @param url   分享的链接
 *  @param vc    分享所在页面的控制器
 *  @param stateChangedHandler    状态变更回调处理
 */
- (void)YKWechatShareParamsByTitle:(NSString *)title
                       description:(NSString *)description
                             image:(UIImage *)image
                               url:(NSString *)url
                             scene:(int)scene
                         currentVc:(UIViewController *)vc
                           handler:(YKShareStateChangedHandler)stateChangedHandler;

#pragma mark -- Apple支付

/* 发起AppleIAP支付验证 通过orderId和PayPal回调返回的paypalId
 * orderId 订单号
 * receiptData apple支付凭证 base64字符串
 * verifyEnvironment 环境 如果是沙箱传Sandbox 如果是正式环境传Live
 */
- (void)verifyAppleIAPWithOrderId:(NSString *)orderId receiptData:(NSString *)receiptData verifyEnvironment:(NSString *)verifyEnvironment;

@end
