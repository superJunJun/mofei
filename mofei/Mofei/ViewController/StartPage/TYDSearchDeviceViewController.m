//
//  TYDSearchDeviceViewController.m
//  Mofei
//
//  Created by caiyajie on 15-1-4.
//  Copyright (c) 2015年 Young. All rights reserved.
//

#import "TYDSearchDeviceViewController.h"
#import "TYDDeviceManageViewController.h"
#import "TYDDeviceHelpViewController.h"

@interface TYDSearchDeviceViewController ()

@property (strong, nonatomic) UIView *circleView;

@end

@implementation TYDSearchDeviceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithHex:0x2acacc];
    [self loadSubViews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self circleViewRotateAnimationStart];
}

- (void)circleViewRotateAnimationEnd
{
    [self.circleView.layer removeAllAnimations];
}

- (void)circleViewRotateAnimationStart
{
    [self circleViewRotateAnimationEnd];
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2.0 ];
    rotationAnimation.duration = 1.0f;//控制旋转快慢
    rotationAnimation.repeatCount =FLT_MAX;//控制旋转次数
    [self.circleView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)loadSubViews
{
    CGRect frame = self.view.bounds;
    UIView *bottomBaseView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.center.y+76.5,frame.size.width ,(frame.size.height-(self.view.center.y+76.5)))];
    [self.view addSubview:bottomBaseView];
    CGFloat  baseHeight = bottomBaseView.height/22.0;
    UIEdgeInsets capInsets = UIEdgeInsetsMake(19, 20, 19, 20);
    UIButton *searchDeviece = [[UIButton alloc] initWithImageName:@"startPage_searchDeviceButtonN" highlightedImageName:@"startPage_searchDeviceButtonP" capInsets:capInsets givenButtonSize:CGSizeMake(280, 4*baseHeight) title:@"搜索设备" titleFont:[UIFont fontWithName:@"Arial" size:18] titleColor:[UIColor colorWithHex:0xfeffff]];
    searchDeviece.center = CGPointMake(self.view.center.x, baseHeight*9);
    [searchDeviece addTarget:self action:@selector(searchDeviceButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [bottomBaseView addSubview:searchDeviece];
    
    UIButton *getHelp = [[UIButton alloc] initWithImageName:@"startPage_searchDeviceButtonN" highlightedImageName:@"startPage_searchDeviceButtonP" capInsets:capInsets givenButtonSize:CGSizeMake(280, 4*baseHeight) title:@"连接不上设备？" titleFont:[UIFont fontWithName:@"Arial" size:18] titleColor:[UIColor colorWithHex:0xfeffff]];
    getHelp.xCenter =self.view.xCenter;
    getHelp.top = searchDeviece.bottom + baseHeight;
    [bottomBaseView addSubview:getHelp];
    [getHelp addTarget:self action:@selector(getHelpButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *bottomLabel = [UILabel new];
    bottomLabel.backgroundColor = [UIColor clearColor];
    bottomLabel.textAlignment = NSTextAlignmentCenter;
    bottomLabel.textColor = [UIColor colorWithHex:0xb8feff];
    bottomLabel.font = [UIFont fontWithName:@"Arial" size:10];
    bottomLabel.text = @"先不绑定?";
    [bottomLabel sizeToFit];
    bottomLabel.width = 280;
    bottomLabel.height += 12;
    bottomLabel.xCenter = self.view.xCenter;
    bottomLabel.top = getHelp.bottom + baseHeight;
    [bottomBaseView addSubview:bottomLabel];
    UITapGestureRecognizer *delayBindTapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(delayBind:)];
    [bottomLabel addGestureRecognizer:delayBindTapGr];
    bottomLabel.userInteractionEnabled = YES;
    
    UIImageView *circleView = [UIImageView new];
    circleView.size = CGSizeMake(153,153);
    circleView.image= [UIImage imageNamed:@"startPage_searchDeviceCircle"];
    circleView.center = self.view.center;
    circleView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:circleView];
    
    UIImageView *shellView = [UIImageView new];
    shellView.size = CGSizeMake(69.5,61);
    shellView.center = self.view.center;
    shellView.image = [UIImage imageNamed:@"startPage_searchDeviceShell"];
    shellView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:shellView];
    
    UIView *titleBaseView = [[UIView alloc]initWithFrame:self.view.bounds];
    titleBaseView.height  = self.view.height - bottomBaseView.height-153;
    [self.view addSubview:titleBaseView];
    
    CGFloat titleBaseHeight = titleBaseView.height / 19.0;
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont fontWithName:@"Arial" size:24];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = @"搜索Venus";
    [titleLabel sizeToFit];
    titleLabel.center = self.view.innerCenter;
    titleLabel.bottom = titleBaseView.height - 8 * titleBaseHeight;
    [self.view addSubview:titleLabel];
    
    UILabel *detailLabel = [UILabel new];
    detailLabel.backgroundColor = [UIColor clearColor];
    detailLabel.font = [UIFont fontWithName:@"Arial" size:10];
    detailLabel.textColor = [UIColor colorWithHex:0x9bfcfd];
    detailLabel.text = @"请将设备靠近手机";
    [detailLabel sizeToFit];
    detailLabel.center = titleLabel.center;
    detailLabel.top = titleLabel.bottom + 4;
    [titleBaseView addSubview:detailLabel];
    
    self.circleView = circleView;
}

#pragma mark - TouchEvent

- (void)searchDeviceButtonAction
{
    NSLog(@"searchDevice");
    TYDDeviceManageViewController *vc = [TYDDeviceManageViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)getHelpButtonAction
{
    TYDDeviceHelpViewController * vc = [TYDDeviceHelpViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)delayBind:(UIGestureRecognizer *)sender
{
    NSLog(@"delayBind");
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TYDSuspendEventDelegate

- (void)applicationWillEnterForeground
{
    [self circleViewRotateAnimationEnd];
}

- (void)applicationDidBecomeActive
{
    [self circleViewRotateAnimationStart];
}

@end
