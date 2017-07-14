//
//  TYDCalendarDateBlock.h
//  Mofei
//
//  Created by macMini_Dev on 14/11/15.
//  Copyright (c) 2014年 Young. All rights reserved.
//
//  贴心闺蜜 - 基础日历块
//

#import <UIKit/UIKit.h>
#import "TYDMensesDataCenter.h"

#define nCalendarInvalidDate        NSIntegerMax

typedef NS_ENUM(NSInteger, MensesInfoDayType)
{
    MensesInfoDayTypeNone = 0,  //无特征
    MensesInfoDayTypeSafe,      //安全期
    MensesInfoDayTypePrediction,//预测期
    MensesInfoDayTypePregnant,  //易孕期
    MensesInfoDayTypeOvulate    //排卵日
};

@class TYDCalendarDateBlock;
@protocol TYDCalendarDateBlockDelegate <NSObject>
@optional
- (void)calendarDateBlockSelected:(TYDCalendarDateBlock *)calendarDateBlock;
@end

@interface TYDCalendarDateBlock : UIControl

@property (assign, nonatomic) id<TYDCalendarDateBlockDelegate> delegate;

//设置顺序：1、dateBeginningTimeStamp 2、dateType 3、isMensesBloodDay
@property (nonatomic) NSInteger dateBeginningTimeStamp;
@property (nonatomic) MensesInfoDayType dateType;
@property (nonatomic) BOOL isMensesBloodDay;

- (instancetype)initWithFrame:(CGRect)frame;

@end
