//
//  TYDBestieCalendarView.h
//  Mofei
//
//  Created by macMini_Dev on 14/11/12.
//  Copyright (c) 2014年 Young. All rights reserved.
//
//  贴心闺蜜 -- 月经日历
//  三个基础日历视图控件通过滑动展现所有日历
//

#import <UIKit/UIKit.h>

@class TYDBestieCalendarView;
@protocol TYDBestieCalendarViewDelegate <NSObject>
@optional
//高度更改
//动画加速方式：UIViewAnimationOptionCurveEaseInOut
//持续时间：0.25
- (void)bestieCalendarViewHeightWillChange:(CGFloat)heightNew;
- (void)bestieCalendarViewSelectedNewDate:(TYDBestieCalendarView *)view;
- (void)bestieCalendarViewMonthChanged:(TYDBestieCalendarView *)view;
@end

@interface TYDBestieCalendarView : UIView

@property (nonatomic) NSInteger currentMonthBeginningTimeStamp;
@property (nonatomic) NSInteger selectedDateTimeStamp;
@property (nonatomic) NSInteger todayBeginningTimeStamp;

@property (nonatomic, readonly) int mensesBloodDuration;//行经时长
@property (nonatomic, readonly) int mensesDuration;     //月经周期

@property (assign, nonatomic) id<TYDBestieCalendarViewDelegate> delegate;

//当前显示页面月经信息有更新，刷新页面
- (void)mensesInfosInCurrentMonthUpdated;

//当用户设置新的月经周期值和行经时长时调用
- (void)mensesDurationBasicInfoUpdated;

//上传接口，不可赋值
- (BOOL *)mensesBloodInfoListObtain;
- (int)mensesBloodInfoListLengthObtain;
- (NSInteger)mensesBloodInfoMonthBeginningTimeStampObtain;

@end
