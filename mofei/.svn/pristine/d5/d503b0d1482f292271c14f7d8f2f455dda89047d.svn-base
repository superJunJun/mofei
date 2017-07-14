//
//  TYDAppDelegate.h
//  Mofei
//
//  Created by macMini_Dev on 14-8-19.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TYDSuspendEventDelegate <NSObject>
@optional
- (void)applicationWillEnterForeground;
- (void)applicationDidBecomeActive;
@end

@interface TYDAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (assign, nonatomic) UIViewController<TYDSuspendEventDelegate> *eventDelegate;

@end
