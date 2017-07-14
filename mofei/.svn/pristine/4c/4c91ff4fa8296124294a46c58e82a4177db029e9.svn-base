//
//  TYDAppDelegate.m
//  Mofei
//
//  Created by macMini_Dev on 14-8-19.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import "TYDAppDelegate.h"
#import "TYDDataCenter.h"
#import "TYDLoginViewController.h"

#import "OpenPlatformAppRegInfo.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "WeiboSDK.h"
#import "WXApi.h"

@interface TYDAppDelegate () <WeiboSDKDelegate, WXApiDelegate>

@property (strong, nonatomic) NSString *sinaWeiboToken;
@property (strong, nonatomic) NSString *noticeText;

@end

@implementation TYDAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if([[UITextField appearance] respondsToSelector:@selector(tintColor)])
    {
        [UITextView appearance].tintColor = [UIColor colorWithHex:0xe23674];
    }
    //application.idleTimerDisabled = YES;
    
    NSLog(@"applicationDidFinishLaunching");
    [WeiboSDK enableDebugMode:YES];
    if(![WeiboSDK registerApp:sShareSDKSinaWeiboAppKey])
    {
        NSLog(@"微博注册失败");
    }
    
    //if(![WXApi registerApp:sShareSDKWeChatAppId])
    if(![WXApi registerApp:sShareSDKWeChatAppId withDescription:@"默菲"])
    {
        NSLog(@"微信注册失败");
    }
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"applicationWillResignActive");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"---applicationDidEnterBackground");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"applicationWillEnterForeground");
    if([self.eventDelegate respondsToSelector:@selector(applicationWillEnterForeground)])
    {
        [self.eventDelegate applicationWillEnterForeground];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"---applicationDidBecomeActive");
    if([self.eventDelegate respondsToSelector:@selector(applicationDidBecomeActive)])
    {
        [self.eventDelegate applicationDidBecomeActive];
        
        if(self.noticeText.length > 0
           && [self.eventDelegate respondsToSelector:@selector(setNoticeText:)])
        {
            [self.eventDelegate performSelector:@selector(setNoticeText:) withObject:self.noticeText];
            self.noticeText = nil;
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[TYDDataCenter defaultCenter] globalTimerCancel];
    NSLog(@"applicationWillTerminate");
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSLog(@"sourceApplication:%@", sourceApplication);

//    if([sourceApplication isEqualToString:sQQBundleIdentifier])
//    {
//        return [TencentOAuth HandleOpenURL:url];
//    }
//    else if([sourceApplication isEqualToString:sSinaWeiboBundleIdentifier])
//    {
//        return [WeiboSDK handleOpenURL:url delegate:self];
//    }
//    else if([sourceApplication isEqualToString:sWeChatBundleIdentifier])
//    {
//        return [WXApi handleOpenURL:url delegate:self];
//    }
//    
//    return NO;
    
    return ([WXApi handleOpenURL:url delegate:self] || [TencentOAuth HandleOpenURL:url] || [WeiboSDK handleOpenURL:url delegate:self]);
}

#pragma mark - WeiboSDKDelegate

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    if([request isKindOfClass:WBProvideMessageForWeiboRequest.class])
    {
        
    }
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if([response isKindOfClass:WBSendMessageToWeiboResponse.class])
    {
        NSString *sinaWeiboShareResultInfo = nil;
        NSInteger statusCode = response.statusCode;
        if(statusCode == WeiboSDKResponseStatusCodeSuccess)
        {
            sinaWeiboShareResultInfo = @"微博分享成功";
        }
        else if(statusCode == WeiboSDKResponseStatusCodeSentFail)
        {
            sinaWeiboShareResultInfo = @"微博分享发送失败";
        }
        else if(statusCode == WeiboSDKResponseStatusCodeUserCancel)
        {
            sinaWeiboShareResultInfo = @"微博分享被取消";
        }
        else
        {
            sinaWeiboShareResultInfo = @"微博分享失败";
        }
        if([self.eventDelegate respondsToSelector:@selector(setNoticeText:)])
        {
            [self.eventDelegate performSelector:@selector(setNoticeText:) withObject:sinaWeiboShareResultInfo afterDelay:0.25];
        }
    }
    else if([response isKindOfClass:WBAuthorizeResponse.class])
    {
        if([self.eventDelegate respondsToSelector:@selector(setSinaWeiboAuthResponse:)])
        {
            [self.eventDelegate performSelector:@selector(setSinaWeiboAuthResponse:) withObject:response];
        }
    }
}

#pragma mark - WXApiDelegate

/*! @brief 收到一个来自微信的请求，第三方应用程序处理完后调用sendResp向微信发送结果
 *
 * 收到一个来自微信的请求，异步处理完成后必须调用sendResp发送处理结果给微信。
 * 可能收到的请求有GetMessageFromWXReq、ShowMessageFromWXReq等。
 * @param req 具体请求内容，是自动释放的
 */
- (void)onReq:(BaseReq *)req
{
    NSLog(@"onReq:%@", req);
}

/*! @brief 发送一个sendReq后，收到微信的回应
 *
 * 收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。
 * 可能收到的处理结果有SendMessageToWXResp、SendAuthResp等。
 * @param resp具体的回应内容，是自动释放的
 */
- (void)onResp:(BaseResp *)resp
{
    NSLog(@"onResp:%@", resp);
    NSString *weChatShareResultInfo = nil;
    if(resp.errCode == WXSuccess)
    {
        weChatShareResultInfo = @"微信分享成功";
        NSLog(@"WX Share Succeed");
    }
    else if(resp.errCode == WXErrCodeUserCancel)
    {
        weChatShareResultInfo = @"微信分享被取消";
        NSLog(@"WX Share Cancel");
    }
    else
    {
        weChatShareResultInfo = @"微信分享失败";
        NSLog(@"WX Share Failed");
    }
    
    self.noticeText = weChatShareResultInfo;
}

@end
