//
//  YKSDKManager.h
//  ZYCTestDemo
//
//  Created by ifreeplay on 2017/8/7.
//  Copyright © 2017年 ifreeplay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^YKSDKManagerRequestSuccess)(NSDictionary *data);
typedef void (^YKSDKManagerRequestFailed)(NSError *error);

/* 根据微信返回的code获取accessToken和openId 调用接口 */
#define kWechatGetToken     @"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code"

#define kWechatGetUserInfo  @"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@"

@interface YKSDKManager : NSObject

+ (instancetype)shareManager;

#pragma mark -- FaceBook登录
/* 初始化Facebook */
- (void)initFaceBookSDKForApplication:(UIApplication *)application
        didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

/* 记录APP激活数据统计 */
+ (void)activateApp;

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation;

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

#pragma mark -- 微信登录
/* WXApi的成员函数，向微信终端程序注册第三方应用 */
- (void)registerAppForWechat:(NSString *)wxAppid;

/* 处理微信通过URL启动App时传递的数据 */
- (BOOL)handleOpenURLForWechat:(NSURL *)url;

/* 登录微信获取用户信息 */
- (void)loginWechatGetUserInfoVc:(UIViewController *)vc
                          GameId:(NSString *)gameId
                            Type:(NSString *)type
                           Appid:(NSString *)appid
                       Appsecret:(NSString *)appSecret
                         success:(void (^)(NSDictionary *))successBlock
                         failure:(void (^)(NSError *))failureBlock;


@end
