//
//  IFProductListViewController.m
//  CocoapodsTestDemo
//
//  Created by ifreeplay on 2017/9/15.
//  Copyright © 2017年 ifreeplay. All rights reserved.
//

#import <IFreePlaySDK/YKSDKManager.h>
#import <IFreePlaySDK/YKLoginRequest.h>
#import <IFreePlaySDK/YKUtilsMacro.h>
#import "PayViewController.h"
#import "IFProductListViewController.h"

#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>
#import <CommonCrypto/CommonDigest.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

@interface IFProductListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *productListArray;

@end

@implementation IFProductListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"商品列表";
    self.view.backgroundColor = [UIColor clearColor];
    self.productListArray = [NSMutableArray arrayWithCapacity:100];
    self.automaticallyAdjustsScrollViewInsets = NO;

    [self createTableView];
    [self createDataSource];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 88) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    [self.view addSubview:self.tableView];
}

- (void)createDataSource
{
    YKGameIdRequest *request = [[YKGameIdRequest alloc] initGameId:@"3"];
    
    [request startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSDictionary *result = request.responseObject;
        NSArray *data = [result objectForKey:@"data"];
        if (data.count > 0 ) {
            [data enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.productListArray addObject:obj];
            }];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSLog(@"%@",request.error);
    }];
}

#pragma mark -- UITableViewDelegate,UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.productListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell_id"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell_id"];
    }
    NSString *name = [self.productListArray[indexPath.row] objectForKey:@"name"];
    NSString *price = [self.productListArray[indexPath.row] objectForKey:@"price"];
    cell.textLabel.text = [NSString stringWithFormat:@"商品名称: %@",name];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"商品单价: %@ $",price];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dict = self.productListArray[indexPath.row];
    NSDictionary *params = @{@"productId":[dict objectForKey:@"id"],
                             @"playerId":@"1",
                             @"currencyTypes":CurrencyType(YKCNY),
                             @"spbillCreateIp":[self getIPAddress:YES]
                             };
    [[YKSDKManager shareManager] getOrderInfoWithParams:params
                                                success:^(NSDictionary *result)
     {
         PayViewController *payVc = [[PayViewController alloc] init];
         payVc.productDict = self.productListArray[indexPath.row];
         payVc.orderId = [[result objectForKey:@"data"] objectForKey:@"id"];
         
         [self.navigationController pushViewController:payVc animated:YES];
     }
                                                failure:^(NSError *error)
     {
         NSLog(@"%@",error);
     }];
}

#pragma mark - 获取设备当前网络IP地址
- (NSString *)getIPAddress:(BOOL)preferIPv4
{
    NSArray *searchArray = preferIPv4 ?
    @[ IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        address = addresses[key];
        //筛选出IP地址格式
        if([self isValidatIP:address]) *stop = YES;
    } ];
    return address ? address : @"0.0.0.0";
}

- (BOOL)isValidatIP:(NSString *)ipAddress
{
    if (ipAddress.length == 0) {
        return NO;
    }
    NSString *urlRegEx = @"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])$";
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlRegEx options:0 error:&error];
    
    if (regex != nil)
    {
        NSTextCheckingResult *firstMatch=[regex firstMatchInString:ipAddress options:0 range:NSMakeRange(0, [ipAddress length])];
        
        if (firstMatch)
        {
            NSRange resultRange = [firstMatch rangeAtIndex:0];
            NSString *result = [ipAddress substringWithRange:resultRange];
            //            输出结果
            NSLog(@"打印一下IP地址: %@",result);
            return YES;
        }
    }
    return NO;
}

- (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces))
    {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next)
        {
            if(!(interface->ifa_flags & IFF_UP)) {
                continue;
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family == AF_INET || addr->sin_family == AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN))
                    {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type)
                {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

@end
