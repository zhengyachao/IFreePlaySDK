//
//  YKSDKManager.m
//  ZYCTestDemo
//
//  Created by ifreeplay on 2017/8/7.
//  Copyright © 2017年 ifreeplay. All rights reserved.
//


#import "WXApi.h"
#import "YKSDKManager.h"
#import "YKUtilsMacro.h"
#import "PayPalMobile.h"
#import "YKLoginRequest.h"
#import <LineSDK/LineSDK.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface YKSDKManager ()<LineSDKLoginDelegate,WXApiDelegate,FBSDKSharingDelegate,FBSDKAppInviteDialogDelegate>
{
    NSString *_gameId;
    NSString *_type;
}

@property (nonatomic, copy) void(^successBlock)(NSDictionary *data);
@property (nonatomic, copy) void(^failureBlock)(NSError *error);
@property (nonatomic, copy) void(^stateChangedHandler)(YKResponseState state, NSError *error);

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
/* 初始化SDK */
- (void)initSDKForApplication:(UIApplication *)application launchOptions:(NSDictionary *)launchOptions appId:(NSString *)appId clientId:(NSString *)clientIds {
    
    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
    [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction :clientIds,
                                                           PayPalEnvironmentSandbox : clientIds}];
    [WXApi registerApp:appId enableMTA:NO];
}

+ (void)activateApp {
    
    [FBSDKAppEvents activateApp];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL result =  [[LineSDKLogin sharedInstance] handleOpenURL:url];
    if (!result)
    {
        BOOL resultFb = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                       openURL:url
                                                             sourceApplication:sourceApplication
                                                                    annotation:annotation];
        if (!resultFb)
        {
            return [WXApi handleOpenURL:url delegate:self];
        }
        
        return resultFb;
    }
    
    return result;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary *)options
{
    BOOL result =  [[LineSDKLogin sharedInstance] handleOpenURL:url];
    if (!result)
    {
        BOOL resultFb = [[FBSDKApplicationDelegate sharedInstance] application:app
                                                                       openURL:url
                                 sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                                annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
        if (!resultFb)
        {
            return [WXApi handleOpenURL:url delegate:self];
        }
            
        return resultFb;
    }
        
    return result;
}
    
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [WXApi handleOpenURL:url delegate:self];
}

/* 登录Facebook读取用户权限 */
- (void)loginFacebookVC:(UIViewController *)vc
                 GameId:(NSString *)gameId
                   Type:(NSString *)type
                success:(void (^)(NSDictionary *))successBlock
                failure:(void (^)(NSError *))failureBlock
{
    _gameId = gameId;
    _type = type;
    self.successBlock = successBlock;
    self.failureBlock = failureBlock;
    
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
                 FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me?fields=id,name,picture" parameters:nil];
                 [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error)
                  {
                      NSString *userID = result[@"id"];
                      
                      if (!error && [[FBSDKAccessToken currentAccessToken].userID isEqualToString:userID])
                      {
                          NSString *userID = result[@"id"];
                          NSString *userName = result[@"name"];
                          NSString *userPicture = result[@"picture"] [@"data"] [@"url"];
                          
                          NSLog(@"userId = %@, userName = %@, userPicture= %@",userID,userName,userPicture);
                          [self postServiceName:userName openId:userID headPortraitUrl:userPicture];
                      }
                  }];
             }
         }
     }];
}

#pragma mark -- Facebook分享
/**
 *  @param url   分享的链接
 *  @param vc    分享所在页面的控制器
 *  @param stateChangedHandler    状态变更回调处理
 */
- (void)YKSetupShareParamsByUrl:(NSURL *)url currentVc:(UIViewController *)vc handler:(YKShareStateChangedHandler)stateChangedHandler
{
    self.stateChangedHandler = stateChangedHandler;
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = url;
    
//    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
//    content.contentURL = [NSURL URLWithString:@"http://developers.facebook.com"];
    [FBSDKShareDialog showFromViewController:vc
                                 withContent:content
                                    delegate:self];
}

- (void)YKSetupInviteParamsByUrl:(NSURL *)url currentVc:(UIViewController *)vc handler:(YKShareStateChangedHandler)stateChangedHandler {
    self.stateChangedHandler = stateChangedHandler;
    FBSDKAppInviteContent *inviteContent = [[FBSDKAppInviteContent alloc] init];
    inviteContent.appLinkURL = url;
    inviteContent.appInvitePreviewImageURL = [NSURL URLWithString:@"http://i0.cy.com/xtl3d/pic/2014/10/17/1.png"];
    
    FBSDKAppInviteDialog *dialog = [[FBSDKAppInviteDialog alloc] init];
    dialog.content = inviteContent;
    dialog.fromViewController = vc;
    dialog.delegate = self;
    
    [dialog show];
}
    
- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didCompleteWithResults:(NSDictionary *)results
{
    if (results == nil)
    {
        self.stateChangedHandler(SSDKResponseStateCancel, nil);
    } else {
        self.stateChangedHandler(SSDKResponseStateSuccess, nil);
    }
}

- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didFailWithError:(NSError *)error
{
    self.stateChangedHandler(SSDKResponseStateFail, error);
}

#pragma mark - FaceBook Share Delegate
- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {
    NSString *postId = results[@"postId"];
    FBSDKShareDialog *dialog = (FBSDKShareDialog *)sharer;
    if (dialog.mode == FBSDKShareDialogModeBrowser && (postId == nil || [postId isEqualToString:@""])) {
        // 如果使用webview分享的，但postId是空的，
        // 这种情况是用户点击了『完成』按钮，并没有真的分享
        self.stateChangedHandler(SSDKResponseStateCancel, nil);
    } else {
        self.stateChangedHandler(SSDKResponseStateSuccess, nil);
    }
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    FBSDKShareDialog *dialog = (FBSDKShareDialog *)sharer;
    if (error == nil && dialog.mode == FBSDKShareDialogModeNative) {
        // 如果使用原生登录失败，但error为空，那是因为用户没有安装Facebook app
        // 重设dialog的mode，再次弹出对话框
        dialog.mode = FBSDKShareDialogModeBrowser;
        [dialog show];
    } else
    {
        // 分享失败
        self.stateChangedHandler(SSDKResponseStateFail, error);
    }
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    self.stateChangedHandler(SSDKResponseStateCancel, nil);
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
    
    if ([[LineSDKLogin sharedInstance] canLoginWithLineApp])
    {
        [[LineSDKLogin sharedInstance] startLogin];
    } else
    {
        [[LineSDKLogin sharedInstance] startWebLoginWithSafariViewController:YES];
    }
    [LineSDKLogin sharedInstance].delegate = self;
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
    if (error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }
    else {
        NSString * userID = profile.userID;
        NSString * displayName = profile.displayName;
        NSString *headPortraitUrl = [NSString stringWithFormat:@"%@", profile.pictureURL];
        [self postServiceName:displayName openId:userID headPortraitUrl:headPortraitUrl];    }
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
 * 发送一个sendReq后，收到微信的回应
 */
- (void)onResp:(BaseResp *)resp
{
    NSString *strTitle;
    NSString *strMsg = [NSString stringWithFormat:@"errcode:%d", resp.errCode];
    
    if ([resp isKindOfClass:[SendAuthResp class]]) //判断是否为授权请求，否则与微信支付等功能发生冲突
    {
        SendAuthResp *aresp = (SendAuthResp *)resp;
        if (aresp.errCode== 0)
        {
            [self getWechatAccessTokenWithCode:aresp.code];
        }
    }
    
    if ([resp isKindOfClass:[PayResp class]])
    {
        //支付返回结果，实际支付结果需要去微信服务器端查询
        strTitle = [NSString stringWithFormat:@"支付结果"];
        
        switch (resp.errCode)
        {
            case WXSuccess:
            {
                strMsg = @"支付结果：成功！";
                NSLog(@"支付成功－PaySuccess，retcode = %d", resp.errCode);
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"支付成功" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alertView show];
            }
                break;
                
            default:
            {
                strMsg = [NSString stringWithFormat:@"支付结果：失败"];
                NSLog(@"错误，retcode = %d, retstr = %@", resp.errCode, resp.errStr);
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"支付失败" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alertView show];
            }
                break;
        }
    }
}

/* 根据微信的name获取用户信息 */
- (void)loginWechatGetUserInfoVc:(UIViewController *)vc
                          GameId:(NSString *)gameId
                            Type:(NSString *)type
                         success:(void (^)(NSDictionary *))successBlock
                         failure:(void (^)(NSError *))failureBlock
{
    self.successBlock = successBlock;
    self.failureBlock = failureBlock;
    _gameId = gameId;
    _type = type;
    
    if ([WXApi isWXAppInstalled])
    {
        SendAuthReq *req = [[SendAuthReq alloc] init];
        req.scope = @"snsapi_userinfo";
        req.state = @"App";
        [WXApi sendReq:req];
    } else
    {
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

#pragma mark -- 网络请求
- (void)getWechatAccessTokenWithCode:(NSString *)code
{
    NSString *url =[NSString stringWithFormat:kWechatGetToken,kWxApp_id,kWxApp_Secret,code];
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

- (void)getWechatUserInfoWithAccessToken:(NSString *)accessToken openId:(NSString *)openId
{
    NSString *url = [NSString stringWithFormat:kWechatGetUserInfo,accessToken,openId];
    
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
                NSString *headPortraitUrl = [dic objectForKey:@"headimgurl"];
                
                [self postServiceName:memNickName openId:openId headPortraitUrl:headPortraitUrl];
            }
        });
    });
}

- (void)postServiceName:(NSString *)name
                 openId:(NSString *)openId
        headPortraitUrl:(NSString *)headPortraitUrl
{
    YKLoginRequest *login = [[YKLoginRequest alloc] initWithGameId:_gameId openId:openId type:_type name:name headPortraitUrl:headPortraitUrl];
    [login startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        
        NSLog(@"%@",request.responseObject);
        self.successBlock(request.responseObject);
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSLog(@"%@", request.error);
        self.failureBlock(request.error);
    }];
}

/* 获取orderId */
- (void)getOrderInfoWithParams:(NSDictionary *)params
                       success:(void (^)(NSDictionary *))successBlock
                       failure:(void (^)(NSError *))failureBlock
{
    YKRequestOrder *orderApi = [[YKRequestOrder alloc] initWithParams:params];
    [orderApi startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSDictionary *data = request.responseObject;
        successBlock(data);
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSLog(@"%@",request.error);
        failureBlock(request.error);
    }];
}
/* 发起微信支付 通过orderId*/
- (void)lunchWechatPayWithOrderId:(NSString *)orderId viewController:(UIViewController *)vc
{
    YKWechatPayRequest *wechatApi = [[YKWechatPayRequest alloc] initWithOrderId:orderId];
    [wechatApi startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
         NSDictionary *result = [request.responseObject objectForKey:@"data"];
        if ([WXApi isWXAppInstalled])
        {
            //调起微信支付
            PayReq* req             = [[PayReq alloc] init];
            req.openID              = [result objectForKey:@"appId"];
            req.partnerId           = [result objectForKey:@"partnerId"];
            req.prepayId            = [result objectForKey:@"prepayId"];
            req.nonceStr            = [result objectForKey:@"nonceStr"];
            req.timeStamp           = [[result objectForKey:@"timeStamp"] intValue];
            req.package             = [result objectForKey:@"packageValue"];
            req.sign                = [result objectForKey:@"sign"];
            [WXApi sendReq:req];
        } else
        {
            [self setupAlertController:vc];
        }
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSLog(@"%@",request.error);
    }];
}

/* 发起Paypal支付验证 通过orderId和PayPal回调返回的paypalId*/
- (void)verifyPaypalWithPaypalId:(NSString *)paypalId orderId:(NSString *)orderId
{
    YKPaypalRequest *paypalApi = [[YKPaypalRequest alloc] initWithPaypalId:paypalId orderId:orderId];
    
    [paypalApi startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        
        NSLog(@"%@",request.responseObject);
        if ([[request.responseObject objectForKey:@"code"] intValue] == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"Paypal支付成功" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",nil];
                [alert show];
            });
        }
        
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        
        NSLog(@"%@",request.error);
    }];
}

/* 发起AppleIAP支付验证 通过orderId和PayPal回调返回的paypalId
 * orderNumber 订单号
 * receiptData apple支付凭证 base64字符串
 * verifyEnvironment 环境 如果是沙箱传Sandbox 如果是正式环境不传
 */
- (void)verifyAppleIAPWithOrderId:(NSString *)orderId receiptData:(NSString *)receiptData verifyEnvironment:(NSString *)verifyEnvironment
{
    YKIAPPayRequest *iapRequest = [[YKIAPPayRequest alloc] initWithOrderId:orderId receiptData:receiptData verifyEnvironment:verifyEnvironment];
    [iapRequest startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSLog(@"%@",request.responseObject);
        if ([[request.responseObject objectForKey:@"data"] intValue] == 1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"苹果iap内购支付成功" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",nil];
                [alert show];
            });
        } else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[request.responseObject objectForKey:@"message"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",nil];
                [alert show];
            });
        }
        
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSLog(@"%@",request.error);
    }];
}

@end
