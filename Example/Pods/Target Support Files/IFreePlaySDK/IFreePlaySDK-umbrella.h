#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "LineSDK.h"
#import "LineSDKAccessToken.h"
#import "LineSDKAPI.h"
#import "LineSDKConfiguration.h"
#import "LineSDKCredential.h"
#import "LineSDKHTTPClient.h"
#import "LineSDKLogin.h"
#import "LineSDKProfile.h"
#import "LineSDKRequestProtocol.h"
#import "LineSDKVerifyResult.h"
#import "NSError+LineSDK.h"
#import "WechatAuthSDK.h"
#import "WXApi.h"
#import "WXApiObject.h"
#import "YKRequestNetwork.h"
#import "YKSDKManager.h"

FOUNDATION_EXPORT double IFreePlaySDKVersionNumber;
FOUNDATION_EXPORT const unsigned char IFreePlaySDKVersionString[];

