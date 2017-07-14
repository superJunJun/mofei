//
//  TYDSportViewController.m
//  Mofei
//
//  Created by macMini_Dev on 14-8-12.
//  Copyright (c) 2014年 Young. All rights reserved.
//
//  "运动"首页
//

#import "TYDSportViewController.h"
#import "TYDDataCenter.h"
#import "TYDBLEDeviceManager.h"

#import "TYDSportRecordViewController.h"
#import "TYDHeartRateRecordViewController.h"
#import "TYDSportStatisticsViewController.h"
#import "TYDSportRankingViewController.h"
#import "TYDDeviceManageViewController.h"
#import "TYDLoginViewController.h"

#import "TYDSportCircleView.h"
#import "TYDUnitLabel.h"
#import "TYDHistogramView.h"
#import "TYDShareActionSheet.h"
#import "BOCoverlayingGuideView.h"

#define sDeviceStateNoticeInfoDeviceDidNotConnect   @"设备未连接，现在就去连接！"
#define sDeviceStateNoticeInfoDeviceLowPower        @"电量低！主人，快给我充电吧"
#define sUserSportRankingInfoInquire                @"获取用户运动排名信息，需先登录\n是否现在登录？"

@interface TYDSportViewController () <UIAlertViewDelegate, TYDShareActionSheetDelegate, TYDDataCenterRefreshedDelegate, TYDBLEDeviceManagerDeviceDisconnectDelegate>

@property (strong, nonatomic) TYDSportCircleView *circleView;

@property (strong, nonatomic) TYDUnitLabel *stepLabel;
@property (strong, nonatomic) TYDUnitLabel *distanceLabel;
@property (strong, nonatomic) TYDUnitLabel *heartRateLabel;

@property (strong, nonatomic) TYDHistogramView *sportHistogramView;
@property (strong, nonatomic) TYDHistogramView *heartRateHistogramView;

@property (strong, nonatomic) UILabel *sportRecordTimeLabel;
@property (strong, nonatomic) UILabel *heartRateRecordTimeLabel;

@property (strong, nonatomic) NSTimer *basicTimer;
//beginningOfEveryDay
@property (nonatomic, readonly) NSUInteger todayBeginningTimeStamp;
@property (nonatomic) NSUInteger dateBeginningTimeStamp;
@property (nonatomic) BOOL isSportInfoForToday;

@property (strong, nonatomic) UIView *deviceStateBar;
@property (strong, nonatomic) UILabel *deviceStateNoticeLabel;
@property (strong, nonatomic) UIView *screenShotView;

@end

@implementation TYDSportViewController
{
    BOOL _isNeedToShowGuideView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self localDataInitialize];
    [self navigationBarItemsLoad];
    [self subviewsLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"sportVc viewWillAppear");
    [super viewWillAppear:animated];
    
    [TYDBLEDeviceManager sharedBLEDeviceManager].disconnectDelegate = self;
    TYDDataCenter *dataCenter = [TYDDataCenter defaultCenter];
    dataCenter.refreshedDelegate = self;
    if(dataCenter.isDataUpdated)
    {
        dataCenter.isDataUpdated = NO;
        if(self.isSportInfoForToday)
        {
            [self timeLabelRefreshAction];
            [self dynamicValueRefreshAction];
        }
    }
    [self sportBasicTimerCreate];
    
    self.navigationBarTintColor = [UIColor colorWithHex:0xe23674];
    [[TYDShareActionSheet defaultSheet] setDelegate:self screenShotView:self.screenShotView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //self.noticeBarCenter = CGPointMake(self.view.width * 0.5, self.view.height - 48 - 40);
    self.noticeBarCenter = CGPointMake(self.view.width * 0.5, self.view.height - 40);
    
    [self guideViewLoad];
    [self deviceStateCheck];
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"sportVc viewWillDisappear");
    [super viewWillDisappear:animated];
    [self sportBasicTimerCancel];
    [TYDDataCenter defaultCenter].refreshedDelegate = nil;
    [[TYDShareActionSheet defaultSheet] setDelegate:nil screenShotView:nil];
    [TYDBLEDeviceManager sharedBLEDeviceManager].disconnectDelegate = nil;
}

- (void)localDataInitialize
{
    self.isSportInfoForToday = YES;
    self.dateBeginningTimeStamp = self.todayBeginningTimeStamp;
    
    NSString *launchedMarkKey = @"sportGuideViewAppearedMark";
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _isNeedToShowGuideView = ![userDefaults boolForKey:launchedMarkKey];
    //_isNeedToShowGuideView = YES;//Test
    if(_isNeedToShowGuideView)
    {
        [userDefaults setBool:YES forKey:launchedMarkKey];
        [userDefaults synchronize];
    }
    
    self.screenShotView = self.navigationController.view;
}

- (void)navigationBarItemsLoad
{
    self.titleText = [BOTimeStampAssistor getTimeStringWithTimeStamp:[BOTimeStampAssistor getCurrentTime] dateStyle:BOTimeStampStringFormatStyleDateShortC1 timeStyle:BOTimeStampStringFormatStyleTimeNone];
    
    UIBarButtonItem *rankingButtonItem = [BOAssistor barButtonItemCreateWithImageName:@"sport_rankingBtn" highlightedImageName:@"sport_rankingBtnH" target:self action:@selector(rankingButtonTap:)];
    UIBarButtonItem *statisticsButtonItem = [BOAssistor barButtonItemCreateWithImageName:@"sport_statisticsBtn" highlightedImageName:@"sport_statisticsBtnH" target:self action:@selector(statisticsButtonTap:)];
    self.navigationItem.rightBarButtonItems = @[statisticsButtonItem, rankingButtonItem];
}

- (void)subviewsLoad
{
    [self sportCircleViewLoad];
    [self sportRecordViewLoad];
    [self heartRateRecordViewLoad];
    [self deviceStateNoticeLabelLoad];
}

- (void)sportCircleViewLoad
{
    //sportCircleBaseView
    CGRect frame = self.baseView.bounds;
    UIView *baseView = [[UIView alloc] initWithFrame:frame];
    baseView.backgroundColor = [UIColor colorWithHex:0xe23674];
    [self.baseView addSubview:baseView];
    
    TYDSportCircleView *circleView = [TYDSportCircleView new];
    circleView.center = baseView.innerCenter;
    circleView.top = 20;
    [baseView addSubview:circleView];
    
    UIImage *shareImage = [UIImage imageNamed:@"common_shareBtn"];
    UIImage *shareImageH = [UIImage imageNamed:@"common_shareBtnH"];
    UIButton *shareButton = [[UIButton alloc] initWithImage:shareImage highlightedImage:shareImageH givenButtonSize:CGSizeMake(shareImage.size.width * 2, shareImage.size.height * 2)];
    [shareButton addTarget:self action:@selector(shareButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    CGPoint btnPosition = CGPointMake(baseView.width - 8, 8);
    shareButton.topRight = [self.baseView convertPoint:btnPosition fromView:baseView];
    [self.baseView addSubview:shareButton];
    
    UIImage *leftArrowImage = [UIImage imageNamed:@"common_leftArrowBtn"];
    UIImage *leftArrowImageH = [UIImage imageNamed:@"common_leftArrowBtnH"];
    UIButton *leftArrowButton = [[UIButton alloc] initWithImage:leftArrowImage highlightedImage:leftArrowImageH];
    [leftArrowButton addTarget:self action:@selector(leftArrowButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    btnPosition = CGPointMake(circleView.left * 0.5, circleView.yCenter);
    leftArrowButton.center = [self.baseView convertPoint:btnPosition fromView:baseView];
    [self.baseView addSubview:leftArrowButton];
    
    UIButton *rightArrowButton = [[UIButton alloc] initWithImage:leftArrowImage highlightedImage:leftArrowImageH];
    [rightArrowButton addTarget:self action:@selector(rightArrowButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    rightArrowButton.transform = CGAffineTransformMakeRotation(M_PI);
    btnPosition = CGPointMake(baseView.width - circleView.left * 0.5, leftArrowButton.yCenter);
    rightArrowButton.center = [self.baseView convertPoint:btnPosition fromView:baseView];
    [self.baseView addSubview:rightArrowButton];
    
    UIFont *numberTextFont = [UIFont fontWithName:sFontNameForRBNo2Light size:22];
    UIColor *numberTextColor = [UIColor colorWithHex:0xffffff];
    UIFont *unitTextFont = [UIFont fontWithName:@"Arial" size:12];
    UIColor *unitTextColor = [UIColor colorWithHex:0xffffff andAlpha:0.65];
    NSInteger spaceCount = 1;
    
    TYDUnitLabel *stepLabel = [[TYDUnitLabel alloc] initWithNumberText:@"98000" numberTextFont:numberTextFont numberTextColor:numberTextColor unitText:sStepBasicUnit unitTextFont:unitTextFont unitTextColor:unitTextColor alignmentType:UIViewAlignmentLeft spaceCountForInterval:spaceCount];
    TYDUnitLabel *distanceLabel = [[TYDUnitLabel alloc] initWithNumberText:@"2000" numberTextFont:numberTextFont numberTextColor:numberTextColor unitText:sDistanceKiloCommonUnit unitTextFont:unitTextFont unitTextColor:unitTextColor alignmentType:UIViewAlignmentCenter spaceCountForInterval:spaceCount];
    TYDUnitLabel *heartRateLabel = [[TYDUnitLabel alloc] initWithNumberText:@"108" numberTextFont:numberTextFont numberTextColor:numberTextColor unitText:sHeartRateBasicUnit unitTextFont:unitTextFont unitTextColor:unitTextColor alignmentType:UIViewAlignmentRight spaceCountForInterval:spaceCount];
    [baseView addSubview:stepLabel];
    [baseView addSubview:distanceLabel];
    [baseView addSubview:heartRateLabel];
    
    stepLabel.top = circleView.bottom;
    distanceLabel.bottom = stepLabel.bottom;
    heartRateLabel.bottom = stepLabel.bottom;
    
    stepLabel.left = 36;
    distanceLabel.xCenter = baseView.width * 0.5;
    heartRateLabel.right = baseView.width - 36;
    
    stepLabel.numberText = @"0";
    distanceLabel.numberText = @"0.000";
    heartRateLabel.numberText = @"0";
    
    self.circleView = circleView;
    self.stepLabel = stepLabel;
    self.distanceLabel = distanceLabel;
    self.heartRateLabel = heartRateLabel;
    
    baseView.height = stepLabel.bottom + 16;//16 pixel offset
    self.baseViewBaseHeight = baseView.bottom;
    
    //ScreenShotView
    //self.screenShotView = baseView;
}

- (void)sportRecordViewLoad
{
    CGFloat top = self.baseViewBaseHeight;
    
    //SportRecordBaseView
    CGRect frame = CGRectMake(0, top, self.baseView.width, 100);
    UIView *baseView = [[UIView alloc] initWithFrame:frame];
    baseView.backgroundColor = [UIColor clearColor];
    [self.baseView addSubview:baseView];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont systemFontOfSize:12];
    titleLabel.textColor = [UIColor colorWithHex:0x9d9d9d];
    titleLabel.text = @"运动记录";
    [titleLabel sizeToFit];
    titleLabel.origin = CGPointMake(12, 12);
    [baseView addSubview:titleLabel];
    
    UIImage *detailBtnImage = [UIImage imageNamed:@"sport_detailInfoArrowRightBtn"];
    UIButton *detailButton = [UIButton new];
    detailButton.size = CGSizeMake(40, 40);
    [detailButton setImage:detailBtnImage forState:UIControlStateNormal];
    [detailButton addTarget:self action:@selector(sportRecordDetailButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    detailButton.center = titleLabel.center;
    detailButton.right = baseView.width;
    [baseView addSubview:detailButton];
    
    //运动记录柱状图
    NSArray *levelValues = kHistogramViewStepValueLevels;
    CGSize coreViewSize = CGSizeMake(260, 180);
    CGFloat itemWith = 10;
    CGFloat itemInterval = 4;
    UIColor *textColor = [UIColor colorWithHex:0x45d8da];
    UIColor *bgColor = [UIColor colorWithHex:0xe1fcff];
    UIColor *dashLineColor = [UIColor colorWithHex:0xc9e0e3];
    UIColor *solidLineColor = [UIColor colorWithHex:0x45d8da];
    UIColor *itemColor = [UIColor colorWithHex:0x45d8da];
    
    TYDHistogramView *sportHView = [[TYDHistogramView alloc] initWithCoreViewSize:coreViewSize backgroundColor:bgColor solidLineColor:solidLineColor dashLineColor:dashLineColor valueLevelTextColor:textColor timeStampTextColor:textColor itemColor:itemColor itemWidth:itemWith itemInterval:itemInterval valueLevels:levelValues maxValueVisible:NO timeStampType:TYDHistogramTimeStampTypeHoursPerDay];
    sportHView.xCenter = baseView.innerCenter.x;
    sportHView.top = MAX(titleLabel.bottom, detailButton.bottom) + 2;
    [baseView addSubview:sportHView];
    
    UILabel *timeStampLabel = [UILabel new];
    timeStampLabel.backgroundColor = [UIColor clearColor];
    timeStampLabel.font = [UIFont systemFontOfSize:12];
    timeStampLabel.textColor = [UIColor colorWithHex:0x9d9d9d];
    timeStampLabel.text = @"12月12日 12:12";
    [timeStampLabel sizeToFit];
    timeStampLabel.text = @"";
    timeStampLabel.left = 24;
    timeStampLabel.top = sportHView.bottom + 4;
    [baseView addSubview:timeStampLabel];
    
    baseView.height = timeStampLabel.bottom;
    
    self.sportRecordTimeLabel = timeStampLabel;
    self.sportHistogramView = sportHView;
    self.baseViewBaseHeight = baseView.bottom + 12;
}

- (void)heartRateRecordViewLoad
{
    CGFloat top = self.baseViewBaseHeight + 8;
    
    //HeartRateRecordBaseView
    CGRect frame = CGRectMake(0, top, self.baseView.width, 100);
    UIView *baseView = [[UIView alloc] initWithFrame:frame];
    baseView.backgroundColor = [UIColor clearColor];
    [self.baseView addSubview:baseView];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont systemFontOfSize:12];
    titleLabel.textColor = [UIColor colorWithHex:0x9d9d9d];
    titleLabel.text = @"心率记录";
    [titleLabel sizeToFit];
    titleLabel.origin = CGPointMake(12, 12);
    [baseView addSubview:titleLabel];
    
    UIImage *detailBtnImage = [UIImage imageNamed:@"sport_detailInfoArrowRightBtn"];
    UIButton *detailButton = [UIButton new];
    detailButton.size = CGSizeMake(40, 40);
    [detailButton setImage:detailBtnImage forState:UIControlStateNormal];
    [detailButton addTarget:self action:@selector(heartRateRecordDetailButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    detailButton.center = titleLabel.center;
    detailButton.right = baseView.width;
    [baseView addSubview:detailButton];
    
    //心率记录柱状图
    NSArray *levelValues = kHistogramViewHeartRateValueLevels;
    CGSize coreViewSize = CGSizeMake(260, 160);
    CGFloat itemWith = 10;
    CGFloat itemInterval = 4;
    UIColor *textColor = [UIColor colorWithHex:0xec4762];
    UIColor *bgColor = [UIColor colorWithHex:0xfdf5fa];
    UIColor *dashLineColor = [UIColor colorWithHex:0xddd6da];
    UIColor *solidLineColor = [UIColor colorWithHex:0xff96a0];
    UIColor *itemColor = [UIColor colorWithHex:0xff96a0];
    
    TYDHistogramView *heartRateHView = [[TYDHistogramView alloc] initWithCoreViewSize:coreViewSize backgroundColor:bgColor solidLineColor:solidLineColor dashLineColor:dashLineColor valueLevelTextColor:textColor timeStampTextColor:textColor itemColor:itemColor itemWidth:itemWith itemInterval:itemInterval valueLevels:levelValues maxValueVisible:NO timeStampType:TYDHistogramTimeStampType15MinutesPerDay];
    //heartRateHView.xCenter = baseView.innerCenter.x;
    heartRateHView.top = MAX(titleLabel.bottom, detailButton.bottom) + 2;
    heartRateHView.right = self.sportHistogramView.right;
    [baseView addSubview:heartRateHView];
    
    UILabel *timeStampLabel = [UILabel new];
    timeStampLabel.backgroundColor = [UIColor clearColor];
    timeStampLabel.font = [UIFont systemFontOfSize:12];
    timeStampLabel.textColor = [UIColor colorWithHex:0x9d9d9d];
    timeStampLabel.text = @"12月12日 12:12";
    [timeStampLabel sizeToFit];
    timeStampLabel.left = 24;
    timeStampLabel.top = heartRateHView.bottom + 4;
    [baseView addSubview:timeStampLabel];
    
    baseView.height = timeStampLabel.bottom;
    
    self.heartRateHistogramView = heartRateHView;
    self.heartRateRecordTimeLabel = timeStampLabel;
    self.baseViewBaseHeight = baseView.bottom + 8;
}

- (void)deviceStateNoticeLabelLoad
{
    CGRect frame = self.view.bounds;
    frame.size.height = 40;
    
    UIControl *deviceStateBar = [[UIControl alloc] initWithFrame:frame];
    deviceStateBar.backgroundColor = [UIColor colorWithHex:0xffe99f];
    deviceStateBar.bottom = 0;
    [deviceStateBar addTarget:self action:@selector(deviceStateBarTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:deviceStateBar];
    
    frame = deviceStateBar.bounds;
    UILabel *noticeLabel = [[UILabel alloc] initWithFrame:frame];
    noticeLabel.backgroundColor = [UIColor clearColor];
    noticeLabel.font = [UIFont systemFontOfSize:14];
    noticeLabel.textAlignment = NSTextAlignmentCenter;
    noticeLabel.textColor = [UIColor colorWithHex:0x504a3c];
    [deviceStateBar addSubview:noticeLabel];
    
    UIButton *closeButton = [[UIButton alloc] initWithImage:[UIImage imageNamed:@"sport_xIcon"] highlightedImage:nil givenButtonSize:CGSizeMake(deviceStateBar.height + 16, deviceStateBar.height)];
    [closeButton addTarget:self action:@selector(deviceStateBarClose:) forControlEvents:UIControlEventTouchUpInside];
    closeButton.bottomRight = CGPointMake(noticeLabel.width, noticeLabel.height);
    [deviceStateBar addSubview:closeButton];
    
    self.deviceStateBar = deviceStateBar;
    self.deviceStateNoticeLabel = noticeLabel;
}

- (void)guideViewLoad
{
    if(_isNeedToShowGuideView)
    {
        _isNeedToShowGuideView = NO;
        
        CGPoint topRight = CGPointMake(self.view.width, 22);
        
        UIImageView *rankingGuideView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sport_funcLeading_ranking"]];
        UIImageView *statisticsGuideView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sport_funcLeading_statistics"]];
        rankingGuideView.topRight = topRight;
        statisticsGuideView.topRight = topRight;
        
        BOCoverlayingGuideView *guideView = [[BOCoverlayingGuideView alloc] initWithGuideViews:@[rankingGuideView, statisticsGuideView]];
        [guideView show];
    }
}

#pragma mark - BasicTimer

- (void)sportBasicTimerInvalidate
{
    if([self.basicTimer isValid])
    {
        [self.basicTimer invalidate];
        self.basicTimer = nil;
    }
}

- (void)sportBasicTimerCancel
{
    [self sportBasicTimerInvalidate];
}

- (void)sportBasicTimerCreate
{
    self.circleView.calorieTargetValue = [TYDUserInfo sharedUserInfo].sportTarget.unsignedIntegerValue;
    self.circleView.calorieBurnedValue = self.circleView.calorieBurnedValue;
    
    [self sportBasicTimerInvalidate];
    if(self.isSportInfoForToday)
    {
        [self sportBasicTimerEvent];
        self.basicTimer = [NSTimer scheduledTimerWithTimeInterval:nBasicTimerInterval target:self selector:@selector(sportBasicTimerEvent) userInfo:nil repeats:YES];
    }
}

- (void)sportBasicTimerEvent
{
    NSLog(@"sportBasicTimerEvent");
    if(self.isSportInfoForToday
       && self.dateBeginningTimeStamp != self.todayBeginningTimeStamp)
    {//日期变更
        self.dateBeginningTimeStamp = self.todayBeginningTimeStamp;
    }
    [self timeLabelRefreshAction];
    [self dynamicValueRefreshAction];
    //[self deviceStateCheck];
}

- (void)deviceStateCheck
{
    TYDDataCenter *dataCenter = [TYDDataCenter defaultCenter];
    if([TYDBLEDeviceManager sharedBLEDeviceManager].activePeripheralEnable)
    {
        if(dataCenter.batteryLevelCurrentValue < nDeviceBatteryLevelWarning)
        {
            [self deviceStateNoticeLabelShowWithText:sDeviceStateNoticeInfoDeviceLowPower];
        }
        else
        {
            [self deviceStateNoticeLabelHide:YES];
        }
    }
    else
    {
        [self deviceStateNoticeLabelShowWithText:sDeviceStateNoticeInfoDeviceDidNotConnect];
    }
}

- (void)dynamicValueRefreshAction
{
    TYDDataCenter *dataCenter = [TYDDataCenter defaultCenter];
    NSUInteger stepCount = dataCenter.stepCountCurrentValue;
    NSUInteger heartRate = dataCenter.heartRateCurrentValue;
    CGFloat distance = [TYDUserInfo distanceMeasuredWithHeight:[TYDUserInfo sharedUserInfo].height.floatValue andStepCount:stepCount];
    NSTimeInterval currentTime = [BOTimeStampAssistor getCurrentTime];
    
    self.stepLabel.numberText = [NSString stringWithFormat:@"%lu", (unsigned long)stepCount];
    self.heartRateLabel.numberText = [NSString stringWithFormat:@"%lu", (unsigned long)heartRate];
    self.distanceLabel.numberText = [BOAssistor distanceStringWithDistance:distance];
    
    [self.sportHistogramView refreshAllValues:[dataCenter stepCountMarkValuesDailyWithTimeStamp:currentTime] animated:YES];
    [self.heartRateHistogramView refreshAllValues:[dataCenter heartRateMarkValuesDailyWithTimeStamp:currentTime] animated:YES];
    
    CGFloat calorie = [TYDUserInfo calorieMeasuredWithWeight:[TYDUserInfo sharedUserInfo].weight.floatValue andDistance:distance];
    self.circleView.calorieTargetValue = [TYDUserInfo sharedUserInfo].sportTarget.unsignedIntegerValue;
    self.circleView.calorieBurnedValue = calorie;
}

- (void)timeLabelRefreshAction
{
    NSTimeInterval currentTime = [BOTimeStampAssistor getCurrentTime];
    NSString *timeString = [BOTimeStampAssistor getTimeStringWithTimeStamp:currentTime dateStyle:BOTimeStampStringFormatStyleDateShortC1 timeStyle:BOTimeStampStringFormatStyleTimeShort];
    self.sportRecordTimeLabel.text = timeString;
    self.heartRateRecordTimeLabel.text = timeString;
    [self titleTextReset];
}

- (void)titleTextReset
{
    NSString *currentYearString = [BOTimeStampAssistor getYearStringWithTimeStamp:[BOTimeStampAssistor getCurrentTime]];
    BOTimeStampStringFormatDateStyle dateStyle = BOTimeStampStringFormatStyleDateShortC1;
    if(![[BOTimeStampAssistor getYearStringWithTimeStamp:self.dateBeginningTimeStamp] isEqualToString:currentYearString])
    {
        dateStyle = BOTimeStampStringFormatStyleDateC;
    }
    NSString *dateString = [BOTimeStampAssistor getTimeStringWithTimeStamp:self.dateBeginningTimeStamp dateStyle:dateStyle timeStyle:BOTimeStampStringFormatStyleTimeNone];
    self.titleText = dateString;
}


#pragma mark - DeviceStateNoticeLabelEvent

- (void)deviceStateNoticeLabelShowWithText:(NSString *)text
{
    UILabel *noticeLabel = self.deviceStateNoticeLabel;
    UIView *deviceStateBar = self.deviceStateBar;
    
    noticeLabel.text = text;
    if([text isEqualToString:sDeviceStateNoticeInfoDeviceLowPower])
    {
        noticeLabel.textColor = [UIColor colorWithHex:0xe00d0d];
    }
    else//sDeviceStateNoticeInfoDeviceDidNotConnect
    {
        noticeLabel.textColor = [UIColor colorWithHex:0x504a3c];
    }
    if(deviceStateBar.bottom == 0)
    {
        UIView *scrollView = self.scrollView;
        CGRect scrollViewFrame = scrollView.frame;
        scrollViewFrame.origin.y = deviceStateBar.height;
        scrollViewFrame.size.height -= deviceStateBar.height;
        
        [UIView animateWithDuration:0.25
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             deviceStateBar.top = 0;
                             scrollView.frame = scrollViewFrame;
                         }
                         completion:nil];
    }
}

- (void)deviceStateNoticeLabelHide:(BOOL)animated
{
    UIView *deviceStateBar = self.deviceStateBar;
    if(deviceStateBar.top == 0)
    {
        UIView *scrollView = self.scrollView;
        CGRect scrollViewFrame = self.view.bounds;
        if(animated)
        {
            [UIView animateWithDuration:0.25 animations:^{
                deviceStateBar.bottom = 0;
                scrollView.frame = scrollViewFrame;
            }];
        }
        else
        {
            deviceStateBar.bottom = 0;
            scrollView.frame = scrollViewFrame;
        }
    }
}

#pragma mark - TouchEvent

- (void)deviceStateBarTap:(id)sender
{
    [self deviceStateNoticeLabelHide:NO];
    TYDDeviceManageViewController *vc = [TYDDeviceManageViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)deviceStateBarClose:(id)sender
{
    [self deviceStateNoticeLabelHide:YES];
}

- (void)statisticsButtonTap:(UIButton *)sender
{
    NSLog(@"statisticsButtonTap");
    TYDSportStatisticsViewController *vc = [TYDSportStatisticsViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)rankingButtonTap:(UIButton *)sender
{
    NSLog(@"rankingButtonTap");
    if([TYDUserInfo sharedUserInfo].isUserAccountEnable)
    {
        TYDSportRankingViewController *vc = [TYDSportRankingViewController new];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:sUserSportRankingInfoInquire delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    }
}

- (void)shareButtonTap:(UIButton *)sender
{
    NSLog(@"shareButtonTap");
    [[TYDShareActionSheet defaultSheet] actionSheetShow];
}

- (void)leftArrowButtonTap:(UIButton *)sender
{
    NSLog(@"leftArrowButtonTap");
    [self timeStampOfDateForSportInfoChanged:NO];
}

- (void)rightArrowButtonTap:(UIButton *)sender
{
    NSLog(@"rightArrowButtonTap");
    [self timeStampOfDateForSportInfoChanged:YES];
}

- (void)sportRecordDetailButtonTap:(UIButton *)sender
{
    NSLog(@"sportRecordDetailButtonTap");
    TYDSportRecordViewController *vc = [TYDSportRecordViewController new];
    vc.dateBeginningTimeStamp = self.dateBeginningTimeStamp;
    vc.isRecordInfoForToday = self.isSportInfoForToday;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)heartRateRecordDetailButtonTap:(UIButton *)sender
{
    NSLog(@"heartRateRecordDetailButtonTap");
    TYDHeartRateRecordViewController *vc = [TYDHeartRateRecordViewController new];
    vc.dateBeginningTimeStamp = self.dateBeginningTimeStamp;
    vc.isRecordInfoForToday = self.isSportInfoForToday;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == alertView.firstOtherButtonIndex)
    {
        if([alertView.message isEqualToString:sUserSportRankingInfoInquire])
        {
            TYDLoginViewController *vc = [TYDLoginViewController new];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

#pragma mark - SportInfoDateChange

- (NSUInteger)todayBeginningTimeStamp
{
    return [BOTimeStampAssistor timeStampOfDayBeginningForToday];
}

- (void)timeStampOfDateForSportInfoChanged:(BOOL)isIncreased
{
    NSUInteger newTimeStamp = self.dateBeginningTimeStamp;
    NSUInteger minTimeStamp = [TYDDataCenter defaultCenter].firstInfoItemSavedDateTimeStamp;
    
    if(isIncreased)
    {
        newTimeStamp += nTimeIntervalSecondsPerDay;
        if(newTimeStamp > self.todayBeginningTimeStamp)
        {
            [self setNoticeText:@"明天很快就到了"];
            return;
        }
    }
    else
    {
        newTimeStamp -= nTimeIntervalSecondsPerDay;
        if(newTimeStamp < minTimeStamp)
        {
            [self setNoticeText:@"前面没有了"];
            return;
        }
    }
    
    self.dateBeginningTimeStamp = newTimeStamp;
    if(newTimeStamp == self.todayBeginningTimeStamp)
    {
        self.isSportInfoForToday = YES;
        [self sportBasicTimerCreate];
        return;
    }
    
    self.isSportInfoForToday = NO;
    [self sportBasicTimerCancel];
    NSString *timeString = [BOTimeStampAssistor getTimeStringWithTimeStamp:newTimeStamp dateStyle:BOTimeStampStringFormatStyleDateShortC1 timeStyle:BOTimeStampStringFormatStyleTimeNone];
    self.sportRecordTimeLabel.text = timeString;
    self.heartRateRecordTimeLabel.text = timeString;
    [self titleTextReset];
    
    TYDDataCenter *dataCenter = [TYDDataCenter defaultCenter];
    NSArray *stepCountArray = [dataCenter stepCountMarkValuesDailyWithTimeStamp:newTimeStamp];
    NSArray *heartRateArray = [dataCenter heartRateMarkValuesDailyWithTimeStamp:newTimeStamp];
    [self.sportHistogramView refreshAllValues:stepCountArray animated:YES];
    [self.heartRateHistogramView refreshAllValues:heartRateArray animated:YES];
    
    NSUInteger stepCount = 0;
    NSUInteger heartRate = 0;
    for(NSNumber *stepValueNumber in stepCountArray)
    {
        stepCount += stepValueNumber.unsignedIntegerValue;
    }
    NSUInteger heartRateSum = 0;
    NSUInteger heartRateCount = 0;
    for(NSNumber *heartRateNumber in heartRateArray)
    {
        NSUInteger hrValue = heartRateNumber.unsignedIntegerValue;
        if(hrValue > 0)
        {
            heartRateSum += hrValue;
            heartRateCount++;
        }
    }
    if(heartRateCount > 0)
    {
        heartRate = heartRateSum / heartRateCount;
    }
    
    CGFloat distance = [TYDUserInfo distanceMeasuredWithHeight:[TYDUserInfo sharedUserInfo].height.floatValue andStepCount:stepCount];
    
    self.stepLabel.numberText = [NSString stringWithFormat:@"%lu", (unsigned long)stepCount];
    self.heartRateLabel.numberText = [NSString stringWithFormat:@"%lu", (unsigned long)heartRate];
    self.distanceLabel.numberText = [BOAssistor distanceStringWithDistance:distance];
    
    CGFloat calorie = [TYDUserInfo calorieMeasuredWithWeight:[TYDUserInfo sharedUserInfo].weight.floatValue andDistance:distance];
    self.circleView.calorieTargetValue = [TYDUserInfo sharedUserInfo].sportTarget.unsignedIntegerValue;
    self.circleView.calorieBurnedValue = calorie;
}

#pragma mark - TYDShareActionSheetDelegate

- (void)screenShotImageSaveToAlbumComplete:(BOOL)succeed
{
    NSString *text = @"图片已保存";
    if(!succeed)
    {
        text = @"图片保存失败";
    }
    [self setNoticeText:text];
}

#pragma mark - TYDDataCenterRefreshedDelegate

- (void)dataCenterSavedInfosRefreshed:(TYDDataCenter *)dataCenter
{
    NSLog(@"dataCenterSavedInfosRefreshed");
    [TYDDataCenter defaultCenter].isDataUpdated = NO;
    if(self.isSportInfoForToday)
    {
        [self sportBasicTimerCancel];
        [self timeLabelRefreshAction];
        [self dynamicValueRefreshAction];
        [self sportBasicTimerCreate];
    }
}

#pragma mark - TYDSuspendEventDelegate

- (void)applicationWillResignActive
{
    [self sportBasicTimerCancel];
}

- (void)applicationDidBecomeActive
{
    [self sportBasicTimerCreate];
    [self deviceStateCheck];
}

#pragma mark - MenmoryWaring

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"MenmoryWaring");
}

#pragma mark - TYDBLEDeviceManagerDeviceDisconnectDelegate

- (void)centralManagerDisconnectPeripheral:(CBPeripheral *)peripheral
{
    [self deviceStateCheck];
}

@end
