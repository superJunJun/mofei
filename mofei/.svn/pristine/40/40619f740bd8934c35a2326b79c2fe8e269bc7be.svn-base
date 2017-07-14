//
//  TYDBestieCalendar.h
//  Mofei
//
//  Created by macMini_Dev on 14/11/15.
//  Copyright (c) 2014年 Young. All rights reserved.
//
//  贴心闺蜜 - 基础日历视图
//

#import <UIKit/UIKit.h>

#define nDaysCountPerWeek           7
#define nDateBlockPerRow            nDaysCountPerWeek
#define nDateBlockRowMax            6

@protocol TYDBestieCalendarDelegate <NSObject>
@optional
- (void)bestieCalendarSelectedDate:(NSInteger)selectedDataTimeStamp;
@end

@interface TYDBestieCalendar : UIView

@property (nonatomic) NSInteger monthBeginningTimeStamp;
@property (nonatomic, readonly) NSInteger daysCountInMonth;

@property (nonatomic) NSInteger todayBeginningTimeStamp;//临界值，日期变更。。
@property (nonatomic) NSInteger selectedDateTimeStamp;

@property (assign, nonatomic) id<TYDBestieCalendarDelegate> delegate;

- (instancetype)initWithBlockSize:(CGSize)blockSize;
- (CGSize)bestieCalendarValidSize;
- (void)setMensesInfos:(NSArray *)mensesInfos andMensesBloodInfos:(NSArray *)mensesBloodInfos;

@end
