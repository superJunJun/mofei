//
//  TYDBestieViewController.m
//  Mofei
//
//  Created by macMini_Dev on 14-8-12.
//  Copyright (c) 2014年 Young. All rights reserved.
//
//  "贴心闺蜜"首页
//

#import "TYDBestieViewController.h"
#import "TYDMensesRecordViewController.h"
#import "TYDBestieCalendarView.h"
#import "BOSwitchableIcon.h"
#import "BOCoverlayingGuideView.h"
#import "TYDMensesDataCenter.h"
#import "TYDDataCenter.h"
#import "TYDMensesInfo.h"
#import "TYDFileResourceManager.h"

#define sMensesDidBeginText             @"今天大姨妈来了么？"
#define sMensesDidEndText               @"今天大姨妈走了么？"
#define sMensesCannotRecordFuture       @"无法记录未来的日子哦"
//#define sMensesNoRecord                 @"没有记录哦"

#define sMensesHowToUpdateEndTime       @"如何修改月经结束日期：如果不是今天结束，请在结束那天选“是”；如果到今天还没有结束，等到了未来结束那天选“是”"
#define sMensesDurationTooLong          @"经期这么长，是不是记错啦？"
#define sMensesToofrequent              @"姨妈来得这么频繁，是不是记错啦？"

#define nDayCountMaxForMensesBloodDuration      14
#define nDayCountOfTwoMensesPeriodIntervelMin   5//定死两次间隔为5天

@interface TYDBestieViewController () <UIAlertViewDelegate, TYDBestieCalendarViewDelegate, BOSwitchableIconDelegate, TYDMensesDataCenterRefreshedDelegate>

@property (strong, nonatomic) TYDBestieCalendarView *calendarView;
@property (strong, nonatomic) UIButton *todayButton;

@property (strong, nonatomic) UIView *editView;
@property (strong, nonatomic) UILabel *promptLabel;
@property (strong, nonatomic) UIView *editInfoBaseView;
@property (strong, nonatomic) UILabel *editInfoLabel;
@property (strong, nonatomic) BOSwitchableIcon *switcher;

@property (strong, nonatomic) NSTimer *bestieBasicTimer;

@end

@implementation TYDBestieViewController
{
    BOOL _isNeedToShowBestieGuideView;
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
    TYDMensesDataCenter *mensesDataCenter = [TYDMensesDataCenter defaultCenter];
    mensesDataCenter.refreshedDelegate = self;
    if(mensesDataCenter.isMensesDataUpdated)
    {
        [self.calendarView mensesInfosInCurrentMonthUpdated];
        mensesDataCenter.isMensesDataUpdated = NO;
    }
    [self bestieBasicTimerCreate];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self bestieBasicTimerCancel];
    [TYDMensesDataCenter defaultCenter].refreshedDelegate = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //self.noticeBarCenter = CGPointMake(self.view.width * 0.5, self.view.height - 48 - 40);
    self.noticeBarCenter = CGPointMake(self.view.width * 0.5, self.view.height - 40);
    [self todayButtonStatusCheck];
    [self bestieGuideViewLoad];
    [self mensesDurationBasicInfoCheck];
}

- (void)localDataInitialize
{
    NSString *launchedMarkKey = @"bestieGuideViewAppearedMark";
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _isNeedToShowBestieGuideView = ![userDefaults boolForKey:launchedMarkKey];
    //_isNeedToShowBestieGuideView = YES;//Test
    if(_isNeedToShowBestieGuideView)
    {
        [userDefaults setBool:YES forKey:launchedMarkKey];
        [userDefaults synchronize];
    }
}

- (void)navigationBarItemsLoad
{
    //self.title = @"贴心闺蜜";
    
    UIButton *todayButton = [UIButton new];
    [todayButton setTitle:@"今天" forState:UIControlStateNormal];
    [todayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [todayButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [todayButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    todayButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [todayButton sizeToFit];
    [todayButton addTarget:self action:@selector(todayButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    todayButton.hidden = YES;
    UIBarButtonItem *todayBtnItem = [[UIBarButtonItem alloc] initWithCustomView:todayButton];
    self.navigationItem.leftBarButtonItem = todayBtnItem;
    
    UIBarButtonItem *recordListButtonItem = [BOAssistor barButtonItemCreateWithImageName:@"bestie_recordListBtn" highlightedImageName:@"bestie_recordListBtnH" target:self action:@selector(recordListButtonTap:)];
    self.navigationItem.rightBarButtonItem = recordListButtonItem;
    
    self.todayButton = todayButton;
}

- (void)subviewsLoad
{
    [self bgImageViewLoad];
    [self calendarViewLoad];
    [self editViewLoad];
    [self refreshTitleText];
    [self editViewStatusCheck];
}

- (void)bgImageViewLoad
{
    CGRect frame = self.view.bounds;
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:frame];
    bgImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    bgImageView.image = [UIImage imageNamed:@"bestieCalendar_bg"];
    [self.view insertSubview:bgImageView atIndex:0];
}

- (void)calendarViewLoad
{
    TYDBestieCalendarView *calendarView = [TYDBestieCalendarView new];
    calendarView.backgroundColor = [UIColor clearColor];
    calendarView.origin = CGPointZero;
    calendarView.delegate = self;
    [self.baseView addSubview:calendarView];
    
    self.baseViewBaseHeight = calendarView.bottom;
    self.calendarView = calendarView;
}

- (void)editViewLoad
{
    UIFont *textFont = [UIFont fontWithName:@"Arial" size:18];
    UIColor *textColor = [UIColor colorWithHex:0x585858];
    
    CGRect frame = CGRectMake(0, self.baseViewBaseHeight, self.baseView.width, 0);
    UIView *editView = [[UIView alloc] initWithFrame:frame];
    editView.backgroundColor = [UIColor clearColor];
    [self.baseView addSubview:editView];
    
    frame = editView.bounds;
    UILabel *promptLabel = [[UILabel alloc] initWithFrame:frame];
    promptLabel.backgroundColor = [UIColor clearColor];
    promptLabel.font = textFont;
    promptLabel.textColor = textColor;
    promptLabel.textAlignment = NSTextAlignmentCenter;
    promptLabel.text = sMensesCannotRecordFuture;
    [editView addSubview:promptLabel];
    
    UIView *editInfoBaseView = [[UIView alloc] initWithFrame:frame];
    editInfoBaseView.backgroundColor = [UIColor clearColor];
    [editView addSubview:editInfoBaseView];
    
    UILabel *editInfoLabel = [UILabel new];
    editInfoLabel.backgroundColor = [UIColor clearColor];
    editInfoLabel.font = textFont;
    editInfoLabel.textColor = textColor;
    editInfoLabel.text = sMensesDidBeginText;
    [editInfoLabel sizeToFit];
    [editInfoBaseView addSubview:editInfoLabel];
    
    UIImage *switcherYesImage = [UIImage imageNamed:@"bestieCalendar_checkBtnYes"];
    UIImage *switcherNoImage = [UIImage imageNamed:@"bestieCalendar_checkBtnNo"];
    BOSwitchableIcon *switcher = [[BOSwitchableIcon alloc] initWithImage:switcherNoImage imageH:switcherYesImage keepHighlightedState:NO];
    switcher.delegate = self;
    [editInfoBaseView addSubview:switcher];
    
    CGFloat intervalHor = 4;
    CGFloat intervalVer = 18;
    CGFloat height = MAX(switcher.height, editInfoLabel.height) + intervalVer * 2;
    editInfoBaseView.height = height;
    editView.height = height;
    promptLabel.height = height;
    
    editInfoLabel.center = editInfoBaseView.innerCenter;
    switcher.center = editInfoLabel.center;
    editInfoLabel.left = (editInfoBaseView.width - editInfoLabel.width - switcher.width - intervalHor) * 0.5;
    switcher.left = editInfoLabel.right + intervalHor;
    
    promptLabel.hidden = YES;
    
    self.editView = editView;
    self.promptLabel = promptLabel;
    self.editInfoBaseView = editInfoBaseView;
    self.editInfoLabel = editInfoLabel;
    self.switcher = switcher;
    self.baseViewBaseHeight = editView.bottom;
}

- (void)bestieGuideViewLoad
{
    if(_isNeedToShowBestieGuideView)
    {
        _isNeedToShowBestieGuideView = NO;
        CGPoint topRight = CGPointMake(self.view.width, 156);
        
        UIImageView *swipeGuideView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bestie_funcLeading_swipe"]];
        swipeGuideView.topRight = topRight;
        
        BOCoverlayingGuideView *guideView = [[BOCoverlayingGuideView alloc] initWithGuideViews:@[swipeGuideView]];
        [guideView show];
    }
}

- (void)refreshTitleText
{
    self.titleText = [BOTimeStampAssistor getTimeStringWithTimeStamp:self.calendarView.currentMonthBeginningTimeStamp dateStyle:BOTimeStampStringFormatStyleDateCM timeStyle:BOTimeStampStringFormatStyleTimeNone];
}

- (void)mensesDurationBasicInfoCheck
{
    TYDMensesDataCenter *mensesDataCenter = [TYDMensesDataCenter defaultCenter];
    TYDBestieCalendarView *calendarView = self.calendarView;
    if(mensesDataCenter.mensesBloodDuration != calendarView.mensesBloodDuration
       || mensesDataCenter.mensesDuration != calendarView.mensesDuration)
    {
        [calendarView mensesDurationBasicInfoUpdated];
    }
}

- (void)todayButtonStatusCheck
{
    NSUInteger todayBeginning = [BOTimeStampAssistor timeStampOfDayBeginningForToday];
    NSUInteger currentMonthBeginning = [BOTimeStampAssistor timeStampOfMonthBeginningWithTimerStamp:todayBeginning];
    if(todayBeginning == self.calendarView.selectedDateTimeStamp
       && currentMonthBeginning == self.calendarView.currentMonthBeginningTimeStamp)
    {
        self.todayButton.hidden = YES;
    }
    else
    {
        self.todayButton.hidden = NO;
    }
}

- (void)editViewStatusCheck
{
    TYDBestieCalendarView *calendarView = self.calendarView;
    BOOL *mensesBloodInfoList = [calendarView mensesBloodInfoListObtain];
    NSInteger beginningTime = [calendarView mensesBloodInfoMonthBeginningTimeStampObtain];
    
    NSInteger selectedDateBeginningTime = calendarView.selectedDateTimeStamp;
    NSInteger monthBeginningTimeForSelectedDate = [BOTimeStampAssistor timeStampOfMonthBeginningWithTimerStamp:selectedDateBeginningTime];
    
    if(monthBeginningTimeForSelectedDate == calendarView.currentMonthBeginningTimeStamp)
    {//中间页面，只操作当前页面
        if(selectedDateBeginningTime > calendarView.todayBeginningTimeStamp)
        {
            self.editInfoBaseView.hidden = YES;
            self.promptLabel.hidden = NO;
        }
        else
        {
            self.promptLabel.hidden = YES;
            self.editInfoBaseView.hidden = NO;
            int index = (int)((selectedDateBeginningTime - beginningTime) / nTimeIntervalSecondsPerDay);
            if(mensesBloodInfoList[index] == YES)
            {
                if(mensesBloodInfoList[index - 1] == YES)
                {
                    self.editInfoLabel.text = sMensesDidEndText;
                    if(mensesBloodInfoList[index + 1] == YES)
                    {
                        self.switcher.selected = NO;
                    }
                    else
                    {
                        self.switcher.selected = YES;
                    }
                }
                else
                {//开始日
                    self.switcher.selected = YES;
                    self.editInfoLabel.text = sMensesDidBeginText;
                }
            }
            else
            {
                self.switcher.selected = NO;
                int bloodIntervalDayCountMin = nDayCountOfTwoMensesPeriodIntervelMin;
                //int mensesBloodDuration = [TYDMensesDataCenter defaultCenter].mensesBloodDuration;
                if([self searchMensesBloodList:mensesBloodInfoList anchorIndex:index searchCount:bloodIntervalDayCountMin forward:YES])
                {//前向搜索，在行经周期内找到有标记的日期
                    self.editInfoLabel.text = sMensesDidEndText;
                }
                else
                {
                    self.editInfoLabel.text = sMensesDidBeginText;
                }
            }
        }
    }
    else
    {
        self.editInfoBaseView.hidden = YES;
        self.promptLabel.hidden = YES;
    }
}

//YES:碰到有标记过的日期
- (BOOL)searchMensesBloodList:(BOOL *)list
                  anchorIndex:(uint)anchorIndex
                  searchCount:(uint)searchCount
                      forward:(BOOL)isForward
{
    int bloodDayCount = 0;
    int offset = isForward ? (-1) : 1;
    int index = anchorIndex + offset;
    for(int count = 0; count < searchCount; count++)
    {
        if(list[index] == YES)
        {
            bloodDayCount++;
        }
        index += offset;
    }
    return (bloodDayCount > 0);
}

#pragma mark - TouchEvent

- (void)todayButtonTap:(UIButton *)sender
{
    NSLog(@"todayButtonTap");
    
    NSUInteger todayBeginning = [BOTimeStampAssistor timeStampOfDayBeginningForToday];
    self.calendarView.selectedDateTimeStamp = todayBeginning;
    self.calendarView.currentMonthBeginningTimeStamp = todayBeginning;
    self.todayButton.hidden = YES;
    [self refreshTitleText];
    [self editViewStatusCheck];
}

- (void)recordListButtonTap:(UIButton *)sender
{
    NSLog(@"recordListButtonTap");
    TYDMensesRecordViewController *vc = [TYDMensesRecordViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - TYDBestieCalendarViewDelegate

- (void)bestieCalendarViewHeightWillChange:(CGFloat)heightNew
{
    CGFloat topNew = self.calendarView.bottom + (heightNew - self.calendarView.height);
    CGFloat baseNewHeight = topNew + self.editView.height;
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.editView.top = topNew;
                         self.baseViewBaseHeight = baseNewHeight;
                     }
                     completion:nil];
}

- (void)bestieCalendarViewSelectedNewDate:(TYDBestieCalendarView *)view
{
    [self todayButtonStatusCheck];
    [self editViewStatusCheck];
}

- (void)bestieCalendarViewMonthChanged:(TYDBestieCalendarView *)view
{//日历滑动，月份改变
    [self refreshTitleText];
    [self todayButtonStatusCheck];
    [self editViewStatusCheck];
}

#pragma mark - BOSwitchableIconDelegate

- (void)switchableIconStateChanged:(BOSwitchableIcon *)switchableIcon
{
    //先予还原，判定后再更改
    switchableIcon.selected = !switchableIcon.isSelected;
    //if([TYDFileResourceManager defaultManager].isInCloudSynchronizeDuration)
    if([TYDDataCenter defaultCenter].cloudSynchronizeLocked)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"正在同步数据，请稍候......" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    BOOL isNeedToRefreshView = YES;
    
    TYDBestieCalendarView *calendarView = self.calendarView;
    NSInteger selectedDateBeginningTime = calendarView.selectedDateTimeStamp;
    
    TYDMensesDataCenter *mensesDataCenter = [TYDMensesDataCenter defaultCenter];
    NSArray *mensesInfoArray = [mensesDataCenter allMensesRecordInfos];
    int mensesBloodDuration = mensesDataCenter.mensesBloodDuration;
    TYDMensesInfo *mensesInfo = [mensesDataCenter relativeMensesRecordInfoWithTimeStamp:selectedDateBeginningTime];
    int bloodIntervalDayCountMin = nDayCountOfTwoMensesPeriodIntervelMin;
    NSInteger mensesBloodDurationIntervalMin = bloodIntervalDayCountMin * nTimeIntervalSecondsPerDay;
    NSInteger mensesBloodDurationMax = nDayCountMaxForMensesBloodDuration * nTimeIntervalSecondsPerDay;
    
    if(mensesInfo == nil)
    {
        if(mensesInfoArray.count == 0)
        {//无条目
            TYDMensesInfo *mensesInfoNew = [self mensesInfoCreateWithTimeStamp:selectedDateBeginningTime duration:mensesBloodDuration];
            [mensesDataCenter saveOneMensesRecordInfo:mensesInfoNew];
        }
        else
        {//现有条目都早于此时
            TYDMensesInfo *lastMensesInfo = mensesInfoArray.lastObject;
            
            if((selectedDateBeginningTime - lastMensesInfo.endTimeStamp) > mensesBloodDurationIntervalMin)
            {//可分两段，新建记录
                TYDMensesInfo *mensesInfoNew = [self mensesInfoCreateWithTimeStamp:selectedDateBeginningTime duration:mensesBloodDuration];
                [mensesDataCenter saveOneMensesRecordInfo:mensesInfoNew];
            }
            else
            {
                if((selectedDateBeginningTime - lastMensesInfo.timeStamp) >= mensesBloodDurationMax)
                {//新成记录超长
                    [self showConfirmAlertViewWithMessage:sMensesDurationTooLong delegate:nil];
                    isNeedToRefreshView = NO;
                }
                else
                {
                    [mensesDataCenter updateMensesRecordInfo:lastMensesInfo withNewEndTimeStamp:selectedDateBeginningTime];
                }
            }
        }
    }
    else
    {
        if(mensesInfo.timeStamp <= selectedDateBeginningTime
           && mensesInfo.endTimeStamp >= selectedDateBeginningTime)
        {//在已有记录条目时间区间内进行操作
            if(mensesInfo.timeStamp == selectedDateBeginningTime)
            {//开始时间
                [mensesDataCenter removeOneMensesRecordInfo:mensesInfo];
            }
            else if(mensesInfo.endTimeStamp == selectedDateBeginningTime)
            {//结束时间
                [self showConfirmAlertViewWithMessage:sMensesHowToUpdateEndTime delegate:nil];
                return;
            }
            else
            {
                [mensesDataCenter updateMensesRecordInfo:mensesInfo withNewEndTimeStamp:selectedDateBeginningTime];
            }
        }
        else
        {//选择时间在条目外，条目必然在选择时间之后
            NSUInteger infoItemIndex = [mensesInfoArray indexOfObject:mensesInfo];
            if(infoItemIndex == 0)
            {//选择时间在第一条之前
                NSInteger predicateEndTime = selectedDateBeginningTime + (nTimeIntervalSecondsPerDay * (mensesBloodDuration - 1));
                if(mensesInfo.timeStamp - predicateEndTime > mensesBloodDurationIntervalMin)
                {//可分两段，新建记录
                    TYDMensesInfo *mensesInfoNew = [self mensesInfoCreateWithTimeStamp:selectedDateBeginningTime duration:mensesBloodDuration];
                    [mensesDataCenter saveOneMensesRecordInfo:mensesInfoNew];
                }
                else
                {
                    if(mensesInfo.endTimeStamp - selectedDateBeginningTime >= mensesBloodDurationMax)
                    {//新记录超长
                        [self showConfirmAlertViewWithMessage:sMensesDurationTooLong delegate:nil];
                        isNeedToRefreshView = NO;
                    }
                    else
                    {
                        NSString *oldStartDateString = [BOTimeStampAssistor getTimeStringWithTimeStamp:mensesInfo.timeStamp dateStyle:BOTimeStampStringFormatStyleDateShortC1 timeStyle:BOTimeStampStringFormatStyleTimeNone];
                        NSString *newStartDateString = [BOTimeStampAssistor getTimeStringWithTimeStamp:selectedDateBeginningTime dateStyle:BOTimeStampStringFormatStyleDateShortC1 timeStyle:BOTimeStampStringFormatStyleTimeNone];
                        NSString *message = [NSString stringWithFormat:@"您已于%@标记了月经开始日，是否将月经开始日提前到%@", oldStartDateString, newStartDateString];
                        [self showCheckAlertViewWithMessage:message delegate:self];
                        isNeedToRefreshView = NO;
                    }
                }
            }
            else
            {//两条记录之间
                TYDMensesInfo *priorMensesInfo = mensesInfoArray[infoItemIndex - 1];
                if(selectedDateBeginningTime - priorMensesInfo.endTimeStamp > mensesBloodDurationIntervalMin)
                {//与前一条无关联
                    if(mensesInfo.timeStamp - selectedDateBeginningTime > mensesBloodDurationIntervalMin)
                    {//与后一条无关联
                        TYDMensesInfo *mensesInfoNew = [self mensesInfoCreateWithTimeStamp:selectedDateBeginningTime duration:mensesBloodDuration];
                        if(mensesInfo.timeStamp - mensesInfoNew.endTimeStamp > mensesBloodDurationIntervalMin)
                        {//新记录与后一条记录间隔适当
                            [mensesDataCenter saveOneMensesRecordInfo:mensesInfoNew];
                        }
                        else
                        {//新记录与后一条记录间隔过密，应合并
                            if(mensesInfo.endTimeStamp - mensesInfoNew.timeStamp >= mensesBloodDurationMax)
                            {//若合并，过长
                                [self showConfirmAlertViewWithMessage:sMensesDurationTooLong delegate:nil];
                                isNeedToRefreshView = NO;
                            }
                            else
                            {//可合并
                                NSString *oldStartDateString = [BOTimeStampAssistor getTimeStringWithTimeStamp:mensesInfo.timeStamp dateStyle:BOTimeStampStringFormatStyleDateShortC1 timeStyle:BOTimeStampStringFormatStyleTimeNone];
                                NSString *newStartDateString = [BOTimeStampAssistor getTimeStringWithTimeStamp:selectedDateBeginningTime dateStyle:BOTimeStampStringFormatStyleDateShortC1 timeStyle:BOTimeStampStringFormatStyleTimeNone];
                                NSString *message = [NSString stringWithFormat:@"您已于%@标记了月经开始日，是否将月经开始日提前到%@", oldStartDateString, newStartDateString];
                                [self showCheckAlertViewWithMessage:message delegate:self];
                                isNeedToRefreshView = NO;
                            }
                        }
                    }
                    else
                    {//与后一条有关联
                        if(mensesInfo.endTimeStamp - selectedDateBeginningTime >= mensesBloodDurationMax)
                        {//若合并，过长
                            [self showConfirmAlertViewWithMessage:sMensesDurationTooLong delegate:nil];
                            isNeedToRefreshView = NO;
                        }
                        else
                        {//可合并
                            NSString *oldStartDateString = [BOTimeStampAssistor getTimeStringWithTimeStamp:mensesInfo.timeStamp dateStyle:BOTimeStampStringFormatStyleDateShortC1 timeStyle:BOTimeStampStringFormatStyleTimeNone];
                            NSString *newStartDateString = [BOTimeStampAssistor getTimeStringWithTimeStamp:selectedDateBeginningTime dateStyle:BOTimeStampStringFormatStyleDateShortC1 timeStyle:BOTimeStampStringFormatStyleTimeNone];
                            NSString *message = [NSString stringWithFormat:@"您已于%@标记了月经开始日，是否将月经开始日提前到%@", oldStartDateString, newStartDateString];
                            [self showCheckAlertViewWithMessage:message delegate:self];
                            isNeedToRefreshView = NO;
                        }
                    }
                }
                else
                {//与前一条有关联
                    if(mensesInfo.timeStamp - selectedDateBeginningTime > mensesBloodDurationIntervalMin)
                    {//与后一条无关联
                        if(selectedDateBeginningTime - priorMensesInfo.timeStamp >= mensesBloodDurationMax)
                        {//与前一条合并，超长
                            [self showConfirmAlertViewWithMessage:sMensesDurationTooLong delegate:nil];
                            isNeedToRefreshView = NO;
                        }
                        else
                        {//可以合并
                            [mensesDataCenter updateMensesRecordInfo:priorMensesInfo withNewEndTimeStamp:selectedDateBeginningTime];
                        }
                    }
                    else
                    {//与后一条有关联
                        [self showConfirmAlertViewWithMessage:sMensesToofrequent delegate:nil];
                        isNeedToRefreshView = NO;
                    }
                }
            }
        }
    }
    
    if(isNeedToRefreshView)
    {
        [calendarView mensesInfosInCurrentMonthUpdated];
        [self editViewStatusCheck];
    }
}

- (void)showCheckAlertViewWithMessage:(NSString *)message delegate:(id)delegate
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:delegate cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}

- (void)showConfirmAlertViewWithMessage:(NSString *)message delegate:(id)delegate
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:delegate cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alertView show];
}

- (TYDMensesInfo *)mensesInfoCreateWithTimeStamp:(NSInteger)timeStamp
                                        duration:(int)duration
{
    TYDMensesInfo *mensesInfo = [TYDMensesInfo new];
    mensesInfo.timeStamp = timeStamp;
    mensesInfo.endTimeStamp = timeStamp + (nTimeIntervalSecondsPerDay * (duration - 1));
    return mensesInfo;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == alertView.firstOtherButtonIndex)
    {
        NSInteger selectedDateTime = self.calendarView.selectedDateTimeStamp;
        NSString *selectedDateString = [BOTimeStampAssistor getTimeStringWithTimeStamp:selectedDateTime dateStyle:BOTimeStampStringFormatStyleDateShortC1 timeStyle:BOTimeStampStringFormatStyleTimeNone];
        //更新经期起始日期
        if([alertView.message rangeOfString:selectedDateString].length > 0)
        {
            TYDMensesDataCenter *mensesDataCenter = [TYDMensesDataCenter defaultCenter];
            TYDMensesInfo *mensesInfo = [mensesDataCenter relativeMensesRecordInfoWithTimeStamp:selectedDateTime];
            if(mensesInfo)
            {
                [mensesDataCenter updateMensesRecordInfo:mensesInfo withNewStartTimeStamp:selectedDateTime];
                [self.calendarView mensesInfosInCurrentMonthUpdated];
                [self editViewStatusCheck];
            }
        }
    }
}

#pragma mark - TYDSuspendEventDelegate

- (void)applicationWillResignActive
{
    [self bestieBasicTimerCancel];
}

- (void)applicationDidBecomeActive
{
    [self bestieBasicTimerCreate];
}

#pragma mark - Timer

- (void)bestieBasicTimerInvalidate
{
    if([self.bestieBasicTimer isValid])
    {
        [self.bestieBasicTimer invalidate];
        self.bestieBasicTimer = nil;
    }
}

- (void)bestieBasicTimerCancel
{
    [self bestieBasicTimerInvalidate];
}

- (void)bestieBasicTimerCreate
{
    [self bestieBasicTimerInvalidate];
    [self bestieBasicTimerEvent];//先行校正
    CGFloat timerInterval = nBasicTimerInterval * 10;//10s
    self.bestieBasicTimer = [NSTimer scheduledTimerWithTimeInterval:timerInterval target:self selector:@selector(bestieBasicTimerEvent) userInfo:nil repeats:YES];
}

- (void)bestieBasicTimerEvent
{
    NSLog(@"bestieBasicTimerEvent");
    NSInteger todayBeginningTime = [BOTimeStampAssistor timeStampOfDayBeginningForToday];
    NSInteger monthBeginningTimeForToday = [BOTimeStampAssistor timeStampOfMonthBeginningWithTimerStamp:todayBeginningTime];
    if(todayBeginningTime != self.calendarView.todayBeginningTimeStamp)
    {//日期变更
        self.calendarView.todayBeginningTimeStamp = todayBeginningTime;
        [self todayButtonStatusCheck];//
        
        if(monthBeginningTimeForToday == self.calendarView.currentMonthBeginningTimeStamp)
        {//日历展示页所属月份为本月，刷新页面
            [self.calendarView mensesInfosInCurrentMonthUpdated];
        }
    }
}

#pragma mark - TYDMensesDataCenterRefreshedDelegate

- (void)mensesDataCenterSavedInfosRefreshed:(TYDMensesDataCenter *)dataCenter
{
    [self bestieBasicTimerCancel];
    [self.calendarView mensesInfosInCurrentMonthUpdated];
    [TYDMensesDataCenter defaultCenter].isMensesDataUpdated = NO;
    [self bestieBasicTimerCreate];
}

@end
