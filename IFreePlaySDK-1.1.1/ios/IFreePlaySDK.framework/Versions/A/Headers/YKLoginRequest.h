//
//  YKLoginRequest.h
//  CocoapodsTestDemo
//
//  Created by ifreeplay on 2017/9/14.
//  Copyright © 2017年 ifreeplay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YTKNetwork/YTKRequest.h>

@interface YKLoginRequest : YTKRequest

- (instancetype)initWithGameId:(NSString *)gameId
                        openId:(NSString *)openId
                          type:(NSString *)type
                          name:(NSString *)name;
@end

@interface YKRequestOrder : YTKRequest

- (instancetype)initWithParams:(NSDictionary *)params;
@end

@interface YKGameIdRequest : YTKRequest

- (instancetype)initGameId:(NSString *)gameId;

@end

@interface YKPaypalRequest : YTKRequest

- (instancetype)initWithPaypalId:(NSString *)paypalId
                        orderNum:(NSString *)orderNum;
@end

@interface YKWechatPayRequest : YTKRequest

- (instancetype)initWithOrderNumber:(NSString *)orderNumber;
@end

@interface YKIAPPayRequest : YTKRequest

- (instancetype)initWithOrderNumber:(NSString *)orderNumber
                        receiptData:(NSString *)receiptData
                  verifyEnvironment:(NSString *)verifyEnvironment;
@end
