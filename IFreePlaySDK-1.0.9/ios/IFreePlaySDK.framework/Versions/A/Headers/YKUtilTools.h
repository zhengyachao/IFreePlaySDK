//
//  YKUtilTools.h
//  Pods
//
//  Created by ifreeplay on 2017/9/1.
//
//

#import <Foundation/Foundation.h>

@interface YKUtilTools : NSObject

/* 获取当前设备的终端IP地址 */
+ (NSString *)getIPAddress:(BOOL)preferIPv4;

/* 创建微信发起支付时的二次sige签名 */
+ (NSString *)createMD5SingForPay:(NSString *)appid_key
                        partnerid:(NSString *)partnerid_key
                         prepayid:(NSString *)prepayid_key
                          package:(NSString *)package_key
                         noncestr:(NSString *)noncestr_key
                        timestamp:(UInt32)timestamp_key;

@end
