//
//  TYDUserInfoSettingController.m
//  Mofei
//
//  Created by macMini_Dev on 15/1/20.
//  Copyright (c) 2015年 Young. All rights reserved.
//

#import "TYDUserInfoSettingController.h"
#import "TYDMensesDataCenter.h"
#import "TYDMensesInfo.h"
#import "TYDBasicInfoConverter.h"

#define sNormalItemCellIdentifier       @"userInfoSettingItemCell"
#define nTableSectionHeaderViewHeight   14
#define nTableViewCellHeight            44
#define fCellTitleTextFont              [UIFont fontWithName:@"Arial" size:16]
#define fCellDetailTextFont             [UIFont fontWithName:@"Arial" size:14]

#define sModifiedUserInfoSaveInquire    @"信息已更改，是否保存？"

@interface TYDUserInfoSettingController () <UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIView *promptBaseView;
@property (strong, nonatomic) UIView *promptBgView;
@property (strong, nonatomic) UIView *promptView;
@property (strong, nonatomic) UILabel *promptTitleLabel;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIPickerView *pickerView;

@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@property (assign, nonatomic) NSInteger birthdayTimeStamp;  //生日
@property (assign, nonatomic) int weight;                   //身高，单位cm
@property (assign, nonatomic) int height;                   //体重，单位kg
@property (assign, nonatomic) int sportTarget;              //运动目标，单位卡路里
@property (assign, nonatomic) int mensesBloodDuration;      //行经天数
@property (assign, nonatomic) int mensesDuration;           //月经周期

@property (strong, nonatomic) NSArray *basicTitles;
@property (strong, nonatomic) NSArray *mensesTitles;
@property (assign, nonatomic) Scope pickerViewScope;
@property (assign, nonatomic) NSInteger pickerViewScopePace;
@property (strong, nonatomic) NSString *pickerViewUnitText;

@end

@implementation TYDUserInfoSettingController
{
    Scope _birthdayScope;
    Scope _heightScope;
    Scope _weightScope;
    Scope _sportTargetScope;
    Scope _mensesBloodDurationScope;
    Scope _mensesDurationScope;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHex:0xefeef0];
    
    [self localDataInitialize];
    [self navigationBarItemsLoad];
    [self subviewsLoad];
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
    _sportTargetScope = scopeMake(200, 400);
    _mensesBloodDurationScope = scopeMake(2, 14);
    _mensesDurationScope = scopeMake(15, 45);
    
    self.basicTitles = @[sAgeBasicTitle, sHeightBasicTitle, sWeightBasicTitle, @"每天运动目标"];
    self.mensesTitles = @[@"平均行经天数", @"平均月经周期"];
    self.pickerViewUnitText = @"";
    self.pickerViewScope = _heightScope;
    
    TYDUserInfo *userInfo = [TYDUserInfo sharedUserInfo];
    self.birthdayTimeStamp = userInfo.birthday.integerValue;
    self.weight = userInfo.weight.intValue;
    self.height = userInfo.height.intValue;
    self.sportTarget = userInfo.sportTarget.intValue;
    self.mensesBloodDuration = userInfo.mensesBloodDuration.intValue;
    self.mensesDuration = userInfo.mensesDuration.intValue;
    
    self.pickerViewScopePace = 1;
}

- (void)navigationBarItemsLoad
{
    self.title = @"个人信息";
    
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
    datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_Hans_CN"];
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
    //self.pickerViewScope = scopeMake(0, 0);
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
                unitText = sAgeBasicUnit;
                break;
            case 1:
                unitText = sHeightCentimeterUnitEn;
                break;
            case 2:
                unitText = sWeightBasicUnitEn;
                break;
            case 3:
                unitText = sCalorieBasicUnit;
                break;
        }
    }
    else
    {
        switch(indexPath.row)
        {
            case 0:
            case 1:
                unitText = sTimeDayBasicUnit;
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
            case 3:
                detailText = [NSString stringWithFormat:@"%d", self.sportTarget];
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
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"me_remindAlert_detailArrow"]];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    cell.textLabel.text = [self tableTitleAtIndexPath:indexPath];
    cell.detailTextLabel.text = [self infoDetailTextAtIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedIndexPath = indexPath;
    self.promptTitleLabel.text = [self tableTitleAtIndexPath:indexPath];
    if([self.promptTitleLabel.text isEqualToString:sAgeBasicTitle])
    {//fix
        self.promptTitleLabel.text = sBirthdayBasicTitle;
    }
    self.pickerViewUnitText = [self infoUnitTextAtIndexPath:indexPath];
    
    BOOL isDatePickerEnable = YES;
    NSInteger currentValue = 0;
    NSInteger scopePace = 1;
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
            case 3:
                isDatePickerEnable = NO;
                self.pickerViewScope = _sportTargetScope;
                currentValue = self.sportTarget;
                scopePace = 100;
                break;
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
        }
    }
    if(isDatePickerEnable)
    {
        self.datePicker.minimumDate = [NSDate dateWithTimeIntervalSince1970:self.pickerViewScope.startValue];
        self.datePicker.maximumDate = [NSDate dateWithTimeIntervalSince1970:self.pickerViewScope.endValue];
        self.datePicker.date = [NSDate dateWithTimeIntervalSince1970:currentValue];
        
        [self promptViewShow:self.datePicker];
    }
    else
    {
        self.pickerViewScopePace = scopePace;
        NSInteger row = (currentValue - self.pickerViewScope.startValue) / scopePace;
        [self.pickerView reloadAllComponents];
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
    return (countOfScope(self.pickerViewScope) + self.pickerViewScopePace - 1) / self.pickerViewScopePace;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSInteger titleValue = MIN((self.pickerViewScope.startValue + row * self.pickerViewScopePace), self.pickerViewScope.endValue);
    return [NSString stringWithFormat:@"%ld %@", (long)titleValue, self.pickerViewUnitText];
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
    
    if(indexPath.section == 0)
    {
        switch(indexPath.row)
        {
            case 0:
                self.birthdayTimeStamp = [[self.datePicker date] timeIntervalSince1970];
                break;
            case 1:
                self.height = (int)(self.pickerViewScope.startValue + [self.pickerView selectedRowInComponent:0]);
                break;
            case 2:
                self.weight = (int)(self.pickerViewScope.startValue + [self.pickerView selectedRowInComponent:0]);
            break;
                case 3:
                self.sportTarget = (int)MIN((self.pickerViewScope.startValue + [self.pickerView selectedRowInComponent:0] * self.pickerViewScopePace), self.pickerViewScope.endValue);
        }
    }
    else
    {
        switch(indexPath.row)
        {
            case 0:
                self.mensesBloodDuration = (int)(self.pickerViewScope.startValue + [self.pickerView selectedRowInComponent:0]);
                break;
            case 1:
                self.mensesDuration = (int)(self.pickerViewScope.startValue + [self.pickerView selectedRowInComponent:0]);
                break;
        }
    }
    [self.tableView reloadData];
}

- (void)saveButtonTap:(UIButton *)sender
{
    NSLog(@"saveButtonTap");
    [self promptViewHide];
    [self saveUserInfo];
}

- (void)popBackEventWillHappen
{
    if(![self userInfoChangedCheck])
    {
        [super popBackEventWillHappen];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:sModifiedUserInfoSaveInquire delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if([alertView.message isEqualToString:sModifiedUserInfoSaveInquire])
    {
        if(buttonIndex == alertView.cancelButtonIndex)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [self saveUserInfo];
        }
    }
}

#pragma mark - SaveUserInfo

- (BOOL)userInfoChangedCheck
{
    BOOL isChanged = YES;
    TYDUserInfo *userInfo = [TYDUserInfo sharedUserInfo];
    if((self.birthdayTimeStamp == userInfo.birthday.integerValue)
       && (self.height == userInfo.height.integerValue)
       && (self.weight == userInfo.weight.integerValue)
       && (self.sportTarget == userInfo.sportTarget.integerValue)
       && (self.mensesBloodDuration == userInfo.mensesBloodDuration.integerValue)
       && (self.mensesDuration == userInfo.mensesDuration.integerValue))
    {
        isChanged = NO;
    }
    
    return isChanged;
}

- (void)saveUserInfoLocal
{
    TYDUserInfo *userInfo = [TYDUserInfo sharedUserInfo];
    userInfo.birthday = @(self.birthdayTimeStamp);
    userInfo.height = @(self.height);
    userInfo.weight = @(self.weight);
    userInfo.sportTarget = @(self.sportTarget);
    userInfo.mensesBloodDuration = @(self.mensesBloodDuration);
    userInfo.mensesDuration = @(self.mensesDuration);
    [userInfo saveUserInfo];
}

- (void)saveUserInfo
{
    TYDUserInfo *userInfo = [TYDUserInfo sharedUserInfo];
    if(![self userInfoChangedCheck])
    {//虚像“已保存”
        [self showProgressHUDWithLabelText:nil];
        [self showProgressCompleteWithLabelText:@"保存完成" isSucceed:YES additionalTarget:self.navigationController action:@selector(popViewControllerAnimated:) object:@(YES)];
    }
    else
    {
        if(userInfo.isUserAccountEnable && [self networkIsValid])
        {
            [self saveUserInfoToServer];
        }
        else
        {
            [self saveUserInfoLocal];
            [self showProgressHUDWithLabelText:nil];
            [self showProgressCompleteWithLabelText:@"保存完成" isSucceed:YES additionalTarget:self.navigationController action:@selector(popViewControllerAnimated:) object:@(YES)];
        }
    }
}

#pragma mark - ConnectToServer

- (void)saveUserInfoToServer
{
    NSString *message = nil;
    if(![self networkIsValid])
    {
        message = sNetworkFailed;
    }
    
    if(message)
    {
        [self setNoticeText:message];
        return;
    }
    
    TYDUserInfo *userInfo = [TYDUserInfo sharedUserInfo];
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:userInfo.userID forKey:sPostUrlRequestUserAcountKey];
    [params setValue:@(self.birthdayTimeStamp) forKey:@"birthday"];
    [params setValue:@(self.height) forKey:@"height"];
    [params setValue:@(self.weight) forKey:@"weight"];
    [params setValue:@(self.sportTarget) forKey:@"sportsTarget"];
    [params setValue:@(self.mensesBloodDuration) forKey:@"avgMenses"];
    [params setValue:@(self.mensesDuration) forKey:@"avgPeriod"];
    
    NSDictionary *appendDic = [TYDBasicInfoConverter basicInfoConvertToServerInfo:params];
    [params setValuesForKeysWithDictionary:appendDic];
    NSLog(@"saveUserInfoToServer:%@", params);
    
    [self postURLRequestWithMessageCode:ServiceMsgCodeUserInfoUpload
                           HUDLabelText:nil
                                 params:params
                          completeBlock:^(id result) {
                              [self saveUserInfoToServerComplete:result];
                          }];
}

#pragma mark - ServerConnectReceipt

- (void)saveUserInfoToServerComplete:(id)result
{
    NSLog(@"saveUserInfoToServerComplete:%@", result);
    NSNumber *errorCode = result[@"errorCode"];
    if(errorCode.intValue == 0)
    {
        NSNumber *resultNumber = result[@"result"];
        if(resultNumber.intValue == 0)
        {
            [self saveUserInfoLocal];
            [self showProgressCompleteWithLabelText:@"保存完成" isSucceed:YES additionalTarget:self.navigationController action:@selector(popViewControllerAnimated:) object:@(YES)];
            return;
        }
    }
    [self showProgressCompleteWithLabelText:@"保存失败" isSucceed:NO];
}
@end
