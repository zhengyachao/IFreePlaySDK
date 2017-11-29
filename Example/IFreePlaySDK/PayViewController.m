//
//  PayViewController.m
//  CocoapodsTestDemo
//
//  Created by ifreeplay on 2017/8/22.
//  Copyright © 2017年 ifreeplay. All rights reserved.
//

#import "GTMBase64.h"
#import <IFreePlaySDK/PayPalMobile.h>
#import <IFreePlaySDK/YKSDKManager.h>
#import <IFreePlaySDK/YKLoginRequest.h>
#import "PayViewController.h"
#import <StoreKit/StoreKit.h>
#import <LocalAuthentication/LocalAuthentication.h>


@interface PayViewController () <PayPalPaymentDelegate,SKProductsRequestDelegate,SKPaymentTransactionObserver>

@property (nonatomic, strong) PayPalConfiguration *paypalConfig;

@end

@implementation PayViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 配置支付环境
    [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentSandbox];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"三方支付";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initPayPalConfiguration];
    [self createPaypalButton];
    [self createWechatPayButton];
    [self createApplePayButton];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initPayPalConfiguration
{
    _paypalConfig = [[PayPalConfiguration alloc] init];
    //是否接受信用卡
    _paypalConfig.acceptCreditCards = NO;
    //商家名称
    _paypalConfig.merchantName = @"zhengyachao-facilitator@ifreeplay.com";
    //商家隐私协议网址和用户授权网址-说实话这个没用到
    _paypalConfig.merchantPrivacyPolicyURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/privacy-full"];
    _paypalConfig.merchantUserAgreementURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/useragreement-full"];
    //paypal账号下的地址信息
    _paypalConfig.payPalShippingAddressOption = PayPalShippingAddressOptionPayPal;
    
    //配置语言环境
    _paypalConfig.languageOrLocale = [NSLocale preferredLanguages][0];
}

#pragma mark --  按钮事件
- (void)createPaypalButton
{
    UIButton *payLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    payLogin.frame = CGRectMake(20, 44, self.view.frame.size.width - 40, 44);
    payLogin.backgroundColor = [UIColor colorWithRed:255/255.0 green:143/255.0 blue:22/255.0 alpha:1.0];
    [payLogin setTitle:@"Paypal支付" forState:UIControlStateNormal];
    [payLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    payLogin.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    [payLogin addTarget:self action:@selector(_onPaypalViewController:) forControlEvents:UIControlEventTouchUpInside];
    payLogin.layer.cornerRadius = 5.0;
    
    [self.view addSubview:payLogin];
}

- (void)createWechatPayButton
{
    UIButton *payLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    payLogin.frame = CGRectMake(20, 44 * 3, self.view.frame.size.width - 40, 44);
    payLogin.backgroundColor = [UIColor colorWithRed:255/255.0 green:31/255.0 blue:65/255.0 alpha:1.0];
    [payLogin setTitle:@"微信支付" forState:UIControlStateNormal];
    [payLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    payLogin.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    [payLogin addTarget:self action:@selector(_onWechatPay:) forControlEvents:UIControlEventTouchUpInside];
    payLogin.layer.cornerRadius = 5.0;
    
    [self.view addSubview:payLogin];
}

- (void)createApplePayButton
{
    UIButton *payLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    payLogin.frame = CGRectMake(20, 44 * 5, self.view.frame.size.width - 40, 44);
    payLogin.backgroundColor = [UIColor colorWithRed:192/255.0 green:192/255.0 blue:192/255.0 alpha:1.0];
    [payLogin setTitle:@"ApplePay支付" forState:UIControlStateNormal];
    [payLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    payLogin.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    [payLogin addTarget:self action:@selector(_onApplePayButton:) forControlEvents:UIControlEventTouchUpInside];
    payLogin.layer.cornerRadius = 5.0;
    
    [self.view addSubview:payLogin];
}

- (void)_onPaypalViewController:(UIButton *)button
{
    PayPalPayment *payment = [[PayPalPayment alloc] init];
    //订单总额
    NSString *priceCount = [NSString stringWithFormat:@"%@",[self.productDict objectForKey:@"price"]];
    payment.amount = [NSDecimalNumber decimalNumberWithString:priceCount];
    //货币类型-RMB是没用的
    payment.currencyCode = @"USD";
    //订单描述
    payment.shortDescription = @"Hipster clothing";
    //生成paypal控制器，并模态出来(push也行)
    //将之前生成的订单信息和paypal配置传进来，并设置订单VC为代理
    PayPalPaymentViewController *paymentViewController = [[PayPalPaymentViewController alloc] initWithPayment:payment                                                                                            configuration:self.paypalConfig                                                                                                  delegate:self];
    
    //模态展示
    [self presentViewController:paymentViewController animated:YES completion:nil];
}

- (void)_onWechatPay:(UIButton *)button
{
    // 发起微信支付
    [[YKSDKManager shareManager] lunchWechatPayWithOrderId:self.orderId viewController:self];
}

- (void)_onApplePayButton:(UIButton *)button
{
    // 检测是否允许内购
    if([SKPaymentQueue canMakePayments])
    {
        [self requestProductData:@"com.ifreeplay.airtravelers_roomcard1"];
    }else
    {
        NSLog(@"不允许程序内付费");
    }
}

- (void)requestProductData:(NSString *)type
{
    NSArray *product = [[NSArray alloc] initWithObjects:type, nil];
    NSSet *nsset = [NSSet setWithArray:product];
    
    // 请求动作
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:nsset];
    request.delegate = self;
    [request start];
}

#pragma mark -- SKProductsRequestDelegate
//收到产品返回信息
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"收到了请求反馈");
    NSArray *product = response.products;
    if([product count] == 0)
    {
        NSLog(@"没有这个商品");
        return;
    }
    
    NSLog(@"productID:%@", response.invalidProductIdentifiers);
    NSLog(@"产品付费数量:%ld",[product count]);
    SKProduct *p = nil;
    
    // 所有的商品, 遍历招到我们的商品
    for (SKProduct *pro in product)
    {
        NSLog(@"%@", [pro description]);
        NSLog(@"%@", [pro localizedTitle]);
        NSLog(@"%@", [pro localizedDescription]);
        NSLog(@"%@", [pro price]);
        NSLog(@"%@", [pro productIdentifier]);
        
        if ([pro.productIdentifier isEqualToString:@"com.ifreeplay.airtravelers_roomcard1"])
        {
            p = pro;
        }
    }
    
    SKPayment * payment = [SKPayment paymentWithProduct:p];
    NSLog(@"发送购买请求");
    
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}
//请求失败
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"商品信息请求错误:%@", error);
}

- (void)requestDidFinish:(SKRequest *)request {
    NSLog(@"请求结束");
}

//监听购买结果
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transaction {
    
    for(SKPaymentTransaction *tran in transaction){
        
        switch (tran.transactionState) {
            case SKPaymentTransactionStatePurchased:
            {
                NSLog(@"交易完成");
                // 结束掉请求
                [self completeTransaction:tran];
            }
                break;
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"商品添加进列表");
                
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"已经购买过商品");
                
                break;
            case SKPaymentTransactionStateFailed:
                NSLog(@"交易失败");
                
                [self failedTransaction:tran];
            default:
                break;
        }
    }
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    NSLog(@"failedTransaction...");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

//交易结束
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"交易结束");
    NSData *data = [NSData dataWithContentsOfFile:[[[NSBundle mainBundle] appStoreReceiptURL] path]];
    NSString *receiptData = [[NSString alloc] initWithData:[GTMBase64 encodeData:data] encoding:NSUTF8StringEncoding];
    NSLog(@"%@",receiptData);
    [[YKSDKManager shareManager] verifyAppleIAPWithOrderId:self.orderId receiptData:receiptData verifyEnvironment:@"Sandbox"];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

#pragma mark -- PayPalPaymentDelegate
- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController
                 didCompletePayment:(PayPalPayment *)completedPayment
{
    NSString *paypalId = [[completedPayment.confirmation objectForKey:@"response"] objectForKey:@"id"];
    [[YKSDKManager shareManager] verifyPaypalWithPaypalId:paypalId orderId:self.orderId];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- dealloc
- (void)dealloc {
    // 移除监听
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

@end
