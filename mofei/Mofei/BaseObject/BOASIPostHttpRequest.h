//
//  BOASIPostHttpRequest.h
//
//  网络连接辅助模块
//

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"
//#import "TYDBasicServerUrl.h"

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

typedef void(^PostHttpRequestCompletionBlock)(id result);
typedef void(^PostHttpRequestFailedBlock)(NSUInteger msgCode, id result);

@interface BOASIPostHttpRequest : NSObject

//网络连接是否有效
+ (BOOL)networkConnectionIsAvailable;

//发起网络连接
+ (ASIHTTPRequest *)requestWithMessageCode:(NSUInteger)msgCode
                                    params:(NSMutableDictionary *)params
                             completeBlock:(PostHttpRequestCompletionBlock)completionBlock
                               failedBlock:(PostHttpRequestFailedBlock)failedBlock;
+ (ASIHTTPRequest *)requestGetWithMessageCode:(NSUInteger)msgCode
                                       params:(NSMutableDictionary *)params
                                completeBlock:(PostHttpRequestCompletionBlock)completionBlock
                                  failedBlock:(PostHttpRequestFailedBlock)failedBlock;

@end
