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
#import "YKLoginRequest.h"
#import "GTMBase64.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

// Whatsapp URLs
NSString *const whatsAppUrl = @"whatsapp://app";
NSString *const whatsAppSendTextUrl = @"whatsapp://send?text=";

@interface YKSDKManager ()<WXApiDelegate,FBSDKSharingDelegate,FBSDKAppInviteDialogDelegate,UIDocumentInteractionControllerDelegate,SKProductsRequestDelegate,SKPaymentTransactionObserver>
{
    UIDocumentInteractionController *_docControll;
    NSString *_gameId;
    NSString *_type;
    NSString *_orderId;
}
@property(nonatomic,weak) SKPaymentQueue *paymentQueue;

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
    
    [WXApi registerApp:appId enableMTA:NO];
}

+ (void)activateApp {
    
    [FBSDKAppEvents activateApp];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
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

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary *)options
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
    if (dialog.mode == FBSDKShareDialogModeNative && (postId == nil || [postId isEqualToString:@""])) {
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
    if ([resp isKindOfClass:[SendAuthResp class]]) //判断是否为授权请求，否则与微信支付等功能发生冲突
    {
        SendAuthResp *aresp = (SendAuthResp *)resp;
        if (aresp.errCode== 0)
        {
            [self getWechatAccessTokenWithCode:aresp.code];
        }
    }
    
    if([resp isKindOfClass:[SendMessageToWXResp class]]) {
        
        switch (resp.errCode) {
            case WXSuccess:
            {
                NSLog(@"success");
            }
                break;
            case WXErrCodeUserCancel:
                break;
            default:
            {
                NSLog(@"failure");
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

- (void)YKWechatShareParamsByTitle:(NSString *)title
                       description:(NSString *)description
                             image:(UIImage *)image
                               url:(NSString *)url
                             scene:(int)scene
                         currentVc:(UIViewController *)vc
                           handler:(YKShareStateChangedHandler)stateChangedHandler
{
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = description;
    [message setThumbImage:image];
    
    WXWebpageObject *webpage = [WXWebpageObject object];
    webpage.webpageUrl = url;
    message.mediaObject = webpage;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    
    [WXApi sendReq:req];
}

#pragma mark -- Whatsapp
/* 判断用户是否安装whatsapp */
- (BOOL)isWhatsAppInstalled
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:whatsAppUrl]];
}

- (void)sendText:(NSString *)message
{
    NSString *urlWhats = [NSString stringWithFormat:@"%@%@",whatsAppSendTextUrl,message];
    NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];
    urlWhats = [urlWhats stringByAddingPercentEncodingWithAllowedCharacters:set];
    NSURL *whatsappURL = [NSURL URLWithString:urlWhats];
    
    if ( [self isWhatsAppInstalled] ) {
        [[UIApplication sharedApplication] openURL: whatsappURL];
    } else {
        [self alertWithTitle:@"Your device has no WhatsApp installed" message:message];
    }
}

/* 分享图片 */
- (void)sendImage:(NSData *)data view:(UIView *)view{
    
    NSURL *tempFile    = [self createTempFile:data type:@"whatsAppTmp.wai"];
    _docControll = [UIDocumentInteractionController interactionControllerWithURL:tempFile];
    _docControll.UTI = @"net.whatsapp.image";
    _docControll.delegate = self;
    
    [_docControll presentOpenInMenuFromRect:CGRectZero
                                     inView:view
                                   animated:YES];
}

/* 分享链接 */
- (void)sendLinkUrl:(NSString*)linkUrl {

    linkUrl = (NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef) linkUrl, NULL,CFSTR("!*'();:@&=+$,/?%#[]"),kCFStringEncodingUTF8));
    
    NSString * urlWhats = [NSString stringWithFormat:@"%@%@",whatsAppSendTextUrl,linkUrl];
    NSURL * whatsappURL = [NSURL URLWithString:urlWhats];
    
    if ( [self isWhatsAppInstalled] ) {
        [[UIApplication sharedApplication] openURL: whatsappURL];
    } else {
        [self alertWithTitle:@"Your device has no WhatsApp installed" message:nil];
    }
}

- (NSURL *)createTempFile:(NSData *)data type:(NSString *)type
{
    NSError *error = nil;
    NSURL *tempFile = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                             inDomain:NSUserDomainMask
                                                    appropriateForURL:nil
                                                               create:NO
                                                                error:&error];
    
    if (tempFile)
    {
        tempFile = [tempFile URLByAppendingPathComponent:type];
    } else {
        [self alertWithTitle:[NSString stringWithFormat:@"Error getting document directory: %@", error] message:nil];
    }
    
    if (![data writeToURL:tempFile options:NSDataWritingAtomic error:&error]){
        [self alertWithTitle:[NSString stringWithFormat:@"Error writing File: %@", error] message:nil];
    }
    
    return tempFile;
}

- (void)alertWithTitle:(NSString *)title message:(NSString *)message
{
    UIViewController *vc = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction *action) {
                                                
                                                [vc dismissViewControllerAnimated:YES completion:^{}];
                                            }]];
    
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

#pragma mark -- apple支付

-(void)setup
{
    _paymentQueue = [SKPaymentQueue defaultQueue];
    //监听SKPayment过程
    [_paymentQueue addTransactionObserver:self];
    NSLog(@"YKSDKManager 开启交易监听");
}

-(void)dealloc
{
    //解除监听
    [_paymentQueue removeTransactionObserver:self];
    _paymentQueue = nil;
    NSLog(@"YKSDKManager 注销交易监听");
}

-(BOOL)canMakePayments
{
    return [SKPaymentQueue canMakePayments];
}

-(void)buyWithProductId:(NSString*)productId orderId:(NSString *)orderId
{
    if([self canMakePayments])
    {
        _orderId = orderId;
        [self setup];
        [self requestProduct:productId];
    }
    else
    {
       [self alertWithTitle:@"提示" message:@"不支持内购"];
    }
}

-(void)requestProduct:(NSString*)productId
{
    NSArray *product = [[NSArray alloc] initWithObjects:productId,nil];
    NSSet *nsset = [NSSet setWithArray:product];
    SKProductsRequest *request =[[SKProductsRequest alloc] initWithProductIdentifiers: nsset];
    request.delegate = self;
    [request start];
}

#pragma mark - SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *productArray = response.products;
    if([productArray count] == 0)
    {
        NSLog(@"没有这个商品");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有这个商品" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",nil];
        [alert show];
        return;
    }
    
    if(productArray != nil && productArray.count>0)
    {
        SKProduct *product = [productArray objectAtIndex:0];
        NSLog(@"SKProduct 描述信息%@", [product description]);
        NSLog(@"产品标题 %@" , product.localizedTitle);
        NSLog(@"产品描述信息: %@" , product.localizedDescription);
        NSLog(@"价格: %@" , product.price);
        NSLog(@"Product id: %@" , product.productIdentifier);
        
        SKPayment* payment = [SKPayment paymentWithProduct:product];
        [_paymentQueue addPayment:payment];
    }
}

#pragma mark - SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for(SKPaymentTransaction* transaction in transactions)
    {
        NSLog(@"%@",transaction.payment.productIdentifier);
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"商品添加进列表");
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"已经购买过商品");
                break;
            case SKPaymentTransactionStateFailed:
                {
                    if (transaction.error.code != SKErrorPaymentCancelled)
                    {
                        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
                    }
                    
                    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
                }
                break;
                
            default:
                break;
        }
    }
}

//交易结束
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"交易结束");
    NSData *data = [NSData dataWithContentsOfFile:[[[NSBundle mainBundle] appStoreReceiptURL] path]];
    NSString *receiptData = [[NSString alloc] initWithData:[GTMBase64 encodeData:data] encoding:NSUTF8StringEncoding];
    NSLog(@"%@",receiptData);
    [self verifyAppleIAPWithOrderId:_orderId receiptData:receiptData verifyEnvironment:@"Sandbox"];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
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
