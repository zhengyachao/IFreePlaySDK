//
//  YKSDKManager.h
//  ZYCTestDemo
//
//  Created by ifreeplay on 2017/8/7.
//  Copyright © 2017年 ifreeplay. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef void (^YKSDKManagerRequestSuccess)(NSDictionary *data);
typedef void (^YKSDKManagerRequestFailed)(NSError *error);

@interface YKSDKManager : NSObject

+ (instancetype)shareManager;

#pragma mark -- FaceBook登录
/* 初始化*/
- (void)initSDKForApplication:(UIApplication *)application launchOptions:(NSDictionary *)launchOptions appId:(NSString *)appId clientId:(NSString *)clientIds;

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

#pragma mark -- Line登录
/* 登录Line */
- (void)startLoginToLineGameId:(NSString *)gameId
                          Type:(NSString *)type
                       success:(void (^)(NSDictionary *))successBlock
                       failure:(void (^)(NSError *))failureBlock;;
/* 唤起Line */
- (BOOL)handleOpenURL:(NSURL *)url;

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
/* 获取orderNmuber
 * gameId      游戏id
 * productId   商品id
 * productName 商品名称
 * playerId    玩家id
 * status      状态"OPEN" 新建 PAYED,已支付REFUND,已退款 CANCELED,已取消
 * price       商品单价
 * totalPrice  订单总价
 * dealPrice   订单成交价
 * spbillCreateIp  终端的设备IP地址
 */
- (void)getOrderInfoWithParams:(NSDictionary *)params
                       success:(void (^)(NSDictionary *))successBlock
                       failure:(void (^)(NSError *))failureBlock;

/* 发起微信支付 通过orderNumber*/
- (void)lunchWechatPayWithOrderNum:(NSString *)orderNum;

/* 发起Paypal支付验证 通过orderNumber和PayPal回调返回的paypalId*/
- (void)verifyPaypalWithPaypalId:(NSString *)paypalId orderNumber:(NSString *)orderNumber;

/* 发起AppleIAP支付验证 通过orderNumber和PayPal回调返回的paypalId
 * orderNumber 订单号
 * receiptData apple支付凭证 base64字符串
 * verifyEnvironment 环境 如果是沙箱传Sandbox 如果是正式环境传Live
 */
- (void)verifyAppleIAPWithorderNumber:(NSString *)orderNumber receiptData:(NSString *)receiptData verifyEnvironment:(NSString *)verifyEnvironment;

@end
