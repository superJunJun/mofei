//
//  TYDPostUrlRequest.h
//  Mofei
//
//  Created by macMini_Dev on 14/12/1.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServicePostUrlRequestMsgCode.h"

#define sNetworkError   @"网络链接错误"
#define sNetworkFailed  @"网络掉线，请在确认网络链接状态后重试"

#define sHUDHintSubmitData      @"提交数据"
#define sHUDHintSubmitRequest   @"提交请求"
#define sHUDHintSubmitSucceed   @"提交完成"
#define sHUDHintSubmitFailed    @"提交失败"
#define sHUDHintObtainData      @"获取数椐"
#define sHUDHintObtainSucceed   @"获取成功"
#define sHUDHintObtainFailed    @"获取失败"
#define sHUDHintRequestSucceed  @"请求成功"
#define sHUDHintRequestFailed   @"请求失败"

#define sVertificationCodeRequestComplete  @"请求提交完成，请等待短信验证码"

typedef void(^PostUrlRequestCompleteBlock)(id result);
typedef void(^PostUrlRequestFailedBlock)(NSUInteger msgCode, id result);
#define sPostUrlRequestUserAcountKey            @"account"

@interface TYDPostUrlRequest : NSObject

//网络连接是否有效
+ (BOOL)networkConnectionIsAvailable;

//发起网络连接
+ (void)postUrlRequestWithMessageCode:(NSUInteger)msgCode
                               params:(NSMutableDictionary *)params
                        completeBlock:(PostUrlRequestCompleteBlock)completionBlock
                          failedBlock:(PostUrlRequestFailedBlock)failedBlock;

@end
