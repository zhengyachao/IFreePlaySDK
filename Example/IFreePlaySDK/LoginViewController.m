//
//  LoginViewController.m
//  ZYCTestDemo
//
//  Created by ifreeplay on 2017/8/7.
//  Copyright © 2017年 ifreeplay. All rights reserved.
//

#import "YKSDKManager.h"
#import "LoginViewController.h"
#import "PayViewController.h"
#import "IFProductListViewController.h"

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
    [self createLineLoginButton];
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
    fbLogin.frame = CGRectMake(20, 20, self.view.frame.size.width - 40, 44);
    fbLogin.backgroundColor = [UIColor lightGrayColor];
    [fbLogin setTitle:@"FaceBook登录" forState:UIControlStateNormal];
    [fbLogin setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    fbLogin.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [fbLogin addTarget:self action:@selector(_onLoginFaceBook:) forControlEvents:UIControlEventTouchUpInside];
    fbLogin.layer.cornerRadius = 5.0f;
    
    [self.view addSubview:fbLogin];
}

/* 自定义Line登录按钮 */
- (void)createLineLoginButton
{
    UIButton *lineLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    lineLogin.frame = CGRectMake(20, 20 + 44 * 2 , self.view.frame.size.width - 40, 44);
    lineLogin.backgroundColor = [UIColor lightGrayColor];
    [lineLogin setTitle:@"Line登录" forState:UIControlStateNormal];
    [lineLogin setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    lineLogin.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [lineLogin addTarget:self action:@selector(_onLoginLine:) forControlEvents:UIControlEventTouchUpInside];
    lineLogin.layer.cornerRadius = 5.0f;
    
    [self.view addSubview:lineLogin];
}

/* 自定义微信登录按钮 */
- (void)createWechatLoginButton
{
    UIButton *wxBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    wxBtn.frame = CGRectMake(20, 20 + 44 * 4, self.view.frame.size.width - 40, 44);
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
    CGFloat minHeight;
    if (iPhoneX) {
      minHeight  = self.view.frame.size.height - 88;
    } else {
        minHeight  = self.view.frame.size.height - 64;
    }
    
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
                                            Type:PlatformsType(YKPlatformType_Facebook)//@"FACEBOOK"
                                         success:^(NSDictionary *data)
     {
         NSLog(@"打印Facebook的回掉信息 %@",data);
         [self showCallbackInfoData:@"FaceBook登录回调信息" dataResult:data];
     } failure:^(NSError *error)
     {
         NSLog(@"打印错误信息%@",error);
         [self showCallbackErrorData:@"FaceBook登录回调信息" error:error];
     }];
}

/* 点击登录line */
- (void)_onLoginLine:(UIButton *)button
{
    [[YKSDKManager shareManager] startLoginToLineGameId:@"2" Type:PlatformsType(YKPlatformType_Line) success:^(NSDictionary *data)
     {
         NSLog(@"打印LINE的回调信息 %@",data);
         [self showCallbackInfoData:@"Line登录回调信息" dataResult:data];
     } failure:^(NSError *error)
     {
         NSLog(@"打印错误信息%@",error);
         [self showCallbackErrorData:@"Line登录回调信息" error:error];
     }];
}

/* 点击登录微信 */
- (void)_onLoginWeChat:(UIButton *)button
{
    [[YKSDKManager shareManager] loginWechatGetUserInfoVc:self
                                                   GameId:@"1"
                                                     Type:PlatformsType(YKPlatformType_Wechat)
                                                  success:^(NSDictionary *data)
     {
         NSLog(@"打印微信的回调信息  ---  %@",data);
         [self showCallbackInfoData:@"微信登录回调信息" dataResult:data];
     }
                                                  failure:^(NSError *error)
     {
         NSLog(@"打印错误信息%@",error);
         [self showCallbackErrorData:@"微信登录回调信息" error:error];
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

@end
