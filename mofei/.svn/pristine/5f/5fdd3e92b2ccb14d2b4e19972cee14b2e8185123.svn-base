//
//  TYDSportRankingViewController.m
//  Mofei
//
//  Created by macMini_Dev on 14-9-9.
//  Copyright (c) 2014年 Young. All rights reserved.
//
//  运动排名界面，末端页面
//

#import "TYDSportRankingViewController.h"
#import "BOSegmentedView.h"
#import "TYDShareActionSheet.h"
#import "BOAvatarView.h"
#import "TYDUserRankingInfo.h"
#import "TYDUserRankingCell.h"
#import "TYDUnitLabel.h"

#import "TYDDataCenter.h"
#import "CoreDataManager.h"
#import "WalkStepEntity.h"

@interface TYDSportRankingViewController () <UITableViewDataSource, UITableViewDelegate, BOSegmentedViewDelegate, TYDShareActionSheetDelegate>

@property (strong, nonatomic) BOSegmentedView *segmentedView;
@property (strong, nonatomic) UILabel *introductionLabel;

//bottom userInfoBar
@property (strong, nonatomic) UIView *userRankingInfoBar;
@property (strong, nonatomic) UIImageView *userRankingIcon;
@property (strong, nonatomic) UILabel *userRankingLabel;
@property (strong, nonatomic) BOAvatarView *userAvatarView;
@property (strong, nonatomic) UILabel *usernameLabel;
@property (strong, nonatomic) TYDUnitLabel *userCalorieLabel;

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSArray *segmentTitles;
@property (strong, nonatomic) UIView *screenShotView;

@property (strong, nonatomic) NSArray *rankingDailyInfos;
@property (strong, nonatomic) NSArray *rankingWeeklyInfos;
@property (strong, nonatomic) NSArray *rankingMonthlyInfos;
@property (strong, nonatomic) NSArray *rankingInfos;

@end

@implementation TYDSportRankingViewController
{
    CGFloat _userDailyCalorie;
    CGFloat _userWeeklyCalorie;
    CGFloat _userMonthlyCalorie;
    
    NSUInteger _userDailyRankingValue;
    NSUInteger _userWeeklyRankingValue;
    NSUInteger _userMonthlyRankingValue;
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
    [super viewWillAppear:animated];
    [self baseDataLoad];
    [[TYDShareActionSheet defaultSheet] setDelegate:self screenShotView:self.screenShotView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[TYDShareActionSheet defaultSheet] setDelegate:nil screenShotView:nil];
}

- (void)localDataInitialize
{
    self.segmentTitles = @[@"日排名", @"周排名", @"月排名"];
    
    _userDailyRankingValue = 0;
    _userWeeklyRankingValue = 0;
    _userMonthlyRankingValue = 0;
    
    self.rankingDailyInfos = nil;
    self.rankingWeeklyInfos = nil;
    self.rankingMonthlyInfos = nil;
    self.rankingInfos = nil;
    
    NSInteger todayBeginningTimeStamp = [BOTimeStampAssistor timeStampOfDayBeginningForToday];
    NSInteger weekBeginningTimeStamp = [BOTimeStampAssistor timeStampOfWeekBeginningWithTimerStamp:todayBeginningTimeStamp];
    NSInteger monthBeginningTimeStamp = [BOTimeStampAssistor timeStampOfMonthBeginningWithTimerStamp:todayBeginningTimeStamp];
    
    NSUInteger dailyStepCount = [[TYDDataCenter defaultCenter] stepCountCurrentValue];
    _userDailyCalorie = [TYDUserInfo calorieMeasuredWithUserInfo:[TYDUserInfo sharedUserInfo] andStepCount:dailyStepCount];
    _userWeeklyCalorie = _userDailyCalorie;
    _userMonthlyCalorie = _userDailyCalorie;
    
    _userWeeklyCalorie += [self calorieValueSumWithBeginningTime:weekBeginningTimeStamp endTime:todayBeginningTimeStamp];
    _userMonthlyCalorie += [self calorieValueSumWithBeginningTime:monthBeginningTimeStamp endTime:todayBeginningTimeStamp];
    
    self.screenShotView = self.navigationController.view;
}

- (void)navigationBarItemsLoad
{
    self.title = @"我的排名";
    
    UIBarButtonItem *shareButtonItem = [BOAssistor barButtonItemCreateWithImageName:@"common_naviShareBtn" highlightedImageName:nil target:self action:@selector(shareButtonTap:)];;
    self.navigationItem.rightBarButtonItem = shareButtonItem;
}

- (void)subviewsLoad
{
    [self segmentedViewLoad];
    [self introductionLabelLoad];
    [self userRankingInfoBarLoad];
    [self tableViewLoad];
}

- (void)segmentedViewLoad
{
    CGRect frame = CGRectMake(0, 0, self.view.width, 40);
    UIColor *bgGrayColor = [UIColor colorWithHex:0xf3f3f6];
    NSArray *titles = self.segmentTitles;
    UIFont *titleFont = [UIFont systemFontOfSize:16];
    UIColor *titleGrayColor = [UIColor colorWithHex:0x6e6e6e];
    UIColor *titlePinkColor = [UIColor colorWithHex:0xe23674];
    UIImage *separatorImage = [UIImage imageNamed:@"sportRanking_separator"];
    CGFloat verOffset = 0;
    
    BOSegmentedView *segmentedView = [[BOSegmentedView alloc] initWithFrame:frame titles:titles titleFont:titleFont titleNormalColor:titleGrayColor titleSelectedColor:titlePinkColor titleLabelVerOffset:verOffset indicatorBarColor:titlePinkColor backgroundColor:bgGrayColor segmentSeparatorImage:separatorImage cornerRadius:0];
    segmentedView.delegate = self;
    [self.view addSubview:segmentedView];
    
    UIImageView *horSeparator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sportRanking_separatorLineHor"]];
    horSeparator.width = segmentedView.width;
    horSeparator.bottom = segmentedView.height;
    [segmentedView insertSubview:horSeparator atIndex:0];
    
    self.segmentedView = segmentedView;
}

- (void)introductionLabelLoad
{
    CGRect frame = CGRectMake(0, 0, self.view.width, 20);
    NSString *introString = @"最近一天消耗的卡路里排名（凌晨更新）";
    
    UILabel *introductionLabel = [[UILabel alloc] initWithFrame:frame];
    introductionLabel.backgroundColor = [UIColor colorWithHex:0xf3f3f6];
    introductionLabel.font = [UIFont systemFontOfSize:10];
    introductionLabel.textColor = [UIColor colorWithHex:0xa7a7a7];
    introductionLabel.text = [@"  " stringByAppendingString:introString];
    introductionLabel.top = self.segmentedView.bottom;
    [self.view addSubview:introductionLabel];
    
    self.introductionLabel = introductionLabel;
}

- (void)userRankingInfoBarLoad
{
    CGRect frame = CGRectMake(0, 0, self.view.width, 60);
    UIView *infoBar = [[UIView alloc] initWithFrame:frame];
    infoBar.backgroundColor = [UIColor colorWithHex:0xededf1];
    infoBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;////
    infoBar.bottom = self.view.height;
    [self.view addSubview:infoBar];
    
    frame = infoBar.bounds;
    frame.size.width = 44;
    UIView *pinkHeadView = [[UIView alloc] initWithFrame:frame];
    pinkHeadView.backgroundColor = [UIColor colorWithHex:0xe23674];
    [infoBar addSubview:pinkHeadView];
    
    frame = infoBar.bounds;
    frame.size.height = 1;
    UIView *pinkLine = [[UIView alloc] initWithFrame:frame];
    pinkLine.backgroundColor = [UIColor colorWithHex:0xe23674];
    [infoBar addSubview:pinkLine];
    
    UIImageView *rankingIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sportRanking_endRanking"]];
    rankingIcon.backgroundColor = [UIColor clearColor];
    rankingIcon.center = pinkHeadView.center;
    rankingIcon.hidden = YES;
    [infoBar addSubview:rankingIcon];
    
    UILabel *rankingLabel = [[UILabel alloc] initWithFrame:pinkHeadView.frame];
    rankingLabel.backgroundColor = [UIColor clearColor];
    rankingLabel.font = [UIFont systemFontOfSize:16];
    rankingLabel.textColor = [UIColor whiteColor];
    rankingLabel.textAlignment = NSTextAlignmentCenter;
    [infoBar addSubview:rankingLabel];
    
    BOAvatarView *avatarView = [[BOAvatarView alloc] initWithAvatarRadius:20];
    avatarView.shadowEnable = NO;
    avatarView.borderWidth = 0;
    avatarView.center = pinkHeadView.center;
    avatarView.left = pinkHeadView.right + 4;
    [infoBar addSubview:avatarView];
    
    UILabel *usernameLabel = [UILabel new];
    usernameLabel.backgroundColor = [UIColor clearColor];
    usernameLabel.font = [UIFont fontWithName:@"Arial" size:15];
    usernameLabel.textColor = [UIColor colorWithHex:0x3d3d3d];
    usernameLabel.text = @" ";
    [usernameLabel sizeToFit];
    usernameLabel.center = avatarView.center;
    usernameLabel.left = avatarView.right + 4;
    [infoBar addSubview:usernameLabel];
    
    UIFont *numberTextFont = [UIFont fontWithName:sFontNameForRBNo2Light size:30];
    UIColor *numberTextColor = [UIColor colorWithHex:0x454545];
    UIFont *unitTextFont = [UIFont systemFontOfSize:12];
    UIColor *unitTextColor = [UIColor colorWithHex:0x898989];
    TYDUnitLabel *calorieLabel = [[TYDUnitLabel alloc] initWithNumberText:@"0" numberTextFont:numberTextFont numberTextColor:numberTextColor unitText:sCalorieBasicUnit unitTextFont:unitTextFont unitTextColor:unitTextColor alignmentType:UIViewAlignmentRight spaceCountForInterval:1];
    calorieLabel.center = avatarView.center;
    calorieLabel.right = infoBar.width - 8;
    calorieLabel.yCenter += 3;
    [infoBar addSubview:calorieLabel];
    
    self.userRankingInfoBar = infoBar;
    self.userRankingLabel = rankingLabel;
    self.userRankingIcon = rankingIcon;
    self.userAvatarView = avatarView;
    self.usernameLabel = usernameLabel;
    self.userCalorieLabel = calorieLabel;
    
    TYDUserInfo *userInfo = [TYDUserInfo sharedUserInfo];
    self.usernameLabel.text = userInfo.username;
    [self.usernameLabel sizeToFit];
    [self.userAvatarView setAvatarImageWithAvatarID:userInfo.avatarID];
    
    self.userCalorieLabel.numberText = [NSString stringWithFormat:@"%ld", (long)_userDailyCalorie];
}

- (void)tableViewLoad
{
    CGRect frame = CGRectMake(0, self.introductionLabel.bottom, self.view.width, self.userRankingInfoBar.top - self.introductionLabel.bottom);
    UITableView *tableView = [[UITableView alloc] initWithFrame:frame];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.separatorColor = [UIColor colorWithHex:0xcecece];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.showsHorizontalScrollIndicator = NO;
    tableView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:tableView];
    
    [tableView registerClass:TYDUserRankingCell.class forCellReuseIdentifier:sUserRankingCellIdentifier];
    
    self.tableView = tableView;
}

- (void)userRankingInfoBarImportData
{
    CGFloat userCalorie = _userMonthlyCalorie;
    NSUInteger userRankingValue = _userMonthlyRankingValue;
    
    if(self.rankingInfos == self.rankingDailyInfos)
    {
        userCalorie = _userDailyCalorie;
        userRankingValue = _userDailyRankingValue;
    }
    else if(self.rankingInfos == self.rankingWeeklyInfos)
    {
        userCalorie = _userWeeklyCalorie;
        userRankingValue = _userWeeklyRankingValue;
    }
    
    if(userRankingValue >= 1000)
    {
        self.userRankingIcon.hidden = NO;
        self.userRankingLabel.hidden = YES;
    }
    else
    {
        self.userRankingIcon.hidden = YES;
        self.userRankingLabel.hidden = NO;
        self.userRankingLabel.text = [NSString stringWithFormat:@"%d", (int)userRankingValue];
    }
    
    self.userCalorieLabel.numberText = [NSString stringWithFormat:@"%ld", (long)userCalorie];
}

#pragma mark - Fetch

- (CGFloat)calorieValueSumWithBeginningTime:(NSInteger)beginningTime endTime:(NSInteger)endTime
{
    CGFloat calorieSum = 0;
    if(endTime > beginningTime)
    {
        CoreDataManager *coreDataManager = [CoreDataManager defaultManager];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(timeStamp >= %ld) AND (timeStamp <= %ld)", (long)beginningTime, (long)endTime];
        NSArray *savedInfos = [coreDataManager fetchObjectsWithEntityName:sWalkStepInfoEntityName sortDescriptors:nil predicate:predicate];
        for(WalkStepEntity *wsEntity in savedInfos)
        {
            calorieSum += wsEntity.calorie.floatValue;
        }
    }
    
    return calorieSum;
}

#pragma mark - TouchEvent

- (void)shareButtonTap:(UIButton *)sender
{
    NSLog(@"shareButtonTap");
    [[TYDShareActionSheet defaultSheet] actionSheetShow];
}

#pragma mark - BOSegmentedViewDelegate

- (void)segmentedView:(BOSegmentedView *)segmentedView valueChanged:(NSUInteger)value
{
    switch(value)
    {
        case 1:
            self.rankingInfos = self.rankingWeeklyInfos;
            self.introductionLabel.text = @"  最近一周消耗的卡路里排名（凌晨更新）";
            break;
        case 2:
            self.rankingInfos = self.rankingMonthlyInfos;
            self.introductionLabel.text = @"  最近一月消耗的卡路里排名（凌晨更新）";
            break;
        case 0:
        default:
            self.rankingInfos = self.rankingDailyInfos;
            self.introductionLabel.text = @"  最近一天消耗的卡路里排名（凌晨更新）";
            break;
    }
    [self userRankingInfoBarImportData];
    [self.tableView reloadData];
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

#pragma mark - UITableViewRelative

- (TYDUserRankingInfo *)userRankingInfoAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row < self.rankingInfos.count)
    {
        return self.rankingInfos[indexPath.row];
    }
    return nil;
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TYDUserRankingCell.cellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.rankingInfos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TYDUserRankingCell *cell = [tableView dequeueReusableCellWithIdentifier:sUserRankingCellIdentifier];
    cell.userRankingInfo = [self userRankingInfoAtIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - ConnectToServer

- (void)baseDataLoad
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:@(_userDailyCalorie) forKey:@"dayCalorie"];
    [params setValue:@(_userWeeklyCalorie) forKey:@"weekCalorie"];
    [params setValue:@(_userMonthlyCalorie) forKey:@"monthCalorie"];
    
    [self postURLRequestWithMessageCode:ServiceMsgCodeSportRankingInfo
                           HUDLabelText:nil
                                 params:params
                          completeBlock:^(id result) {
                              [self userSportRankingInfoLoadComplete:result];
                          }];
}

#pragma mark - ServerConnectionReceipt

- (NSArray *)rankingInfosCreateWithRankingDicInfos:(NSArray *)rankingDicInfos calorieKey:(NSString *)calorieKey
{
    NSMutableArray *rankingInfos = [NSMutableArray new];
    for(NSDictionary *rankingDicInfo in rankingDicInfos)
    {
        TYDUserRankingInfo *rankingInfo = [TYDUserRankingInfo new];
        [rankingInfo setAttributes:rankingDicInfo];
        rankingInfo.calorieValue = rankingDicInfo[calorieKey];
        //[rankingInfo calorieValueFix];
        [rankingInfos addObject:rankingInfo];
    }
    
    [rankingInfos sortUsingComparator:^NSComparisonResult(TYDUserRankingInfo * obj1, TYDUserRankingInfo * obj2) {
        return [obj1.rankingNumber compare:obj2.rankingNumber];
    }];
    
    return rankingInfos;
}

- (void)userSportRankingInfoLoadComplete:(id)result
{
    NSLog(@"userSportRankingInfoLoadComplete:%@", result);
    NSNumber *errorCode = result[@"errorCode"];
    if(errorCode.intValue == 0)
    {
        NSNumber *resultNumber = result[@"result"];
        if(resultNumber.intValue == 0)
        {
            NSArray *dailyRankingDicInfos = result[@"daySportList"];
            NSArray *weeklyRankingDicInfos = result[@"weekSportList"];
            NSArray *monthlyRankingDicInfos = result[@"monthSportList"];
            
            self.rankingDailyInfos = [self rankingInfosCreateWithRankingDicInfos:dailyRankingDicInfos calorieKey:@"dayCalorie"];
            self.rankingWeeklyInfos = [self rankingInfosCreateWithRankingDicInfos:weeklyRankingDicInfos calorieKey:@"weekCalorie"];
            self.rankingMonthlyInfos = [self rankingInfosCreateWithRankingDicInfos:monthlyRankingDicInfos calorieKey:@"monthCalorie"];
            self.rankingInfos = self.rankingDailyInfos;
            
            NSDictionary *userDailyRankingInfo = result[@"daySportRanking"];
            NSDictionary *userWeeklyRankingInfo = result[@"weekSportRanking"];
            NSDictionary *userMonthlyRankingInfo = result[@"monthSportRanking"];
            _userDailyRankingValue = [userDailyRankingInfo[@"count"] unsignedIntegerValue];
            _userWeeklyRankingValue = [userWeeklyRankingInfo[@"count"] unsignedIntegerValue];
            _userMonthlyRankingValue = [userMonthlyRankingInfo[@"count"] unsignedIntegerValue];
            
            [self userRankingInfoBarImportData];
            [self.tableView reloadData];
            [self showProgressCompleteWithLabelText:@"获取完成" isSucceed:YES];
            return;
        }
    }
    
    [self showProgressCompleteWithLabelText:@"获取失败" isSucceed:NO];
}

@end
