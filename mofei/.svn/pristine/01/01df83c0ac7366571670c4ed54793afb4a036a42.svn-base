//
//  TYDBasicInfoConverter.m
//  Mofei
//
//  Created by caiyajie on 15-1-16.
//  Copyright (c) 2015年 Young. All rights reserved.
//

#import "TYDBasicInfoConverter.h"

//#define sSexKey             @"sex"
#define sAgeKey             @"age"
#define sHeightKey          @"height"
#define sWeightKey          @"weight"
#define sMensesAverageKey   @"avgMenses"
#define sMensesPeriodKey    @"avgPeriod"
#define sSportTargetKey     @"sportsTarget"
#define sBirthdayKey        @"birthday"

typedef struct _IntergerScope
{
    NSInteger startValue;
    NSInteger endValue;
}IntergerScope;


IntergerScope intergerScopeMake(NSInteger startValue, NSInteger endValue)
{
    IntergerScope scope;
    scope.startValue = startValue;
    scope.endValue = endValue;
    return scope;
}

NSInteger countOfIntergerScope(IntergerScope scope)
{
    return ABS((scope.endValue - scope.startValue + 1));
}

@implementation TYDBasicInfoConverter

#pragma mark - ConvertToServer

+ (void)convertBasicInfoItem:(NSNumber *)item withKey:(NSString *)key scope:(IntergerScope)scope ToServerInfoDic:(NSMutableDictionary *)dic
{
    if(!item)
    {
        item = @0;
    }
    if(key.length > 0)
    {
        NSInteger value = item.integerValue;
        value = MIN((scope.endValue), (MAX((scope.startValue), value)));
        NSInteger index = value - scope.startValue;
        [dic setValue:@(index) forKey:key];
    }
}

+ (NSDictionary *)basicInfoConvertToServerInfo:(NSDictionary *)basicInfoDic
{
    NSMutableDictionary *serverInfoDic = [NSMutableDictionary new];
    
    NSLog(@"%f",[BOTimeStampAssistor getCurrentTime]);
    NSLog(@"aaaaa----%d", [BOTimeStampAssistor getYearStringWithTimeStamp:[BOTimeStampAssistor getCurrentTime]].intValue);
    IntergerScope ageScope = intergerScopeMake(1925, [BOTimeStampAssistor getYearStringWithTimeStamp:[BOTimeStampAssistor getCurrentTime]].intValue);
    //IntergerScope ageScope = intergerScopeMake(1925, 2014);
    IntergerScope heightScope = intergerScopeMake(60, 240);
    IntergerScope weightScope = intergerScopeMake(25, 205);
    IntergerScope mensesAverageScope = intergerScopeMake(2, 14);
    IntergerScope mensesPeriodScope = intergerScopeMake(15, 45);
    IntergerScope sportTargetScope = intergerScopeMake(200, 400);
    NSInteger sportTargetScopeStepValue = 100;
    
    [self convertBasicInfoItem:basicInfoDic[sHeightKey] withKey:sHeightKey scope:heightScope ToServerInfoDic:serverInfoDic];
    [self convertBasicInfoItem:basicInfoDic[sWeightKey] withKey:sWeightKey scope:weightScope ToServerInfoDic:serverInfoDic];
    [self convertBasicInfoItem:basicInfoDic[sMensesAverageKey] withKey:sMensesAverageKey scope:mensesAverageScope ToServerInfoDic:serverInfoDic];
    [self convertBasicInfoItem:basicInfoDic[sMensesPeriodKey] withKey:sMensesPeriodKey scope:mensesPeriodScope ToServerInfoDic:serverInfoDic];
    
    NSNumber *birthdayNumber = basicInfoDic[sBirthdayKey];
    if(birthdayNumber)
    {
        NSInteger birthYear = [BOTimeStampAssistor getYearStringWithTimeStamp:birthdayNumber.floatValue].integerValue;
        birthYear = MIN(ageScope.endValue, (MAX(ageScope.startValue, birthYear)));
        NSInteger age = ageScope.endValue - birthYear;
        [serverInfoDic setValue:@(age) forKey:sBirthdayKey];
    }
    
    NSNumber *targetNumber = basicInfoDic[sSportTargetKey];
    if(targetNumber)
    {
        NSInteger value = targetNumber.integerValue;
        value = MIN((sportTargetScope.endValue), (MAX((sportTargetScope.startValue), value)));
        NSInteger index = (value - sportTargetScope.startValue) / sportTargetScopeStepValue;
        [serverInfoDic setValue:@(index) forKey:sSportTargetKey];
    }
    return serverInfoDic;
}

#pragma mark - ConvertToLocal

+ (void)convertServerInfoItem:(NSNumber *)item withKey:(NSString *)key scope:(IntergerScope)scope ToBasicInfoDic:(NSMutableDictionary *)dic
{
    if(!item)
    {
        item = @0;
    }
    if(key.length > 0)
    {
        NSInteger index = item.integerValue;
        index = MAX(0, (MIN((countOfIntergerScope(scope)), index)));
        NSInteger value = index + scope.startValue;
        [dic setValue:@(value) forKey:key];
    }
}

+ (NSDictionary *)serverInfoConvertToBasicInfo:(NSDictionary *)serverInfoDic
{
    NSMutableDictionary *basicInfoDic = [NSMutableDictionary new];
    
    IntergerScope ageScope = intergerScopeMake(1925, [BOTimeStampAssistor getYearStringWithTimeStamp:[BOTimeStampAssistor getCurrentTime]].intValue);
    //IntergerScope ageScope = intergerScopeMake(1925, 2014);
    IntergerScope heightScope = intergerScopeMake(60, 240);
    IntergerScope weightScope = intergerScopeMake(25, 205);
    IntergerScope mensesAverageScope = intergerScopeMake(2, 14);
    IntergerScope mensesPeriodScope = intergerScopeMake(15, 45);
    IntergerScope sportTargetScope = intergerScopeMake(200, 400);
    NSInteger sportTargetScopeStepValue = 100;
    
    [self convertServerInfoItem:serverInfoDic[sHeightKey] withKey:sHeightKey scope:heightScope ToBasicInfoDic:basicInfoDic];
    [self convertServerInfoItem:serverInfoDic[sWeightKey] withKey:sWeightKey scope:weightScope ToBasicInfoDic:basicInfoDic];
    [self convertServerInfoItem:serverInfoDic[sMensesAverageKey] withKey:sMensesAverageKey scope:mensesAverageScope ToBasicInfoDic:basicInfoDic];
    [self convertServerInfoItem:serverInfoDic[sMensesPeriodKey] withKey:sMensesPeriodKey scope:mensesPeriodScope ToBasicInfoDic:basicInfoDic];
    
    NSNumber *ageNumber = serverInfoDic[sBirthdayKey];
    NSInteger age = ageNumber.integerValue;
    NSInteger birthYear = ageScope.endValue - age;
    birthYear = MIN(ageScope.endValue, (MAX(ageScope.startValue, birthYear)));
    NSString *birthDayString = [@(birthYear).stringValue stringByAppendingString:@"01010000"];
    NSTimeInterval birthdayTimeStamp = [BOTimeStampAssistor timeStringToTimeStamp:birthDayString];
    [basicInfoDic setValue:@(birthdayTimeStamp) forKey:sBirthdayKey];
    
    NSNumber *targetIndexNumber = serverInfoDic[sSportTargetKey];
    NSUInteger index = targetIndexNumber.unsignedIntegerValue;
    NSInteger target = sportTargetScopeStepValue * index + sportTargetScope.startValue;
    target = MAX(sportTargetScope.startValue, (MIN(sportTargetScope.endValue, target)));
    [basicInfoDic setValue:@(target) forKey:sSportTargetKey];
    
    return basicInfoDic;
}


@end
