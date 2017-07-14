//
//  TYDWelcomeViewController.h
//  Mofei
//
//  Created by macMini_Dev on 14-10-30.
//  Copyright (c) 2014年 Young. All rights reserved.
//
//  欢迎页面，通常作为TYDStartPageViewController子页
//

#import "BaseViewController.h"

@class TYDWelcomeViewController;
@protocol TYDWelcomeViewControllerDelegate <NSObject>
@optional
- (void)welcomeViewControllerLoginButtonTap:(TYDWelcomeViewController *)viewController;
- (void)welcomeViewControllerDelayLoginButtonTap:(TYDWelcomeViewController *)viewController;
@end

@interface TYDWelcomeViewController : BaseViewController

@property (assign, nonatomic) id<TYDWelcomeViewControllerDelegate> delegate;
- (void)destroyAnimated:(BOOL)animated;

@end
