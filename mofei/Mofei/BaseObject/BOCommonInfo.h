//
//  BOCommonInfo.h
//

#ifndef __BOCOMMONINFO_H__
#define __BOCOMMONINFO_H__

//#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UIViewAlignmentType)
{
    //UIViewAlignmentNone     = -1,
    UIViewAlignmentLeft     = 0,
    UIViewAlignmentCenter   = 1,
    UIViewAlignmentRight    = 2
};

typedef struct _Scope
{
    NSInteger startValue;
    NSInteger endValue;
}Scope;

static inline NSInteger countOfScope(Scope scope)
{
    return ABS((scope.endValue - scope.startValue)) + 1;
}

static inline void scopeSetValue(Scope scope, NSInteger startValue, NSInteger endValue)
{
    scope.startValue = startValue;
    scope.endValue = endValue;
}

static inline Scope scopeMake(NSInteger startValue, NSInteger endValue)
{
    Scope scope;
    scope.startValue = startValue;
    scope.endValue = endValue;
    return scope;
}

#define cBasicPinkColor                 [UIColor colorWithHex:0xe23674]
#define sCalorieBasicShortUnit          @"卡"
#define sCalorieBasicUnit               @"卡路里"
#define sCalorieKiloUnit                @"大卡"

#define sHeartRateBasicTitle            @"心率"
#define sWeightBasicTitle               @"体重"
#define sHeightBasicTitle               @"身高"
#define sStepBasicTitle                 @"步数"
#define sDistanceBasicTitle             @"距离"
#define sTimeBasicTitle                 @"时间"
#define sDateBasicTitle                 @"日期"
#define sBirthdayBasicTitle             @"出生日期"
#define sBirthdayShortTitle             @"生日"
#define sNameBasicTitle                 @"名字"
#define sAgeBasicTitle                  @"年龄"
#define sGenderBasicTitle               @"性别"

#define sHeartRateBasicUnit             @"次/分"

#define sWeightBasicUnit                @"千克"
#define sWeightBasicUnitEn              @"kg"
#define sWeightBasicUnitEnUppercase     @"KG"

#define sHeightBasicUnit                @"米"
#define sHeightCentimeterUnit           @"厘米"
#define sHeightCentimeterUnitEn         @"cm"

#define sStepBasicUnit                  @"步"

#define sDistanceBasicUnit              @"米"
#define sDistanceKiloUnit               @"千米"
#define sDistanceKiloCommonUnit         @"公里"

#define sTimeSecondBasicUnit            @"秒"
#define sTimeMinuteBasicUnit            @"分"
#define sTimeHourBasicUnit              @"时"
#define sTimeMinuteCommonUnit           @"分钟"
#define sTimeHourCommonUnit             @"小时"
#define sTimeDayBasicUnit               @"天"

#define sAgeBasicUnit                   @"岁"

#define sRMBSign                        @"¥"
//#define sUSDSign                        @"$"//USD dollar


#endif

