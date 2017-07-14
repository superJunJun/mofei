//
//  BaseNavigationController.m
//  Mofei
//
//  Created by macMini_Dev on 14-8-28.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import "BaseNavigationController.h"

@interface BaseNavigationController ()

@end

@implementation BaseNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationBar.translucent = NO;
    
    UIColor *tintColor = [UIColor colorWithHex:0xe23674];
    self.navigationBar.tintColor = tintColor;
    if([self.navigationBar respondsToSelector:@selector(barTintColor)])
    {
        self.navigationBar.barTintColor = tintColor;
    }
    
    UIFont *titleTextFont = [UIFont boldSystemFontOfSize:20];
    self.navigationBar.titleTextAttributes = @{NSFontAttributeName:titleTextFont};
}

#pragma mark - Push

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    viewController.hidesBottomBarWhenPushed = YES;
    [super pushViewController:viewController animated:animated];
}

@end



