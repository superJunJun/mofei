//
//  TYDBestieCalendar.m
//  Mofei
//
//  Created by macMini_Dev on 14/11/15.
//  Copyright (c) 2014年 Young. All rights reserved.
//
//  贴心闺蜜 - 基础日历视图
//

#import "TYDBestieCalendar.h"
#import "TYDCalendarDateBlock.h"

#import "TYDMensesDataCenter.h"
#import "TYDMensesInfo.h"

#define nGraySeparatorLineWidth     0.5
#define nDateBlockCountMax          42//(nDateBlockPerRow * nDateBlockRowMax)

@interface TYDBestieCalendar () <TYDCalendarDateBlockDelegate>

@property (strong, nonatomic) TYDCalendarDateBlock *selectedBlock;
@property (strong, nonatomic) NSArray *dateBlocks;
@property (nonatomic) CGSize validSize;

@property (strong, nonatomic) NSArray *mensesInfos;     //MensesInfoDayType number
@property (strong, nonatomic) NSArray *mensesBloodInfos;//bool number

@end

@implementation TYDBestieCalendar

- (instancetype)initWithBlockSize:(CGSize)blockSize
{
    CGFloat grayLineWidth = nGraySeparatorLineWidth;
    CGRect frame = CGRectMake(0, 0, blockSize.width * nDateBlockPerRow, blockSize.height * nDateBlockRowMax + grayLineWidth);
    if(self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
        [self separatorLinesLoadWithBlockSize:blockSize];
        
        frame = CGRectMake(0, 0, blockSize.width, blockSize.height);
        NSMutableArray *dateBlocks = [NSMutableArray new];
        for(int i = 0; i < nDateBlockRowMax; i++)
        {
            for(int j = 0; j < nDateBlockPerRow; j++)
            {
                TYDCalendarDateBlock *dateBlock = [[TYDCalendarDateBlock alloc] initWithFrame:frame];
                dateBlock.delegate = self;
                [dateBlocks addObject:dateBlock];
                [self addSubview:dateBlock];
                frame.origin.x += dateBlock.width;
            }
            frame.origin.x = 0;
            frame.origin.y += blockSize.height;
        }
        self.dateBlocks = dateBlocks;
        _selectedBlock = nil;
        _todayBeginningTimeStamp = [BOTimeStampAssistor timeStampOfDayBeginningForToday];
        self.validSize = self.frame.size;
    }
    return self;
}

- (void)separatorLinesLoadWithBlockSize:(CGSize)blockSize
{
    UIColor *grayLineColor = [UIColor colorWithHex:0x0 andAlpha:0.1];
    CGRect lineFrame = CGRectMake(0, 0, self.frame.size.width, nGraySeparatorLineWidth);
    for(int i = 0; i <= nDateBlockRowMax; i++)
    {
        UIView *line = [[UIView alloc] initWithFrame:lineFrame];
        line.backgroundColor = grayLineColor;
        [self addSubview:line];
        lineFrame.origin.y += blockSize.height;
    }
    
    lineFrame = CGRectMake(blockSize.width, 0, nGraySeparatorLineWidth, self.frame.size.height);
    for(int i = 0; i < nDateBlockPerRow; i++)
    {
        UIView *line = [[UIView alloc] initWithFrame:lineFrame];
        line.backgroundColor = grayLineColor;
        [self addSubview:line];
        lineFrame.origin.x += blockSize.width;
    }
}

- (TYDCalendarDateBlock *)calendarDateBlockWithDateTimeStamp:(NSInteger)time
{
    TYDCalendarDateBlock *dateBlock = nil;
    if(time != nCalendarInvalidDate
       && time >= self.monthBeginningTimeStamp
       && time < self.monthBeginningTimeStamp + _daysCountInMonth * nTimeIntervalSecondsPerDay)
    {
        NSUInteger index = (time - self.monthBeginningTimeStamp) / nTimeIntervalSecondsPerDay;
        NSUInteger weekDay = [BOTimeStampAssistor weekdayWithTimeStamp:self.monthBeginningTimeStamp];
        dateBlock = self.dateBlocks[index + weekDay - 1];
    }
    return dateBlock;
}

#pragma mark - OverrideSettingMethod

- (void)setMonthBeginningTimeStamp:(NSInteger)monthBeginningTimeStamp
{
    monthBeginningTimeStamp = [BOTimeStampAssistor timeStampOfMonthBeginningWithTimerStamp:monthBeginningTimeStamp];//校正
    _monthBeginningTimeStamp = monthBeginningTimeStamp;
    _daysCountInMonth = [BOTimeStampAssistor daysPerMonthWithTimeStamp:monthBeginningTimeStamp];
    
    NSInteger weekDay = [BOTimeStampAssistor weekdayWithTimeStamp:monthBeginningTimeStamp];
    weekDay--;//校正
    
    NSInteger dayTimeStamp = monthBeginningTimeStamp;
    NSInteger index = 0;
    for(index = 0; index < nDateBlockCountMax; index++)
    {
        TYDCalendarDateBlock *dateBlock = self.dateBlocks[index];
        dateBlock.dateBeginningTimeStamp = nCalendarInvalidDate;
    }
    for(index = 0; index < self.daysCountInMonth; index++)
    {
        TYDCalendarDateBlock *dateBlock = self.dateBlocks[weekDay + index];
        dateBlock.dateBeginningTimeStamp = dayTimeStamp;
        dayTimeStamp += nTimeIntervalSecondsPerDay;
    }
    
    TYDCalendarDateBlock *oneDateBlock = self.dateBlocks[0];
    NSInteger validRowCount = (weekDay + self.daysCountInMonth + nDaysCountPerWeek - 1) / nDaysCountPerWeek;
    self.validSize = CGSizeMake(self.frame.size.width, validRowCount * oneDateBlock.frame.size.height + nGraySeparatorLineWidth);
}

- (void)setSelectedDateTimeStamp:(NSInteger)selectedDateTimeStamp
{
    _selectedDateTimeStamp = selectedDateTimeStamp;
    self.selectedBlock = [self calendarDateBlockWithDateTimeStamp:selectedDateTimeStamp];
}

- (void)setSelectedBlock:(TYDCalendarDateBlock *)selectedBlock
{
    if(_selectedBlock != selectedBlock)
    {
        _selectedBlock.selected = NO;
    }
    _selectedBlock = selectedBlock;
    selectedBlock.selected = YES;
}

- (void)setTodayBeginningTimeStamp:(NSInteger)todayBeginningTimeStamp
{
    if(_todayBeginningTimeStamp != todayBeginningTimeStamp)
    {
        _todayBeginningTimeStamp = todayBeginningTimeStamp;
        [self refreshCalendarDateBlocks];
    }
}

#pragma mark - MensesInfo Import

- (void)setMensesInfos:(NSArray *)mensesInfos andMensesBloodInfos:(NSArray *)mensesBloodInfos
{
    self.mensesInfos = mensesInfos;
    self.mensesBloodInfos = mensesBloodInfos;
    [self refreshCalendarDateBlocks];
}

- (NSRange)validCalendarDateBlocksRange
{
    return NSMakeRange([BOTimeStampAssistor weekdayWithTimeStamp:self.monthBeginningTimeStamp] - 1, self.daysCountInMonth);
}

- (void)refreshCalendarDateBlocks
{
    int count = (int)MIN(self.mensesInfos.count, self.mensesBloodInfos.count);
    count = (int)MIN(count, self.daysCountInMonth);
    NSRange range = [self validCalendarDateBlocksRange];
    if(count == 0)
    {
        for(int index = 0; index < range.length; index++)
        {
            TYDCalendarDateBlock *dateBlock = self.dateBlocks[index + range.location];
            dateBlock.dateType = MensesInfoDayTypeNone;
            dateBlock.isMensesBloodDay = NO;
        }
        return;
    }
    
    for(int index = 0; index < count; index++)
    {
        TYDCalendarDateBlock *dateBlock = self.dateBlocks[index + range.location];
        MensesInfoDayType dateType = [self.mensesInfos[index] intValue];
        BOOL isMensesBloodDay = [self.mensesBloodInfos[index] boolValue];
        
        if(dateBlock.dateBeginningTimeStamp <= self.todayBeginningTimeStamp)
        {
            if(dateType == MensesInfoDayTypePrediction)
            {
                dateType = MensesInfoDayTypeSafe;
            }
        }
        else
        {
            if(isMensesBloodDay)
            {
                isMensesBloodDay = NO;
                dateType = MensesInfoDayTypePrediction;
            }
        }
        
        dateBlock.dateType = dateType;
        dateBlock.isMensesBloodDay = isMensesBloodDay;
    }
}

#pragma mark - TYDCalendarDateBlockDelegate

- (void)calendarDateBlockSelected:(TYDCalendarDateBlock *)calendarDateBlock
{
    if(!calendarDateBlock.selected)
    {
        _selectedDateTimeStamp = calendarDateBlock.dateBeginningTimeStamp;
        self.selectedBlock = calendarDateBlock;
        if([self.delegate respondsToSelector:@selector(bestieCalendarSelectedDate:)])
        {
            [self.delegate bestieCalendarSelectedDate:self.selectedDateTimeStamp];
        }
    }
}

#pragma mark - ValidSize

- (CGSize)bestieCalendarValidSize
{
    return self.validSize;
}

@end
