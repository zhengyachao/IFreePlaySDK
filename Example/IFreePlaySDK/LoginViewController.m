//
//  LoginViewController.m
//  ZYCTestDemo
//
//  Created by ifreeplay on 2017/8/7.
//  Copyright © 2017年 ifreeplay. All rights reserved.
//

#import "LoginViewController.h"
#import "PayViewController.h"
#import "IFProductListViewController.h"
#import <IFreePlaySDK/YKSDKManager.h>
#import <IFreePlaySDK/YKUtilsMacro.h>

@interface LoginViewController ()
{
    NSString *_userID;
    NSString *_userName;
    NSString *_userMail;
    NSString *_userHeadUrl;
}
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"三方登录";
    
    [self createFBLoginButton];
    [self createFBShareButton];
    [self createFBInvitedButton];
    [self createLineLoginButton];
    [self createLineShareTextButton];
    [self createLineShareImageButton];
    [self createWechatLoginButton];
    [self createProductListButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- 创建自定义按钮
/* 自定义Facebook登录按钮 */
- (void)createFBLoginButton
{
    UIButton *fbLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    fbLogin.frame = CGRectMake(20, 10, self.view.frame.size.width - 40, 44);
    fbLogin.backgroundColor = [UIColor lightGrayColor];
    [fbLogin setTitle:@"FaceBook登录" forState:UIControlStateNormal];
    [fbLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    fbLogin.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [fbLogin addTarget:self action:@selector(_onLoginFaceBook:) forControlEvents:UIControlEventTouchUpInside];
    fbLogin.layer.cornerRadius = 5.0f;
    
    [self.view addSubview:fbLogin];
}

- (void)createFBShareButton {
    UIButton *fbLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    fbLogin.frame = CGRectMake(20, 10 * 2 + 44, self.view.frame.size.width - 40, 44);
    fbLogin.backgroundColor = [UIColor lightGrayColor];
    [fbLogin setTitle:@"FaceBook分享" forState:UIControlStateNormal];
    [fbLogin setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    fbLogin.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [fbLogin addTarget:self action:@selector(_onShareFaceBook:) forControlEvents:UIControlEventTouchUpInside];
    fbLogin.layer.cornerRadius = 5.0f;
    
    [self.view addSubview:fbLogin];
}

- (void)createFBInvitedButton {
    UIButton *fbLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    fbLogin.frame = CGRectMake(20, 10 * 3 + 44 * 2, self.view.frame.size.width - 40, 44);
    fbLogin.backgroundColor = [UIColor lightGrayColor];
    [fbLogin setTitle:@"FaceBook邀请好友" forState:UIControlStateNormal];
    [fbLogin setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    fbLogin.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [fbLogin addTarget:self action:@selector(_onInviteFacebook:) forControlEvents:UIControlEventTouchUpInside];
    fbLogin.layer.cornerRadius = 5.0f;
    
    [self.view addSubview:fbLogin];
}

/* 自定义Line登录按钮 */
- (void)createLineLoginButton
{
    UIButton *lineLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    lineLogin.frame = CGRectMake(20, 10 * 4 + 44 * 3 , self.view.frame.size.width - 40, 44);
    lineLogin.backgroundColor = [UIColor lightGrayColor];
    [lineLogin setTitle:@"Line登录" forState:UIControlStateNormal];
    [lineLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    lineLogin.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [lineLogin addTarget:self action:@selector(_onLoginLine:) forControlEvents:UIControlEventTouchUpInside];
    lineLogin.layer.cornerRadius = 5.0f;
    
    [self.view addSubview:lineLogin];
}

- (void)createLineShareTextButton {
    UIButton *lineLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    lineLogin.frame = CGRectMake(20, 10 * 5 + 44 * 4 , self.view.frame.size.width - 40, 44);
    lineLogin.backgroundColor = [UIColor lightGrayColor];
    [lineLogin setTitle:@"Line文本分享" forState:UIControlStateNormal];
    [lineLogin setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    lineLogin.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [lineLogin addTarget:self action:@selector(_onShareTextForLine:) forControlEvents:UIControlEventTouchUpInside];
    lineLogin.layer.cornerRadius = 5.0f;
    
    [self.view addSubview:lineLogin];
}

- (void)createLineShareImageButton {
    UIButton *lineLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    lineLogin.frame = CGRectMake(20, 10 * 6 + 44 * 5 , self.view.frame.size.width - 40, 44);
    lineLogin.backgroundColor = [UIColor lightGrayColor];
    [lineLogin setTitle:@"Line图片分享" forState:UIControlStateNormal];
    [lineLogin setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    lineLogin.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [lineLogin addTarget:self action:@selector(_onShareImageForLine:) forControlEvents:UIControlEventTouchUpInside];
    lineLogin.layer.cornerRadius = 5.0f;
    
    [self.view addSubview:lineLogin];
}

/* 自定义微信登录按钮 */
- (void)createWechatLoginButton
{
    UIButton *wxBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    wxBtn.frame = CGRectMake(20, 10 * 7 + 44 * 6, self.view.frame.size.width - 40, 44);
    wxBtn.backgroundColor = [UIColor lightGrayColor];
    [wxBtn setTitle:@"微信授权登录" forState:UIControlStateNormal];
    [wxBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    wxBtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [wxBtn addTarget:self action:@selector(_onLoginWeChat:) forControlEvents:UIControlEventTouchUpInside];
    wxBtn.layer.cornerRadius = 5.0f;
    
    [self.view addSubview:wxBtn];
}

- (void)createProductListButton
{
    UIButton *payLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat minHeight = self.view.frame.size.height - 64;
    
    payLogin.frame = CGRectMake(20, minHeight - 44 * 2, self.view.frame.size.width - 40, 44);
    payLogin.backgroundColor = [UIColor colorWithRed:255/255.0 green:143/255.0 blue:22/255.0 alpha:1.0];
    [payLogin setTitle:@"获取产品列表" forState:UIControlStateNormal];
    [payLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    payLogin.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    [payLogin addTarget:self action:@selector(_onJumpProductVC:) forControlEvents:UIControlEventTouchUpInside];
    payLogin.layer.cornerRadius = 5.0;
    
    [self.view addSubview:payLogin];
}

#pragma mark -- 按钮点击方法
/* 点击登录facebook */
- (void)_onLoginFaceBook:(UIButton *)button
{
    [[YKSDKManager shareManager] loginFacebookVC:self
                                          GameId:@"3"
                                            Type:PlatformsType(YKPlatformType_Facebook)
                                         success:^(NSDictionary *data)
     {
         [self showCallbackInfoData:@"FaceBook登录回调信息" dataResult:data];
     } failure:^(NSError *error)
     {
         [self showCallbackErrorData:@"FaceBook登录错误信息" error:error];
     }];
}

- (void)_onShareFaceBook:(UIButton *)button {
    [[YKSDKManager shareManager] YKSetupShareParamsByUrl:[NSURL URLWithString:@"https://d3uu10x6fsg06w.cloudfront.net/shareitexampleapp/liking/index.html"] currentVc:self handler:^(YKResponseState state, NSError *error) {
        switch (state) {
            case 0:
                [self showShareHandleBack:@"分享成功"];
                break;
            case 1:
                [self showShareHandleBack:@"分享失败"];
                break;
            case 2:
                [self showShareHandleBack:@"取消分享"];
            default:
                break;
        }
    }];
}

- (void)_onInviteFacebook:(UIButton *)button {
    [[YKSDKManager shareManager] YKSetupInviteParamsByUrl:[NSURL URLWithString:@"https://d3uu10x6fsg06w.cloudfront.net/shareitexampleapp/liking/index.html"] currentVc:self handler:^(YKResponseState state, NSError *error) {
        switch (state) {
            case 0:
            [self showShareHandleBack:@"邀请成功"];
            break;
            case 1:
            [self showShareHandleBack:@"邀请失败"];
            break;
            case 2:
            [self showShareHandleBack:@"取消邀请"];
            default:
            break;
        }
    }];
}

/* 点击登录line */
- (void)_onLoginLine:(UIButton *)button
{
    [[YKSDKManager shareManager] startLoginToLineGameId:@"2" Type:PlatformsType(YKPlatformType_Line)
                                                success:^(NSDictionary *data)
     {
         [self showCallbackInfoData:@"Line登录回调信息" dataResult:data];
     } failure:^(NSError *error)
     {
         [self showCallbackErrorData:@"Line登录错误信息" error:error];
     }];
}

- (void)_onShareTextForLine:(UIButton *)button {
    [self shareText:@"测试"];
}

- (void)_onShareImageForLine:(UIButton *)button {
    [self shareImage:@"https://ww4.sinaimg.cn/bmiddle/005Q8xv4gw1evlkov50xuj30go0a6mz3.jpg"];
}

//是否有安装Line
- (BOOL)canShareToLine
{
    BOOL isLine = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"line://"]];
    if (!isLine) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"暂未安装Line" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionConfirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:actionConfirm];
        [self presentViewController:alert animated:YES completion:nil];
    }
    return isLine;
}
//分享文字
- (void)shareText:(NSString*)text {
    NSString*contentKey = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)text,NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8);
    NSString*contentType =@"text";
    NSString*urlString = [NSString stringWithFormat:@"line://msg/%@/%@",contentType, contentKey];
    
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:urlString]];
}
//分享图片
- (void)shareImage:(NSString *)imageUrl
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
    UIImage *image = [UIImage imageWithData:data];
    [pasteboard setData:UIImageJPEGRepresentation(image, 0.9) forPasteboardType:@"public.jpeg"];
    NSString *contentType =@"image";
    
    NSString *contentKey = [pasteboard.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *urlString = [NSString stringWithFormat:@"line://msg/%@/%@",contentType, contentKey];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}


/* 点击登录微信 */
- (void)_onLoginWeChat:(UIButton *)button
{
    [[YKSDKManager shareManager] loginWechatGetUserInfoVc:self
                                                   GameId:@"1"
                                                     Type:PlatformsType(YKPlatformType_Wechat)
                                                  success:^(NSDictionary *data)
     {
         [self showCallbackInfoData:@"微信登录回调信息" dataResult:data];
     }
                                                  failure:^(NSError *error)
     {
         [self showCallbackErrorData:@"微信登录错误信息" error:error];
     }];
}

- (void)_onJumpProductVC:(UIButton *)button
{
    IFProductListViewController *productVC = [[IFProductListViewController alloc] init];
    [self.navigationController pushViewController:productVC animated:YES];
}
#pragma mark -- UIAlertController
/* 展示不同类型的登录得到的回调详细信息 */
- (void)showCallbackInfoData:(NSString *)loginType dataResult:(NSDictionary *)dataResult
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:loginType message:[NSString stringWithFormat:@"dataResult: %@",dataResult] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionConfirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:actionConfirm];
    [self presentViewController:alert animated:YES completion:nil];
}

/* 展示不同类型的登录得到的回调错误信息 */
- (void)showCallbackErrorData:(NSString *)loginType error:(NSError *)error
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:loginType message:[NSString stringWithFormat:@"%@",error] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionConfirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:actionConfirm];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showShareHandleBack:(NSString *)state
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:state message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionConfirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:actionConfirm];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
