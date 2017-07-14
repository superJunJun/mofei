//
//  TYDSportStatisticsViewController.m
//  Mofei
//
//  Created by macMini_Dev on 14-9-5.
//  Copyright (c) 2014年 Young. All rights reserved.
//
//  运动统计，末端页面
//

#import "TYDSportStatisticsViewController.h"
#import "TYDSimpleHistogramView.h"
#import "TYDShareActionSheet.h"
#import "TYDUnitLabel.h"
#import "TYDDataCenter.h"
#import "TYDHeartRateRecordInfo.h"
#import "TYDStepRecordInfo.h"

#define nLocalInfoItemTitleLableTag         500
#define nLocalInfoItemUnitLabelTag          501
#define sShowWeeklyStatisticsInfoTitle      @"查看周统计 >>"
#define sShowMonthlyStatisticsInfoTitle     @"查看月统计 >>"
#define nStepMaxPerDay                      50000

@interface TYDSportStatisticsViewController () <TYDShareActionSheetDelegate, TYDDataCenterSaveEventDelegate>

@property (strong, nonatomic) UIView *titleBar;
@property (strong, nonatomic) UILabel *changeLabel;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *baseView;
@property (strong, nonatomic) UIView *infoView;
@property (strong, nonatomic) TYDSimpleHistogramView *weeklyHView;
@property (strong, nonatomic) TYDSimpleHistogramView *monthlyHView;
@property (strong, nonatomic) NSArray *infoUnitLabels;

@property (strong, nonatomic) UILabel *heartRateTitleLabel;
@property (strong, nonatomic) UIView *screenShotView;

@property (nonatomic) BOOL isWeeklyInfoShowed;
@property (strong, nonatomic) NSTimer *basicTimer;

@property (strong, nonatomic) NSMutableArray *weeklyStepMarkValues;
@property (strong, nonatomic) NSMutableArray *monthlyStepMarkValues;

@end

@implementation TYDSportStatisticsViewController
{
    BOOL _weeklyInfoInitialized;
    NSUInteger _weeklyBeginningTimeStamp;
    NSUInteger _weeklyEndTimeStamp;
    NSUInteger _weeklyHeartRateSum;
    NSUInteger _weeklyHeartRateCount;
    NSUInteger _weeklyHeartRateMax;
    NSUInteger _weeklyHeartRateMin;
    NSUInteger _weeklyStepSum;
    NSUInteger _weeklyDays;
    
    BOOL _monthlyInfoInitialized;
    NSUInteger _monthlyBeginningTimeStamp;
    NSUInteger _monthlyEndTimeStamp;
    NSUInteger _monthlyHeartRateSum;
    NSUInteger _monthlyHeartRateCount;
    NSUInteger _monthlyHeartRateMax;
    NSUInteger _monthlyHeartRateMin;
    NSUInteger _monthlyStepSum;
    NSUInteger _monthlyDays;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self localDataInitialize];
    [self navigationBarItemsLoad];
    [self subviewsLoad];
    [self infoInitializeStateCheck];
    [self titleTextReset];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [TYDDataCenter defaultCenter].saveEventDelegate = self;
    [self sportStatisticsBasicTimerCreate];
    [[TYDShareActionSheet defaultSheet] setDelegate:self screenShotView:self.screenShotView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self infoInitializeStateCheck];
    [self titleTextReset];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [TYDDataCenter defaultCenter].saveEventDelegate = nil;
    [self sportStatisticsBasicTimerCancel];
    [[TYDShareActionSheet defaultSheet] setDelegate:nil screenShotView:nil];
    
    [self titleTextFontReset];
}

- (void)titleTextFontReset
{
    UIFont *titleTextFont = [UIFont boldSystemFontOfSize:20];
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:titleTextFont};
}

- (void)localDataInitialize
{
    _isWeeklyInfoShowed = YES;
    _weeklyInfoInitialized = NO;
    _monthlyInfoInitialized = NO;
    
    NSTimeInterval currentTime = [BOTimeStampAssistor getCurrentTime];
    _weeklyBeginningTimeStamp = [BOTimeStampAssistor timeStampOfWeekBeginningWithTimerStamp:currentTime];
    _weeklyEndTimeStamp = [BOTimeStampAssistor timeStampOfWeekEndWithTimerStamp:currentTime];
    _weeklyHeartRateSum = 0;
    _weeklyHeartRateCount = 0;
    _weeklyHeartRateMax = 0;
    _weeklyHeartRateMin = 0;
    _weeklyStepSum = 0;
    _weeklyDays = 7;
    
    _monthlyBeginningTimeStamp = [BOTimeStampAssistor timeStampOfMonthBeginningWithTimerStamp:currentTime];
    _monthlyEndTimeStamp = [BOTimeStampAssistor timeStampOfMonthEndWithTimerStamp:currentTime];
    _monthlyHeartRateSum = 0;
    _monthlyHeartRateCount = 0;
    _monthlyHeartRateMax = 0;
    _monthlyHeartRateMin = 0;
    _monthlyStepSum = 0;
    _monthlyDays = 31;
}

- (void)navigationBarItemsLoad
{
    UIBarButtonItem *shareButtonItem = [BOAssistor barButtonItemCreateWithImageName:@"common_naviShareBtn" highlightedImageName:nil target:self action:@selector(shareButtonTap:)];
    self.navigationItem.rightBarButtonItem = shareButtonItem;
}

- (void)subviewsLoad
{
    [self titleBarLoad];
    [self scrollViewLoad];
    [self histogramViewLoad];
    [self infoViewLoad];
    
    self.screenShotView = self.navigationController.view;
}

- (void)titleBarLoad
{
    CGRect frame = self.view.bounds;
    frame.size.height = 36;
    UIView *titleBar = [[UIView alloc] initWithFrame:frame];
    titleBar.backgroundColor = [UIColor colorWithHex:0xededf1];
    [self.view addSubview:titleBar];
    
    UILabel *changeLabel = [UILabel new];
    changeLabel.backgroundColor = [UIColor clearColor];
    changeLabel.font = [UIFont fontWithName:@"Arial" size:16];
    changeLabel.textColor = [UIColor colorWithHex:0xe23674];
    changeLabel.text = [self getChangeLabelText];
    [changeLabel sizeToFit];
    changeLabel.height = titleBar.height;
    changeLabel.topRight = titleBar.topRight;
    [self.view addSubview:changeLabel];
    
    changeLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeLabelTap:)];
    [changeLabel addGestureRecognizer:tapGr];
    
    self.titleBar = titleBar;
    self.changeLabel = changeLabel;
}

- (void)scrollViewLoad
{
    CGRect frame = CGRectMake(0, self.titleBar.bottom, self.view.width, self.view.height - self.titleBar.height);
    UIColor *backgroundColor = [UIColor colorWithHex:0xfcfcff];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:frame];
    scrollView.backgroundColor = backgroundColor;
    scrollView.contentSize = frame.size;
    scrollView.pagingEnabled = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollEnabled = YES;
    scrollView.bounces = YES;
    scrollView.autoresizesSubviews = NO;
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight;
    scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:scrollView];
    
    UIView *baseView = [[UIView alloc] initWithFrame:scrollView.bounds];
    baseView.backgroundColor = backgroundColor;
    [scrollView addSubview:baseView];
    
    self.scrollView = scrollView;
    self.baseView = baseView;
}

- (void)histogramViewLoad
{
    UIView *baseView = self.baseView;
    
    UIView *hViewBaseView = [[UIView alloc] initWithFrame:baseView.bounds];
    hViewBaseView.backgroundColor = [UIColor clearColor];
    [baseView addSubview:hViewBaseView];
    
    CGSize hViewSize = CGSizeMake(240, 140);
    UIColor *itemColor = [UIColor colorWithHex:0xf3b8d0];
    UIColor *timeStampTextColor = [UIColor colorWithHex:0xe23674];
    UIColor *maxValueColor = [UIColor colorWithHex:0xe23674];
    UIFont *maxValueFont = [UIFont fontWithName:@"Arial" size:14];
    UIFont *timeStampTextFont = [UIFont systemFontOfSize:15];
    NSUInteger valueLevelMax = nStepMaxPerDay;
    CGFloat scale = 2.4;
    CGFloat top = 12;
    
    TYDSimpleHistogramView *weeklyHView = [[TYDSimpleHistogramView alloc] initWithCoreViewSize:hViewSize scale:scale itemColor:itemColor timeStampTextColor:timeStampTextColor timeStampTextFont:timeStampTextFont maxValueTextColor:maxValueColor maxValueTextFont:maxValueFont maxValueVisible:YES valueLevelMax:valueLevelMax type:TYDSimpleHistogramTypeDaysPerWeek];
    weeklyHView.center = hViewBaseView.innerCenter;
    weeklyHView.top = top;
    [hViewBaseView addSubview:weeklyHView];
    
    timeStampTextFont = [UIFont systemFontOfSize:12];
    maxValueFont = [UIFont fontWithName:@"Arial" size:12];
    TYDSimpleHistogramView *monthlyHView = [[TYDSimpleHistogramView alloc] initWithCoreViewSize:hViewSize scale:scale itemColor:itemColor timeStampTextColor:timeStampTextColor timeStampTextFont:timeStampTextFont maxValueTextColor:maxValueColor maxValueTextFont:maxValueFont maxValueVisible:YES valueLevelMax:valueLevelMax type:TYDSimpleHistogramTypeDaysPerMonth];
    monthlyHView.center = hViewBaseView.innerCenter;
    monthlyHView.top = top;
    [hViewBaseView addSubview:monthlyHView];
    
    monthlyHView.height = weeklyHView.height;
    weeklyHView.backgroundColor = [UIColor colorWithHex:0xfcfcff];
    monthlyHView.backgroundColor = [UIColor colorWithHex:0xfcfcff];
    [hViewBaseView bringSubviewToFront:weeklyHView];
    
    UIImage *leftArrowImage = [UIImage imageNamed:@"sport_leftArrowBtn"];
    UIImage *leftArrowImageH = [UIImage imageNamed:@"sport_leftArrowBtnH"];
    UIButton *leftArrowButton = [UIButton new];
    leftArrowButton.size = leftArrowImage.size;
    [leftArrowButton setImage:leftArrowImage forState:UIControlStateNormal];
    [leftArrowButton setImage:leftArrowImageH forState:UIControlStateHighlighted];
    [leftArrowButton addTarget:self action:@selector(leftArrowButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    leftArrowButton.center = CGPointMake(weeklyHView.left * 0.5, weeklyHView.yCenter);
    [hViewBaseView addSubview:leftArrowButton];
    
    UIButton *rightArrowButton = [UIButton new];
    rightArrowButton.size = leftArrowImage.size;
    [rightArrowButton setImage:leftArrowImage forState:UIControlStateNormal];
    [rightArrowButton setImage:leftArrowImageH forState:UIControlStateHighlighted];
    [rightArrowButton addTarget:self action:@selector(rightArrowButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    rightArrowButton.transform = CGAffineTransformMakeRotation(M_PI);
    rightArrowButton.center = CGPointMake(baseView.width - weeklyHView.left * 0.5, weeklyHView.yCenter);
    [hViewBaseView addSubview:rightArrowButton];
    
    hViewBaseView.height = weeklyHView.bottom + 12;
    baseView.height = hViewBaseView.bottom;
    
    self.weeklyHView = weeklyHView;
    self.monthlyHView = monthlyHView;
}

- (void)infoViewLoad
{
    UIScrollView *scrollView = self.scrollView;
    UIView *baseView = self.baseView;
    CGFloat top = baseView.bottom;
    
    CGRect frame = CGRectMake(0, top, baseView.width, 6);
    UIView *separatarBar = [[UIView alloc] initWithFrame:frame];
    separatarBar.backgroundColor = [UIColor colorWithHex:0xededf1];
    [baseView addSubview:separatarBar];
    
    CGSize itemSize = CGSizeMake(baseView.width * 0.5, 62);
    UIColor *blueNumberColor = [UIColor colorWithHex:0x5c5c5c];
    UIView *stepTotalItem = [self recordItemViewCreateWithSize:itemSize title:@"已走步数" numberColor:blueNumberColor numberText:@"0" unitText:sStepBasicUnit];
    UIView *stepPerDayItem = [self recordItemViewCreateWithSize:itemSize title:@"平均每天" numberColor:blueNumberColor numberText:@"0" unitText:sStepBasicUnit];
    UIView *calorieItem = [self recordItemViewCreateWithSize:itemSize title:@"累计消耗" numberColor:blueNumberColor numberText:@"0" unitText:sCalorieBasicShortUnit];
    UIView *distanceItem = [self recordItemViewCreateWithSize:itemSize title:@"已走里程" numberColor:blueNumberColor numberText:@"0" unitText:sDistanceKiloCommonUnit];
    stepTotalItem.origin = CGPointMake(0, separatarBar.bottom);
    stepPerDayItem.origin = stepTotalItem.topRight;
    calorieItem.origin = stepTotalItem.bottomLeft;
    distanceItem.origin = stepTotalItem.bottomRight;
    [baseView addSubview:stepTotalItem];
    [baseView addSubview:stepPerDayItem];
    [baseView addSubview:calorieItem];
    [baseView addSubview:distanceItem];
    
    //heartRate
    frame = CGRectMake(0, distanceItem.bottom, baseView.width, 6);
    separatarBar = [[UIView alloc] initWithFrame:frame];
    separatarBar.backgroundColor = [UIColor colorWithHex:0xededf1];
    [baseView addSubview:separatarBar];
    
    UIColor *redNumberColor = [UIColor colorWithHex:0x5c5c5c];
    UIView *heartRateItem = [self recordItemViewCreateWithSize:itemSize title:@"当前心率" numberColor:redNumberColor numberText:@"0" unitText:sHeartRateBasicUnit];
    UIView *heartRateAverageItem = [self recordItemViewCreateWithSize:itemSize title:@"平均心率" numberColor:redNumberColor numberText:@"0" unitText:sHeartRateBasicUnit];
    UIView *heartRateMaxItem = [self recordItemViewCreateWithSize:itemSize title:@"最高心率" numberColor:redNumberColor numberText:@"0" unitText:sHeartRateBasicUnit];
    UIView *heartRateMinItem = [self recordItemViewCreateWithSize:itemSize title:@"最低心率" numberColor:redNumberColor numberText:@"0" unitText:sHeartRateBasicUnit];
    heartRateItem.origin = CGPointMake(0, separatarBar.bottom);
    heartRateAverageItem.origin = heartRateItem.topRight;
    heartRateMaxItem.origin = heartRateItem.bottomLeft;
    heartRateMinItem.origin = heartRateItem.bottomRight;
    [baseView addSubview:heartRateItem];
    [baseView addSubview:heartRateAverageItem];
    [baseView addSubview:heartRateMaxItem];
    [baseView addSubview:heartRateMinItem];
    
    baseView.height = heartRateMinItem.bottom + 24;
    scrollView.contentSize = baseView.size;
    
    NSMutableArray *unitLabels = [NSMutableArray new];
    [unitLabels addObject:[stepTotalItem viewWithTag:nLocalInfoItemUnitLabelTag]];
    [unitLabels addObject:[stepPerDayItem viewWithTag:nLocalInfoItemUnitLabelTag]];
    [unitLabels addObject:[calorieItem viewWithTag:nLocalInfoItemUnitLabelTag]];
    [unitLabels addObject:[distanceItem viewWithTag:nLocalInfoItemUnitLabelTag]];
    [unitLabels addObject:[heartRateItem viewWithTag:nLocalInfoItemUnitLabelTag]];
    [unitLabels addObject:[heartRateAverageItem viewWithTag:nLocalInfoItemUnitLabelTag]];
    [unitLabels addObject:[heartRateMaxItem viewWithTag:nLocalInfoItemUnitLabelTag]];
    [unitLabels addObject:[heartRateMinItem viewWithTag:nLocalInfoItemUnitLabelTag]];
    
    self.heartRateTitleLabel = (UILabel *)[heartRateItem viewWithTag:nLocalInfoItemTitleLableTag];
    self.infoUnitLabels = unitLabels;
}

- (UIView *)recordItemViewCreateWithSize:(CGSize)size title:(NSString *)title numberColor:(UIColor *)numberColor numberText:(NSString *)numberText unitText:(NSString *)unitText
{
    UIFont *titleFont = [UIFont fontWithName:@"Arial" size:12];
    UIColor *titleColor = [UIColor colorWithHex:0x858585];
    UIFont *numberFont = [UIFont fontWithName:sFontNameForRBNo2Light size:30];
    UIFont *unitFont = [UIFont systemFontOfSize:13];
    UIColor *unitColor = [UIColor colorWithHex:0x7b7b7b];
    NSUInteger spaceCount = unitText.length > 0 ? 1 : 0;
    
    UIView *itemView = [UIView new];
    itemView.size = size;
    itemView.backgroundColor = [UIColor clearColor];
    
    CGPoint center = itemView.innerCenter;
    UILabel *titleLabel = [UILabel new];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = titleFont;
    titleLabel.textColor = titleColor;
    titleLabel.text = title;
    [titleLabel sizeToFit];
    titleLabel.center = center;
    titleLabel.tag = nLocalInfoItemTitleLableTag;
    [itemView addSubview:titleLabel];
    
    if(unitText.length > 0)
    {
        center.x += [BOAssistor string:unitText sizeWithFont:unitFont].width * 0.35;
    }
    TYDUnitLabel *unitLabel = [[TYDUnitLabel alloc] initWithNumberText:numberText numberTextFont:numberFont numberTextColor:numberColor unitText:unitText unitTextFont:unitFont unitTextColor:unitColor alignmentType:UIViewAlignmentCenter spaceCountForInterval:spaceCount];
    unitLabel.center = center;
    unitLabel.tag = nLocalInfoItemUnitLabelTag;
    [itemView addSubview:unitLabel];
    
    CGFloat interval = (itemView.height - titleLabel.height - unitLabel.height) / 3;
    titleLabel.top = interval;
    unitLabel.top = titleLabel.bottom + interval;
    
    return itemView;
}

#pragma mark - Transition

- (BOOL)infoInitializeStateCheck
{
    BOOL actionPerformed = NO;
    if(self.isWeeklyInfoShowed)
    {
        if(!_weeklyInfoInitialized)
        {
            actionPerformed = YES;
            _weeklyInfoInitialized = YES;
            [self weeklyInfosReload];
        }
    }
    else
    {
        if(!_monthlyInfoInitialized)
        {
            actionPerformed = YES;
            _monthlyInfoInitialized = YES;
            [self monthlyInfosReload];
        }
    }
    return actionPerformed;
}

- (NSString *)getChangeLabelText
{
    NSString *labelTitle = sShowWeeklyStatisticsInfoTitle;
    if(self.isWeeklyInfoShowed)
    {
        labelTitle = sShowMonthlyStatisticsInfoTitle;
    }
    return [NSString stringWithFormat:@"        %@  ", labelTitle];
}

- (void)exchangeHViewShow
{
    self.changeLabel.userInteractionEnabled = NO;
    self.scrollView.contentOffset = CGPointZero;
    
    UIView *viewShow = self.monthlyHView;
    UIView *viewHide = self.weeklyHView;
    if(self.isWeeklyInfoShowed)
    {
        viewShow = self.weeklyHView;
        viewHide = self.monthlyHView;
    }
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         viewShow.alpha = 1;
                         viewHide.alpha = 0;
                     }completion:^(BOOL finished) {
                         self.changeLabel.userInteractionEnabled = YES;
                         self.changeLabel.text = [self getChangeLabelText];
                     }];
}

#pragma mark - OverrideSettingMethod

- (void)setIsWeeklyInfoShowed:(BOOL)isWeeklyInfoShowed
{
    if(_isWeeklyInfoShowed != isWeeklyInfoShowed)
    {
        _isWeeklyInfoShowed = isWeeklyInfoShowed;
        [self exchangeHViewShow];
        if(![self infoInitializeStateCheck])
        {
            [self infoLabelsRefreshAction:YES];
        }
        [self titleTextReset];
    }
}

#pragma mark - TouchEvent

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

- (void)changeLabelTap:(UIGestureRecognizer *)sender
{
    NSLog(@"changeLabelTap");
    self.isWeeklyInfoShowed = !self.isWeeklyInfoShowed;
}

- (void)shareButtonTap:(UIButton *)sender
{
    NSLog(@"shareButtonTap");
    [[TYDShareActionSheet defaultSheet] actionSheetShow];
}

#pragma mark - DateChange

- (void)setTitleText:(NSString *)titleText
{
    [super setTitleText:titleText];
    UINavigationController *naviController = self.navigationController;
    CGFloat currentTitleLabelWidthMax = 220;
    UIFont *titleTextFont = [UIFont boldSystemFontOfSize:20];
    if([BOAssistor string:titleText sizeWithFont:titleTextFont].width > currentTitleLabelWidthMax)
    {
        titleTextFont = [UIFont boldSystemFontOfSize:14];
    }
    //    UIFont *titleTextFont = [UIFont boldSystemFontOfSize:[self fontSizeMeasureWithText:titleText limitedWidth:currentTitleLabelWidthMax]];
    naviController.navigationBar.titleTextAttributes = @{NSFontAttributeName:titleTextFont};
}

- (void)titleTextReset
{
    NSString *dateDurationString = nil;
    NSString *currentYearString = [BOTimeStampAssistor getYearStringWithTimeStamp:[BOTimeStampAssistor getCurrentTime]];
    BOTimeStampStringFormatDateStyle beginDateStyle = BOTimeStampStringFormatStyleDateShortC1;
    BOTimeStampStringFormatDateStyle endDateStyle = BOTimeStampStringFormatStyleDateShortC1;
    if(self.isWeeklyInfoShowed)
    {
        if(![[BOTimeStampAssistor getYearStringWithTimeStamp:_weeklyBeginningTimeStamp] isEqualToString:currentYearString])
        {
            beginDateStyle = BOTimeStampStringFormatStyleDateC;
            endDateStyle = BOTimeStampStringFormatStyleDateC;
        }
        
        NSString *weeklyBeginingDateString = [BOTimeStampAssistor getTimeStringWithTimeStamp:_weeklyBeginningTimeStamp dateStyle:beginDateStyle timeStyle:BOTimeStampStringFormatStyleTimeNone];
        NSString *weeklyEndDateString = [BOTimeStampAssistor getTimeStringWithTimeStamp:_weeklyEndTimeStamp dateStyle:endDateStyle timeStyle:BOTimeStampStringFormatStyleTimeNone];
        dateDurationString = [NSString stringWithFormat:@"%@-%@", weeklyBeginingDateString, weeklyEndDateString];
    }
    else
    {
        if(![[BOTimeStampAssistor getYearStringWithTimeStamp:_monthlyBeginningTimeStamp] isEqualToString:currentYearString])
        {
            beginDateStyle = BOTimeStampStringFormatStyleDateC;
            endDateStyle = BOTimeStampStringFormatStyleDateC;
        }
        NSString *monthlyBeginingDateString = [BOTimeStampAssistor getTimeStringWithTimeStamp:_monthlyBeginningTimeStamp dateStyle:beginDateStyle timeStyle:BOTimeStampStringFormatStyleTimeNone];
        NSString *monthlyEndDateString = [BOTimeStampAssistor getTimeStringWithTimeStamp:_monthlyEndTimeStamp dateStyle:endDateStyle timeStyle:BOTimeStampStringFormatStyleTimeNone];
        dateDurationString = [NSString stringWithFormat:@"%@-%@", monthlyBeginingDateString, monthlyEndDateString];
    }
    self.titleText = dateDurationString;
}

- (void)weeklyInfosReload
{
    //TitleText
    [self titleTextReset];
    
    //Step HistogramView
    TYDDataCenter *dataCenter = [TYDDataCenter defaultCenter];
    NSArray *stepMarkValues = [dataCenter stepCountMarkValuesWeeklyWithTimeStamp:_weeklyBeginningTimeStamp];
    self.weeklyStepMarkValues = [stepMarkValues mutableCopy];
    [self.weeklyHView refreshAllValues:stepMarkValues animated:YES];
    
    //StepInfo
    _weeklyStepSum = 0;
    for(NSNumber *stepNumber in stepMarkValues)
    {
        _weeklyStepSum += stepNumber.unsignedIntegerValue;
    }
    
    CGFloat distance = [TYDUserInfo distanceMeasuredWithHeight:[TYDUserInfo sharedUserInfo].height.floatValue andStepCount:_weeklyStepSum];
    NSUInteger calorie = [TYDUserInfo calorieMeasuredWithWeight:[TYDUserInfo sharedUserInfo].weight.floatValue andDistance:distance];
    
    NSUInteger daysCount = [self daysCountFix];
    TYDUnitLabel *stepTotalLabel = self.infoUnitLabels[0];
    TYDUnitLabel *stepAverageLabel = self.infoUnitLabels[1];
    TYDUnitLabel *calorieLabel = self.infoUnitLabels[2];
    TYDUnitLabel *distanceLabel = self.infoUnitLabels[3];
    stepTotalLabel.numberText = [NSString stringWithFormat:@"%lu", (unsigned long)_weeklyStepSum];
    stepAverageLabel.numberText = [NSString stringWithFormat:@"%lu", (unsigned long)_weeklyStepSum / daysCount];
    calorieLabel.numberText = [NSString stringWithFormat:@"%lu", (unsigned long)calorie];
    distanceLabel.numberText = [BOAssistor distanceStringWithDistance:distance];
    
    //heartRateInfos
    NSArray *heartRateStatisticsInfo = [dataCenter heartRateStatisticsValuesWeeklyWithTimeStamp:_weeklyBeginningTimeStamp];
    _weeklyHeartRateMax = [heartRateStatisticsInfo[0] unsignedIntegerValue];
    _weeklyHeartRateMin = [heartRateStatisticsInfo[1] unsignedIntegerValue];
    _weeklyHeartRateSum = [heartRateStatisticsInfo[2] unsignedIntegerValue];
    _weeklyHeartRateCount = [heartRateStatisticsInfo[3] unsignedIntegerValue];
    
    NSUInteger hrAverage = 0;
    if(_weeklyHeartRateCount > 0)
    {
        hrAverage = _weeklyHeartRateSum / _weeklyHeartRateCount;
    }
    else
    {
        hrAverage = (_weeklyHeartRateMax + _weeklyHeartRateMin) / 2;
    }
    
    TYDUnitLabel *hrCurrentLabel = self.infoUnitLabels[4];
    TYDUnitLabel *hrAverageLabel = self.infoUnitLabels[5];
    TYDUnitLabel *hrMaxLabel = self.infoUnitLabels[6];
    TYDUnitLabel *hrMinLabel = self.infoUnitLabels[7];
    
    hrCurrentLabel.numberText = [NSString stringWithFormat:@"%lu", (unsigned long)dataCenter.heartRateCurrentValue];
    hrAverageLabel.numberText = [NSString stringWithFormat:@"%lu", (unsigned long)hrAverage];
    hrMaxLabel.numberText = [NSString stringWithFormat:@"%lu", (unsigned long)_weeklyHeartRateMax];
    hrMinLabel.numberText = [NSString stringWithFormat:@"%lu", (unsigned long)_weeklyHeartRateMin];
}

- (void)monthlyInfosReload
{
    //TitleText
    [self titleTextReset];
    
    //Step HistogramView
    TYDDataCenter *dataCenter = [TYDDataCenter defaultCenter];
    NSArray *stepMarkValues = [dataCenter stepCountMarkValuesMonthlyWithTimeStamp:_monthlyBeginningTimeStamp];
    self.monthlyStepMarkValues = [stepMarkValues mutableCopy];
    [self.monthlyHView refreshAllValues:stepMarkValues animated:YES];
    
    //StepInfo
    _monthlyStepSum = 0;
    for(NSNumber *stepNumber in stepMarkValues)
    {
        _monthlyStepSum += stepNumber.unsignedIntegerValue;
    }
    CGFloat distance = [TYDUserInfo distanceMeasuredWithHeight:[TYDUserInfo sharedUserInfo].height.floatValue andStepCount:_monthlyStepSum];
    NSUInteger calorie = [TYDUserInfo calorieMeasuredWithWeight:[TYDUserInfo sharedUserInfo].weight.floatValue andDistance:distance];
    _monthlyDays = [BOTimeStampAssistor daysPerMonthWithTimeStamp:_monthlyBeginningTimeStamp];
    
    NSUInteger monthlyDays = [self daysCountFix];
    TYDUnitLabel *stepTotalLabel = self.infoUnitLabels[0];
    TYDUnitLabel *stepAverageLabel = self.infoUnitLabels[1];
    TYDUnitLabel *calorieLabel = self.infoUnitLabels[2];
    TYDUnitLabel *distanceLabel = self.infoUnitLabels[3];
    stepTotalLabel.numberText = [NSString stringWithFormat:@"%lu", (unsigned long)_monthlyStepSum];
    stepAverageLabel.numberText = [NSString stringWithFormat:@"%lu", (unsigned long)_monthlyStepSum / monthlyDays];
    calorieLabel.numberText = [NSString stringWithFormat:@"%lu", (unsigned long)calorie];
    distanceLabel.numberText = [BOAssistor distanceStringWithDistance:distance];
    
    //heartRateInfos
    NSArray *heartRateStatisticsInfo = [dataCenter heartRateStatisticsValuesMonthlyWithTimeStamp:_monthlyBeginningTimeStamp];
    _monthlyHeartRateMax = [heartRateStatisticsInfo[0] unsignedIntegerValue];
    _monthlyHeartRateMin = [heartRateStatisticsInfo[1] unsignedIntegerValue];
    _monthlyHeartRateSum = [heartRateStatisticsInfo[2] unsignedIntegerValue];
    _monthlyHeartRateCount = [heartRateStatisticsInfo[3] unsignedIntegerValue];
    
    NSUInteger hrAverage = 0;
    if(_monthlyHeartRateCount > 0)
    {
        hrAverage = _monthlyHeartRateSum / _monthlyHeartRateCount;
    }
    else
    {
        hrAverage = (_monthlyHeartRateMax + _monthlyHeartRateMin) / 2;
    }
    
    TYDUnitLabel *hrCurrentLabel = self.infoUnitLabels[4];
    TYDUnitLabel *hrAverageLabel = self.infoUnitLabels[5];
    TYDUnitLabel *hrMaxLabel = self.infoUnitLabels[6];
    TYDUnitLabel *hrMinLabel = self.infoUnitLabels[7];
    
    hrCurrentLabel.numberText = [NSString stringWithFormat:@"%lu", (unsigned long)dataCenter.heartRateCurrentValue];
    hrAverageLabel.numberText = [NSString stringWithFormat:@"%lu", (unsigned long)hrAverage];
    hrMaxLabel.numberText = [NSString stringWithFormat:@"%lu", (unsigned long)_monthlyHeartRateMax];
    hrMinLabel.numberText = [NSString stringWithFormat:@"%lu", (unsigned long)_monthlyHeartRateMin];
}

- (void)timeStampOfDateForSportInfoChanged:(BOOL)isIncreased
{
    NSUInteger currentTimeStamp = [BOTimeStampAssistor getCurrentTime];
    NSUInteger limitTimeStampMin = [TYDDataCenter defaultCenter].firstInfoItemSavedDateTimeStamp;
    
    if(self.isWeeklyInfoShowed)
    {
        NSUInteger weeklyBeginningTimeStampNew = [BOTimeStampAssistor timeStampOfWeekBeginningWithTimerStamp:_weeklyBeginningTimeStamp];//校正
        NSUInteger intervalPerWeek = nTimeIntervalSecondsPerDay * 7;
        
        if(isIncreased)
        {
            weeklyBeginningTimeStampNew += intervalPerWeek;
            if(weeklyBeginningTimeStampNew > currentTimeStamp)
            {
                [self setNoticeText:@"后面没有了"];
                return;
            }
        }
        else
        {
            NSUInteger weeklyEndTimeStamp = weeklyBeginningTimeStampNew - 1;
            if(weeklyEndTimeStamp < limitTimeStampMin)
            {
                [self setNoticeText:@"前面没有了"];
                return;
            }
            weeklyBeginningTimeStampNew -= intervalPerWeek;
        }
        _weeklyBeginningTimeStamp = weeklyBeginningTimeStampNew;
        _weeklyEndTimeStamp = _weeklyBeginningTimeStamp + intervalPerWeek - 1;
        [self weeklyInfosReload];
    }
    else
    {
        NSUInteger monthlyBeginningTimeStampNew = [BOTimeStampAssistor timeStampOfMonthBeginningWithTimerStamp:_monthlyBeginningTimeStamp];//校正
        
        if(isIncreased)
        {
            monthlyBeginningTimeStampNew = [BOTimeStampAssistor timeStampOfMonthEndWithTimerStamp:monthlyBeginningTimeStampNew] + 1;
            if(monthlyBeginningTimeStampNew > currentTimeStamp)
            {
                [self setNoticeText:@"后面没有了"];
                return;
            }
        }
        else
        {
            NSUInteger monthlyEndTimeStamp = monthlyBeginningTimeStampNew - 1;
            if(monthlyEndTimeStamp < limitTimeStampMin)
            {
                [self setNoticeText:@"前面没有了"];
                return;
            }
            monthlyBeginningTimeStampNew = [BOTimeStampAssistor timeStampOfMonthBeginningWithTimerStamp:monthlyEndTimeStamp];
        }
        _monthlyBeginningTimeStamp = monthlyBeginningTimeStampNew;
        _monthlyEndTimeStamp = [BOTimeStampAssistor timeStampOfMonthEndWithTimerStamp:_monthlyBeginningTimeStamp];
        [self monthlyInfosReload];
    }
}

#pragma mark - Timer

- (void)currentHeartRateRefreshAction
{
    TYDUnitLabel *hrCurrentLabel = self.infoUnitLabels[4];
    hrCurrentLabel.numberText = [NSString stringWithFormat:@"%lu", (unsigned long)[TYDDataCenter defaultCenter].heartRateCurrentValue];
}

- (void)histogramViewRefreshAction
{
    NSUInteger currentTimeStamp = [BOTimeStampAssistor getCurrentTime];
    TYDDataCenter *dataCenter = [TYDDataCenter defaultCenter];
    
    if(!dataCenter.isDataValid)//设备未连接
    {
        return;
    }
    if((self.isWeeklyInfoShowed
       && (currentTimeStamp < _weeklyBeginningTimeStamp
           || currentTimeStamp > _weeklyEndTimeStamp))//weekly
       || (!self.isWeeklyInfoShowed
           && (currentTimeStamp < _monthlyBeginningTimeStamp
               || currentTimeStamp > _monthlyEndTimeStamp)))//monthly
    {
        return;
    }
    
    //动态刷新
    NSMutableArray *stepMarkValues = self.monthlyStepMarkValues;
    TYDSimpleHistogramView *hView = self.monthlyHView;
    if(self.isWeeklyInfoShowed)
    {
        stepMarkValues = self.weeklyStepMarkValues;
        hView = self.weeklyHView;
    }
    [hView refreshAllValues:stepMarkValues animated:YES];
}

- (void)infoLabelsRefreshAction:(BOOL)forced
{
    NSUInteger currentTimeStamp = [BOTimeStampAssistor getCurrentTime];
    TYDDataCenter *dataCenter = [TYDDataCenter defaultCenter];
    
    if(!dataCenter.isDataValid)//设备未连接
    {
        return;
    }
    if((self.isWeeklyInfoShowed
        && (currentTimeStamp < _weeklyBeginningTimeStamp
            || currentTimeStamp > _weeklyEndTimeStamp))//weekly
       || (!self.isWeeklyInfoShowed
           && (currentTimeStamp < _monthlyBeginningTimeStamp
               || currentTimeStamp > _monthlyEndTimeStamp)))//monthly
    {
        return;
    }
    
    //动态刷新
    NSUInteger heartRateSum = _monthlyHeartRateSum;
    NSUInteger heartRateCount = _monthlyHeartRateCount;
    NSUInteger heartRateMax = _monthlyHeartRateMax;
    NSUInteger heartRateMin = _monthlyHeartRateMin;
    NSUInteger stepSum = _monthlyStepSum;
    NSUInteger daysCount = _monthlyDays;
    if(self.isWeeklyInfoShowed)
    {
        heartRateSum = _weeklyHeartRateSum;
        heartRateCount = _weeklyHeartRateCount;
        heartRateMax = _weeklyHeartRateMax;
        heartRateMin = _weeklyHeartRateMin;
        stepSum = _weeklyStepSum;
        daysCount = _weeklyDays;
    }
    daysCount = [self daysCountFix];
    
    CGFloat distance = [TYDUserInfo distanceMeasuredWithHeight:[TYDUserInfo sharedUserInfo].height.floatValue andStepCount:stepSum];
    NSUInteger calorie = [TYDUserInfo calorieMeasuredWithWeight:[TYDUserInfo sharedUserInfo].weight.floatValue andDistance:distance];
    
    TYDUnitLabel *stepTotalLabel = self.infoUnitLabels[0];
    TYDUnitLabel *stepAverageLabel = self.infoUnitLabels[1];
    TYDUnitLabel *calorieLabel = self.infoUnitLabels[2];
    TYDUnitLabel *distanceLabel = self.infoUnitLabels[3];
    //TYDUnitLabel *hrCurrentLabel = self.infoUnitLabels[4];
    TYDUnitLabel *hrAverageLabel = self.infoUnitLabels[5];
    TYDUnitLabel *hrMaxLabel = self.infoUnitLabels[6];
    TYDUnitLabel *hrMinLabel = self.infoUnitLabels[7];
    
    stepTotalLabel.numberText = [NSString stringWithFormat:@"%lu", (unsigned long)stepSum];
    stepAverageLabel.numberText = [NSString stringWithFormat:@"%lu", (unsigned long)stepSum / daysCount];
    calorieLabel.numberText = [NSString stringWithFormat:@"%lu", (unsigned long)calorie];
    distanceLabel.numberText = [BOAssistor distanceStringWithDistance:distance];
    
    NSUInteger hrAverage = 0;
    if(heartRateCount > 0)
    {
        hrAverage = heartRateSum / heartRateCount;
    }
    else
    {
        hrAverage = (heartRateMax + heartRateMin) / 2;
    }
    hrAverageLabel.numberText = [NSString stringWithFormat:@"%lu", (unsigned long)hrAverage];
    hrMaxLabel.numberText = [NSString stringWithFormat:@"%lu", (unsigned long)heartRateMax];
    hrMinLabel.numberText = [NSString stringWithFormat:@"%lu", (unsigned long)heartRateMin];
}

- (NSUInteger)daysCountFix
{
    NSUInteger daysCount = 1;
    NSTimeInterval currentTimeStamp = [BOTimeStampAssistor getCurrentTime];
    if((self.isWeeklyInfoShowed
        && currentTimeStamp >= _weeklyBeginningTimeStamp
        && currentTimeStamp <= _weeklyEndTimeStamp)//weekly
       || (!self.isWeeklyInfoShowed
           && currentTimeStamp >= _monthlyBeginningTimeStamp
           && currentTimeStamp <= _monthlyEndTimeStamp))//monthly
    {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *dateComponents = [calendar components:NSCalendarUnitWeekday | kCFCalendarUnitDay fromDate:[NSDate date]];
        if(self.isWeeklyInfoShowed)
        {
            NSInteger weekDay = dateComponents.weekday;
            if(weekDay == 1)
            {
                weekDay = 8;
            }
            daysCount = weekDay - 1;
        }
        else
        {
            daysCount = dateComponents.day;
        }
    }
    else
    {
        if(self.isWeeklyInfoShowed)
        {
            daysCount = _weeklyDays;
        }
        else
        {
            daysCount = _monthlyDays;
        }
    }
    return daysCount;
}

- (void)stepCountCalculate
{
    NSUInteger currentTimeStamp = [BOTimeStampAssistor getCurrentTime];
    TYDDataCenter *dataCenter = [TYDDataCenter defaultCenter];
    
    if(!dataCenter.isDataValid)//设备未连接
    {
        return;
    }
    if((self.isWeeklyInfoShowed
        && (currentTimeStamp < _weeklyBeginningTimeStamp
            || currentTimeStamp > _weeklyEndTimeStamp))//weekly
       || (!self.isWeeklyInfoShowed
           && (currentTimeStamp < _monthlyBeginningTimeStamp
               || currentTimeStamp > _monthlyEndTimeStamp)))//monthly
    {
        return;
    }
    
    NSUInteger dynamicStepCount = dataCenter.stepCountCurrentValue;
    NSMutableArray *stepMarkValues = self.monthlyStepMarkValues;
    NSUInteger beginningTimeStamp = _monthlyBeginningTimeStamp;
    NSUInteger *stepSum = &_monthlyStepSum;
    if(self.isWeeklyInfoShowed)
    {
        stepMarkValues = self.weeklyStepMarkValues;
        beginningTimeStamp = _weeklyBeginningTimeStamp;
        stepSum = &_weeklyStepSum;
    }
    
    NSUInteger stepCount = 0;
    NSUInteger index = (currentTimeStamp - beginningTimeStamp) / nTimeIntervalSecondsPerDay;
    if(index < stepMarkValues.count)
    {
        for(NSUInteger i = 0; i < index; i++)
        {
            stepCount += [stepMarkValues[i] unsignedIntegerValue];
        }
        *stepSum = stepCount + dynamicStepCount;
        [stepMarkValues replaceObjectAtIndex:index withObject:@(dynamicStepCount)];
    }
}

- (void)sportStatisticsBasicTimerEvent
{
    [self histogramViewRefreshAction];
    [self stepCountCalculate];
    [self currentHeartRateRefreshAction];
    [self infoLabelsRefreshAction:NO];
}

- (void)sportStatisticsBasicTimerInvalidate
{
    if([self.basicTimer isValid])
    {
        [self.basicTimer invalidate];
        self.basicTimer = nil;
    }
}

- (void)sportStatisticsBasicTimerCancel
{
    [self sportStatisticsBasicTimerInvalidate];
}

- (void)sportStatisticsBasicTimerCreate
{
    [self sportStatisticsBasicTimerInvalidate];
    if([TYDDataCenter defaultCenter].isDataValid)
    {
        self.basicTimer = [NSTimer scheduledTimerWithTimeInterval:nBasicTimerInterval target:self selector:@selector(sportStatisticsBasicTimerEvent) userInfo:nil repeats:YES];
    }
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

#pragma mark - TYDDataCenterSaveEventDelegate

- (void)dataCenterSavedOneHeartRateRecordInfo:(TYDHeartRateRecordInfo *)heartRateRecordInfo
{
    if(heartRateRecordInfo)
    {
        NSUInteger heartRate = heartRateRecordInfo.heartRate;
        NSUInteger currentTimeStamp = [BOTimeStampAssistor getCurrentTime];
        if(currentTimeStamp >= _weeklyBeginningTimeStamp
           && currentTimeStamp <= _weeklyEndTimeStamp)
        {
            _weeklyHeartRateSum += heartRate;
            _weeklyHeartRateCount++;
            
            _weeklyHeartRateMax = MAX(heartRate, _weeklyHeartRateMax);
            if(_weeklyHeartRateMin == 0)
            {
                _weeklyHeartRateMin = heartRate;
            }
            else
            {
                _weeklyHeartRateMin = MIN(_weeklyHeartRateMin, heartRate);
            }
        }
        if(currentTimeStamp >= _monthlyBeginningTimeStamp
           && currentTimeStamp <= _monthlyEndTimeStamp)
        {
            _monthlyHeartRateSum += heartRateRecordInfo.heartRate;
            _monthlyHeartRateCount++;
            
            _monthlyHeartRateMax = MAX(heartRate, _monthlyHeartRateMax);
            if(_monthlyHeartRateMin == 0)
            {
                _monthlyHeartRateMin = heartRate;
            }
            else
            {
                _monthlyHeartRateMin = MIN(_monthlyHeartRateMin, heartRate);
            }
        }
    }
}

#pragma mark - TYDSuspendEventDelegate

- (void)applicationWillResignActive
{
    [self sportStatisticsBasicTimerCancel];
}

- (void)applicationDidBecomeActive
{
    [self sportStatisticsBasicTimerCreate];
}

/*
- (int)fontSizeMeasureWithText:(NSString *)text limitedWidth:(CGFloat)limitedWidth
{
    int fontSize = 20;
    for(; fontSize > 10; fontSize--)
    {
        if([BOAssistor string:text sizeWithFont:[UIFont boldSystemFontOfSize:fontSize]].width <= limitedWidth)
        {
            break;
        }
    }
    return fontSize;
}
*/

@end
