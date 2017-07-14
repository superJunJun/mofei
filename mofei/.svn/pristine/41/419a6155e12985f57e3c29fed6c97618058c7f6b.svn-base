//
//  BOASIPostHttpRequest.m
//
//  网络连接辅助模块
//

#import "BOASIPostHttpRequest.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "SBJson.h"

#define sPostHttpMethodName     @"POST"
#define sGetHttpMethodName      @"GET"
#define sTestServerUrl          @"wap.baidu.com"
#define sServerUrlBasic         @"http://service-mofei.yy845.com:2660"
//#define sServerUrlBasic         @"http://cmp-mofei.yy845.com:8081/"
//#define sServerUrlBasic         @"http://192.168.0.52:2661"

#define sMessageCodeKey         @"msgCode"
#define sDeviceUDIDKey          @"UDID"
#define sUserAcountKey          @"account"
#define sDeviceIMSIKey          @"imsi"
@implementation BOASIPostHttpRequest

+ (NSDictionary *)requestHeadDictionaryCreateWithMessageCode:(NSUInteger)msgCode
{
    NSMutableDictionary *headDic = [NSMutableDictionary new];
    [headDic setValue:@1 forKey:@"ver"];
    [headDic setValue:@(-9153731842417392736) forKey:@"lsb"];
    [headDic setValue:@1 forKey:@"type"];
    [headDic setValue:@(4696390634531605470) forKey:@"msb"];
    [headDic setValue:@(msgCode) forKey:@"mcd"];
    
    return headDic;
}

+ (ASIHTTPRequest *)requestWithMessageCode:(NSUInteger)msgCode
                                    params:(NSMutableDictionary *)params
                             completeBlock:(PostHttpRequestCompletionBlock)completionBlock
                               failedBlock:(PostHttpRequestFailedBlock)failedBlock
{
    
//    SBJsonWriter *jsonWriter = [SBJsonWriter new];
//    NSDictionary *headDic = [self requestHeadDictionaryCreateWithMessageCode:msgCode];
//    NSString *jsonHeadString = [jsonWriter stringWithObject:headDic];
//    NSString *jsonBodyString = [jsonWriter stringWithObject:params];
//    NSDictionary *infoDic = @{@"head":jsonHeadString, @"body":jsonBodyString};
    if(!params)
    {
        params = [NSMutableDictionary new];
    }
    NSDictionary *headDic = [self requestHeadDictionaryCreateWithMessageCode:msgCode];
    [params addEntriesFromDictionary:headDic];
    
    NSLog(@"params:%@", params);
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:sServerUrlBasic]];
    //请求超时时间
    [request setTimeOutSeconds:60];
    [request setRequestMethod:sPostHttpMethodName];
    
    //POST请求
    for(NSString *key in params)
    {
        id value = [params objectForKey:key];
        if([value isKindOfClass:[NSData class]])
        {
            [request addData:value forKey:key];
        }
        else
        {
            [request addPostValue:value forKey:key];
        }
    }
    
    //设置请求完成的block
    __weak ASIFormDataRequest *requestTemp = request;
    [request setCompletionBlock:^{
        NSData *data = requestTemp.responseData;
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"str:%@", str);
//        id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//        NSError *error;
//        id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if(completionBlock != nil)
        {
            completionBlock(result);
        }
    }];
    
    //设置请求失败的block
    [request setFailedBlock:^{
        NSError *error = requestTemp.error;
        if(failedBlock != nil)
        {
            failedBlock(msgCode, error);
        }
    }];
    
    [request startAsynchronous];
    return request;
}

+ (ASIHTTPRequest *)requestGetWithMessageCode:(NSUInteger)msgCode
                                       params:(NSMutableDictionary *)params
                                completeBlock:(PostHttpRequestCompletionBlock)completionBlock
                                  failedBlock:(PostHttpRequestFailedBlock)failedBlock
{
    
    NSString *wholeURL = sServerUrlBasic;
    //GET请求
    NSMutableString *paramsString = [NSMutableString string];
    if(!params)
    {
        params = [NSMutableDictionary new];
    }
    [params setValue:@(msgCode) forKey:sMessageCodeKey];
    [params setValue:[BOAssistor deviceUDID] forKey:sDeviceUDIDKey];
    [params setValue:[TYDUserInfo sharedUserInfo].userID forKey:sUserAcountKey];
    [params setValue:@"" forKey:sDeviceIMSIKey];
    
    for(NSString *key in params)
    {
        id value = [params objectForKey:key];
        
        [paramsString appendFormat:@"%@=%@", key, value];
        if(![key isEqualToString:[[params allKeys] lastObject]])
        {
            [paramsString appendString:@"&"];
        }
    }
    if(paramsString.length > 0)
    {
        //wholeURL = [wholeURL stringByAppendingFormat:@"?%@", [paramsString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        wholeURL = [wholeURL stringByAppendingFormat:@"?%@", paramsString];
    }
    NSLog(@"-----------》》》%@",wholeURL);
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:wholeURL]];
    //请求超时时间
    [request setTimeOutSeconds:60];
    [request setRequestMethod:sGetHttpMethodName];
    
    //设置请求完成的block
    __weak ASIFormDataRequest *requestTemp = request;
    [request setCompletionBlock:^{
        NSData *data = requestTemp.responseData;
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"str:%@", str);
        //        id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        //        NSError *error;
        //        id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if(completionBlock != nil)
        {
            completionBlock(result);
        }
    }];
    
    //设置请求失败的block
    [request setFailedBlock:^{
        NSError *error = requestTemp.error;
        if(failedBlock != nil)
        {
            failedBlock(msgCode, error);
        }
    }];
    
    [request startAsynchronous];
    return request;
}

//网络连接是否有效
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

//+ (ASIHTTPRequest *)requestWithMessageCode:(NSUInteger)msgCode
//                                    params:(NSMutableDictionary *)params
//                             completeBlock:(PostHttpRequestCompletionBlock)completionBlock
//                               failedBlock:(PostHttpRequestFailedBlock)failedBlock
//{
//    if(!params)
//    {
//        params = [NSMutableDictionary new];
//    }
//    [params setValue:@(msgCode) forKey:sMessageCodeKey];
//    
//    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:sServerUrlBasic]];
//    //请求超时时间
//    [request setTimeOutSeconds:60];
//    [request setRequestMethod:sPostHttpMethodName];
//    
//    //POST请求
//    for(NSString *key in params)
//    {
//        id value = [params objectForKey:key];
//        if([value isKindOfClass:[NSData class]])
//        {
//            [request addData:value forKey:key];
//        }
//        else
//        {
//            [request addPostValue:value forKey:key];
//        }
//    }
//    
//    //设置请求完成的block
//    __weak ASIFormDataRequest *requestTemp = request;
//    [request setCompletionBlock:^{
//        NSData *data = requestTemp.responseData;
//        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSLog(@"str:%@", str);
//        //        id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//        //        NSError *error;
//        //        id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
//        id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
//        if(completionBlock != nil)
//        {
//            completionBlock(result);
//        }
//    }];
//    
//    //设置请求失败的block
//    [request setFailedBlock:^{
//        NSError *error = requestTemp.error;
//        if(failedBlock != nil)
//        {
//            failedBlock(msgCode, error);
//        }
//    }];
//    
//    [request startAsynchronous];
//    return request;
//}

//#define sPostHttpTokenKey       @"token"
//#define kRequestParamsFileData      @"dataKey"
//#define kRequestParamsFileName      @"fileNameKey"
//#define kRequestParamsFileType      @"contentTypeKey"
//#define kRequestParamsFileKey       @"file"
//+ (ASIHTTPRequest *)requestWithURL:(NSString *)url
//                            params:(NSMutableDictionary *)params
//                     completeBlock:(PostHttpRequestCompletionBlock)completionBlock
//                       failedBlock:(PostHttpRequestFailedBlock)failedBlock
//{
//    NSString *wholeURL = [sServerUrlBasic stringByAppendingFormat:@"%@", url];
//    NSLog(@"requestUrl:%@", wholeURL);
//    
//    if(!params)
//    {
//        params = [NSMutableDictionary new];
//    }
//    
//    //token注入
//    //NSString *token = [AFUserInfo sharedUser].httpToken;
//    //    if(token.length > 0)
//    //    {
//    //        [params setValue:token forKey:sPostHttpTokenKey];
//    //    }
//    
//    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:wholeURL]];
//    //请求超时时间
//    [request setTimeOutSeconds:60];
//    [request setRequestMethod:sPostHttpMethodName];
//    
//    //拆解图片音频资源
//    //    if([params objectForKey:kRequestParamsFileDicKey])
//    //    {
//    //        NSDictionary *fileDic = [params objectForKey:kRequestParamsFileDicKey];
//    //        NSString *fileName = fileDic[kRequestParamsFileName];
//    //        NSString *fileType = fileDic[kRequestParamsFileType];
//    //        NSData *fileData = fileDic[kRequestParamsFileData];
//    //        NSString *fileKey = fileDic[kRequestParamsFileKey];
//    //
//    //        [request addData:fileData withFileName:fileName andContentType:fileType forKey:fileKey];
//    //        //remove
//    //        [params removeObjectForKey:kRequestParamsFileDicKey];
//    //    }
//    
//    //POST请求
//    for(NSString *key in params)
//    {
//        id value = [params objectForKey:key];
//        if([value isKindOfClass:[NSData class]])
//        {
//            [request addData:value forKey:key];
//        }
//        else
//        {
//            [request addPostValue:value forKey:key];
//        }
//    }
//    
//    //设置请求完成的block
//    __weak ASIFormDataRequest *requestTemp = request;
//    [request setCompletionBlock:^{
//        NSData *data = requestTemp.responseData;
//        
//        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSLog(@"str:%@", str);
//        //        id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//        //        NSError *error;
//        //        id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
//        id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
//        
//        //更新token
//        //[AFUserInfo sharedUser].httpToken = [result objectForKey:sPostHttpTokenKey];
//        
//        if(completionBlock != nil)
//        {
//            completionBlock(result);
//        }
//    }];
//    
//    //设置请求失败的block
//    __block NSString *bUrl = url;
//    [request setFailedBlock:^{
//        NSError *error = requestTemp.error;
//        if(failedBlock != nil)
//        {
//            failedBlock(bUrl, error);
//        }
//    }];
//    
//    [request startAsynchronous];
//    return request;
//}

//网络连接需要附带上传图片或音频资源前，生成参数字典
//+ (NSDictionary *)fileInfoDicWithFileData:(NSData *)fileData
//                          fileContentType:(NSString *)fileContentType
//                                 fileName:(NSString *)fileName
//                                  fileKey:(NSString *)fileKey
//{
//    NSMutableDictionary *fileInfoDic = [[NSMutableDictionary alloc] initWithCapacity:4];
//    [fileInfoDic setValue:fileKey forKey:kRequestParamsFileKey];
//    [fileInfoDic setValue:fileName forKey:kRequestParamsFileName];
//    [fileInfoDic setValue:fileContentType forKey:kRequestParamsFileType];
//    [fileInfoDic setValue:fileData forKey:kRequestParamsFileData];
//    return fileInfoDic;
//}

@end
