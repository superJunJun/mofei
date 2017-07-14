//
//  TYDHeartRateRecordViewController.m
//  Mofei
//
//  Created by macMini_Dev on 14-9-5.
//  Copyright (c) 2014年 Young. All rights reserved.
//
//  心率记录，末端页面
//

#import "TYDHeartRateRecordViewController.h"
#import "TYDHistogramView.h"
#import "TYDUnitLabel.h"
#import "TYDShareActionSheet.h"
#import "TYDHeartRateRecordInfo.h"
#import "TYDHeartRateRecordInfoCell.h"
#import "TYDDataCenter.h"

#define nUnitLabelTag               500
#define nSectionHeaderViewHeight    24

@interface TYDHeartRateRecordViewController () <UITableViewDataSource, UITableViewDelegate, TYDShareActionSheetDelegate, TYDDataCenterSaveEventDelegate>

@property (strong, nonatomic) UIView *screenShotView;

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *unitLabels;
@property (strong, nonatomic) TYDHistogramView *heartRateRecordHView;

@property (strong, nonatomic) NSTimer *basicTimer;
@property (strong, nonatomic) NSMutableArray *heartRateInfos;
@property (nonatomic) NSUInteger heartRateMax;
@property (nonatomic) NSUInteger heartRateMin;
@property (nonatomic) NSUInteger heartRateSum;
@property (nonatomic) NSUInteger heartRateCount;

@end

@implementation TYDHeartRateRecordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self localDataInitialize];
    [self navigationBarItemsLoad];
    [self subviewsLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [TYDDataCenter defaultCenter].saveEventDelegate = self;
    [self heartRateRecordBasicTimerCreate];
    [[TYDShareActionSheet defaultSheet] setDelegate:self screenShotView:self.screenShotView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [TYDDataCenter defaultCenter].saveEventDelegate = nil;
    [self heartRateRecordBasicTimerCancel];
    [[TYDShareActionSheet defaultSheet] setDelegate:nil screenShotView:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self basicDataLoad];
}

- (void)localDataInitialize
{
    self.heartRateMax = 0;
    self.heartRateMin = 0;
    self.heartRateSum = 0;
    self.heartRateCount = 0;
    self.heartRateInfos = [NSMutableArray new];
    self.screenShotView = self.navigationController.view;
}

- (void)navigationBarItemsLoad
{
    self.title = @"心率记录";
    
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
    
    self.tableView = tableView;
    
    [tableView registerClass:TYDHeartRateRecordInfoCell.class forCellReuseIdentifier:sHeartRateRecordInfoCellIdentifier];
}

- (void)tableHeaderViewLoad
{
    CGRect frame = self.tableView.bounds;
    UIView *headerView = [[UIView alloc] initWithFrame:frame];
    headerView.backgroundColor = [UIColor clearColor];
    
    NSArray *levelValues = kHistogramViewHeartRateValueLevels;
    CGFloat itemWith = 6;
    CGFloat itemInterval = 2;
    UIColor *textColor = [UIColor colorWithHex:0xec4762];
    UIColor *bgColor = [UIColor colorWithHex:0xfdf5fa];
    UIColor *dashLineColor = [UIColor colorWithHex:0xdbd4d8];
    UIColor *solidLineColor = [UIColor colorWithHex:0xff96a0];
    UIColor *itemColor = [UIColor colorWithHex:0xff96a0];
    CGSize viewSize = CGSizeMake(280, 160);
    
    TYDHistogramView *heartRateRecordHView = [[TYDHistogramView alloc] initWithCoreViewSize:viewSize backgroundColor:bgColor solidLineColor:solidLineColor dashLineColor:dashLineColor valueLevelTextColor:textColor timeStampTextColor:textColor itemColor:itemColor itemWidth:itemWith itemInterval:itemInterval valueLevels:levelValues maxValueVisible:YES timeStampType:TYDHistogramTimeStampType15MinutesPerDay];
    //heartRateRecordHView.right = headerView.width;
    heartRateRecordHView.center = headerView.innerCenter;
    heartRateRecordHView.top = 20;
    [headerView addSubview:heartRateRecordHView];
    
    frame = CGRectMake(0, heartRateRecordHView.bottom + 12, headerView.width, 12);
    UIView *separatarBar = [[UIView alloc] initWithFrame:frame];
    separatarBar.backgroundColor = [UIColor colorWithHex:0xffd0d3];
    [headerView addSubview:separatarBar];
    
    self.unitLabels = [NSMutableArray new];
    CGSize itemSize = CGSizeMake(headerView.width * 0.5, 62);
    UIView *currentHrItem = [self recordItemViewCreateWithSize:itemSize title:@"当前心率" numberText:@"0" unitText:sHeartRateBasicUnit];
    UIView *averageHrItem = [self recordItemViewCreateWithSize:itemSize title:@"平均心率" numberText:@"0" unitText:sHeartRateBasicUnit];
    UIView *maxHrItem = [self recordItemViewCreateWithSize:itemSize title:@"最高心率" numberText:@"0" unitText:sHeartRateBasicUnit];
    UIView *minHrItem = [self recordItemViewCreateWithSize:itemSize title:@"最低心率" numberText:@"0" unitText:sHeartRateBasicUnit];
    currentHrItem.origin = CGPointMake(0, separatarBar.bottom);
    averageHrItem.origin = currentHrItem.topRight;
    maxHrItem.origin = currentHrItem.bottomLeft;
    minHrItem.origin = currentHrItem.bottomRight;
    [headerView addSubview:currentHrItem];
    [headerView addSubview:averageHrItem];
    [headerView addSubview:maxHrItem];
    [headerView addSubview:minHrItem];
    
    self.unitLabels = [NSMutableArray new];
    [self.unitLabels addObject:[currentHrItem viewWithTag:nUnitLabelTag]];
    [self.unitLabels addObject:[averageHrItem viewWithTag:nUnitLabelTag]];
    [self.unitLabels addObject:[maxHrItem viewWithTag:nUnitLabelTag]];
    [self.unitLabels addObject:[minHrItem viewWithTag:nUnitLabelTag]];
    
    UIView *separatorLineHor = [UIView new];
    separatorLineHor.size = CGSizeMake(headerView.width, 0.5);
    separatorLineHor.backgroundColor = [UIColor colorWithHex:0xcecece];
    separatorLineHor.origin = currentHrItem.bottomLeft;
    [headerView addSubview:separatorLineHor];
    
    UIView *separatorLineVer = [UIView new];
    separatorLineVer.size = CGSizeMake(0.5, currentHrItem.height * 2);
    separatorLineVer.backgroundColor = [UIColor colorWithHex:0xcecece];
    separatorLineVer.origin = currentHrItem.topRight;
    [headerView addSubview:separatorLineVer];
    
    headerView.height = minHrItem.bottom;
    
    self.heartRateRecordHView = heartRateRecordHView;
    self.tableView.tableHeaderView = headerView;
}

- (UIView *)recordItemViewCreateWithSize:(CGSize)size title:(NSString *)title numberText:(NSString *)numberText unitText:(NSString *)unitText
{
    UIFont *titleFont = [UIFont fontWithName:@"Arial" size:12];
    UIColor *titleColor = [UIColor colorWithHex:0x858585];
    UIFont *numberFont = [UIFont fontWithName:sFontNameForRBNo2Light size:30];
    UIColor *numberColor = [UIColor colorWithHex:0xfa4f60];
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
    sectionHeaderView.backgroundColor = [UIColor colorWithHex:0xe0ceed];
    NSArray *titles = @[@"时间", @"心率"];
    
    CGRect frame = sectionHeaderView.bounds;
    frame.size.width /= titles.count;
    UIFont *itemFont = [UIFont fontWithName:@"Arial" size:12];
    UIColor *itemColor = [UIColor colorWithHex:0x70408c];
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
    return TYDHeartRateRecordInfoCell.cellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.heartRateInfos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = sHeartRateRecordInfoCellIdentifier;
    TYDHeartRateRecordInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.heartRateRecordInfo = self.heartRateInfos[indexPath.row];
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
    
    self.heartRateInfos = [dataCenter heartRateRecordInfosDailyWithTimeStamp:self.dateBeginningTimeStamp];
    [self.tableView reloadData];
    
    [self.heartRateRecordHView refreshAllValues:[dataCenter heartRateMarkValuesDailyWithTimeStamp:self.dateBeginningTimeStamp] animated:YES];
    
    NSUInteger heartRateCurrent = dataCenter.heartRateCurrentValue;
    NSUInteger heartRateMax = 0;
    NSUInteger heartRateMin = 0;
    NSUInteger heartRateSum = 0;
    NSUInteger heartRateAverage = 0;
    
    if(self.heartRateInfos.count > 0)
    {
        for(TYDHeartRateRecordInfo *hrInfo in self.heartRateInfos)
        {
            heartRateSum += hrInfo.heartRate;
            heartRateMax = MAX(heartRateMax, hrInfo.heartRate);
            if(heartRateMin == 0)
            {
                heartRateMin = hrInfo.heartRate;
            }
            else
            {
                heartRateMin = MIN(heartRateMin, hrInfo.heartRate);
            }
        }
        heartRateAverage = heartRateSum / self.heartRateInfos.count;
    }
    
    self.heartRateSum = heartRateSum;
    self.heartRateCount = self.heartRateInfos.count;
    self.heartRateMax = heartRateMax;
    self.heartRateMin = heartRateMin;
    
    TYDUnitLabel *currentHrLabel = self.unitLabels[0];
    TYDUnitLabel *averageHrLabel = self.unitLabels[1];
    TYDUnitLabel *maxHrLabel = self.unitLabels[2];
    TYDUnitLabel *minHrLabel = self.unitLabels[3];
    
    if(heartRateAverage == 0)
    {
        heartRateAverage = (heartRateMax + heartRateMin) * 0.5;
    }
    
    currentHrLabel.numberText = [NSString stringWithFormat:@"%lu", (unsigned long)heartRateCurrent];
    averageHrLabel.numberText = [NSString stringWithFormat:@"%lu", (unsigned long)heartRateAverage];
    maxHrLabel.numberText = [NSString stringWithFormat:@"%lu", (unsigned long)heartRateMax];
    minHrLabel.numberText = [NSString stringWithFormat:@"%lu", (unsigned long)heartRateMin];
}

#pragma mark - BasicTimer

- (void)heartRateRecordBasicTimerInvalidate
{
    if([self.basicTimer isValid])
    {
        [self.basicTimer invalidate];
        self.basicTimer = nil;
    }
}

- (void)heartRateRecordBasicTimerCancel
{
    [self heartRateRecordBasicTimerInvalidate];
}

- (void)heartRateRecordBasicTimerCreate
{
    [self heartRateRecordBasicTimerInvalidate];
    if([TYDDataCenter defaultCenter].isDataValid)
    {
        self.basicTimer = [NSTimer scheduledTimerWithTimeInterval:nBasicTimerInterval target:self selector:@selector(basicTimerEvent) userInfo:nil repeats:YES];
    }
}

- (void)basicTimerEvent
{
    [self currentHeartRateRefreshAction];
    if(self.isRecordInfoForToday)
    {
        [self heartRateMarkValuesRefreshAction];
        [self heartRateInfoLabelsRefreshAction];
    }
}

- (void)currentHeartRateRefreshAction
{
    NSUInteger heartRateCurrent = [TYDDataCenter defaultCenter].heartRateCurrentValue;
    TYDUnitLabel *currentHrLabel = self.unitLabels[0];
    currentHrLabel.numberText = [NSString stringWithFormat:@"%lu", (unsigned long)heartRateCurrent];
}

- (void)heartRateMarkValuesRefreshAction
{
    [self.heartRateRecordHView refreshAllValues:[[TYDDataCenter defaultCenter] heartRateMarkValuesDailyWithTimeStamp:self.dateBeginningTimeStamp] animated:YES];
}

- (void)heartRateInfoLabelsRefreshAction
{
    TYDDataCenter *dataCenter = [TYDDataCenter defaultCenter];
    NSUInteger heartRateMax = MAX(dataCenter.heartRateCurrentMaxValue, self.heartRateMax);
    NSUInteger heartRateMin = dataCenter.heartRateCurrentMinValue;
    
    NSUInteger heartRateAverage = 0;
    if(self.heartRateCount > 0)
    {
        heartRateAverage = self.heartRateSum / self.heartRateCount;
    }
    if(heartRateAverage == 0)
    {
        heartRateAverage = (heartRateMax + heartRateMin) * 0.5;
    }
    if(heartRateMin == 0)
    {
        heartRateMin = self.heartRateMin;
    }
    else if(self.heartRateMin > 0)
    {
        heartRateMin = MIN(heartRateMin, self.heartRateMin);
    }
    
    TYDUnitLabel *averageHrLabel = self.unitLabels[1];
    TYDUnitLabel *maxHrLabel = self.unitLabels[2];
    TYDUnitLabel *minHrLabel = self.unitLabels[3];
    
    averageHrLabel.numberText = [NSString stringWithFormat:@"%lu", (unsigned long)heartRateAverage];
    maxHrLabel.numberText = [NSString stringWithFormat:@"%lu", (unsigned long)heartRateMax];
    minHrLabel.numberText = [NSString stringWithFormat:@"%lu", (unsigned long)heartRateMin];
}

#pragma mark - TYDDataCenterSaveEventDelegate

- (void)dataCenterSavedOneHeartRateRecordInfo:(TYDHeartRateRecordInfo *)heartRateRecordInfo
{
    if(heartRateRecordInfo)
    {
        [self.heartRateInfos insertObject:heartRateRecordInfo atIndex:0];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        self.heartRateMax = MAX(self.heartRateMax, heartRateRecordInfo.heartRate);
        self.heartRateSum += heartRateRecordInfo.heartRate;
        self.heartRateCount++;
        if(self.heartRateMin == 0)
        {
            self.heartRateMin = heartRateRecordInfo.heartRate;
        }
        else
        {
            self.heartRateMin = MIN(self.heartRateMin, heartRateRecordInfo.heartRate);
        }
    }
}

#pragma mark - TYDSuspendEventDelegate

- (void)applicationWillResignActive
{
    [self heartRateRecordBasicTimerCancel];
}

- (void)applicationDidBecomeActive
{
    [self heartRateRecordBasicTimerCreate];
}

@end
