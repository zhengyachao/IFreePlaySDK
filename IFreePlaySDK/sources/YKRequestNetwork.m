//
//  YKRequestNetwork.m
//  CocoapodsTestDemo
//
//  Created by ifreeplay on 2017/8/10.
//  Copyright © 2017年 ifreeplay. All rights reserved.
//

#import "YKRequestNetwork.h"

@implementation YKRequestNetwork

+ (void)getRequestByServiceUrl:(NSString *)URL
                    parameters:(NSDictionary *)dic
                       success:(YKRequestSuccess )success
                       failure:(YKRequestFailed )failure
{
    //创建配置信息
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    //设置请求超时时间：5秒
    configuration.timeoutIntervalForRequest = 10;
    //创建会话
    NSURLSession *session = [NSURLSession sessionWithConfiguration: configuration delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",URL]]];
    //设置请求方式：POST
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"content-Type"];
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Accept"];
    
    //dic的params字典形式转化为jsonData
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    //设置请求体
    [request setHTTPBody:jsonData];
    
    NSURLSessionDataTask * dataTask =[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil)
        {
            NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            success(responseObject);
        }else
        {
            NSLog(@"%@",error);
            failure(error);
        }
    }];
    
    [dataTask resume];
}

+ (void)postRequestByServiceUrl:(NSString *)URL
                     parameters:(NSDictionary *)dic
                        success:(YKRequestSuccess)success
                        failure:(YKRequestFailed)failure
{
    //创建配置信息
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    //设置请求超时时间：5秒
    configuration.timeoutIntervalForRequest = 10;
    //创建会话
    NSURLSession *session = [NSURLSession sessionWithConfiguration: configuration delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",URL]]];
    //设置请求方式：POST
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"content-Type"];
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Accept"];
    
    //dic的params字典形式转化为jsonData
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    //设置请求体
    [request setHTTPBody:jsonData];
    
    NSURLSessionDataTask * dataTask =[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSString *code = responseObject[@"code"];
            NSDictionary *data = responseObject[@"data"];
            
            switch ([code intValue])
            {
                case 0:
                    success(data);
                    break;
                case 10001:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"参数非法" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",nil];
                        [alert show];
                    });
                }
                default:
                    break;
            }
        }else
        {
            NSLog(@"%@",error);
            failure(error);
        }
    }];
    [dataTask resume];
}

@end
