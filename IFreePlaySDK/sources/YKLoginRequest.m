//
//  YKLoginRequest.m
//  CocoapodsTestDemo
//
//  Created by ifreeplay on 2017/9/14.
//  Copyright © 2017年 ifreeplay. All rights reserved.
//


#import "YKLoginRequest.h"
#import "YKUtilsMacro.h"

@implementation YKLoginRequest
{
    NSString *_gameId;
    NSString *_openId;
    NSString *_type;
    NSString *_name;
    NSString *_headPortraitUrl;
}

- (instancetype)initWithGameId:(NSString *)gameId
                        openId:(NSString *)openId
                          type:(NSString *)type
                          name:(NSString *)name
               headPortraitUrl:(NSString *)headPortraitUrl
{
    if (self = [super init]) {
        _gameId = gameId;
        _openId = openId;
        _type = type;
        _name = name;
        _headPortraitUrl = headPortraitUrl;
    }
    return self;
}

-(NSString*)requestUrl{
    
    return [NSString stringWithFormat:@"%@%@",kIFBaseUrl,kIFSDKLogin];
}

-(YTKRequestMethod)requestMethod{
    
    return YTKRequestMethodPOST;
}

- (YTKRequestSerializerType)requestSerializerType
{
    return YTKRequestSerializerTypeJSON;
}

- (YTKResponseSerializerType)responseSerializerType
{
    return YTKResponseSerializerTypeJSON;
}

- (id)requestArgument
{
    NSDictionary *params;
    if ([_type isEqualToString:@"WECHAT"])
    {
        params = @{ @"gameId":_gameId,
                    @"type":_type,
                    @"wechatId":_openId,
                    @"name":_name,
                    @"headPortraitUrl":_headPortraitUrl
                    };
        
    } else if ([_type isEqualToString:@"FACEBOOK"])
    {
        params = @{ @"gameId":_gameId,
                    @"type":_type,
                    @"facebookId":_openId,
                    @"name":_name,
                    @"headPortraitUrl":_headPortraitUrl
                    };
    } else if ([_type isEqualToString:@"LINE"])
    {
        params = @{ @"gameId":_gameId,
                    @"type":_type,
                    @"lineId":_openId,
                    @"name":_name,
                    @"headPortraitUrl":_headPortraitUrl
                    };
    }
    
    return params;
}

@end

@implementation YKRequestOrder
{
    NSDictionary *_params;
}

- (instancetype)initWithParams:(NSDictionary *)params
{
    if (self = [super init]) {
        _params = params;
    }
    
    return self;
}

- (NSString*)requestUrl {
    return [NSString stringWithFormat:@"%@%@",kIFBaseUrl,kIFSDKGetProductsOrder];
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodPOST;
}

- (YTKRequestSerializerType)requestSerializerType
{
    return YTKRequestSerializerTypeJSON;
}

- (YTKResponseSerializerType)responseSerializerType
{
    return YTKResponseSerializerTypeJSON;
}

- (id)requestArgument {
    return _params;
}


@end

@implementation YKGameIdRequest
{
    NSString *_gameId;
}

- (instancetype)initGameId:(NSString *)gameId
{
    if (self = [super init]) {
        _gameId = gameId;
    }
    return self;
}

-(NSString*)requestUrl {
    
    return [NSString stringWithFormat:@"%@%@",kIFBaseUrl,kIFSDKGetProduct];
}

-(YTKRequestMethod)requestMethod {
    return YTKRequestMethodGET;
}

-(id)requestArgument {
    NSDictionary *body = @{ @"gameId": _gameId };
    return body;
}

@end

@implementation YKPaypalRequest
{
    NSString *_paypalId;
    NSString *_orderId;
}

- (instancetype)initWithPaypalId:(NSString *)paypalId
                         orderId:(NSString *)orderId
{
    if (self = [super init]) {
        _paypalId = paypalId;
        _orderId = orderId;
    }
    return self;
}

- (NSString*)requestUrl {
    return [NSString stringWithFormat:@"%@%@",kIFBaseUrl,kIFSDKPaypal];
}

-(YTKRequestMethod)requestMethod {
    return YTKRequestMethodPOST;
}

- (id)requestArgument {
    NSDictionary *params = @{ @"paymentId":_paypalId, @"orderNumber":_orderId};
    return params;
}

@end

@implementation YKWechatPayRequest
{
    NSString *_orderId;
}

- (instancetype)initWithOrderId:(NSString *)orderId
{
    if (self = [super init]) {
        _orderId = orderId;
    }
    
    return self;
}

- (NSString*)requestUrl {
    return [NSString stringWithFormat:@"%@%@",kIFBaseUrl,kIFSDKGetPayInfo];
}

-(YTKRequestMethod)requestMethod {
    return YTKRequestMethodPOST;
}

- (id)requestArgument {
    
    NSDictionary *params = @{@"orderId":_orderId};
    return params;
}
@end

@implementation YKIAPPayRequest
{
    NSString *_orderId;
    NSString *_receiptData;
    NSString *_verifyEnvironment;
}

- (instancetype)initWithOrderId:(NSString *)orderId
                    receiptData:(NSString *)receiptData
              verifyEnvironment:(NSString *)verifyEnvironment
{
    if (self = [super init]) {
        _orderId = orderId;
        _receiptData = receiptData;
        _verifyEnvironment = verifyEnvironment;
    }
    
    return self;
}

- (NSString*)requestUrl {
    return [NSString stringWithFormat:@"%@%@",kIFBaseUrl,kIAPPayInfo];
}

-(YTKRequestMethod)requestMethod {
    return YTKRequestMethodPOST;
}

- (id)requestArgument
{
    NSDictionary *params = @{@"orderId":_orderId,
                             @"receiptData":_receiptData,
                             @"verifyEnvironment":_verifyEnvironment
                             };
    return params;
}

@end


