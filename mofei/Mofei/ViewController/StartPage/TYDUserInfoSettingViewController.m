//
//  TYDUserInfoSettingViewController.m
//  Mofei
//
//  Created by macMini_Dev on 14/11/13.
//  Copyright (c) 2014年 Young. All rights reserved.
//
//  个人信息设定
//

#import "TYDUserInfoSettingViewController.h"
#import "TYDSportTargetViewController.h"
#import "TYDMensesDataCenter.h"
#import "TYDMensesInfo.h"
#import "TYDBasicInfoConverter.h"

#define sHeightUnitText     @"cm"
#define sWeightUnitText     @"kg"
#define sDayUnitText        @"天"
#define sAgeUnitText        @"岁"

//#define sGenderItemCellIdentifier       @"genderItemCell"
#define sNormalItemCellIdentifier       @"userInfoSettingItemCell"
#define nTableSectionHeaderViewHeight   14
#define nTableViewCellHeight            44

#define fCellTitleTextFont      [UIFont fontWithName:@"Arial" size:16]
#define fCellDetailTextFont     [UIFont fontWithName:@"Arial" size:14]

@interface TYDUserInfoSettingViewController () <UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) UIView *promptBaseView;
@property (strong, nonatomic) UIView *promptBgView;
@property (strong, nonatomic) UIView *promptView;
@property (strong, nonatomic) UILabel *promptTitleLabel;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIPickerView *pickerView;

@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@property (nonatomic) NSInteger birthdayTimeStamp;  //生日
@property (nonatomic) int weight;                   //身高，单位cm
@property (nonatomic) int height;                   //体重，单位kg
@property (nonatomic) int mensesBloodDuration;      //行经天数
@property (nonatomic) int mensesDuration;           //月经周期
@property (nonatomic) NSInteger recentMensesBloodStartTimeStamp;//最近月经开始时间
@property (strong, nonatomic) NSArray *basicTitles;
@property (strong, nonatomic) NSArray *mensesTitles;

@property (nonatomic) Scope pickerViewScope;
@property (strong, nonatomic) NSString *pickerViewUnitText;

@end

@implementation TYDUserInfoSettingViewController
{
    Scope _birthdayScope;
    Scope _heightScope;
    Scope _weightScope;
    Scope _mensesBloodDurationScope;
    Scope _mensesDurationScope;
    Scope _recentMensesBloodStartScope;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHex:0xefeef0];
    
    [self localDataInitialize];
    [self navigationBarItemsLoad];
    [self subviewsLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.pickerViewScope = scopeMake(0, 0);
}

- (void)localDataInitialize
{
    NSInteger todayBeginning = [BOTimeStampAssistor timeStampOfDayBeginningForToday];
    _birthdayScope = scopeMake([BOTimeStampAssistor getTimeStampWithYear:1925 month:1 day:1], todayBeginning);
    _heightScope = scopeMake(60, 240);
    _weightScope = scopeMake(25, 205);
    _mensesBloodDurationScope = scopeMake(2, 14);
    _mensesDurationScope = scopeMake(15, 45);
    _recentMensesBloodStartScope = scopeMake([BOTimeStampAssistor getTimeStampWithYear:2012 month:1 day:1], todayBeginning);
    
    self.basicTitles = @[@"年龄", @"身高", @"体重"];
    self.mensesTitles = @[@"平均行经天数", @"平均月经周期", @"上次月经来的时间"];
    if([TYDUserInfo sharedUserInfo].isUserAccountEnable)
    {
        self.mensesTitles = @[@"平均行经天数", @"平均月经周期"];
    }
    self.pickerViewUnitText = @"";
    self.pickerViewScope = _heightScope;
    
    TYDUserInfo *userInfo = [TYDUserInfo sharedUserInfo];
    self.birthdayTimeStamp = userInfo.birthday.integerValue;
    self.weight = userInfo.weight.intValue;
    self.height = userInfo.height.intValue;
    self.mensesBloodDuration = userInfo.mensesBloodDuration.intValue;
    self.mensesDuration = userInfo.mensesDuration.intValue;
    
    self.recentMensesBloodStartTimeStamp = todayBeginning;
}

- (void)navigationBarItemsLoad
{
    self.title = @"个人信息";
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

- (void)subviewsLoad
{
    [self tableViewLoad];
    [self tableFooterViewLoad];
    [self promptViewLoad];
}

- (void)tableViewLoad
{
    CGRect frame = self.view.bounds;
    UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.separatorColor = [UIColor colorWithHex:0xe1e1e1];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:tableView];
    
    self.tableView = tableView;
}

- (void)tableFooterViewLoad
{
    CGRect frame = CGRectMake(0, 0, self.view.width, 20);
    UIView *tableFooterView = [[UIView alloc] initWithFrame:frame];
    tableFooterView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = tableFooterView;
}

#pragma mark - PromptView

- (void)promptViewLoad
{
    UIView *baseView = self.view;
    CGFloat promptTitleBarHeight = 44;
    
    CGRect frame = baseView.bounds;
    UIView *promptBaseView = [[UIView alloc] initWithFrame:frame];
    promptBaseView.backgroundColor = [UIColor clearColor];
    promptBaseView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [baseView addSubview:promptBaseView];
    
    frame = promptBaseView.bounds;
    UIControl *promptBgView = [[UIControl alloc] initWithFrame:frame];
    promptBgView.backgroundColor = [UIColor colorWithHex:0x0 andAlpha:0.3];
    promptBgView.alpha = 0;
    promptBgView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [promptBgView addTarget:self action:@selector(promptBgViewTap:) forControlEvents:UIControlEventTouchUpInside];
    [promptBaseView addSubview:promptBgView];
    
    UIView *promptView = [UIView new];
    promptView.backgroundColor = [UIColor whiteColor];
    [promptBaseView addSubview:promptView];
    
    UIDatePicker *datePicker = [UIDatePicker new];
    datePicker.backgroundColor = [UIColor whiteColor];
    datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_Hans_CN"];//@"en_US";//@"zh_CN"
    [promptView addSubview:datePicker];
    
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:datePicker.frame];
    pickerView.backgroundColor = [UIColor whiteColor];
    pickerView.showsSelectionIndicator = YES;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    [promptView addSubview:pickerView];
    
    promptView.frame = CGRectMake(0, 0, promptBaseView.width, datePicker.height + promptTitleBarHeight);
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, promptBaseView.width, promptTitleBarHeight)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont fontWithName:@"Arial" size:16];
    titleLabel.textColor = [UIColor colorWithHex:0x323232];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [promptView addSubview:titleLabel];
    
    UIButton *confirmButton = [UIButton new];
    [confirmButton setTitle:@"确定" forState:UIControlStateNormal];
    [confirmButton setTitleColor:[UIColor colorWithHex:0xe23674] forState:UIControlStateNormal];
    [confirmButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [confirmButton addTarget:self action:@selector(confirmButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    [confirmButton sizeToFit];
    confirmButton.size = CGSizeMake(confirmButton.width + 16, promptTitleBarHeight);
    confirmButton.topRight = CGPointMake(promptView.width - 4, 0);
    [promptView addSubview:confirmButton];
    
    frame = CGRectMake(0, promptTitleBarHeight - 0.5, promptView.width, 0.5);
    UIView *separatorLine = [[UIView alloc] initWithFrame:frame];
    separatorLine.backgroundColor = [UIColor colorWithHex:0xcecece];
    [promptView addSubview:separatorLine];
    
    pickerView.top = separatorLine.bottom;
    datePicker.top = separatorLine.bottom;
    
    datePicker.hidden = YES;
    pickerView.hidden = YES;
    promptBaseView.hidden = YES;
    promptBgView.alpha = 0;
    
    self.promptBaseView = promptBaseView;
    self.promptBgView = promptBgView;
    self.promptView = promptView;
    self.promptTitleLabel = titleLabel;
    self.datePicker = datePicker;
    self.pickerView = pickerView;
}

- (void)promptViewShow:(UIView *)pickerView
{
    self.datePicker.hidden = YES;
    self.pickerView.hidden = YES;
    if(self.datePicker == pickerView)
    {
        self.datePicker.hidden = NO;
    }
    else if(self.pickerView == pickerView)
    {
        self.pickerView.hidden = NO;
    }
    
    self.promptBaseView.hidden = NO;
    self.promptBgView.alpha = 0;
    self.promptView.top = self.promptBgView.bottom;
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.promptBgView.alpha = 1;
                         self.promptView.bottom = self.promptBgView.bottom;
                     }
                     completion:nil];
}

- (void)promptViewHide
{
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.promptBgView.alpha = 0;
                         self.promptView.top = self.promptBgView.bottom;
                     }
                     completion:^(BOOL finished){
                         self.promptBaseView.hidden = YES;
                     }];
}

#pragma mark - UITableViewRelative

- (NSString *)tableTitleAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *titles = self.mensesTitles;
    if(indexPath.section == 0)
    {
        titles = self.basicTitles;
    }
    NSString *title = nil;
    if(indexPath.row < titles.count)
    {
        title = titles[indexPath.row];
    }
    return title;
}

- (NSString *)infoUnitTextAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *unitText = @"";
    if(indexPath.section == 0)
    {
        switch(indexPath.row)
        {
            case 0:
                unitText = sAgeUnitText;
                break;
            case 1:
                unitText = sHeightUnitText;
                break;
            case 2:
                unitText = sWeightUnitText;
                break;
        }
    }
    else
    {
        switch(indexPath.row)
        {
            case 0:
            case 1:
                unitText = sDayUnitText;
                break;
        }
    }
    return unitText;
}

- (NSString *)infoDetailTextAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *detailText = @"";
    if(indexPath.section == 0)
    {
        switch(indexPath.row)
        {
            case 0:
                detailText = [NSString stringWithFormat:@"%d", (int)[BOTimeStampAssistor getAgeWithTimeStamp:self.birthdayTimeStamp]];
                break;
            case 1:
                detailText = [NSString stringWithFormat:@"%d", self.height];
                break;
            case 2:
                detailText = [NSString stringWithFormat:@"%d", self.weight];
                break;
        }
    }
    else
    {
        switch(indexPath.row)
        {
            case 0:
                detailText = [NSString stringWithFormat:@"%d", self.mensesBloodDuration];
                break;
            case 1:
                detailText = [NSString stringWithFormat:@"%d", self.mensesDuration];
                break;
            case 2:
                detailText = [NSString stringWithFormat:@"%@", [BOTimeStampAssistor getDateStringWithTimeStamp:self.recentMensesBloodStartTimeStamp]];
                break;
        }
    }
    return [NSString stringWithFormat:@"%@%@", detailText, [self infoUnitTextAtIndexPath:indexPath]];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return self.basicTitles.count;
    }
    return self.mensesTitles.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return nTableSectionHeaderViewHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, nTableSectionHeaderViewHeight)];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nTableViewCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = sNormalItemCellIdentifier;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.textLabel.textColor = [UIColor colorWithHex:0x323232];
        cell.textLabel.font = fCellTitleTextFont;
        cell.detailTextLabel.textColor = [UIColor colorWithHex:0xe23674];
        cell.detailTextLabel.font = fCellDetailTextFont;
    }
    
    cell.textLabel.text = [self tableTitleAtIndexPath:indexPath];
    cell.detailTextLabel.text = [self infoDetailTextAtIndexPath:indexPath];
    
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"me_remindAlert_detailArrow"]];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.selectedIndexPath = indexPath;
    self.promptTitleLabel.text = [self tableTitleAtIndexPath:indexPath];
    if([self.promptTitleLabel.text isEqualToString:@"年龄"])
    {//fix
        self.promptTitleLabel.text = @"出生日期";
    }
    self.pickerViewUnitText = [self infoUnitTextAtIndexPath:indexPath];
    
    BOOL isDatePickerEnable = YES;
    NSInteger currentValue = 0;
    if(indexPath.section == 0)
    {
        switch(indexPath.row)
        {
            case 0:
                self.pickerViewScope = _birthdayScope;
                currentValue = self.birthdayTimeStamp;
                break;
            case 1:
                isDatePickerEnable = NO;
                self.pickerViewScope = _heightScope;
                currentValue = self.height;
                break;
            case 2:
                isDatePickerEnable = NO;
                self.pickerViewScope = _weightScope;
                currentValue = self.weight;
                break;
            default:
                return;
        }
    }
    else
    {
        switch(indexPath.row)
        {
            case 0:
                isDatePickerEnable = NO;
                self.pickerViewScope = _mensesBloodDurationScope;
                currentValue = self.mensesBloodDuration;
                break;
            case 1:
                isDatePickerEnable = NO;
                self.pickerViewScope = _mensesDurationScope;
                currentValue = self.mensesDuration;
                break;
            case 2:
                self.pickerViewScope = _recentMensesBloodStartScope;
                currentValue = self.recentMensesBloodStartTimeStamp;
                break;
            default:
                return;
        }
    }
    if(isDatePickerEnable)
    {
        self.datePicker.minimumDate = [NSDate dateWithTimeIntervalSince1970:self.pickerViewScope.startValue];
        self.datePicker.maximumDate = [NSDate dateWithTimeIntervalSince1970:self.pickerViewScope.endValue];
        [self.datePicker setDate:[NSDate dateWithTimeIntervalSince1970:currentValue] animated:YES];
        
        [self promptViewShow:self.datePicker];
    }
    else
    {
        [self.pickerView reloadAllComponents];
        NSInteger row = currentValue - self.pickerViewScope.startValue;
        [self.pickerView selectRow:row inComponent:0 animated:YES];
        [self promptViewShow:self.pickerView];
    }
}

#pragma mark - UIPickerViewDataSource & UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return countOfScope(self.pickerViewScope);
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%ld %@", (long)(self.pickerViewScope.startValue + row), self.pickerViewUnitText];
}

#pragma mark - TouchEvent

- (void)promptBgViewTap:(id)sender
{
    NSLog(@"promptBgViewTap");
    [self promptViewHide];
    self.selectedIndexPath = nil;
}

- (void)confirmButtonTap:(UIButton *)sender
{
    NSLog(@"confirmButtonTap");
    [self promptViewHide];
    
    NSIndexPath *indexPath = self.selectedIndexPath;
    self.selectedIndexPath = nil;
    BOOL needToRefreshTableView = NO;
    
    if(indexPath.section == 0)
    {
        switch(indexPath.row)
        {
            case 0:
                self.birthdayTimeStamp = [[self.datePicker date] timeIntervalSince1970];
                needToRefreshTableView = YES;
                break;
            case 1:
                self.height = (int)(self.pickerViewScope.startValue + [self.pickerView selectedRowInComponent:0]);
                needToRefreshTableView = YES;
                break;
            case 2:
                self.weight = (int)(self.pickerViewScope.startValue + [self.pickerView selectedRowInComponent:0]);
                needToRefreshTableView = YES;
                break;
        }
    }
    else
    {
        switch(indexPath.row)
        {
            case 0:
                self.mensesBloodDuration = (int)(self.pickerViewScope.startValue + [self.pickerView selectedRowInComponent:0]);
                needToRefreshTableView = YES;
                break;
            case 1:
                self.mensesDuration = (int)(self.pickerViewScope.startValue + [self.pickerView selectedRowInComponent:0]);
                needToRefreshTableView = YES;
                break;
            case 2:
                self.recentMensesBloodStartTimeStamp = [[self.datePicker date] timeIntervalSince1970];
                needToRefreshTableView = YES;
                break;
        }
    }
    if(needToRefreshTableView)
    {
        [self.tableView reloadData];
    }
}

- (void)saveButtonTap:(UIButton *)sender
{
    NSLog(@"saveButtonTap");
    [self promptViewHide];
    [self saveUserInfo];
}

#pragma mark - SaveUserInfo

- (void)saveUserInfo
{
    NSLog(@"userInfoSetting saveUserInfoStart");
    TYDUserInfo *userInfo = [TYDUserInfo sharedUserInfo];
    userInfo.sex = @(TYDUserGenderTypeFemale);
    userInfo.birthday = @(self.birthdayTimeStamp);
    userInfo.height = @(self.height);
    userInfo.weight = @(self.weight);
    userInfo.mensesBloodDuration = @(self.mensesBloodDuration);
    userInfo.mensesDuration = @(self.mensesDuration);
    [userInfo saveUserInfo];
    
    if(!userInfo.isUserAccountEnable)
    {
        NSLog(@"userInfoSetting saveMensesInfoToDataBase");
        TYDMensesInfo *mensesInfo = [TYDMensesInfo new];
        mensesInfo.timeStamp = self.recentMensesBloodStartTimeStamp;
        mensesInfo.endTimeStamp = self.recentMensesBloodStartTimeStamp + (nTimeIntervalSecondsPerDay * (self.mensesBloodDuration - 1));
        mensesInfo.syncFlag = NO;
        mensesInfo.modifiedFlag = NO;
        
        TYDMensesDataCenter *mensesDataCenter = [TYDMensesDataCenter defaultCenter];
        [mensesDataCenter saveOneMensesRecordInfo:mensesInfo];
    }
    
    NSLog(@"userInfoSetting saveMark");
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *markKey = sUserBasicInfoSettedMarkKey;
    [userDefaults setBool:YES forKey:markKey];
    [userDefaults synchronize];
    
    NSLog(@"userInfoSetting netConnect");
    
    if(userInfo.isUserAccountEnable && [self networkIsValid])
    {//账号已登录、网络有效
        [self userInfoUploadToServer];
    }
    else
    {
        NSLog(@"continueToSetSportTarget");
        [self continueToSetSportTarget];
    }
}

#pragma mark - ConnectToServer

- (void)userInfoUploadToServer
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
    [params setValue:userInfo.sportTarget forKey:@"sportsTarget"];//有默认值
    //[params setValue:userInfo.avatarID forKey:@"headimgId"];
    
    NSDictionary *appendDic = [TYDBasicInfoConverter basicInfoConvertToServerInfo:params];
    [params setValuesForKeysWithDictionary:appendDic];
    
    [self postURLRequestWithMessageCode:ServiceMsgCodeUserInfoUpload
                           HUDLabelText:nil
                                 params:params
                          completeBlock:^(id result) {
                              [self userInfoUploadToServerComplete:result];
                          }];
}

#pragma mark - ServerConnectionReceipt

- (void)userInfoUploadToServerComplete:(id)result
{
    NSLog(@"userInfoUploadToServerComplete:%@", result);
    [self hiddenProgressHUD];
    [self continueToSetSportTarget];
}

- (void)postURLRequestFailed:(NSUInteger)msgCode result:(id)result
{
    if(msgCode != ServiceMsgCodeUserInfoUpload)
    {
        [super postURLRequestFailed:msgCode result:result];
    }
    else
    {
        [self continueToSetSportTarget];
    }
}

- (void)continueToSetSportTarget
{
    TYDSportTargetViewController *vc = [TYDSportTargetViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
