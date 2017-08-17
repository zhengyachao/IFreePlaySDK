//
//  IFViewController.m
//  IFreePlaySDK
//
//  Created by zhengyachao on 08/17/2017.
//  Copyright (c) 2017 zhengyachao. All rights reserved.
//

#import "IFViewController.h"

@interface IFViewController ()
@property (weak, nonatomic) IBOutlet UIButton *facebookBtn;
@property (weak, nonatomic) IBOutlet UIButton *lineBtn;
@property (weak, nonatomic) IBOutlet UIButton *wechatBtn;

@end

@implementation IFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/* 点击登录facebook拿到授权数据
 *
 */
- (IBAction)loginFaceBookButton:(id)sender {
    

}

/* 点击登录Line拿到授权数据
 *
 */
- (IBAction)loginLineButton:(id)sender {
}

/* 点击登录微信拿到授权数据
 *
 */
- (IBAction)loginWechatButton:(id)sender {
}

@end
