//  LoginViewController.m
//  Created by ifreeplay on 2017/8/7.
//  Copyright © 2017年 ifreeplay. All rights reserved.
//

#import "LoginViewController.h"
#import "PayViewController.h"
#import "IFProductListViewController.h"
#import <IFreePlaySDK/YKSDKManager.h>
#import <IFreePlaySDK/YKUtilsMacro.h>

@interface LoginViewController ()<UIDocumentInteractionControllerDelegate>
{
    NSString *_userID;
    NSString *_userName;
    NSString *_userMail;
    NSString *_userHeadUrl;
}

@property (nonatomic, retain) UIDocumentInteractionController * documentInteractionController;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"三方登录";
    
    [self createFBLoginButton];
    [self createFBShareButton];
    [self createFBInvitedButton];
    [self createWechatLoginButton];
    [self createWechatShareButton];
    [self createWhatsappShareButton];
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
    fbLogin.backgroundColor = [UIColor colorWithRed:255/255.0 green:143/255.0 blue:22/255.0 alpha:1.0];
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
    fbLogin.backgroundColor = [UIColor colorWithRed:255/255.0 green:143/255.0 blue:22/255.0 alpha:1.0];
    [fbLogin setTitle:@"FaceBook分享" forState:UIControlStateNormal];
    [fbLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    fbLogin.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [fbLogin addTarget:self action:@selector(_onShareFaceBook:) forControlEvents:UIControlEventTouchUpInside];
    fbLogin.layer.cornerRadius = 5.0f;
    
    [self.view addSubview:fbLogin];
}

- (void)createFBInvitedButton {
    UIButton *fbLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    fbLogin.frame = CGRectMake(20, 10 * 3 + 44 * 2, self.view.frame.size.width - 40, 44);
    fbLogin.backgroundColor = [UIColor colorWithRed:255/255.0 green:143/255.0 blue:22/255.0 alpha:1.0];
    [fbLogin setTitle:@"FaceBook邀请好友" forState:UIControlStateNormal];
    [fbLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    fbLogin.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [fbLogin addTarget:self action:@selector(_onInviteFacebook:) forControlEvents:UIControlEventTouchUpInside];
    fbLogin.layer.cornerRadius = 5.0f;
    
    [self.view addSubview:fbLogin];
}

/* 自定义微信登录按钮 */
- (void)createWechatLoginButton
{
    UIButton *wxBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    wxBtn.frame = CGRectMake(20, 10 * 4 + 44 * 3, self.view.frame.size.width - 40, 44);
    wxBtn.backgroundColor = [UIColor colorWithRed:255/255.0 green:143/255.0 blue:22/255.0 alpha:1.0];
    [wxBtn setTitle:@"微信授权登录" forState:UIControlStateNormal];
    [wxBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    wxBtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [wxBtn addTarget:self action:@selector(_onLoginWeChat:) forControlEvents:UIControlEventTouchUpInside];
    wxBtn.layer.cornerRadius = 5.0f;
    
    [self.view addSubview:wxBtn];
}
/* 自定义微信分享按钮 */
- (void)createWechatShareButton {
    UIButton *wxBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    wxBtn.frame = CGRectMake(20, 10 * 5 + 44 * 4, self.view.frame.size.width - 40, 44);
    wxBtn.backgroundColor = [UIColor colorWithRed:255/255.0 green:143/255.0 blue:22/255.0 alpha:1.0];
    [wxBtn setTitle:@"微信分享" forState:UIControlStateNormal];
    [wxBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    wxBtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [wxBtn addTarget:self action:@selector(_onShareWeChat:) forControlEvents:UIControlEventTouchUpInside];
    wxBtn.layer.cornerRadius = 5.0f;
    
    [self.view addSubview:wxBtn];
}

- (void)createWhatsappShareButton {
    UIButton *whatsappBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    whatsappBtn.frame = CGRectMake(20, 10 * 6 + 44 * 5, self.view.frame.size.width - 40, 44);
    whatsappBtn.backgroundColor = [UIColor colorWithRed:255/255.0 green:143/255.0 blue:22/255.0 alpha:1.0];
    [whatsappBtn setTitle:@"whatsapp分享按钮" forState:UIControlStateNormal];
    [whatsappBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    whatsappBtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [whatsappBtn addTarget:self action:@selector(_onShareWhatsapp:) forControlEvents:UIControlEventTouchUpInside];
    whatsappBtn.layer.cornerRadius = 5.0f;
    
    [self.view addSubview:whatsappBtn];
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

- (void)_onShareWeChat:(UIButton *)button {
    NSData *netData = [NSData dataWithContentsOfURL:[NSURL URLWithString: @"http://leapkids-dev.oss-cn-beijing.aliyuncs.com/course/cover/4779401786cd45de94d032f105642ce5.jpg?x-oss-process=style/150_150"]];
    UIImage *netImage = [UIImage imageWithData:netData];
    [[YKSDKManager shareManager] YKWechatShareParamsByTitle:@"测试微信分享"
                                                description:@"测试微信分享"
                                                      image:netImage
                                                        url:@"https://d3uu10x6fsg06w.cloudfront.net/shareitexampleapp/liking/index.html"
                                                      scene:YKSceneSession
                                                  currentVc:self
                                                    handler:^(YKResponseState state, NSError *error) {
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

#pragma mark -- WhatsApp分享
- (void)_onShareWhatsapp:(UIButton *)button {
    // 本地图片转data
    /*分享图片的时候 如果碰到whatsapptmp image exclusive 应该是网络问题 */
    // NSData *data = UIImageJPEGRepresentation([UIImage imageNamed:@"image"], 1.0);
    // 网络图片转data
//    NSData *netData = [NSData dataWithContentsOfURL:[NSURL URLWithString: @"http://leapkids-dev.oss-cn-beijing.aliyuncs.com/course/cover/4779401786cd45de94d032f105642ce5.jpg?x-oss-process=style/150_150"]];
    // [[YKSDKManager shareManager] sendImage:data view:self.view];
//    [[YKSDKManager shareManager] sendImage:netData view:self.view];
    /*
     // 文本分享  测试的时候可以打开
    [[YKSDKManager shareManager] sendText:@"Hello--Whatsapp"];
     // 链接分享  测试的时候可以打开
     */
    [[YKSDKManager shareManager] sendLinkUrl:@"https://d3uu10x6fsg06w.cloudfront.net/shareitexampleapp/liking/index.html"];
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
