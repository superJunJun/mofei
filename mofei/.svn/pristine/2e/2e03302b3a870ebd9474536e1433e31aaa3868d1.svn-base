//
//  TYDBestieCalendarView.m
//  Mofei
//
//  Created by macMini_Dev on 14/11/12.
//  Copyright (c) 2014年 Young. All rights reserved.
//
//  贴心闺蜜 -- 月经日历
//

#import "TYDBestieCalendarView.h"
#import "TYDBestieCalendar.h"
#import "TYDCalendarDateBlock.h"

#import "TYDMensesDataCenter.h"
#import "TYDMensesInfo.h"

#define nGraySeparatorLineWidth     0.5
#define nBestieCalendarWidth        320
#define nDateBlockHeight            52
#define nCalendarCountMax           3
#define nWeekDayTitleBarHeight      20
#define nExplainBarHeight           35
#define nCalendarHeightMax          (nDateBlockHeight * nDateBlockRowMax + nGraySeparatorLineWidth)

#define nDaysCountFor3MonthsMax     100//(31 * 2 + 30)

#define nOvulateDayIntervalToBloodInMenses      14
#define nPregnentPeriodIntervalBeforeOvulate    5
#define nPregnentPeriodIntervalAfterOvulate     4
#define nPregnentPeriodIntervalTotal            (nPregnentPeriodIntervalBeforeOvulate + 1 + nPregnentPeriodIntervalAfterOvulate)

//TYDBestieCalendarView
@interface TYDBestieCalendarView () <TYDBestieCalendarDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *explainBar;
@property (strong, nonatomic) NSMutableArray *calendarViews;

//易孕期相关排列参照，用于前推//和月经周期标准表参照
//长度：nPregnentPeriodIntervalTotal
@property (strong, nonatomic) NSArray *standarMensesPregnentPeriodInfoList;
//月经周期参照
@property (strong, nonatomic) NSArray *standarMensesDurationInfoList;

@end

@implementation TYDBestieCalendarView
{
    MensesInfoDayType _mensesDayInfoTypeList[nDaysCountFor3MonthsMax];
    BOOL _mensesBloodInfoList[nDaysCountFor3MonthsMax];
    
    NSInteger _monthBeginningTimeStamp0;
    NSInteger _monthBeginningTimeStamp1;
    NSInteger _monthBeginningTimeStamp2;
    
    //range.location:index, range.length:dayCount
    NSRange _mensesInfoRangeForMonth0;
    NSRange _mensesInfoRangeForMonth1;
    NSRange _mensesInfoRangeForMonth2;
}

//星期抬头、日历、底部说明，3个部分
- (instancetype)init
{
    CGRect frame = CGRectMake(0, 0, nBestieCalendarWidth, nWeekDayTitleBarHeight + nCalendarHeightMax + nExplainBarHeight);
    if(self = [super initWithFrame:frame])
    {
        [self weekDayTitleBarLoad];
        [self explainBarLoad];
        
        frame = CGRectMake(0, nWeekDayTitleBarHeight, nBestieCalendarWidth, nCalendarHeightMax);
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:frame];
        scrollView.backgroundColor = [UIColor clearColor];
        scrollView.contentSize = frame.size;
        scrollView.pagingEnabled = YES;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.scrollEnabled = YES;
        scrollView.bounces = NO;
        scrollView.delegate = self;
        [self addSubview:scrollView];
        
        NSMutableArray *calendarViews = [NSMutableArray new];
        CGSize blockSize = CGSizeMake(frame.size.width / nDateBlockPerRow, nDateBlockHeight);
        CGPoint origin = CGPointZero;
        for(int i = 0; i < nCalendarCountMax; i++)
        {
            TYDBestieCalendar *calendar = [[TYDBestieCalendar alloc] initWithBlockSize:blockSize];
            calendar.delegate = self;
            calendar.origin = origin;
            [scrollView addSubview:calendar];
            [calendarViews addObject:calendar];
            origin.x += calendar.width;
        }
        scrollView.contentSize = CGSizeMake(origin.x, self.height);
        scrollView.contentOffset = CGPointMake(scrollView.width, 0);
        
        NSUInteger todayBeginning = [BOTimeStampAssistor timeStampOfDayBeginningForToday];
        
        self.scrollView = scrollView;
        self.calendarViews = calendarViews;
        
        [self baseDataInit];
        _todayBeginningTimeStamp = todayBeginning;
        self.selectedDateTimeStamp = todayBeginning;
        self.currentMonthBeginningTimeStamp = [BOTimeStampAssistor timeStampOfMonthBeginningWithTimerStamp:todayBeginning];
        
//        [self mensesDayInfoListReset];
//        [self dispatchMensesInfo];
    }
    return self;
}

- (void)weekDayTitleBarLoad
{
    CGRect frame = CGRectMake(0, 0, nBestieCalendarWidth, nWeekDayTitleBarHeight);
    UIView *weekDayTitleBar = [[UIView alloc] initWithFrame:frame];
    weekDayTitleBar.backgroundColor = [UIColor clearColor];
    [self addSubview:weekDayTitleBar];
    
    NSArray *weekDayTitles = @[@"日", @"一",  @"二", @"三", @"四", @"五", @"六"];
    UIColor *weekDayTitleColor = [UIColor colorWithHex:0x83757b];
    UIFont *weekDayTitleFont = [UIFont fontWithName:@"Arial" size:13];
    NSUInteger dayCountPerWeek = 7;
    frame.size.width /= dayCountPerWeek;
    for(int i = 0; i < dayCountPerWeek; i++)
    {
        UILabel *weekDayTitleLabel = [[UILabel alloc] initWithFrame:frame];
        weekDayTitleLabel.backgroundColor = [UIColor clearColor];
        weekDayTitleLabel.font = weekDayTitleFont;
        weekDayTitleLabel.textColor = weekDayTitleColor;
        weekDayTitleLabel.text = weekDayTitles[i];
        weekDayTitleLabel.textAlignment = NSTextAlignmentCenter;
        [weekDayTitleBar addSubview:weekDayTitleLabel];
        
        frame.origin.x += frame.size.width;
    }
}

- (void)explainBarLoad
{
    CGFloat top = nWeekDayTitleBarHeight + nCalendarHeightMax;
    CGRect frame = CGRectMake(0, top, nBestieCalendarWidth, nExplainBarHeight);
    UIView *explainBar = [[UIView alloc] initWithFrame:frame];
    explainBar.backgroundColor = [UIColor clearColor];
    [self addSubview:explainBar];
    
    NSArray *explainIconNames = @[@"bestieCalendar_bloodDayIcon", @"bestieCalendar_safeDayIcon", @"bestieCalendar_predictionDayIcon", @"bestieCalendar_pregnantDayIcon", @"bestieCalendar_ovulateDayIcon"];
    NSArray *explainTexts = @[@"月经期", @"安全期", @"预测期", @"易孕期", @"排卵日"];
    NSArray *explainTextColors = @[[UIColor colorWithHex:0xe93384], [UIColor colorWithHex:0x68b635], [UIColor colorWithHex:0xe3498e], [UIColor colorWithHex:0xa857c0], [UIColor colorWithHex:0xa857c0]];
    UIFont *explainTextFont = [UIFont fontWithName:@"Arial" size:12];
    CGFloat innerInterval = 2;
    
    int explainItemCount = 5;
    frame = CGRectMake(0, 0, nBestieCalendarWidth / explainItemCount, nExplainBarHeight);
    CGFloat yCenter = CGRectGetMidY(frame);
    
    for(int i = 0; i < explainItemCount; i++)
    {
        UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:explainIconNames[i]]];
        [explainBar addSubview:icon];
        
        UILabel *explainLabel = [UILabel new];
        explainLabel.backgroundColor = [UIColor clearColor];
        explainLabel.font = explainTextFont;
        explainLabel.textColor = explainTextColors[i];
        explainLabel.text = explainTexts[i];
        [explainLabel sizeToFit];
        [explainBar addSubview:explainLabel];
        
        CGFloat left = (frame.size.width - icon.width - explainLabel.width - innerInterval) * 0.5;
        left += frame.origin.x;
        icon.yCenter = yCenter;
        icon.left = left;
        explainLabel.center = icon.center;
        explainLabel.left = icon.right + innerInterval;
        
        frame.origin.x += frame.size.width;
    }
    
    UIView *grayLine = [[UIView alloc] initWithFrame:CGRectMake(0, explainBar.height - nGraySeparatorLineWidth, explainBar.width, nGraySeparatorLineWidth)];
    grayLine.backgroundColor = [UIColor colorWithHex:0xcecece];
    [explainBar addSubview:grayLine];
    
    self.explainBar = explainBar;
}

#pragma mark - OverrideSettingMethod

- (void)setTodayBeginningTimeStamp:(NSInteger)todayBeginningTimeStamp
{
    _todayBeginningTimeStamp = todayBeginningTimeStamp;
    for(TYDBestieCalendar *calendar in self.calendarViews)
    {
        calendar.todayBeginningTimeStamp = todayBeginningTimeStamp;
    }
}

- (void)setCurrentMonthBeginningTimeStamp:(NSInteger)currentMonthBeginningTimeStamp
{
    currentMonthBeginningTimeStamp = [BOTimeStampAssistor timeStampOfMonthBeginningWithTimerStamp:currentMonthBeginningTimeStamp];//校正
    if(_currentMonthBeginningTimeStamp == currentMonthBeginningTimeStamp)
    {
        TYDBestieCalendar *calendar1 = self.calendarViews[1];
        if(calendar1.selectedDateTimeStamp != self.selectedDateTimeStamp)
        {
            calendar1.selectedDateTimeStamp = self.selectedDateTimeStamp;
        }
        return;
    }
    
    _currentMonthBeginningTimeStamp = currentMonthBeginningTimeStamp;
    NSInteger previousMonthBeginningTimeStamp = [BOTimeStampAssistor timeStampOfMonthBeginningWithTimerStamp:currentMonthBeginningTimeStamp - 1];
    NSInteger nextMonthBeginningTimeStamp = currentMonthBeginningTimeStamp + [BOTimeStampAssistor daysPerMonthWithTimeStamp:currentMonthBeginningTimeStamp] * nTimeIntervalSecondsPerDay;
    
    [self mensesDayInfoListReset];
    TYDBestieCalendar *calendar0 = self.calendarViews[0];
    TYDBestieCalendar *calendar1 = self.calendarViews[1];
    TYDBestieCalendar *calendar2 = self.calendarViews[2];
    if(calendar0.monthBeginningTimeStamp == currentMonthBeginningTimeStamp)
    {//前向
        calendar2.monthBeginningTimeStamp = previousMonthBeginningTimeStamp;
        self.calendarViews = [@[calendar2, calendar0, calendar1] mutableCopy];
        
        //[self dispatchMensesInfosForCalenderView:calendar2 withMensesInfoRange:_mensesInfoRangeForMonth0];
    }
    else if(calendar2.monthBeginningTimeStamp == currentMonthBeginningTimeStamp)
    {//后向
        calendar0.monthBeginningTimeStamp = nextMonthBeginningTimeStamp;
        self.calendarViews = [@[calendar1, calendar2, calendar0] mutableCopy];
        
        //[self dispatchMensesInfosForCalenderView:calendar0 withMensesInfoRange:_mensesInfoRangeForMonth2];
    }
    else
    {//大幅度变换日期, 或初始化
        calendar0.monthBeginningTimeStamp = previousMonthBeginningTimeStamp;
        calendar1.monthBeginningTimeStamp = currentMonthBeginningTimeStamp;
        calendar2.monthBeginningTimeStamp = nextMonthBeginningTimeStamp;
        //[self dispatchMensesInfo];
    }
    [self dispatchMensesInfo];
    
    CGPoint origin = CGPointZero;
    for(TYDBestieCalendar *calendar in self.calendarViews)
    {
        calendar.selectedDateTimeStamp = self.selectedDateTimeStamp;
        calendar.origin = origin;
        origin.x += calendar.width;
    }
    
    TYDBestieCalendar *currentCalendar = self.calendarViews[1];
    CGFloat validHeight = currentCalendar.bestieCalendarValidSize.height;
    
    self.scrollView.contentOffset = CGPointMake(currentCalendar.width, 0);
    self.scrollView.contentSize = CGSizeMake(currentCalendar.width * self.calendarViews.count, validHeight);
    if(self.scrollView.height != validHeight)
    {
        CGFloat heightNew = nWeekDayTitleBarHeight + validHeight + nExplainBarHeight;
        if([self.delegate respondsToSelector:@selector(bestieCalendarViewHeightWillChange:)])
        {
            [self.delegate bestieCalendarViewHeightWillChange:heightNew];
        }
        [UIView animateWithDuration:0.25
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.scrollView.height = validHeight;
                             self.explainBar.top = validHeight + nWeekDayTitleBarHeight;
                             self.height = heightNew;
                         }
                         completion:nil];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)calendarCurrentMonthChanged:(BOOL)isIncrease
{
    if(isIncrease)
    {
        self.currentMonthBeginningTimeStamp += [BOTimeStampAssistor daysPerMonthWithTimeStamp:self.currentMonthBeginningTimeStamp] * nTimeIntervalSecondsPerDay;
    }
    else
    {
        self.currentMonthBeginningTimeStamp = [BOTimeStampAssistor timeStampOfMonthBeginningWithTimerStamp:self.currentMonthBeginningTimeStamp - 1];
    }
    if([self.delegate respondsToSelector:@selector(bestieCalendarViewMonthChanged:)])
    {
        [self.delegate bestieCalendarViewMonthChanged:self];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger offsetRadio = scrollView.contentOffset.x / scrollView.width;
    [BOAssistor pointShow:scrollView.contentOffset withTitle:@"scrollView.contentOffset"];
    NSLog(@"offsetRadio:%d", (int)offsetRadio);
    switch(offsetRadio)
    {
        case 0:
            [self calendarCurrentMonthChanged:NO];
            break;
        case 2:
            [self calendarCurrentMonthChanged:YES];
            break;
        case 1:
        default:
            break;
    }
}

#pragma mark - BaseDataInit

- (void)mensesPregnentPeriodInfoInit
{
    int listLength = nPregnentPeriodIntervalTotal;
    NSMutableArray *infoList = [[NSMutableArray alloc] initWithCapacity:listLength];
    for(int i = 0; i < listLength; i++)
    {
        [infoList addObject:@(MensesInfoDayTypePregnant)];
    }
    [infoList replaceObjectAtIndex:nPregnentPeriodIntervalBeforeOvulate withObject:@(MensesInfoDayTypeOvulate)];
    
    self.standarMensesPregnentPeriodInfoList = infoList;
    NSLog(@"infoList:%@", infoList);
}

- (void)baseDataInit
{
    [self mensesPregnentPeriodInfoInit];
    [self mensesDurationBasicInfoInit];
}

- (BOOL)mensesDurationBasicInfoReset
{
    int mensesBloodDuration = [TYDMensesDataCenter defaultCenter].mensesBloodDuration;
    int mensesDuration = [TYDMensesDataCenter defaultCenter].mensesDuration;
    if(self.mensesDuration != mensesDuration
       || self.mensesBloodDuration != mensesBloodDuration)
    {
        [self mensesDurationBasicInfoInit];
        return YES;
    }
    return NO;
}

- (void)mensesDurationBasicInfoInit
{
    int mensesBloodDuration = [TYDMensesDataCenter defaultCenter].mensesBloodDuration;
    int mensesDuration = [TYDMensesDataCenter defaultCenter].mensesDuration;
//    int pregnantDuration = mensesDuration / 3;
//    int pregnantStartDay = (mensesDuration - pregnantDuration) * 0.5;
//    //int ovulateDay = pregnantStartDay + pregnantDuration * 0.5;
//    int ovulateDay = mensesDuration  * 0.5;
    
    NSMutableArray *mensesDurationList = [NSMutableArray new];
    
    int index = 0;
    for(index = 0; index < mensesDuration; index++)
    {
        [mensesDurationList addObject:@(MensesInfoDayTypeSafe)];
    }
    int ovulateDay = mensesDuration - nOvulateDayIntervalToBloodInMenses;
    int pregnentTailDay = ovulateDay + nPregnentPeriodIntervalAfterOvulate;
    //从后往前赋值
    for(int subscript = nPregnentPeriodIntervalTotal - 1; subscript >= 0; subscript--, pregnentTailDay--)
    {
        //表单下标到零
        if(pregnentTailDay >= 0)
        {
            [mensesDurationList replaceObjectAtIndex:pregnentTailDay withObject:self.standarMensesPregnentPeriodInfoList[subscript]];
        }
        else
        {
            break;
        }
    }
    for(index = 0; index < mensesBloodDuration; index++)
    {
        [mensesDurationList replaceObjectAtIndex:index withObject:@(MensesInfoDayTypePrediction)];
    }
    
//    for(index = 0; index < mensesBloodDuration; index++)
//    {//首部行经预测期
//        [mensesDurationList addObject:@(MensesInfoDayTypePrediction)];
//    }
//    for(index = mensesBloodDuration; index < mensesDuration; index++)
//    {//安全期覆盖
//        [mensesDurationList addObject:@(MensesInfoDayTypeSafe)];
//    }
//    
//    //可插入易孕期预测
//    if(mensesDuration - mensesBloodDuration >= nOvulateDayIntervalToBloodInMenses)
//    {
//        //排卵日
//        int ovulateDay = mensesDuration - nOvulateDayIntervalToBloodInMenses;
//        [mensesDurationList replaceObjectAtIndex:ovulateDay withObject:@(MensesInfoDayTypeOvulate)];
//        for(index = 1; index <= nPregnentPeriodIntervalAfterOvulate; index++)
//        {//后向易孕期预测
//            [mensesDurationList replaceObjectAtIndex:(index + ovulateDay) withObject:@(MensesInfoDayTypePregnant)];
//        }
//        //前向易孕期预测，或有
//        if(ovulateDay - mensesBloodDuration > 0)
//        {
//            for(index = 1; index <= nPregnentPeriodIntervalBeforeOvulate; index++)
//            {
//                int subscript = ovulateDay - index;
//                if([mensesDurationList[subscript] intValue] != MensesInfoDayTypeSafe)
//                {
//                    break;
//                }
//                [mensesDurationList replaceObjectAtIndex:subscript withObject:@(MensesInfoDayTypePregnant)];
//            }
//        }
//    }
    
    _mensesBloodDuration = mensesBloodDuration;
    _mensesDuration = mensesDuration;
    self.standarMensesDurationInfoList = mensesDurationList;
    NSLog(@"mensesDurationList:%@", mensesDurationList);
}

#pragma mark - DispatchInfo

- (void)dispatchMensesInfosForCalenderView:(TYDBestieCalendar *)calendarView withMensesInfoRange:(NSRange)mensesInfoRange
{
    if(!calendarView)
    {
        return;
    }
    
    int count = (int)mensesInfoRange.length;
    int location = (int)mensesInfoRange.location;
    NSMutableArray *mensesInfos = [[NSMutableArray alloc] initWithCapacity:count];
    NSMutableArray *mensesBloodInfos = [[NSMutableArray alloc] initWithCapacity:count];
    
    NSArray *mensesRecoreInfos = [TYDMensesDataCenter defaultCenter].allMensesRecordInfos;
    if(mensesRecoreInfos.count > 0)
    {
        TYDMensesInfo *firstMensesInfo = mensesRecoreInfos.firstObject;
        NSInteger monthBeginningForFirstMensesInfo = [BOTimeStampAssistor timeStampOfMonthBeginningWithTimerStamp:firstMensesInfo.timeStamp];
        NSInteger priorMonthBeginningForFirstMensesInfo = [BOTimeStampAssistor timeStampOfMonthBeginningWithTimerStamp:monthBeginningForFirstMensesInfo - 1];
        if(calendarView.monthBeginningTimeStamp >= priorMonthBeginningForFirstMensesInfo)
        {
            for(int index = 0; index < count; index++)
            {
                [mensesInfos addObject:@(_mensesDayInfoTypeList[index + location])];
                [mensesBloodInfos addObject:@(_mensesBloodInfoList[index + location])];
            }
        }
    }
    
    [calendarView setMensesInfos:mensesInfos andMensesBloodInfos:mensesBloodInfos];
}

- (void)dispatchMensesInfo
{
    TYDBestieCalendar *calendar0 = self.calendarViews[0];
    TYDBestieCalendar *calendar1 = self.calendarViews[1];
    TYDBestieCalendar *calendar2 = self.calendarViews[2];
    [self dispatchMensesInfosForCalenderView:calendar0 withMensesInfoRange:_mensesInfoRangeForMonth0];
    [self dispatchMensesInfosForCalenderView:calendar1 withMensesInfoRange:_mensesInfoRangeForMonth1];
    [self dispatchMensesInfosForCalenderView:calendar2 withMensesInfoRange:_mensesInfoRangeForMonth2];
}

#pragma mark - MensesDayInfoList

- (NSMutableArray *)mensesInfosWithBeginningTimeStamp:(NSInteger)beginningTimeStamp endTimeStamp:(NSInteger)endTimeStamp
{
    if(beginningTimeStamp > endTimeStamp)
    {
        return nil;
    }
    
    NSInteger duration = endTimeStamp - beginningTimeStamp;
    NSArray *mensesInfos = [TYDMensesDataCenter defaultCenter].allMensesRecordInfos;
    NSMutableArray *infos = [[NSMutableArray alloc] initWithCapacity:4];
    for(TYDMensesInfo *infoItem in mensesInfos)
    {//中心点距离 不大于 两者总长半值
        NSInteger centerDistance2 = ABS(((beginningTimeStamp + endTimeStamp) - (infoItem.timeStamp + infoItem.endTimeStamp)));
        NSInteger lengthTotal = ABS((duration + infoItem.endTimeStamp - infoItem.timeStamp));
        if(centerDistance2 <= lengthTotal)
        {
            [infos addObject:infoItem];
        }
    }
    return infos;
}

- (void)mensesDayInfoTypeListReset
{//经期预测表重置
    
    NSLog(@"mensesDayInfoTypeListReset Start");
    TYDMensesDataCenter *mensesDataCenter = [TYDMensesDataCenter defaultCenter];
    NSArray *mensesInfos = mensesDataCenter.allMensesRecordInfos;
    NSInteger beginningTime = _monthBeginningTimeStamp0;
    NSInteger endTime = [BOTimeStampAssistor timeStampOfMonthEndWithTimerStamp:_monthBeginningTimeStamp2];
    int countTotal = (int)(_mensesInfoRangeForMonth0.length + _mensesInfoRangeForMonth1.length + _mensesInfoRangeForMonth2.length);
    int mensesDuration = (int)self.standarMensesDurationInfoList.count;
    
    if(mensesInfos.count == 0)
    {//无数据
        for(int index = 0; index < countTotal; index++)
        {
            _mensesDayInfoTypeList[index] = MensesInfoDayTypeNone;
        }
    }
    else
    {
        for(int index = 0; index < countTotal; index++)
        {
            _mensesDayInfoTypeList[index] = MensesInfoDayTypeSafe;
        }
        
        NSMutableArray *infos = [self mensesInfosWithBeginningTimeStamp:beginningTime endTimeStamp:endTime];
        if(infos.count > 0)
        {
            TYDMensesInfo *localFirstMensesInfo = infos.firstObject;
            if(localFirstMensesInfo.timeStamp > beginningTime)
            {//基于当前时间区段最早的记录，影响到本页
                NSUInteger index = [infos indexOfObject:localFirstMensesInfo];
                if(index > 0)
                {//不是第一条记录
                    TYDMensesInfo *priorMensesInfo = infos[index - 1];
                    int dayInterval = (int)((localFirstMensesInfo.timeStamp - priorMensesInfo.endTimeStamp) / nTimeIntervalSecondsPerDay);
                    if(dayInterval > nOvulateDayIntervalToBloodInMenses)
                    {//有易孕期 回推测算
                        int baseIndex = (int)((localFirstMensesInfo.timeStamp - _monthBeginningTimeStamp0) / nTimeIntervalSecondsPerDay);
                        int priorMensesInfoEndIndex = (int)((priorMensesInfo.endTimeStamp - _monthBeginningTimeStamp0) / nTimeIntervalSecondsPerDay);
                        int ovulateDayIndex = baseIndex - nOvulateDayIntervalToBloodInMenses;
                        int pregnentTailDayIndex = ovulateDayIndex + nPregnentPeriodIntervalAfterOvulate;
                        //从后往前赋值
                        for(int subscript = nPregnentPeriodIntervalTotal - 1; subscript >= 0; subscript--, pregnentTailDayIndex--)
                        {
                            //表单下标到零 或者 与前一条记录有交集时停止
                            if(pregnentTailDayIndex >= 0 && pregnentTailDayIndex > priorMensesInfoEndIndex)
                            {
                                _mensesDayInfoTypeList[pregnentTailDayIndex] = [self.standarMensesPregnentPeriodInfoList[subscript] intValue];
                            }
                            else
                            {
                                break;
                            }
                        }
                    }
                }
                else
                {//是第一条记录，向前预测不须顾虑交集问题
                    int baseIndex = (int)((localFirstMensesInfo.timeStamp - _monthBeginningTimeStamp0) / nTimeIntervalSecondsPerDay);
                    int ovulateDayIndex = baseIndex - nOvulateDayIntervalToBloodInMenses;
                    int pregnentTailDayIndex = ovulateDayIndex + nPregnentPeriodIntervalAfterOvulate;
                    //从后往前赋值
                    for(int subscript = nPregnentPeriodIntervalTotal - 1; subscript >= 0; subscript--, pregnentTailDayIndex--)
                    {
                        //表单下标到零
                        if(pregnentTailDayIndex >= 0)
                        {
                            _mensesDayInfoTypeList[pregnentTailDayIndex] = [self.standarMensesPregnentPeriodInfoList[subscript] intValue];
                        }
                        else
                        {
                            break;
                        }
                    }
                }
            }
            
            //如果为一条信息，则在之前已经处理；
            if(infos.count > 1)
            {//与当前期间有交集的记录不止一条
                for(int i = 1; i < infos.count; i++)
                {
                    TYDMensesInfo *mensesInfo0 = infos[i - 1];//前一条
                    TYDMensesInfo *mensesInfo1 = infos[i];//当前条
                    
                    int dayInterval = (int)((mensesInfo1.timeStamp - mensesInfo0.endTimeStamp) / nTimeIntervalSecondsPerDay);
                    if(dayInterval > nOvulateDayIntervalToBloodInMenses)
                    {
                        int baseIndex = (int)((mensesInfo1.timeStamp - _monthBeginningTimeStamp0) / nTimeIntervalSecondsPerDay);
                        int priorMensesInfoEndIndex = (int)((mensesInfo0.endTimeStamp - _monthBeginningTimeStamp0) / nTimeIntervalSecondsPerDay);
                        int ovulateDayIndex = baseIndex - nOvulateDayIntervalToBloodInMenses;
                        int pregnentTailDayIndex = ovulateDayIndex + nPregnentPeriodIntervalAfterOvulate;
                        //从后往前赋值
                        for(int subscript = nPregnentPeriodIntervalTotal - 1; subscript >= 0; subscript--, pregnentTailDayIndex--)
                        {
                            //与前一条记录有交集时停止
                            if(pregnentTailDayIndex > priorMensesInfoEndIndex)
                            {
                                _mensesDayInfoTypeList[pregnentTailDayIndex] = [self.standarMensesPregnentPeriodInfoList[subscript] intValue];
                            }
                            else
                            {
                                break;
                            }
                        }
                    }
                }
            }
        }
        //有后向预测
        if(endTime > self.todayBeginningTimeStamp)
        {
            TYDMensesInfo *standarMensesInfo = mensesInfos.lastObject;
            int listIndex = 0;
            int index = 0;
            if(beginningTime >= self.todayBeginningTimeStamp)
            {
                listIndex = ((beginningTime - standarMensesInfo.timeStamp) / nTimeIntervalSecondsPerDay) % mensesDuration;
                index = 0;
            }
            else
            {
                listIndex = ((self.todayBeginningTimeStamp - standarMensesInfo.timeStamp) / nTimeIntervalSecondsPerDay) % mensesDuration;
                listIndex = (listIndex + mensesDuration) % mensesDuration;
                
                index = (int)((self.todayBeginningTimeStamp - beginningTime) / nTimeIntervalSecondsPerDay);
            }
            for(; index < countTotal; index++)
            {
                _mensesDayInfoTypeList[index] = [self.standarMensesDurationInfoList[listIndex] intValue];
                listIndex++;
                listIndex %= mensesDuration;
            }
            //对最后一条进行校正
            if(standarMensesInfo.endTimeStamp <= self.todayBeginningTimeStamp)
            {//未跨界
                int intervalDayCount = (int)((self.todayBeginningTimeStamp - standarMensesInfo.timeStamp) / nTimeIntervalSecondsPerDay);
                if(beginningTime < self.todayBeginningTimeStamp
                   && intervalDayCount <= mensesDuration)
                {//最后一条记录已完成，预测期不显示，并且记录在当前页面可见
                    index = (int)((self.todayBeginningTimeStamp - beginningTime) / nTimeIntervalSecondsPerDay);
                    int predicateDayTotal = mensesDataCenter.mensesBloodDuration;
                    for(int predicateDayCount = 0; predicateDayCount < predicateDayTotal; predicateDayCount++)
                    {
                        if(index < countTotal
                           && _mensesDayInfoTypeList[index] == MensesInfoDayTypePrediction)
                        {
                            _mensesDayInfoTypeList[index++] = MensesInfoDayTypeSafe;
                        }
                        else
                        {
                            break;
                        }
                    }
                }
            }
            else
            {//跨界 结束日在未来
                
            }
        }
    }
}

- (void)mensesDayInfoListReset
{//经期预测表和行经信息表重置
    [self mensesDurationBasicInfoReset];
    NSArray *mensesInfos = [TYDMensesDataCenter defaultCenter].allMensesRecordInfos;
    
    NSInteger monthBeginningTimeStamp1 = self.currentMonthBeginningTimeStamp;
    int daysCountForMonth1 = [BOTimeStampAssistor daysPerMonthWithTimeStamp:monthBeginningTimeStamp1];
    NSInteger monthBeginningTimeStamp0 = [BOTimeStampAssistor timeStampOfMonthBeginningWithTimerStamp:monthBeginningTimeStamp1 - 1];
    int daysCountForMonth0 = [BOTimeStampAssistor daysPerMonthWithTimeStamp:monthBeginningTimeStamp0];
    NSInteger monthBeginningTimeStamp2 = monthBeginningTimeStamp1 + daysCountForMonth1 * nTimeIntervalSecondsPerDay;
    int daysCountForMonth2 = [BOTimeStampAssistor daysPerMonthWithTimeStamp:monthBeginningTimeStamp2];
    
    _monthBeginningTimeStamp0 = monthBeginningTimeStamp0;
    _monthBeginningTimeStamp1 = monthBeginningTimeStamp1;
    _monthBeginningTimeStamp2 = monthBeginningTimeStamp2;
    
    _mensesInfoRangeForMonth0 = NSMakeRange(0, daysCountForMonth0);
    _mensesInfoRangeForMonth1 = NSMakeRange(daysCountForMonth0, daysCountForMonth1);
    _mensesInfoRangeForMonth2 = NSMakeRange(daysCountForMonth0 + daysCountForMonth1, daysCountForMonth2);
    int countTotal = daysCountForMonth0 + daysCountForMonth1 + daysCountForMonth2;
    
    if(mensesInfos.count == 0)
    {//无数据
        for(int index = 0; index < countTotal; index++)
        {
            _mensesDayInfoTypeList[index] = MensesInfoDayTypeNone;
            _mensesBloodInfoList[index] = NO;
        }
    }
    else
    {
        //放置经期预测表
        [self mensesDayInfoTypeListReset];
//        TYDMensesInfo *standarMensesInfo = mensesInfos.lastObject;
//        int listIndex = ((monthBeginningTimeStamp0 - standarMensesInfo.timeStamp) / nTimeIntervalSecondsPerDay) % self.mensesDuration;
//        listIndex = (listIndex + self.mensesDuration) % self.mensesDuration;//处理负值
//        
//        for(int index = 0; index < countTotal; index++)
//        {
//            _mensesDayInfoTypeList[index] = [self.standarMensesDurationInfoList[listIndex] intValue];
//            listIndex++;
//            listIndex %= self.standarMensesDurationInfoList.count;
//        }
        
        //放置行经信息
        for(int index = 0; index < countTotal; index++)
        {//预置
            _mensesBloodInfoList[index] = NO;
        }
        NSInteger beginningTimeStamp = _monthBeginningTimeStamp0;
        NSInteger duration = countTotal * nTimeIntervalSecondsPerDay - 1;
        NSInteger endTimeStamp = beginningTimeStamp + duration;
        
        NSMutableArray *infos = [self mensesInfosWithBeginningTimeStamp:beginningTimeStamp endTimeStamp:endTimeStamp];
        if(infos.count > 0)
        {
            TYDMensesInfo *firstInfo = infos.firstObject;
            if(firstInfo.timeStamp < beginningTimeStamp)
            {//第一条跨界
                int duration = (int)((firstInfo.endTimeStamp - firstInfo.timeStamp) / nTimeIntervalSecondsPerDay);
                int endIndex = (int)((beginningTimeStamp - firstInfo.timeStamp) / nTimeIntervalSecondsPerDay);
                endIndex = duration - endIndex;
                for(int index = 0; index <= endIndex; index++)
                {
                    _mensesBloodInfoList[index] = YES;
                }
                [infos removeObject:firstInfo];
            }
            
            for(TYDMensesInfo *mensesInfo in infos)
            {
                int startIndex = (int)((mensesInfo.timeStamp - beginningTimeStamp) / nTimeIntervalSecondsPerDay);
                int endIndex = (int)((mensesInfo.endTimeStamp - beginningTimeStamp) / nTimeIntervalSecondsPerDay);
                endIndex = MIN((countTotal - 1), endIndex);
                for(int index = startIndex; index <= endIndex; index++)
                {
                    _mensesBloodInfoList[index] = YES;
                }
            }
        }
    }
}

#pragma mark - MensesDurationBasicInfoUpdated

//当用户设置新的月经周期值和行经时长时调用
- (void)mensesDurationBasicInfoUpdated
{
    if(![self mensesDurationBasicInfoReset])
    {
        return;
    }
    NSInteger currentMonthBeginningTimeStampTemple = self.currentMonthBeginningTimeStamp;
    _currentMonthBeginningTimeStamp = 0;
    self.currentMonthBeginningTimeStamp = currentMonthBeginningTimeStampTemple;
//    int countTotal = (int)(_mensesInfoRangeForMonth0.length + _mensesInfoRangeForMonth1.length + _mensesInfoRangeForMonth2.length);
//    NSArray *mensesInfos = [TYDMensesDataCenter defaultCenter].allMensesRecordInfos;
//    if(mensesInfos.count == 0)
//    {
//        for(int index = 0; index < countTotal; index++)
//        {
//            _mensesDayInfoTypeList[index] = MensesInfoDayTypeNone;
//            _mensesBloodInfoList[index] = NO;
//        }
//    }
//    else
//    {
//        TYDMensesInfo *standarMensesInfo = mensesInfos.lastObject;
//        int listIndex = ((_monthBeginningTimeStamp0 - standarMensesInfo.timeStamp) / nTimeIntervalSecondsPerDay) % self.mensesDuration;
//        listIndex = (listIndex + self.mensesDuration) % self.mensesDuration;//处理负值
//        
//        for(int index = 0; index < countTotal; index++)
//        {
//            _mensesDayInfoTypeList[index] = [self.standarMensesDurationInfoList[listIndex] intValue];
//            listIndex++;
//            listIndex %= self.standarMensesDurationInfoList.count;
//        }
//        [self mensesDayInfoTypeListReset];
//    }
}

#pragma mark - TYDBestieCalendarDelegate

- (void)bestieCalendarSelectedDate:(NSInteger)selectedDataTimeStamp
{
    self.selectedDateTimeStamp = selectedDataTimeStamp;
    for(TYDBestieCalendar *calendar in self.calendarViews)
    {
        calendar.selectedDateTimeStamp = selectedDataTimeStamp;
    }
    if([self.delegate respondsToSelector:@selector(bestieCalendarViewSelectedNewDate:)])
    {
        [self.delegate bestieCalendarViewSelectedNewDate:self];
    }
}

#pragma mark - Interface

- (void)mensesInfosInCurrentMonthUpdated
{
    NSInteger currentMonthBeginningTimeStampTemple = self.currentMonthBeginningTimeStamp;
    _currentMonthBeginningTimeStamp = 0;
    self.currentMonthBeginningTimeStamp = currentMonthBeginningTimeStampTemple;
}

- (BOOL *)mensesBloodInfoListObtain
{
    return _mensesBloodInfoList;
}

- (int)mensesBloodInfoListLengthObtain
{
    return (int)(_mensesInfoRangeForMonth0.length + _mensesInfoRangeForMonth1.length + _mensesInfoRangeForMonth2.length);
}

- (NSInteger)mensesBloodInfoMonthBeginningTimeStampObtain
{
    return _monthBeginningTimeStamp0;
}

//向前移动，应该是数组动作越界，故有EXC_BAD_ACCESS
//- (void)mensesInfos:(NSArray *)mensesInfos dispatchedForCalendarView:(TYDBestieCalendar *)calendarView
//{
//    if(!calendarView)
//    {
//        return;
//    }
//
//    if(mensesInfos.count < 2)
//    {
//        calendarView.mensesInfos = mensesInfos;
//    }
//
//    //校正
//    NSInteger monthBeginningTimeStamp = calendarView.monthBeginningTimeStamp;
//    NSInteger monthDuration = (nTimeIntervalSecondsPerDay * [BOTimeStampAssistor daysPerMonthWithTimeStamp:monthBeginningTimeStamp] - 1);
//    NSInteger monthEndTimeStamp = monthBeginningTimeStamp + monthDuration;
//
//    NSMutableArray *infos = [[NSMutableArray alloc] initWithCapacity:4];
//    for(TYDMensesInfo *infoItem in mensesInfos)
//    {//中心点距离 不大于 两者总长半值
//        NSInteger centerDistance2 = ABS(((monthBeginningTimeStamp + monthEndTimeStamp) - (infoItem.timeStamp + infoItem.endTimeStamp)));
//        NSInteger lengthTotal = ABS((monthDuration + infoItem.endTimeStamp - infoItem.timeStamp));
//
//        if(centerDistance2 <= lengthTotal)
//        {
//            [infos addObject:infoItem];
//        }
//    }
//    if(infos.count == 0)
//    {
//        TYDMensesInfo *firstInfoItem = mensesInfos.firstObject;
//        TYDMensesInfo *lastInfoItem = mensesInfos.lastObject;
//
//        if(monthEndTimeStamp <= firstInfoItem.timeStamp)
//        {//位于所有记录之前
//            [infos addObject:firstInfoItem];
//        }
//        else if(monthBeginningTimeStamp >= lastInfoItem.endTimeStamp)
//        {//位于所有记录之后
//            [infos addObject:lastInfoItem];
//        }
//        else
//        {
//            NSInteger index = 0;
//            for(; index < mensesInfos.count; index++)
//            {
//                TYDMensesInfo *infoItem = mensesInfos[index];
//                if(monthEndTimeStamp <= infoItem.timeStamp)
//                {
//                    break;
//                }
//            }
//            if(index > 0)
//            {
//                index--;
//            }
//            [infos addObject:mensesInfos[index]];
//        }
//    }
//    else
//    {//再获取前向条目
//        TYDMensesInfo *firstInfo = infos.firstObject;
//        NSUInteger index = [mensesInfos indexOfObject:firstInfo];
//        if(index != 0
//           && firstInfo.timeStamp < monthBeginningTimeStamp)
//        {
//            [infos addObject:mensesInfos[index - 1]];
//        }
//    }
//
//    calendarView.mensesInfos = infos;
//}

//- (void)mensesDailyPredicateInfoSet
//{
//    NSArray *mensesInfos = [TYDMensesDataCenter defaultCenter].allMensesRecordInfos;
//
//    int countTotal = _mensesInfoRangeForMonth0.length + _mensesInfoRangeForMonth1.length + _mensesInfoRangeForMonth2.length;
//    if(mensesInfos.count == 0)
//    {//无数据
//        for(int index = 0; index < countTotal; index++)
//        {
//            _mensesDayInfoTypeList[index] = MensesInfoDayTypeNone;
//            _mensesBloodInfoList[index] = NO;
//        }
//        return;
//    }
//
//    TYDMensesInfo *firstMensesInfo = mensesInfos.firstObject;
//    NSInteger monthBeginningForFirstMensesInfo = [BOTimeStampAssistor timeStampOfMonthBeginningWithTimerStamp:firstMensesInfo.timeStamp];
//    NSInteger priorMonthBeginningForFirstMensesInfo = [BOTimeStampAssistor timeStampOfMonthBeginningWithTimerStamp:monthBeginningForFirstMensesInfo - 1];
//
//    int monthCount = 3;
//    NSInteger beginningTimes[3] = {_monthBeginningTimeStamp0, _monthBeginningTimeStamp1, _monthBeginningTimeStamp2};
//    NSRange monthDataRanges[3] = {_mensesInfoRangeForMonth0, _mensesInfoRangeForMonth1, _mensesInfoRangeForMonth2};
//
//    TYDMensesInfo *standarMensesInfo = mensesInfos.lastObject;
//    for(int monthIndex = 0; monthIndex < monthCount; monthCount++)
//    {
//        NSRange monthRange = monthDataRanges[monthIndex];
//        NSInteger beginningTime = beginningTimes[monthIndex];
//        if(beginningTime < priorMonthBeginningForFirstMensesInfo)
//        {
//            for(int index = 0; index < monthRange.length; index++)
//            {
//                _mensesDayInfoTypeList[monthRange.location + index] = MensesInfoDayTypeNone;
//                _mensesBloodInfoList[monthRange.location + index] = NO;
//            }
//        }
//        else
//        {
//            int listIndex = ((beginningTime - standarMensesInfo.timeStamp) / nTimeIntervalSecondsPerDay) % self.mensesDuration;
//            listIndex = (listIndex + self.mensesDuration) % self.mensesDuration;//处理负值
//
//            for(int index = 0; index < monthRange.length; index++)
//            {
//                _mensesBloodInfoList[monthRange.location + index] = NO;
//                _mensesDayInfoTypeList[monthRange.location + index] = [self.standarMensesDurationInfoList[listIndex] intValue];
//                listIndex++;
//                listIndex %= self.standarMensesDurationInfoList.count;
//            }
//        }
//    }
//}
//
//- (void)mensesDayInfoListResetMonthlyDecrease
//{//日期前向，递减，向右滑动
//    _monthBeginningTimeStamp2 = _monthBeginningTimeStamp1;
//    _monthBeginningTimeStamp1 = _monthBeginningTimeStamp0;
//    _monthBeginningTimeStamp0 = [BOTimeStampAssistor timeStampOfMonthBeginningWithTimerStamp:_monthBeginningTimeStamp0 - 1];
//
//    int daysCountForMonth0New = [BOTimeStampAssistor daysPerMonthWithTimeStamp:_monthBeginningTimeStamp0];
//    int daysCountForMonth1New = _mensesInfoRangeForMonth0.length;
//    int daysCountForMonth2New = _mensesInfoRangeForMonth1.length;
//    _mensesInfoRangeForMonth0 = NSMakeRange(0, daysCountForMonth0New);
//    _mensesInfoRangeForMonth1 = NSMakeRange(daysCountForMonth0New, daysCountForMonth1New);
//    _mensesInfoRangeForMonth2 = NSMakeRange(daysCountForMonth0New + daysCountForMonth1New, daysCountForMonth2New);
//
//    NSArray *mensesInfos = [TYDMensesDataCenter defaultCenter].allMensesRecordInfos;
//    if(mensesInfos.count == 0)
//    {
//        return;
//    }
//
//    int length = daysCountForMonth1New + daysCountForMonth2New;
//    int resEndIndex = length - 1;
//    int destEndIndex = length + daysCountForMonth0New - 1;
//    for(int count = 0; count < length; count++)
//    {//空出首部用于接收新数据
//        _mensesDayInfoTypeList[destEndIndex] = _mensesDayInfoTypeList[resEndIndex];
//        _mensesBloodInfoList[destEndIndex--] = _mensesBloodInfoList[resEndIndex--];
//    }
//
//    TYDMensesInfo *firstMensesInfo = mensesInfos.firstObject;
//    NSInteger monthBeginningForFirstMensesInfo = [BOTimeStampAssistor timeStampOfMonthBeginningWithTimerStamp:firstMensesInfo.timeStamp];
//    if(monthBeginningForFirstMensesInfo > _monthBeginningTimeStamp1)
//    {//首条记录前向第二个月都为灰色
//        for(int index = 0; index < daysCountForMonth0New; index++)
//        {
//            _mensesDayInfoTypeList[index] = MensesInfoDayTypeNone;
//            _mensesBloodInfoList[index] = NO;
//        }
//        return;
//    }
//
//    TYDMensesInfo *standarMensesInfo = mensesInfos.lastObject;
//    //放置经期预测表
//    int listIndex = ((_monthBeginningTimeStamp0 - standarMensesInfo.timeStamp) / nTimeIntervalSecondsPerDay) % self.mensesDuration;
//    listIndex = (listIndex + self.mensesDuration) % self.mensesDuration;//处理负值
//    int countTotal = daysCountForMonth0New;
//    for(int index = 0; index < countTotal; index++)
//    {
//        _mensesBloodInfoList[index] = NO;
//        _mensesDayInfoTypeList[index] = [self.standarMensesDurationInfoList[listIndex] intValue];
//        listIndex++;
//        listIndex %= self.standarMensesDurationInfoList.count;
//    }
//
//    //放置行经信息
//    NSInteger beginningTimeStamp = _monthBeginningTimeStamp0;
//    NSInteger duration = countTotal * nTimeIntervalSecondsPerDay - 1;
//    NSInteger endTimeStamp = beginningTimeStamp + duration;
//    NSMutableArray *infos = [self mensesInfosWithBeginningTimeStamp:beginningTimeStamp endTimeStamp:endTimeStamp];
//    if(infos.count > 0)
//    {
//        TYDMensesInfo *firstInfo = infos.firstObject;
//        if(firstInfo.timeStamp < beginningTimeStamp)
//        {//第一条跨界
//            int duration = (firstInfo.endTimeStamp - firstInfo.timeStamp) / nTimeIntervalSecondsPerDay;
//            int endIndex = (beginningTimeStamp - firstInfo.timeStamp) / nTimeIntervalSecondsPerDay;
//            endIndex = duration - endIndex;
//            for(int index = 0; index <= endIndex; index++)
//            {
//                _mensesBloodInfoList[index] = YES;
//            }
//            [infos removeObject:firstInfo];
//        }
//
//        for(TYDMensesInfo *mensesInfo in infos)
//        {
//            int startIndex = (mensesInfo.timeStamp - beginningTimeStamp) / nTimeIntervalSecondsPerDay;
//            int endIndex = (mensesInfo.endTimeStamp - beginningTimeStamp) / nTimeIntervalSecondsPerDay;
//            endIndex = MIN((countTotal - 1), endIndex);
//            for(int index = startIndex; index <= endIndex; index++)
//            {
//                _mensesBloodInfoList[index] = YES;
//            }
//        }
//    }
//}
//
//- (void)mensesDayInfoListResetMonthlyIncrease
//{//日期后向，递增，向左滑动
//    _monthBeginningTimeStamp0 = _monthBeginningTimeStamp1;
//    _monthBeginningTimeStamp1 = _monthBeginningTimeStamp2;
//    _monthBeginningTimeStamp2 += _mensesInfoRangeForMonth2.length * nTimeIntervalSecondsPerDay;
//
//    int daysCountForMonth0Old = _mensesInfoRangeForMonth0.length;
//    int daysCountForMonth0New = _mensesInfoRangeForMonth1.length;
//    int daysCountForMonth1New = _mensesInfoRangeForMonth2.length;
//    int daysCountForMonth2New = [BOTimeStampAssistor daysPerMonthWithTimeStamp:_monthBeginningTimeStamp2];
//    _mensesInfoRangeForMonth0 = NSMakeRange(0, daysCountForMonth0New);
//    _mensesInfoRangeForMonth1 = NSMakeRange(daysCountForMonth0New, daysCountForMonth1New);
//    _mensesInfoRangeForMonth2 = NSMakeRange(daysCountForMonth0New + daysCountForMonth1New, daysCountForMonth2New);
//
//    NSArray *mensesInfos = [TYDMensesDataCenter defaultCenter].allMensesRecordInfos;
//    if(mensesInfos.count == 0)
//    {
//        return;
//    }
//
//    int length = daysCountForMonth0New + daysCountForMonth1New;
//    int resStartIndex = daysCountForMonth0Old - 1;
//    int destStartIndex = 0;
//    for(int count = 0; count < length; count++)
//    {//空出尾部用于接收新数据
//        _mensesDayInfoTypeList[destStartIndex] = _mensesDayInfoTypeList[resStartIndex];
//        _mensesBloodInfoList[destStartIndex--] = _mensesBloodInfoList[resStartIndex--];
//    }
//
//    TYDMensesInfo *firstMensesInfo = mensesInfos.firstObject;
//    NSInteger monthBeginningForFirstMensesInfo = [BOTimeStampAssistor timeStampOfMonthBeginningWithTimerStamp:firstMensesInfo.timeStamp];
//    if(monthBeginningForFirstMensesInfo > _monthBeginningTimeStamp2 + daysCountForMonth2New * nTimeIntervalSecondsPerDay)
//    {//首条记录前向第二个月都为灰色
//        int index = _mensesInfoRangeForMonth2.location;
//        for(int count = 0; count < daysCountForMonth2New; count++)
//        {
//            _mensesDayInfoTypeList[index] = MensesInfoDayTypeNone;
//            _mensesBloodInfoList[index++] = NO;
//        }
//        return;
//    }
//
//    TYDMensesInfo *standarMensesInfo = mensesInfos.lastObject;
////    NSInteger timeOffset = _monthBeginningTimeStamp2 - standarMensesInfo.timeStamp;
////    NSInteger daysCountForTimeOffset = timeOffset / nTimeIntervalSecondsPerDay;
//    int mensesDuration = [TYDMensesDataCenter defaultCenter].mensesDuration;
//    NSArray *standarMensesDurationInfoList = self.standarMensesDurationInfoList;
//    //int listIndex = daysCountForTimeOffset % mensesDuration;
//    //放置经期预测表
//    int listIndex = (((_monthBeginningTimeStamp2 - standarMensesInfo.timeStamp) / nTimeIntervalSecondsPerDay)) % mensesDuration;
//    listIndex = (listIndex + mensesDuration) % mensesDuration;//处理负值
//    int countTotal = _mensesInfoRangeForMonth2.length;
//    int index = _mensesInfoRangeForMonth2.location;
//    for(int count = 0; count < countTotal; count++)
//    {
//        _mensesDayInfoTypeList[index] = [self.standarMensesDurationInfoList[listIndex] intValue];
//        _mensesBloodInfoList[index++] = NO;
//        listIndex++;
//        listIndex %= self.standarMensesDurationInfoList.count;
//    }
//
//    //放置行经信息
//    NSInteger beginningTimeStamp = _monthBeginningTimeStamp2;
//    NSInteger duration = countTotal * nTimeIntervalSecondsPerDay - 1;
//    NSInteger endTimeStamp = beginningTimeStamp + duration;
//    NSMutableArray *infos = [self mensesInfosWithBeginningTimeStamp:beginningTimeStamp endTimeStamp:endTimeStamp];
//    if(infos.count > 0)
//    {
//        TYDMensesInfo *firstInfo = infos.firstObject;
//        NSInteger baseIndex = _mensesInfoRangeForMonth2.location;
//        if(firstInfo.timeStamp < beginningTimeStamp)
//        {//第一条跨界
//            int duration = (firstInfo.endTimeStamp - firstInfo.timeStamp) / nTimeIntervalSecondsPerDay;
//            int endIndex = (beginningTimeStamp - firstInfo.timeStamp) / nTimeIntervalSecondsPerDay;
//            endIndex = duration - endIndex;
//            for(int index = 0; index <= endIndex; index++)
//            {
//                _mensesBloodInfoList[index + baseIndex] = YES;
//            }
//            [infos removeObject:firstInfo];
//        }
//
//        for(TYDMensesInfo *mensesInfo in infos)
//        {
//            int startIndex = (mensesInfo.timeStamp - beginningTimeStamp) / nTimeIntervalSecondsPerDay;
//            int endIndex = (mensesInfo.endTimeStamp - beginningTimeStamp) / nTimeIntervalSecondsPerDay;
//            endIndex = MIN((countTotal - 1), endIndex);
//            for(int index = startIndex; index <= endIndex; index++)
//            {
//                _mensesBloodInfoList[index + baseIndex] = YES;
//            }
//        }
//    }
//}

@end
