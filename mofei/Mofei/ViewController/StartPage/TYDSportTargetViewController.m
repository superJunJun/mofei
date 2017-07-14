//
//  TYDSportTargetViewController.m
//  Mofei
//
//  Created by macMini_Dev on 14/12/10.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import "TYDSportTargetViewController.h"
#import "TYDUnitLabel.h"
#import "BOSegmentedView.h"
#import "TYDBasicInfoConverter.h"

@interface TYDSportTargetViewController () <BOSegmentedViewDelegate>

@property (strong, nonatomic) UIView *mainImageBaseView;
@property (strong, nonatomic) UIImageView *mainImageView;
@property (strong, nonatomic) BOSegmentedView *segmentedView;
@property (strong, nonatomic) UIView *sportTargetBaseView;
@property (strong, nonatomic) UILabel *sportTargetInfoLabel;
@property (strong, nonatomic) UILabel *stepTitleLabel;
@property (strong, nonatomic) UILabel *calorieTitleLabel;
@property (strong, nonatomic) UILabel *stepLabel;
@property (strong, nonatomic) UILabel *calorieLabel;

@property (strong, nonatomic) NSArray *targetTitles;
@property (strong, nonatomic) NSArray *targetInfos;
@property (strong, nonatomic) NSArray *mainImageNames;
@property (strong, nonatomic) NSArray *targetStepValues;
@property (strong, nonatomic) NSArray *targetCalorieValues;
@property (nonatomic) NSUInteger selectedTargetIndex;

@end

@implementation TYDSportTargetViewController

- (void)viewDidLoad
{
    NSLog(@"TYDSportTargetViewController viewDidLoad");
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHex:0xfdfdfd];
    
    [self localDataInitialize];
    [self navigationBarItemsLoad];
    [self basicViewsLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"TYDSportTargetViewController viewWillAppear");
    [super viewWillAppear:animated];
    [self importData];
}

- (void)importData
{
    _selectedTargetIndex = 0;
    self.selectedTargetIndex = 1;
    self.segmentedView.selectedSegmentIndex = self.selectedTargetIndex;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self subviewsLocalLayout];
}

- (void)subviewsLocalLayout
{
    CGSize baseViewSize = self.view.size;
    CGFloat baseViewHeight = baseViewSize.height;
    
    self.mainImageBaseView.origin = CGPointZero;
    self.segmentedView.origin = self.mainImageBaseView.bottomLeft;
    self.sportTargetBaseView.height = baseViewHeight - self.segmentedView.bottom;
    self.sportTargetBaseView.origin = self.segmentedView.bottomLeft;
    
    CGFloat targetItemIntervalVer = 8;
    self.stepTitleLabel.top = (self.sportTargetBaseView.height - (self.stepLabel.height + self.stepTitleLabel.height + targetItemIntervalVer)) * 0.5;
    self.calorieTitleLabel.top = self.stepTitleLabel.top;
    self.stepLabel.top = self.stepTitleLabel.bottom + targetItemIntervalVer;
    self.calorieLabel.top = self.stepLabel.top;
    
    CGFloat width_1_3 = self.sportTargetBaseView.width * 0.33;
    
    self.stepLabel.xCenter = width_1_3;
    self.calorieLabel.xCenter = self.sportTargetBaseView.width - width_1_3;
    self.stepTitleLabel.xCenter = self.stepLabel.xCenter;
    self.calorieTitleLabel.xCenter = self.calorieLabel.xCenter;
    
    self.sportTargetInfoLabel.top = (self.stepTitleLabel.top - self.sportTargetInfoLabel.height) * 0.3;
}

- (void)localDataInitialize
{
    self.targetTitles = @[@"很少运动", @"偶尔运动", @"经常运动"];
    self.targetInfos = @[@"很少运动，没什么时间", @"一般不运动，久坐时间长", @"经常运动，健康活力每一天"];
    
    BOOL isFemale = ([TYDUserInfo sharedUserInfo].sex.integerValue == TYDUserGenderTypeFemale);
    self.mainImageNames = @[@"sportTarget_imgFemaleSit", @"sportTarget_imgFemaleWalk", @"sportTarget_imgFemaleSport"];
    if(!isFemale)
    {
        self.mainImageNames = @[@"sportTarget_imgMaleSit", @"sportTarget_imgMaleWalk", @"sportTarget_imgMaleSport"];
    }
    self.targetStepValues = @[@7000, @10000, @15000];
    self.targetCalorieValues = @[@200, @300, @400];
}

- (void)navigationBarItemsLoad
{
    self.title = @"运动目标";
    self.backButtonVisible = NO;
    
    UIButton *saveButton = [UIButton new];
    [saveButton setTitle:@"保存" forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [saveButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [saveButton addTarget:self action:@selector(saveButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    [saveButton sizeToFit];
    UIBarButtonItem *saveBtnItem = [[UIBarButtonItem alloc] initWithCustomView:saveButton];
    self.navigationItem.rightBarButtonItem = saveBtnItem;
}

- (void)basicViewsLoad
{
    [self mainImageViewLoad];
    [self segmentedViewLoad];
    [self targetDetailViewLoad];
}

- (void)mainImageViewLoad
{
    CGRect frame = self.view.bounds;
    frame.size.height = [UIImage imageNamed:self.mainImageNames[0]].size.height;
    UIView *mainImageBaseView = [[UIView alloc] initWithFrame:frame];
    mainImageBaseView.backgroundColor = [UIColor clearColor];
    mainImageBaseView.layer.masksToBounds = YES;
    [self.view addSubview:mainImageBaseView];
    
    frame = mainImageBaseView.bounds;
    UIImageView *mainImageView = [[UIImageView alloc] initWithFrame:frame];
    [mainImageBaseView addSubview:mainImageView];
    
    self.mainImageBaseView = mainImageBaseView;
    self.mainImageView = mainImageView;
}

- (void)segmentedViewLoad
{
    CGRect frame = CGRectMake(0, 0, self.view.width, 40);
    UIColor *bgGrayColor = [UIColor colorWithHex:0xf3f3f6];
    NSArray *titles = self.targetTitles;
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

- (void)targetDetailViewLoad
{
    CGRect frame = self.view.bounds;
    UIView *sportTargetBaseView = [[UIView alloc] initWithFrame:frame];
    sportTargetBaseView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:sportTargetBaseView];
    
    UILabel *sportTargetInfoLabel = [UILabel new];
    sportTargetInfoLabel.backgroundColor = [UIColor clearColor];
    sportTargetInfoLabel.font = [UIFont fontWithName:@"Arial" size:13];
    sportTargetInfoLabel.textColor = [UIColor colorWithHex:0xbebebe];
    sportTargetInfoLabel.textAlignment = NSTextAlignmentCenter;
    sportTargetInfoLabel.text = @" ";
    [sportTargetInfoLabel sizeToFit];
    sportTargetInfoLabel.width = sportTargetBaseView.width;
    sportTargetInfoLabel.origin = CGPointZero;
    [sportTargetBaseView addSubview:sportTargetInfoLabel];
    
    UIFont *titleFont = [UIFont systemFontOfSize:16];
    UIColor *titleColor = [UIColor colorWithHex:0xa6a6a6];
    UIFont *detailFont = [UIFont fontWithName:sFontNameForRBNo2Light size:30];
    UIColor *detailColor = [UIColor colorWithHex:0x5c5c5c];
    
    UILabel *stepTitleLabel = [UILabel new];
    stepTitleLabel.backgroundColor = [UIColor clearColor];
    stepTitleLabel.font = titleFont;
    stepTitleLabel.textColor = titleColor;
    stepTitleLabel.text = @"步数";
    [stepTitleLabel sizeToFit];
    [sportTargetBaseView addSubview:stepTitleLabel];
    
    UILabel *calorieTitleLabel = [UILabel new];
    calorieTitleLabel.backgroundColor = [UIColor clearColor];
    calorieTitleLabel.font = titleFont;
    calorieTitleLabel.textColor = titleColor;
    calorieTitleLabel.text = @"卡路里";
    [calorieTitleLabel sizeToFit];
    [sportTargetBaseView addSubview:calorieTitleLabel];
    
    UILabel *stepLabel = [UILabel new];
    stepLabel.backgroundColor = [UIColor clearColor];
    stepLabel.font = detailFont;
    stepLabel.textColor = detailColor;
    stepLabel.text = @" ";
    [stepLabel sizeToFit];
    [sportTargetBaseView addSubview:stepLabel];
    
    UILabel *calorieLabel = [UILabel new];
    calorieLabel.backgroundColor = [UIColor clearColor];
    calorieLabel.font = detailFont;
    calorieLabel.textColor = detailColor;
    calorieLabel.text = @" ";
    [calorieLabel sizeToFit];
    [sportTargetBaseView addSubview:calorieLabel];
    
    self.sportTargetBaseView = sportTargetBaseView;
    self.sportTargetInfoLabel = sportTargetInfoLabel;
    self.stepTitleLabel = stepTitleLabel;
    self.calorieTitleLabel = calorieTitleLabel;
    self.stepLabel = stepLabel;
    self.calorieLabel = calorieLabel;
}

#pragma mark - TouchEvent

- (void)saveButtonTap:(UIButton *)sender
{
    NSLog(@"saveButtonTap");sender.enabled = NO;
    [self showProgressHUDWithLabelText:@""];
    [self saveUserSportTargetInfo];
}

#pragma mark - BOSegmentedViewDelegate

- (void)segmentedView:(BOSegmentedView *)segmentedView valueChanged:(NSUInteger)value
{
    if(value >= 3)
    {
        value = 0;
    }
    self.selectedTargetIndex = value;
}

#pragma mark - OverrideSettingMethod

- (void)setSelectedTargetIndex:(NSUInteger)index
{
    if(_selectedTargetIndex != index
       && index < 3)
    {
        _selectedTargetIndex = index;
        NSString *mainImageName = self.mainImageNames[index];
        NSString *targetInfo = self.targetInfos[index];
        NSNumber *stepValue = self.targetStepValues[index];
        NSNumber *calorieValue = self.targetCalorieValues[index];
        
        self.mainImageView.image = [UIImage imageNamed:mainImageName];
        self.sportTargetInfoLabel.text = targetInfo;
        self.stepLabel.text = stepValue.stringValue;
        self.calorieLabel.text = calorieValue.stringValue;
        [self.stepLabel sizeToFit];
        [self.calorieLabel sizeToFit];
        self.stepLabel.xCenter = self.stepTitleLabel.xCenter;
        self.calorieLabel.xCenter = self.calorieTitleLabel.xCenter;
    }
}

#pragma mark - Complete

- (void)saveUserSportTargetInfo
{
    TYDUserInfo *userInfo = [TYDUserInfo sharedUserInfo];
    NSNumber *calorieTarget = self.targetCalorieValues[self.selectedTargetIndex];
    
    userInfo.sportTarget = calorieTarget;
    [userInfo saveUserInfo];
    
    if(userInfo.isUserAccountEnable && [self networkIsValid])
    {//账号已登录、网络有效
        [self userSportTargetUploadToServer];
    }
    else
    {
        [self userSportTargetSaveCompleteAndPopBack];
    }
}

#pragma mark - ConnectToServer

- (void)userSportTargetUploadToServer
{
    TYDUserInfo *userInfo = [TYDUserInfo sharedUserInfo];
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:userInfo.userID forKey:sPostUrlRequestUserAcountKey];
    [params setValue:userInfo.sex forKey:@"sex"];
    [params setValue:userInfo.username forKey:@"name"];
    [params setValue:userInfo.birthday forKey:@"age"];
    [params setValue:userInfo.height forKey:@"height"];
    [params setValue:userInfo.weight forKey:@"weight"];
    [params setValue:userInfo.mensesBloodDuration forKey:@"avgMenses"];
    [params setValue:userInfo.mensesDuration forKey:@"avgPeriod"];
    [params setValue:userInfo.sportTarget forKey:@"sportsTarget"];
    //再次全部上传
    
    NSDictionary *appendDic = [TYDBasicInfoConverter basicInfoConvertToServerInfo:params];
    [params setValuesForKeysWithDictionary:appendDic];
    
    [self postURLRequestWithMessageCode:ServiceMsgCodeUserInfoUpload
                           HUDLabelText:nil
                                 params:params
                          completeBlock:^(id result) {
                              [self userSportTargetUploadToServerComplete:result];
                          }];
}

#pragma mark - ServerConnectionReceipt

- (void)postURLRequestFailed:(NSUInteger)msgCode result:(id)result
{
    if(msgCode != ServiceMsgCodeUserInfoUpload)
    {
        [super postURLRequestFailed:msgCode result:result];
    }
    else
    {
        [self userSportTargetSaveCompleteAndPopBack];
    }
}

- (void)userSportTargetUploadToServerComplete:(id)result
{
    NSLog(@"userSportTargetUploadToServerComplete:%@", result);
//    NSNumber *errorCode = result[@"errorCode"];
//    if(errorCode.intValue == 0)
//    {
//        NSNumber *resultNumber = result[@"result"];
//        if(resultNumber.intValue == 0)
//        {
//        }
//    }
    [self userSportTargetSaveCompleteAndPopBack];
}

- (void)userSportTargetSaveCompleteAndPopBack
{
    [self showProgressCompleteWithLabelText:@"保存完成" isSucceed:YES additionalTarget:self.navigationController action:@selector(popToRootViewControllerAnimated:) object:@(YES)];
}

@end
