//
//  IFProductListViewController.m
//  CocoapodsTestDemo
//
//  Created by ifreeplay on 2017/9/15.
//  Copyright © 2017年 ifreeplay. All rights reserved.
//

#import <IFreePlaySDK/YKSDKManager.h>
#import <IFreePlaySDK/YKUtilTools.h>
#import <IFreePlaySDK/YKLoginRequest.h>
#import "PayViewController.h"
#import "IFProductListViewController.h"

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
        NSLog(@"%@",result);
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
    NSDictionary *params = @{@"gameId":[dict objectForKey:@"gameId"],
                             @"productId":[dict objectForKey:@"id"],
                             @"productName":[dict objectForKey:@"name"],
                             @"playerId":@"1",
                             @"status":@"OPEN",
                             @"price":[dict objectForKey:@"price"],
                             @"totalPrice":[dict objectForKey:@"price"],
                             @"dealPrice":[dict objectForKey:@"price"],
                             @"currencyTypes":@"USD",
                             @"spbillCreateIp":[YKUtilTools getIPAddress:YES]
                             };
    [[YKSDKManager shareManager] getOrderInfoWithParams:params
                                               success:^(NSDictionary *result)
     {
         PayViewController *payVc = [[PayViewController alloc] init];
         payVc.productDict = self.productListArray[indexPath.row];
         payVc.orderNumber = [[result objectForKey:@"data"] objectForKey:@"orderNumber"];
         
         [self.navigationController pushViewController:payVc animated:YES];
     }
                                               failure:^(NSError *error)
     {
         NSLog(@"%@",error);
     }];
}

@end
