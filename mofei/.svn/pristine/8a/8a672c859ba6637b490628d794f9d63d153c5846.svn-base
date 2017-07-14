//
//  TYDSportRecordViewController.m
//  Mofei
//
//  Created by macMini_Dev on 14-9-5.
//  Copyright (c) 2014年 Young. All rights reserved.
//
//  运动记录，末端页面
//

#import "TYDSportRecordViewController.h"
#import "TYDHistogramView.h"
#import "TYDUnitLabel.h"
#import "TYDShareActionSheet.h"
#import "TYDDataCenter.h"
#import "TYDStepRecordInfo.h"
#import "TYDStepRecordInfoCell.h"

#define nUnitLabelTag                       500
#define nSectionHeaderViewHeight            24

@interface TYDSportRecordViewController () <UITableViewDataSource, UITableViewDelegate, TYDShareActionSheetDelegate, TYDDataCenterSaveEventDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *unitLabels;
@property (strong, nonatomic) TYDHistogramView *sportRecordHView;
@property (strong, nonatomic) UIView *screenShotView;

@property (strong, nonatomic) NSTimer *basicTimer;

@property (strong, nonatomic) NSMutableArray *stepInfos;

@end

@implementation TYDSportRecordViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self localDataInitialize];
    [self navigationBarItemsLoad];
    [self subviewsLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"sportRecordVc viewWillAppear");
    [super viewWillAppear:animated];
    [TYDDataCenter defaultCenter].saveEventDelegate = self;
    [self sportRecordBasicTimerCreate];
    [[TYDShareActionSheet defaultSheet] setDelegate:self screenShotView:self.screenShotView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [TYDDataCenter defaultCenter].saveEventDelegate = nil;
    [self sportRecordBasicTimerCancel];
    [[TYDShareActionSheet defaultSheet] setDelegate:nil screenShotView:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self basicDataLoad];
}

- (void)localDataInitialize
{
    self.stepInfos = [NSMutableArray new];
    self.screenShotView = self.navigationController.view;
}

- (void)navigationBarItemsLoad
{
    self.title = @"运动记录";
    
    UIBarButtonItem *shareButtonItem = [BOAssistor barButtonItemCreateWithImageName:@"common_naviShareBtn" highlightedImageName:nil target:self action:@selector(shareButtonTap:)];
    self.navigationItem.rightBarButtonItem = shareButtonItem;
}

- (void)subviewsLoad
{
    [self tableViewLoad];
    [self tableHeaderViewLoad];
    
    //self.screenShotView = self.view;
}

- (void)tableViewLoad
{
    CGRect frame = self.view.bounds;
    UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //tableView.separatorColor = [UIColor colorWithHex:0xcecece];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:tableView];
    
    [tableView registerClass:TYDStepRecordInfoCell.class forCellReuseIdentifier:sStepRecordInfoCellIdentifier];
    
    self.tableView = tableView;
}

- (void)tableHeaderViewLoad
{
    CGRect frame = self.tableView.bounds;
    UIView *headerView = [[UIView alloc] initWithFrame:frame];
    headerView.backgroundColor = [UIColor clearColor];
    
    NSArray *levelValues = kHistogramViewStepValueLevels;
    CGFloat itemWith = 10;
    CGFloat itemInterval = 4;
    UIColor *textColor = [UIColor colorWithHex:0x45d8da];
    UIColor *bgColor = [UIColor colorWithHex:0xe1fcff];
    UIColor *dashLineColor = [UIColor colorWithHex:0xc9e0e3];
    UIColor *solidLineColor = [UIColor colorWithHex:0x45d8da];
    UIColor *itemColor = [UIColor colorWithHex:0x45d8da];
    CGSize viewSize = CGSizeMake(280, 200);
    
    TYDHistogramView *sportRecordHView = [[TYDHistogramView alloc] initWithCoreViewSize:viewSize backgroundColor:bgColor solidLineColor:solidLineColor dashLineColor:dashLineColor valueLevelTextColor:textColor timeStampTextColor:textColor itemColor:itemColor itemWidth:itemWith itemInterval:itemInterval valueLevels:levelValues maxValueVisible:YES timeStampType:TYDHistogramTimeStampTypeHoursPerDay];
    //sportRecordHView.right = headerView.width;
    sportRecordHView.center = headerView.innerCenter;
    sportRecordHView.top = 20;
    [headerView addSubview:sportRecordHView];
    
    frame = CGRectMake(0, sportRecordHView.bottom + 12, headerView.width, 12);
    UIView *separatarBar = [[UIView alloc] initWithFrame:frame];
    separatarBar.backgroundColor = [UIColor colorWithHex:0xb9f1f5];
    [headerView addSubview:separatarBar];
    
    CGSize itemSize = CGSizeMake(headerView.width * 0.5, 62);
    UIView *stepItem = [self recordItemViewCreateWithSize:itemSize title:@"步数" numberText:@"0" unitText:sStepBasicUnit];
    UIView *targetItem = [self recordItemViewCreateWithSize:itemSize title:@"每日目标" numberText:@"0.0%" unitText:nil];
    UIView *calorieItem = [self recordItemViewCreateWithSize:itemSize title:@"消耗" numberText:@"0" unitText:sCalorieBasicShortUnit];
    UIView *distanceItem = [self recordItemViewCreateWithSize:itemSize title:@"里程" numberText:@"0.000" unitText:sDistanceKiloCommonUnit];
    stepItem.origin = CGPointMake(0, separatarBar.bottom);
    targetItem.origin = stepItem.topRight;
    calorieItem.origin = stepItem.bottomLeft;
    distanceItem.origin = stepItem.bottomRight;
    [headerView addSubview:stepItem];
    [headerView addSubview:targetItem];
    [headerView addSubview:calorieItem];
    [headerView addSubview:distanceItem];
    
    self.unitLabels = [NSMutableArray new];
    [self.unitLabels addObject:[stepItem viewWithTag:nUnitLabelTag]];
    [self.unitLabels addObject:[targetItem viewWithTag:nUnitLabelTag]];
    [self.unitLabels addObject:[calorieItem viewWithTag:nUnitLabelTag]];
    [self.unitLabels addObject:[distanceItem viewWithTag:nUnitLabelTag]];
    
    UIView *separatorLineHor = [UIView new];
    separatorLineHor.size = CGSizeMake(headerView.width, 0.5);
    separatorLineHor.backgroundColor = [UIColor colorWithHex:0xcecece];
    separatorLineHor.origin = stepItem.bottomLeft;
    [headerView addSubview:separatorLineHor];
    
    UIView *separatorLineVer = [UIView new];
    separatorLineVer.size = CGSizeMake(0.5, stepItem.height * 2);
    separatorLineVer.backgroundColor = [UIColor colorWithHex:0xcecece];
    separatorLineVer.origin = stepItem.topRight;
    [headerView addSubview:separatorLineVer];
    
    headerView.height = distanceItem.bottom;
    
    self.sportRecordHView = sportRecordHView;
    self.tableView.tableHeaderView = headerView;
}

- (UIView *)recordItemViewCreateWithSize:(CGSize)size title:(NSString *)title numberText:(NSString *)numberText unitText:(NSString *)unitText
{
    UIFont *titleFont = [UIFont fontWithName:@"Arial" size:12];
    UIColor *titleColor = [UIColor colorWithHex:0x999999];
    UIFont *numberFont = [UIFont fontWithName:sFontNameForRBNo2Light size:30];
    UIColor *numberColor = [UIColor colorWithHex:0x00c2c9];
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
    [itemView addSubview:titleLabel];
    
    if(unitText.length > 0)
    {
        center.x += [BOAssistor string:unitText sizeWithFont:unitFont].width * 0.35;
    }
    TYDUnitLabel *unitLabel = [[TYDUnitLabel alloc] initWithNumberText:numberText numberTextFont:numberFont numberTextColor:numberColor unitText:unitText unitTextFont:unitFont unitTextColor:unitColor alignmentType:UIViewAlignmentCenter spaceCountForInterval:spaceCount];
    unitLabel.center = center;
    unitLabel.tag = nUnitLabelTag;
    [itemView addSubview:unitLabel];
    
    CGFloat interval = (itemView.height - titleLabel.height - unitLabel.height) / 3;
    titleLabel.top = interval;
    unitLabel.top = titleLabel.bottom + interval;
    
    return itemView;
}

#pragma mark - TouchEvent

- (void)shareButtonTap:(UIButton *)sender
{
    NSLog(@"shareButtonTap");
    [[TYDShareActionSheet defaultSheet] actionSheetShow];
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

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return nSectionHeaderViewHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionHeaderView = [UIView new];
    sectionHeaderView.size = CGSizeMake(tableView.width, nSectionHeaderViewHeight);
    sectionHeaderView.backgroundColor = [UIColor colorWithHex:0xc4edc9];
    NSArray *titles = @[@"时间", @"时长", @"步数", @"里程"];
    
    CGRect frame = sectionHeaderView.bounds;
    frame.size.width /= titles.count;
    UIFont *itemFont = [UIFont fontWithName:@"Arial" size:12];
    UIColor *itemColor = [UIColor colorWithHex:0x398541];
    for(int i = 0; i < titles.count; i++)
    {
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        label.backgroundColor = [UIColor clearColor];
        label.font = itemFont;
        label.textColor = itemColor;
        label.textAlignment = NSTextAlignmentCenter;
        label.text = titles[i];
        [sectionHeaderView addSubview:label];
        
        frame.origin.x += label.width;
    }
    
    return sectionHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TYDStepRecordInfoCell.cellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.stepInfos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = sStepRecordInfoCellIdentifier;
    TYDStepRecordInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.stepRecordInfo = self.stepInfos[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - BasicDataLoad

- (void)basicDataLoad
{
    TYDDataCenter *dataCenter = [TYDDataCenter defaultCenter];
    self.stepInfos = [dataCenter stepCountRecordInfosDailyWithTimeStamp:self.dateBeginningTimeStamp];
    [self.tableView reloadData];
    [self.sportRecordHView refreshAllValues:[dataCenter stepCountMarkValuesDailyWithTimeStamp:self.dateBeginningTimeStamp] animated:YES];
    
    if([self.basicTimer isValid])
    {
        return;
    }
    
    NSUInteger stepCount = 0;
    for(TYDStepRecordInfo *stepInfo in self.stepInfos)
    {
        stepCount += stepInfo.stepCount;
    }
    
    TYDUserInfo *userInfo = [TYDUserInfo sharedUserInfo];
    CGFloat distance = [TYDUserInfo distanceMeasuredWithHeight:userInfo.height.floatValue andStepCount:stepCount];
    NSUInteger calorie = [TYDUserInfo calorieMeasuredWithWeight:userInfo.weight.floatValue andDistance:distance];
    CGFloat calorieTarget = [TYDUserInfo sharedUserInfo].sportTarget.floatValue;
    CGFloat targetCompletePercentValue = calorie / calorieTarget;
    TYDUnitLabel *stepLabel = self.unitLabels[0];
    TYDUnitLabel *targetLabel = self.unitLabels[1];
    TYDUnitLabel *calorieLabel = self.unitLabels[2];
    TYDUnitLabel *distanceLabel = self.unitLabels[3];
    stepLabel.numberText = [NSString stringWithFormat:@"%lu", (unsigned long)stepCount];
    calorieLabel.numberText = [NSString stringWithFormat:@"%lu", (unsigned long)calorie];
    distanceLabel.numberText = [BOAssistor distanceStringWithDistance:distance];
    if(targetCompletePercentValue >= 1.0)
    {
        targetLabel.numberText = @"100%";
    }
    else
    {
        targetLabel.numberText = [NSString stringWithFormat:@"%.1f%%", targetCompletePercentValue * 100];
    }
}

#pragma mark - BasicTimer

- (void)sportRecordBasicTimerInvalidate
{
    if([self.basicTimer isValid])
    {
        [self.basicTimer invalidate];
        self.basicTimer = nil;
    }
}

- (void)sportRecordBasicTimerCancel
{
    [self sportRecordBasicTimerInvalidate];
}

- (void)sportRecordBasicTimerCreate
{
    [self sportRecordBasicTimerInvalidate];
    if(self.isRecordInfoForToday
       && [TYDDataCenter defaultCenter].isDataValid)
    {
        self.basicTimer = [NSTimer scheduledTimerWithTimeInterval:nBasicTimerInterval target:self selector:@selector(basicTimerEvent) userInfo:nil repeats:YES];
    }
}

- (void)basicTimerEvent
{
    [self sportRecordHViewInfoRefreshAction];
    [self sportRecordInfoRefreshAction];
}

- (void)sportRecordHViewInfoRefreshAction
{
    [self.sportRecordHView refreshAllValues:[[TYDDataCenter defaultCenter] stepCountMarkValuesDailyWithTimeStamp:self.dateBeginningTimeStamp] animated:YES];
}

- (void)sportRecordInfoRefreshAction
{
    TYDDataCenter *dataCenter = [TYDDataCenter defaultCenter];
    TYDUserInfo *userInfo = [TYDUserInfo sharedUserInfo];
    NSUInteger stepCount = dataCenter.stepCountCurrentValue;
    
    CGFloat distance = [TYDUserInfo distanceMeasuredWithHeight:userInfo.height.floatValue andStepCount:stepCount];
    NSUInteger calorie = [TYDUserInfo calorieMeasuredWithWeight:userInfo.weight.floatValue andDistance:distance];
    CGFloat calorieTarget = [TYDUserInfo sharedUserInfo].sportTarget.floatValue;
    CGFloat targetCompletePercentValue = calorie / calorieTarget;
    
    TYDUnitLabel *stepLabel = self.unitLabels[0];
    TYDUnitLabel *targetLabel = self.unitLabels[1];
    TYDUnitLabel *calorieLabel = self.unitLabels[2];
    TYDUnitLabel *distanceLabel = self.unitLabels[3];
    stepLabel.numberText = [NSString stringWithFormat:@"%lu", (unsigned long)stepCount];
    calorieLabel.numberText = [NSString stringWithFormat:@"%lu", (unsigned long)calorie];
    distanceLabel.numberText = [BOAssistor distanceStringWithDistance:distance];
    if(targetCompletePercentValue >= 1.0)
    {
        targetLabel.numberText = @"100%";
    }
    else
    {
        targetLabel.numberText = [NSString stringWithFormat:@"%.1f%%", targetCompletePercentValue * 100];
    }
}

#pragma mark - TYDDataCenterSaveEventDelegate

- (void)dataCenterSavedOneStepRecordInfo:(TYDStepRecordInfo *)stepRecordInfo
{
    if(stepRecordInfo)
    {
        [self.stepInfos insertObject:stepRecordInfo atIndex:0];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - TYDSuspendEventDelegate

- (void)applicationWillResignActive
{
    [self sportRecordBasicTimerCancel];
}

- (void)applicationDidBecomeActive
{
    [self sportRecordBasicTimerCreate];
}

@end
