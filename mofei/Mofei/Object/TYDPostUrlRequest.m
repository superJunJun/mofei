//
//  TYDPostUrlRequest.m
//  Mofei
//
//  Created by macMini_Dev on 14/12/1.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import "TYDPostUrlRequest.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "SBJson.h"
#import "DESUtil.h"

#define sServerBasicUrl         @"http://service-mofei.yy845.com:2660"
//#define sServerBasicUrl         @"http://192.168.0.52:2661"
#define sDesKeyString           @"x_s0_s22"

#define sTestServerUrl          @"wap.baidu.com"
#define sPostHttpMethodName     @"POST"

#define sDeviceUDIDKey          @"udid"
#define sDeviceIMSIKey          @"imsi"

@implementation TYDPostUrlRequest

+ (NSDictionary *)urlRequestHeadDictionaryCreateWithMessageCode:(NSUInteger)msgCode
{
    NSMutableDictionary *headDic = [NSMutableDictionary new];
    [headDic setValue:@1 forKey:@"ver"];
    [headDic setValue:@(-7352451723144222243) forKey:@"lsb"];
    [headDic setValue:@(5914685879831120660) forKey:@"msb"];
    [headDic setValue:@1 forKey:@"type"];
    [headDic setValue:@(msgCode) forKey:@"mcd"];
    
    return headDic;
}

+ (NSMutableDictionary *)urlPostRequestAdditionalParams
{
    NSMutableDictionary *additionalParams = [NSMutableDictionary new];
    NSString *userID = [TYDUserInfo sharedUserInfo].userID;
    if(userID.length == 0)
    {
        userID = @"";
    }
    [additionalParams setValue:[BOAssistor deviceUDID] forKey:sDeviceUDIDKey];
    [additionalParams setValue:userID forKey:sPostUrlRequestUserAcountKey];
    [additionalParams setValue:@"" forKey:sDeviceIMSIKey];
    return additionalParams;
}

//发起网络连接
+ (void)postUrlRequestWithMessageCode:(NSUInteger)msgCode
                               params:(NSMutableDictionary *)params
                        completeBlock:(PostUrlRequestCompleteBlock)completeBlock
                          failedBlock:(PostUrlRequestFailedBlock)failedBlock
{
    NSString *urlString = sServerBasicUrl;
    NSString *desKeyString = sDesKeyString;
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = sPostHttpMethodName;
    request.timeoutInterval = 60;
    
    //方便外边设定指定的sUserAcountKey值，loginVC时有需求
    NSMutableDictionary *basicParams = [self urlPostRequestAdditionalParams];
    [basicParams setValuesForKeysWithDictionary:params];
    
    SBJsonWriter *jsonWriter = [SBJsonWriter new];
    NSDictionary *headDic = [self urlRequestHeadDictionaryCreateWithMessageCode:msgCode];
    NSString *jsonHeadString = [jsonWriter stringWithObject:headDic];
    NSString *jsonBodyString = [jsonWriter stringWithObject:basicParams];
    
    NSDictionary *infoDic = @{@"head":jsonHeadString, @"body":jsonBodyString};
    NSString *infoJsonString = [jsonWriter stringWithObject:infoDic];
    NSLog(@"infoJsonString:%@", infoJsonString);
    NSData *infoData = [infoJsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    infoData = [DESUtil DESEncrypt:infoData WithKey:desKeyString];
    [request setHTTPBody:infoData];
    
    NSOperationQueue *queue = [NSOperationQueue new];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(!connectionError)
        {
            NSLog(@"%ld", (long)data.length);
            data = [DESUtil DESDecrypt:data WithKey:desKeyString];
            NSLog(@"%ld", (long)data.length);
            NSString *resultString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"resultString:%@", resultString);
            
            //过滤BOM字符
            unichar ch = 0;
            NSString *chString = [NSString stringWithCharacters:&ch length:1];
            resultString = [resultString stringByReplacingOccurrencesOfString:chString withString:@""];
            
            NSError *error = nil;
            SBJsonParser *jsonParser = [SBJsonParser new];
            id httpDic = [jsonParser objectWithString:resultString error:&error];
            //NSLog(@"error:%ld, %@, %@, %@", (long)error.code, error.userInfo, error.description, error.domain);
            //NSLog(@"httpDic:%@", httpDic);
            NSString *bodyString = httpDic[@"body"];
            id result = [jsonParser objectWithString:bodyString error:&error];
            
            if(completeBlock)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completeBlock(result);
                });
            }
        }
        else
        {
            if(failedBlock)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failedBlock(msgCode, connectionError);
                });
            }
        }
    }];
}

+ (BOOL)networkConnectionIsAvailable
{
    SCNetworkReachabilityFlags flags;
    
    // Recover reachability flags
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(CFAllocatorGetDefault(), [sTestServerUrl UTF8String]);
    //获得连接的标志
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(reachability, &flags);
    CFRelease(reachability);
    //如果不能获取连接标志，则不能连接网络，直接返回
    if(!didRetrieveFlags)
    {
        return NO;
    }
    //根据获得的连接标志进行判断
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    return (isReachable && !needsConnection) ? YES : NO;
}

@end
