//
//  TYDRemindAlertViewController.m
//  Mofei
//
//  Created by macMini_Dev on 14-11-6.
//  Copyright (c) 2014年 Young. All rights reserved.
//
//  久坐提醒页面
//

#import "TYDRemindAlertViewController.h"
#import "TYDDataCenter.h"

#define nRemindAlertIntervalUnit        1800//(30 * 60)//30minute

@interface TYDRemindAlertViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@property (strong, nonatomic) UIView *promptBaseView;
@property (strong, nonatomic) UIView *promptBgView;
@property (strong, nonatomic) UIView *promptView;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIPickerView *intervalPicker;

//@property (nonatomic) BOOL originalIsOn;
//@property (nonatomic) NSUInteger originalInterval;
//@property (nonatomic) NSUInteger originalStartTime;
//@property (nonatomic) NSUInteger originalEndTime;

@property (nonatomic) NSUInteger todayBeginningTimeStamp;

@property (nonatomic) BOOL currentIsOn;
@property (nonatomic) NSUInteger currentInterval;
@property (nonatomic) NSUInteger currentStartTime;
@property (nonatomic) NSUInteger currentEndTime;

@property (strong, nonatomic) NSArray *minuteIntervals;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *titleLabels;
@property (weak, nonatomic) IBOutlet UISwitch *switcher;

@property (weak, nonatomic) IBOutlet UILabel *remindAlertIntervalLabel;
@property (weak, nonatomic) IBOutlet UILabel *remindAlertStartTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *remindAlertEndTimeLabel;

@end

@implementation TYDRemindAlertViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHex:0xefeef0];
    self.tableView.separatorColor = [UIColor colorWithHex:0xe1e1e1];
    
    [self localDataInitialize];
    [self navigationBarItemsLoad];
    [self subviewsLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self remindAlertInfoCheck];
    self.currentInterval = self.currentInterval;
    self.currentStartTime = self.currentStartTime;
    self.currentEndTime = self.currentEndTime;
}

- (void)localDataInitialize
{
    self.switcher.onTintColor = [UIColor colorWithHex:0xe23674];
    self.minuteIntervals = @[@(30), @(60), @(90), @(120)];
    self.selectedIndexPath = nil;
    self.todayBeginningTimeStamp = [BOTimeStampAssistor timeStampOfDayBeginningForToday];
    
    TYDDataCenter *dataCenter = [TYDDataCenter defaultCenter];
    if(!dataCenter.isDataValid
       || !dataCenter.remindAlertIsOn)
    {
        _currentIsOn = NO;
    }
    else
    {
        _currentIsOn = YES;
    }
    self.currentStartTime = dataCenter.remindAlertStartTime;
    self.currentEndTime = dataCenter.remindAlertEndTime;
    self.currentInterval = dataCenter.remindAlertInterval;
    
    self.currentStartTime %= nTimeIntervalSecondsPerDay;
    self.currentEndTime %= nTimeIntervalSecondsPerDay;
    self.currentInterval = self.currentInterval / nRemindAlertIntervalUnit * nRemindAlertIntervalUnit;
    
    NSUInteger secorePerHour = 3600;
    if(self.currentStartTime == 0)
    {
        self.currentStartTime = secorePerHour * 9;
    }
    if(self.currentEndTime == 0)
    {
        self.currentEndTime = secorePerHour * 20;
    }
    if(self.currentEndTime < self.currentStartTime)
    {
        self.currentEndTime = self.currentStartTime;
    }
    
    if(self.currentInterval < nRemindAlertIntervalUnit)
    {
        self.currentInterval = nRemindAlertIntervalUnit;
    }
}

- (void)navigationBarItemsLoad
{
    self.title = @"久坐提醒";
}

- (void)subviewsLoad
{
    [self tableFooterViewLoad];
    [self promptViewLoad];
}

- (void)tableFooterViewLoad
{
    CGRect frame = CGRectMake(0, 0, self.view.width, 20);
    UIView *tableFooterView = [[UIView alloc] initWithFrame:frame];
    tableFooterView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = tableFooterView;
    if([self.tableView respondsToSelector:@selector(separatorInset)])
    {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0.5, 19, 0, 19)];
    }
}

- (void)remindAlertInfoCheck
{
    UIColor *blackColor = [UIColor colorWithHex:0x323232];
    UIColor *pinkColor = [UIColor colorWithHex:0xe23674];
    UIColor *grayColor = [UIColor colorWithHex:0x969696];
    
    UILabel *raTitleLabel = self.titleLabels[0];
    UILabel *raIntervalTitleLabel = self.titleLabels[1];
    UILabel *raStartTimeTitleLabel = self.titleLabels[2];
    UILabel *raEndTimeTitleLabel = self.titleLabels[3];
    
    raTitleLabel.textColor = blackColor;
    if(self.currentIsOn)
    {
        raIntervalTitleLabel.textColor = blackColor;
        raStartTimeTitleLabel.textColor = blackColor;
        raEndTimeTitleLabel.textColor = blackColor;
        
        [self.switcher setOn:YES animated:YES];
        self.remindAlertIntervalLabel.textColor = pinkColor;
        self.remindAlertStartTimeLabel.textColor = pinkColor;
        self.remindAlertEndTimeLabel.textColor = pinkColor;
        
        for(int i = 0; i < 3; i++)
        {
            [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1]].selectionStyle = UITableViewCellSelectionStyleGray;
        }
    }
    else
    {
        raIntervalTitleLabel.textColor = grayColor;
        raStartTimeTitleLabel.textColor = grayColor;
        raEndTimeTitleLabel.textColor = grayColor;
        
        [self.switcher setOn:NO animated:YES];
        self.remindAlertIntervalLabel.textColor = grayColor;
        self.remindAlertStartTimeLabel.textColor = grayColor;
        self.remindAlertEndTimeLabel.textColor = grayColor;
        
        for(int i = 0; i < 3; i++)
        {
            [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1]].selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
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
    datePicker.datePickerMode = UIDatePickerModeTime;//UIDatePickerModeCountDownTimer
    datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_Hans_CN"];//@"en_US";//@"zh_CN"
    datePicker.minimumDate = [NSDate dateWithTimeIntervalSince1970:self.todayBeginningTimeStamp];
    datePicker.maximumDate = [NSDate dateWithTimeIntervalSince1970:self.todayBeginningTimeStamp + nTimeIntervalSecondsPerDay - 1];
    datePicker.minuteInterval = 10;
    [promptView addSubview:datePicker];
    
    UIPickerView *intervalPicker = [[UIPickerView alloc] initWithFrame:datePicker.frame];
    intervalPicker.backgroundColor = [UIColor whiteColor];
    intervalPicker.showsSelectionIndicator = YES;
    intervalPicker.dataSource = self;
    intervalPicker.delegate = self;
    [promptView addSubview:intervalPicker];
    
    promptView.frame = CGRectMake(0, 0, promptBaseView.width, datePicker.height + promptTitleBarHeight);
    
    UIButton *completeButton = [UIButton new];
    [completeButton setTitle:@"完成" forState:UIControlStateNormal];
    [completeButton setTitleColor:[UIColor colorWithHex:0xe23674] forState:UIControlStateNormal];
    [completeButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [completeButton addTarget:self action:@selector(completeButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    [completeButton sizeToFit];
    completeButton.size = CGSizeMake(completeButton.width + 16, promptTitleBarHeight);
    completeButton.topRight = CGPointMake(promptView.width - 4, 0);
    [promptView addSubview:completeButton];
    
    frame = CGRectMake(0, promptTitleBarHeight - 0.5, promptView.width, 0.5);
    UIView *separatorLine = [[UIView alloc] initWithFrame:frame];
    separatorLine.backgroundColor = [UIColor colorWithHex:0xe5e5e7];
    [promptView addSubview:separatorLine];
    
    intervalPicker.top = separatorLine.bottom;
    datePicker.top = separatorLine.bottom;
    
    datePicker.hidden = YES;
    intervalPicker.hidden = YES;
    promptBaseView.hidden = YES;
    promptBgView.alpha = 0;
    
    self.promptBaseView = promptBaseView;
    self.promptBgView = promptBgView;
    self.promptView = promptView;
    self.datePicker = datePicker;
    self.intervalPicker = intervalPicker;
}

- (void)promptViewShow:(UIView *)pickerView
{
    self.datePicker.hidden = YES;
    self.intervalPicker.hidden = YES;
    if(self.datePicker == pickerView)
    {
        self.datePicker.hidden = NO;
    }
    else if(self.intervalPicker == pickerView)
    {
        self.intervalPicker.hidden = NO;
    }
    
    self.tableView.scrollEnabled = NO;////
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
    self.tableView.scrollEnabled = YES;
    
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

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [BOAssistor indexPathShow:indexPath withTitle:@"indexPath"];
    if(!self.currentIsOn)
    {
        return;
    }
    
    if(indexPath.section == 1)
    {
        switch(indexPath.row)
        {
            case 0:
                [self selectRemindAlertIntervalRow:indexPath];
                break;
            case 1:
                [self selectRemindAlertStartTimeRow:indexPath];
                break;
            case 2:
                [self selectRemindAlertEndTimeRow:indexPath];
                break;
        }
    }
}

- (void)selectRemindAlertIntervalRow:(NSIndexPath *)indexPath
{
    self.selectedIndexPath = indexPath;
    
    NSInteger row = self.currentInterval / nRemindAlertIntervalUnit - 1;
    if(row < [self.intervalPicker numberOfRowsInComponent:0])
    {
        [self.intervalPicker selectRow:row inComponent:0 animated:NO];
    }
    [self promptViewShow:self.intervalPicker];
}

- (void)selectRemindAlertStartTimeRow:(NSIndexPath *)indexPath
{
    self.selectedIndexPath = indexPath;
    self.datePicker.date = [NSDate dateWithTimeIntervalSince1970:self.todayBeginningTimeStamp + self.currentStartTime];
    [self promptViewShow:self.datePicker];
}

- (void)selectRemindAlertEndTimeRow:(NSIndexPath *)indexPath
{
    self.selectedIndexPath = indexPath;
    self.datePicker.date = [NSDate dateWithTimeIntervalSince1970:self.todayBeginningTimeStamp + self.currentEndTime];
    [self promptViewShow:self.datePicker];
}

#pragma mark - UIPickerView DataSource & Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.minuteIntervals.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = @"";
    if(row < self.minuteIntervals.count)
    {
        title = [NSString stringWithFormat:@"%@分钟", self.minuteIntervals[row]];
    }
    return title;
}

#pragma mark - TouchEvent

- (IBAction)switcherValueChanged:(UISwitch *)sender
{
    TYDDataCenter *dataCenter = [TYDDataCenter defaultCenter];
    if(!dataCenter.isDataValid)
    {
        if(sender.isOn)
        {
            [self setNoticeText:@"设备未连接"];
            [sender setOn:NO animated:YES];
            return;
        }
    }
    else
    {
        self.currentIsOn = sender.isOn;
    }
}

- (void)promptBgViewTap:(id)sender
{
    NSLog(@"promptBgViewTap");
    [self promptViewHide];
    self.selectedIndexPath = nil;
}

- (void)completeButtonTap:(UIButton *)sender
{
    NSLog(@"completeButtonTap");
    [self promptViewHide];
    
    if(!self.selectedIndexPath
       || self.selectedIndexPath.section != 1)
    {
        return;
    }
    
    if(self.selectedIndexPath.row == 0)
    {
        NSUInteger row = [self.intervalPicker selectedRowInComponent:0];
        self.currentInterval = (row + 1) * nRemindAlertIntervalUnit;
    }
    else if(self.selectedIndexPath.row == 1)
    {
        self.currentStartTime = (NSUInteger)([self.datePicker.date timeIntervalSince1970]) - self.todayBeginningTimeStamp;
        if(self.currentEndTime < self.currentStartTime)
        {
            self.currentEndTime = self.currentStartTime;
        }
    }
    else if(self.selectedIndexPath.row == 2)
    {
        NSUInteger endTime = (NSUInteger)([self.datePicker.date timeIntervalSince1970]) - self.todayBeginningTimeStamp;
        if(endTime < self.currentStartTime)
        {
            [self setNoticeText:@"结束时间需要晚于开始时间"];
        }
        else
        {
            self.currentEndTime = endTime;
        }
    }
    
    self.selectedIndexPath = nil;
}

- (void)popBackEventWillHappen
{
    TYDDataCenter *dataCenter = [TYDDataCenter defaultCenter];
    if(self.currentIsOn != dataCenter.remindAlertIsOn
       || self.currentInterval != dataCenter.remindAlertInterval
       || self.currentStartTime != dataCenter.remindAlertStartTime
       || self.currentEndTime != dataCenter.remindAlertEndTime)
    {
        dataCenter.remindAlertIsOn = self.currentIsOn;
        dataCenter.remindAlertInterval = self.currentInterval;
        dataCenter.remindAlertStartTime = self.currentStartTime;
        dataCenter.remindAlertEndTime = self.currentEndTime;
        [dataCenter remindAlertInfoSave];
    }
    [super popBackEventWillHappen];
}

#pragma mark - OverrideSettingMethod

- (void)setCurrentIsOn:(BOOL)currentIsOn
{
    if(_currentIsOn != currentIsOn)
    {
        _currentIsOn = currentIsOn;
        [self.switcher setOn:currentIsOn animated:YES];
        [self remindAlertInfoCheck];
    }
}

- (void)setCurrentInterval:(NSUInteger)currentInterval
{
    if(_currentInterval != currentInterval)
    {
        _currentInterval = currentInterval;
        self.remindAlertIntervalLabel.text = [NSString stringWithFormat:@"%ld分钟", (long)(currentInterval / 60)];
    }
}

- (void)setCurrentStartTime:(NSUInteger)currentStartTime
{
    if(_currentStartTime != currentStartTime)
    {
        _currentStartTime = currentStartTime;
        self.remindAlertStartTimeLabel.text = [BOTimeStampAssistor getTimeStringWithTimeStamp:self.todayBeginningTimeStamp + currentStartTime dateStyle:BOTimeStampStringFormatStyleDateNone timeStyle:BOTimeStampStringFormatStyleTimeShort];
    }
}

- (void)setCurrentEndTime:(NSUInteger)currentEndTime
{
    if(_currentEndTime != currentEndTime)
    {
        _currentEndTime = currentEndTime;
        self.remindAlertEndTimeLabel.text = [BOTimeStampAssistor getTimeStringWithTimeStamp:self.todayBeginningTimeStamp + currentEndTime dateStyle:BOTimeStampStringFormatStyleDateNone timeStyle:BOTimeStampStringFormatStyleTimeShort];
    }
}

#pragma mark - TYDSuspendEventDelegate

- (void)applicationDidBecomeActive
{
    if(![TYDDataCenter defaultCenter].isDataValid)
    {
        if(self.switcher.isOn)
        {
            [self setNoticeText:@"设备未连接"];
            [self.switcher setOn:NO animated:YES];
        }
    }
}

@end
