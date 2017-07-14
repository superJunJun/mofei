//
//  TYDWelcomeViewController.m
//  Mofei
//
//  Created by macMini_Dev on 14-10-30.
//  Copyright (c) 2014年 Young. All rights reserved.
//
//  欢迎页面，通常作为TYDStartPageViewController子页
//

#import "TYDWelcomeViewController.h"

@interface TYDWelcomeViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) UIPageControl *pageControl;

@end

@implementation TYDWelcomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self localDataInitialize];
    [self navigationBarItemsLoad];
    [self subviewsLoad];
}

- (void)localDataInitialize
{
    
}

- (void)navigationBarItemsLoad
{
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLayoutSubviews
{
    
}

- (void)subviewsLoad
{
    NSArray *welcomeImageNames = @[@"leadingPage_welcomePage1", @"leadingPage_welcomePage2", @"leadingPage_welcomePage3"];
    
    UIView *baseView = self.view;
    CGRect frame = baseView.bounds;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:frame];
    scrollView.backgroundColor = [UIColor colorWithHex:0xf3f3f4];
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.bounces = NO;
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    scrollView.delegate = self;
    scrollView.contentSize = CGSizeMake(scrollView.width * welcomeImageNames.count, scrollView.height);
    [baseView addSubview:scrollView];
    
    UIPageControl *pageControl = [UIPageControl new];
    pageControl.hidesForSinglePage = YES;
    pageControl.numberOfPages = welcomeImageNames.count;
    pageControl.currentPage = 0;
    pageControl.userInteractionEnabled = NO;
    pageControl.pageIndicatorTintColor = [UIColor colorWithHex:0xffffff andAlpha:0.3];
    pageControl.currentPageIndicatorTintColor = [UIColor colorWithHex:0xffffff];
    pageControl.center = baseView.innerCenter;
    pageControl.bottom = baseView.height - 20;
    pageControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [baseView addSubview:pageControl];
    
    frame = scrollView.bounds;
    CGFloat pageControlTop = pageControl.top;
    for(int i = 0; i < welcomeImageNames.count; i++)
    {
        NSString *imageName = welcomeImageNames[i];
        
        UIView *pageView = [[UIView alloc] initWithFrame:frame];
        pageView.backgroundColor = [UIColor clearColor];
        [scrollView addSubview:pageView];
        
        CGPoint center = pageView.innerCenter;
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        imageView.center = center;
        [pageView addSubview:imageView];
        
        if([welcomeImageNames lastObject] == imageName)
        {
            UIFont *buttonTitleFont = [UIFont systemFontOfSize:18];
            CGSize buttonSize = CGSizeMake(280, 40);
            UIEdgeInsets capInsets = UIEdgeInsetsMake(18, 20, 18, 20);
            UIButton *loginButton = [[UIButton alloc] initWithImageName:@"leadingPage_welcomePage_loginBtn" highlightedImageName:@"leadingPage_welcomePage_loginBtnH" capInsets:capInsets givenButtonSize:buttonSize title:@"用户登录" titleFont:buttonTitleFont titleColor:[UIColor whiteColor]];
            [loginButton addTarget:self action:@selector(loginButtonTap:) forControlEvents:UIControlEventTouchUpInside];
            loginButton.center = center;
            [pageView addSubview:loginButton];
            
            UIButton *delayLoginButton = [[UIButton alloc] initWithImageName:@"leadingPage_welcomePage_skipBtn" highlightedImageName:@"leadingPage_welcomePage_skipBtnH" capInsets:capInsets givenButtonSize:buttonSize title:@"跳过" titleFont:buttonTitleFont titleColor:[UIColor whiteColor]];
            [delayLoginButton addTarget:self action:@selector(delayLoginButtonTap:) forControlEvents:UIControlEventTouchUpInside];
            delayLoginButton.center = center;
            [pageView addSubview:delayLoginButton];
            
            CGFloat interval1 = 20;
            CGFloat interval2 = 8;
            
            delayLoginButton.bottom = pageControlTop - interval1;
            loginButton.bottom = delayLoginButton.top - interval2;
        }
        frame.origin.x += pageView.width;
    }
    
    self.pageControl = pageControl;
}

#pragma mark - Destroy

- (void)destroyAnimated:(BOOL)animated
{
    if(animated)
    {
        __weak typeof(self) wself = self;
        [UIView animateWithDuration:0.25 animations:^{
            self.view.alpha = 0;
        } completion:^(BOOL finished){
            if(finished)
            {
                [wself.view.superview sendSubviewToBack:wself.view];
                wself.pageControl = nil;
                [wself.view removeFromSuperview];
                [wself removeFromParentViewController];
            }
        }];
    }
    else
    {
        self.view.alpha = 0;
        [self.view.superview sendSubviewToBack:self.view];
        self.pageControl = nil;
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }
}

#pragma mark - TouchEvent

- (void)loginButtonTap:(UIButton *)sender
{
    NSLog(@"loginButtonTap");
    if([self.delegate respondsToSelector:@selector(welcomeViewControllerLoginButtonTap:)])
    {
        [self.delegate welcomeViewControllerLoginButtonTap:self];
    }
}

- (void)delayLoginButtonTap:(UIButton *)sender
{
    NSLog(@"delayLoginButtonTap");
    if([self.delegate respondsToSelector:@selector(welcomeViewControllerDelayLoginButtonTap:)])
    {
        [self.delegate welcomeViewControllerDelayLoginButtonTap:self];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = scrollView.contentOffset.x / scrollView.width;
    self.pageControl.currentPage = index;
}

@end
