//
//  YKSDKManager.m
//  ZYCTestDemo
//
//  Created by ifreeplay on 2017/8/7.
//  Copyright © 2017年 ifreeplay. All rights reserved.
//


#import "WXApi.h"
#import <LineSDK/LineSDK.h>
#import "YKSDKManager.h"
#import "YKUtilTools.h"
#import "YKRequestNetwork.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

/* 根据微信返回的code获取accessToken和openId 调用接口 */
#define kWechatGetTokenUrl     @"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code"

/* 根据微信返回的accessToken和openId获取用户个人信息 */
#define kWechatGetUserInfoUrl  @"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@"

/* 本地服务器登录接口 */
#define kLocalHostUrl                 @"http://172.100.8.66:8080/auth/login?"

/* 本地服务器微信支付获取商品订单接口 */
#define kLocalHostGetOrderUrl         @"http://172.100.8.66:8080/order"

#define kLocalHostWxPaymentInfo       @"http://172.100.9.96:8080/payment/wechat"

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
    if ([[LineSDKLogin sharedInstance] canLoginWithLineApp])
    {
        [[LineSDKLogin sharedInstance] startLogin];
    } else
    {
        [[LineSDKLogin sharedInstance] startWebLoginWithSafariViewController:YES];
    }
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
    [WXApi registerApp:wxAppid enableMTA:NO];
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

/* 发起微信支付 */
- (void)launchWechatPat
{
    
    NSDictionary *params = @{@"gameId":@"1",
                             @"productId":@"1",
                             @"productName":@"Game props",
                             @"playerId":@"121212121",
                             @"status":@"OPEN",
                             @"price":@"1",
                             @"totalPrice":@"1",
                             @"dealPrice":@"1",
                             @"spbillCreateIp":[YKUtilTools getIPAddress:YES]
                             };
    [YKRequestNetwork postRequestByServiceUrl:@"http://172.100.9.96:8080/order" parameters:params success:^(NSDictionary *data) {
        NSLog(@"success request");
        NSString *url = [NSString stringWithFormat:@"http://172.100.9.96:8080/payment/wechat/%@",data[@"orderId"]];
        NSString *ordercreatetime = [data objectForKey:@"createDateTime"];
        [YKRequestNetwork postRequestByServiceUrl:url parameters:@{} success:^(NSDictionary *data) {
            NSLog(@"%@",data);
            //调起微信支付
            PayReq* req             = [[PayReq alloc] init];
            req.openID              = [data objectForKey:@"appid"];
            req.partnerId           = [data objectForKey:@"mch_id"];
            req.prepayId            = [data objectForKey:@"prepay_id"];
            req.nonceStr            = [data objectForKey:@"nonce_str"];
            req.timeStamp           = [ordercreatetime intValue];
            req.package             = @"Sign=WXPay";
            NSString *newSign = [YKUtilTools createMD5SingForPay:req.openID partnerid:req.partnerId  prepayid:req.prepayId package:req.package noncestr:req.nonceStr timestamp:req.timeStamp];
            req.sign                = newSign;
            [WXApi sendReq:req];
            
        } failure:^(NSError *error) {
            
        }];
        
        
        
    } failure:^(NSError *error) {
        NSLog(@"failure request");
    }];
}


#pragma mark -- 网络请求
/* 三方登录相关的网络请求*/
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

- (void)getWechatPayOrderForGoods
{
    NSDictionary *params = @{@"gameId":@"1",
                             @"productId":@"1",
                             @"productName":@"Game props",
                             @"playerId":@"121212121",
                             @"status":@"OPEN",
                             @"price":@"1",
                             @"totalPrice":@"1",
                             @"dealPrice":@"1",
                             @"spbillCreateIp":[YKUtilTools getIPAddress:YES]
                             };
    [YKRequestNetwork postRequestByServiceUrl:kLocalHostGetOrderUrl parameters:params success:^(NSDictionary *data) {
        
        [self getWechatDateInfo:data];
    } failure:^(NSError *error) {
        NSLog(@"failure request  %@", error);
    }];
}

- (void)getWechatDateInfo:(NSDictionary *)data
{
    NSString *url = [NSString stringWithFormat:@"%@/%@",kLocalHostWxPaymentInfo,data[@"orderId"]];
    NSString *ordercreatetime = [data objectForKey:@"createDateTime"];
    [YKRequestNetwork postRequestByServiceUrl:url parameters:@{} success:^(NSDictionary *data) {
        NSLog(@"%@",data);
        //调起微信支付
        PayReq* req             = [[PayReq alloc] init];
        req.openID              = [data objectForKey:@"appid"];
        req.partnerId           = [data objectForKey:@"mch_id"];
        req.prepayId            = [data objectForKey:@"prepay_id"];
        req.nonceStr            = [data objectForKey:@"nonce_str"];
        req.timeStamp           = [ordercreatetime intValue];
        req.package             = @"Sign=WXPay";
        NSString *newSign = [YKUtilTools createMD5SingForPay:req.openID partnerid:req.partnerId  prepayid:req.prepayId package:req.package noncestr:req.nonceStr timestamp:req.timeStamp];
        req.sign                = newSign;
        [WXApi sendReq:req];
    } failure:^(NSError *error) {
        NSLog(@"failure request %@", error);
    }];
}

@end
