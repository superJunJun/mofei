//
//  TYDLoginViewController.h
//  Mofei
//
//  Created by macMini_Dev on 14-9-22.
//  Copyright (c) 2014年 Young. All rights reserved.
//
//  登录页
//

#import "BaseScrollController.h"

@class WBAuthorizeResponse;
@interface TYDLoginViewController : BaseScrollController

- (void)setSinaWeiboAuthResponse:(WBAuthorizeResponse *)sinaWeiboAuthResponse;

@end
