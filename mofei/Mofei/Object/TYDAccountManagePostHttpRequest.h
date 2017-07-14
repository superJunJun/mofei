//
//  TYDAccountManagePostHttpRequest.h
//  Mofei
//
//  Created by macMini_Dev on 14-11-3.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"

#define sAMServiceUrlLogin          @"lapi/login"       //登录
#define sAMServiceUrlEnroll         @"lapi/signup"      //注册
#define sAMServiceUrlVcode          @"lapi/getrandcode" //验证码
#define sAMServiceUrlResetPwd       @"lapi/resetpass"   //重置密码
#define sAMServiceUrlAuthorize      @"lapi/auth"        //授权第三方

typedef void(^AMPostHttpRequestCompletionBlock)(id result);
typedef void(^AMPostHttpRequestFailedBlock)(NSString *url, id result);

//codetype:验证码 [userreg,resetpasswd,bindmobile]
#define sVCodeTypeEnroll        @"userreg"
#define sVCodeTypeResetPwd      @"resetpasswd"
#define sVCodeTypeBindPhone     @"bindmobile"

//utype:用户类型[openqq,openweibo]
#define sAuthUserTypeQQ         @"openqq"
#define sAuthUserTypeWeibo      @"openweibo"

//utype:[zhuoyou]?
#define sLoginUserTypeZhuoyou   @"zhuoyou"  //卓悠

//regtype:注册步骤[smsreg,randreg]?
#define sEnrollTypeSms          @"smsreg"   //短信注册
#define sEnrollTypeVCode        @"randreg"  //验证码注册

@interface TYDAccountManagePostHttpRequest : NSObject

+ (ASIHTTPRequest *)amRequestWithURL:(NSString *)url
                              params:(NSMutableDictionary *)params
                       completeBlock:(AMPostHttpRequestCompletionBlock)completionBlock
                         failedBlock:(AMPostHttpRequestFailedBlock)failedBlock;

+ (NSString *)deviceInfoEncode:(NSString *)deviceInfo;
+ (NSString *)deviceInfoDecode:(NSString *)deviceInfo;
+ (NSString *)signInfoCreateWithInfos:(NSArray *)stringArray;

@end
