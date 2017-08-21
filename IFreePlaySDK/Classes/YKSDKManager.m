//
//  YKSDKManager.m
//  ZYCTestDemo
//
//  Created by ifreeplay on 2017/8/7.
//  Copyright © 2017年 ifreeplay. All rights reserved.
//

#import "WXApi.h"
#import "YKSDKManager.h"
#import "LineSDK.h"
#import "YKRequestNetwork.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface YKSDKManager ()<LineSDKLoginDelegate,WXApiDelegate>
{
    NSString *_gameId;
    NSString *_type;
    NSString *_wxAppId;
    NSString *_wxAppSecret;
}

@property (nonatomic, copy) void(^successBlock)(NSDictionary *data);
@property (nonatomic, copy) void(^failureBlock)(NSError *error);

@end
@implementation YKSDKManager

+ (instancetype)shareManager
{
    static YKSDKManager *ykmanager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ykmanager = [[YKSDKManager alloc] init];
    });
    
    return ykmanager;
}

#pragma mark -- FaceBook登录相关
/* 初始化facebook */
- (void)initFaceBookSDKForApplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
}

+ (void)activateApp {
    [FBSDKAppEvents activateApp];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return  [[FBSDKApplicationDelegate sharedInstance] application:application
                                                           openURL:url
                                                 sourceApplication:sourceApplication
                                                        annotation:annotation];
}

/* 登录Facebook读取用户权限 */
- (void)loginFacebookVC:(UIViewController *)vc
                 GameId:(NSString *)gameId
                   Type:(NSString *)type
                success:(void (^)(NSDictionary *))successBlock
                failure:(void (^)(NSError *))failureBlock
{
    self.successBlock = successBlock;
    self.failureBlock = failureBlock;
    _gameId = gameId;
    _type = type;
    
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logOut];
    login.loginBehavior = FBSDKLoginBehaviorNative;
    [login logInWithReadPermissions: @[@"public_profile",@"email",@"user_about_me"]
                 fromViewController:vc
                            handler:^(FBSDKLoginManagerLoginResult *result, NSError *error)
     {
         NSLog(@"facebook login result.grantedPermissions = %@,error = %@",result.grantedPermissions,error);
         if (error)
         {
             NSLog(@"Process error");
         } else if (result.isCancelled)
         {
             NSLog(@"Cancelled");
         } else
         {
             NSLog(@"Logged in");
             //获取用户id, 昵称
             if ([FBSDKAccessToken currentAccessToken])
             {
                 FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me?fields=id,name" parameters:nil];
                 [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                     NSString *userID = result[@"id"];
                     
                     if (!error && [[FBSDKAccessToken currentAccessToken].userID isEqualToString:userID])
                     {
                         NSString *userID = result[@"id"];
                         NSString *userName = result[@"name"];
                        
                         [self postServiceName:userName Openid:userID];
                     }
                 }];
             }
         }
     }];
}

#pragma mark -- Line登录相关&LineSDKLoginDelegate
- (void)startLoginToLineGameId:(NSString *)gameId
                          Type:(NSString *)type
                       success:(void (^)(NSDictionary *))successBlock
                       failure:(void (^)(NSError *))failureBlock
{
    self.successBlock = successBlock;
    self.failureBlock = failureBlock;
    _gameId = gameId;
    _type = type;
    
    [LineSDKLogin sharedInstance].delegate = self;
    [[LineSDKLogin sharedInstance] startLogin];
}

/* 唤起Line */
- (BOOL)handleOpenURL:(NSURL *)url
{
    return [[LineSDKLogin sharedInstance] handleOpenURL:url];
}

/* LineSDKLoginDelegate方法 */
- (void)didLogin:(LineSDKLogin *)login
      credential:(nullable LineSDKCredential *)credential
         profile:(nullable LineSDKProfile *)profile
           error:(nullable NSError *)error
{
    if (error)
    {
        NSLog(@"Error: %@", error.localizedDescription);
    }
    else
    {
        NSString * userID = profile.userID;
        NSString * displayName = profile.displayName;
       /* 调用本地服务器接口获取token */
        [self postServiceName:displayName Openid:userID];
    }
}

#pragma mark -- 微信登录
/* WXApi的成员函数，向微信终端程序注册第三方应用 */
- (void)registerAppForWechat:(NSString *)wxAppid
{
    [WXApi registerApp:wxAppid];
}

/* 处理微信通过URL启动App时传递的数据 */
- (BOOL)handleOpenURLForWechat:(NSURL *)url
{
    return [WXApi handleOpenURL:url delegate:self];
}

/* WXApiDelegate方法
 *
 * 发送一个sendReq后，收到微信的回应
 */
- (void)onResp:(BaseResp *)resp
{
    if ([resp isKindOfClass:[SendAuthResp class]]) //判断是否为授权请求，否则与微信支付等功能发生冲突
    {
        SendAuthResp *aresp = (SendAuthResp *)resp;
        if (aresp.errCode== 0)
        {
            /* 根据微信返回的code获取accesstoken和opened */
            [self getWechatAccessTokenWithCode:aresp.code];
        }
    }
}
/* 根据微信回应拿到的code去获取accessToken和openId */
- (void)getWechatAccessTokenWithCode:(NSString *)code
{
    NSString *url =[NSString stringWithFormat:kWechatGetTokenUrl,_wxAppId,_wxAppSecret,code];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (data)
            {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data
                                                                    options:NSJSONReadingMutableContainers error:nil];
                
                NSString *accessToken = dic[@"access_token"];
                NSString *openId = dic[@"openid"];
                
                [self getWechatUserInfoWithAccessToken:accessToken openId:openId];
            }
        });
    });
}
/* 根据获取到的openId和accessToken获取用户个人信息 */
- (void)getWechatUserInfoWithAccessToken:(NSString *)accessToken openId:(NSString *)openId
{
    NSString *url =[NSString stringWithFormat:kWechatGetUserInfoUrl,accessToken,openId];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (data)
            {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data
                                                                    options:NSJSONReadingMutableContainers error:nil];
                NSString *openId = [dic objectForKey:@"openid"];
                NSString *memNickName = [dic objectForKey:@"nickname"];
                /* 调用本地服务器接口获取token */
                [self postServiceName:memNickName Openid:openId];
            }
        });
    });
}

/* 根据微信的name获取用户信息 */
- (void)loginWechatGetUserInfoVc:(UIViewController *)vc
                          GameId:(NSString *)gameId
                            Type:(NSString *)type
                           Appid:(NSString *)appid
                       Appsecret:(NSString *)appSecret
                         success:(void (^)(NSDictionary *))successBlock
                         failure:(void (^)(NSError *))failureBlock
{
    self.successBlock = successBlock;
    self.failureBlock = failureBlock;
    _gameId = gameId;
    _type = type;
    _wxAppId = appid;
    _wxAppSecret = appSecret;
    
    if ([WXApi isWXAppInstalled])
    {
        SendAuthReq *req = [[SendAuthReq alloc] init];
        req.scope = @"snsapi_userinfo";
        req.state = @"App";
        [WXApi sendReq:req];
    }
    else {
        [self setupAlertController:vc];
    }
}

- (void)setupAlertController:(UIViewController *)vc
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请先安装微信客户端" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionConfirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:actionConfirm];
    [vc presentViewController:alert animated:YES completion:nil];
}

- (void)postServiceName:(NSString *)name Openid:(NSString *)openId
{
    NSDictionary *params;
    if ([_type isEqualToString:@"WECHAT"])
    {
        params = @{@"gameId":_gameId,
                   @"type":_type,
                   @"wechatId":openId,
                   @"name":name};
        
    } else if ([_type isEqualToString:@"FACEBOOK"])
    {
        params = @{@"gameId":_gameId,
                   @"type":_type,
                   @"facebookId":openId,
                   @"name":name};
    } else if ([_type isEqualToString:@"LINE"])
    {
        params = @{@"gameId":_gameId,
                   @"type":_type,
                   @"lineId":openId,
                   @"name":name};
    }
    
    
    [YKRequestNetwork postRequestByServiceUrl:kLocalHostUrl
                                   parameters:params success:^(NSDictionary *data)
     {
         self.successBlock(data);
     } failure:^(NSError *error)
     {
         self.failureBlock(error);
     }];
}

@end
