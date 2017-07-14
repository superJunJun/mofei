//
//  TYDEnrollViewController.h
//  Mofei
//
//  Created by macMini_Dev on 14-9-22.
//  Copyright (c) 2014年 Young. All rights reserved.
//
//  用户注册
//

#import "BaseScrollController.h"

@protocol TYDEnrollViewControllerDelegate <NSObject>
@optional
- (void)enrollSucceed:(NSString *)account password:(NSString *)password;
@end

@interface TYDEnrollViewController : BaseScrollController

@property (assign, nonatomic) id<TYDEnrollViewControllerDelegate> delegate;

@end
