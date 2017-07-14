//
//  TYDDataCenter.m
//  Mofei
//
//  Created by macMini_Dev on 14-10-10.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import "TYDDataCenter.h"
#import "CoreDataManager.h"
#import "TYDBLEDeviceManager.h"

#import "HeartRateEntity.h"
#import "WalkStepEntity.h"

#import "TYDHeartRateRecordInfo.h"
#import "TYDStepRecordInfo.h"
#import "TYDFileResourceManager.h"
#import "TYDAppDelegate.h"
#import "BaseViewController.h"

#define nTimeIntervalSecondsIn15Minutes     900//(15*60)
#define nTimeIntervalSecondsPerHour         3600//(60*60)
#define nHourCountPerDay                    24
#define n15MinutesCountPerHour              4
#define nDayCountPerMonthMax                31

//30s计步数据未更新则为一个区段
#define nStepSegmentCheckInterval           30//30s

@interface TYDDataCenter () <TYDBLEDeviceManagerStepDataDelegate>

@property (strong, nonatomic) NSTimer *globalTimer;

@property (strong, nonatomic) NSMutableArray *heartRateMarkValues;
@property (strong, nonatomic) NSMutableArray *stepCountMarkValues;
@property (strong, nonatomic, readonly) NSMutableArray *consignInfos;//寄存数据条目

@property (nonatomic) NSUInteger stepCountStatic;    //离线及之前步数
@property (nonatomic) NSUInteger stepCountDynamic;   //当前实时步数

@end

@implementation TYDDataCenter
{
    NSInteger _todayBeginningTimeStamp; //今天的起始时间戳
    NSInteger _startMarkTimeStamp;      //记录期间起始时间戳
    NSInteger _targetMarkTimeStamp;     //记录期间终止时间戳
    
    //用以计算心率平均值
    NSUInteger _heartRateCount;         //心率计数次数
    NSUInteger _heartRateSum;           //心率总值
    
    NSUInteger _heartRateMax;           //今天心率最高值
    NSUInteger _heartRateMin;           //今天心率最低值
    
    //用以计算步数
    //(离线及之前步数)property
    //NSInteger _stepCountStatic;                     //离线及之前步数
    //(联线状态计步)property
    //NSInteger _stepCountDynamic;                   //当前实时步数
    NSInteger _stepCountDynamicLastMarkValue;       //之前时间段步数
    NSInteger _stepCountDynamicSegmentStartTime;    //当前计步段起始时间
    NSInteger _stepCountDynamicSegmentNoChangeCount;//步数停滞周期数
    
//    //云同步时标记标记值
//    //云同步动作当天的起始时间戳
//    NSInteger _cloudSynchrosizeMarkValueForTimeStamp;
//    //云同步动作时记录的静态步数
//    NSInteger _cloudSynchrosizeMarkValueForStepCountStatic;
//    //云同步动作时记录的动态步数
//    NSInteger _cloudSynchrosizeMarkValueForStepCountDynamic;
//    //云同步动作时记录的已录入数据库的步数值
//    NSInteger _cloudSynchrosizeMarkValueForStepCountInDataBase;
}

#pragma mark - Interface

- (void)saveHeartRateInfoToDataBaseDirectly:(TYDHeartRateRecordInfo *)hrInfo
{
    if(hrInfo)
    {
        CoreDataManager *coreDataManager = [CoreDataManager defaultManager];
        HeartRateEntity *hrEntity = (HeartRateEntity *)[coreDataManager createObjectWithEntityName:sHeartRateInfoEntityName];
        hrEntity.timeStamp = @(hrInfo.timeStamp);
        hrEntity.userID = [TYDUserInfo sharedUserInfo].userID;
        hrEntity.heartRateValue = @(hrInfo.heartRate);
        hrEntity.syncFlag = @(hrInfo.syncFlag);
        [coreDataManager saveContext];
    }
}

- (void)saveStepInfoToDataBaseDirectly:(TYDStepRecordInfo *)stepInfo
{
    if(stepInfo)
    {
        CoreDataManager *coreDateManager = [CoreDataManager defaultManager];
        WalkStepEntity *wsEntity = (WalkStepEntity *)[coreDateManager createObjectWithEntityName:sWalkStepInfoEntityName];
        wsEntity.timeStamp = @(stepInfo.timeStamp);
        wsEntity.userID = [TYDUserInfo sharedUserInfo].userID;
        wsEntity.endTimeStamp = @(stepInfo.endTimeStamp);
        wsEntity.walkStepCount = @(stepInfo.stepCount);
        wsEntity.distance = @(stepInfo.distance);
        wsEntity.calorie = @(stepInfo.calorie);
        wsEntity.syncFlag = @(stepInfo.syncFlag);
        [coreDateManager saveContext];
    }
}

- (void)saveHeartRateInfoToDataBase:(TYDHeartRateRecordInfo *)hrInfo
{
    if(hrInfo)
    {
        //if(![TYDFileResourceManager defaultManager].isInCloudSynchronizeDuration)
        if(!self.cloudSynchronizeLocked)
        {
            [self saveHeartRateInfoToDataBaseDirectly:hrInfo];
        }
        else
        {
            [self consignInfo:hrInfo];
        }
    }
}

- (void)saveStepInfoToDataBase:(TYDStepRecordInfo *)stepInfo
{
    if(stepInfo)
    {
        //if(![TYDFileResourceManager defaultManager].isInCloudSynchronizeDuration)
        if(!self.cloudSynchronizeLocked)
        {
            [self saveStepInfoToDataBaseDirectly:stepInfo];
        }
        else
        {
            [self consignInfo:stepInfo];
        }
    }
}

- (void)consignInfo:(id)info
{
    if(info)
    {
        [self.consignInfos addObject:info];
    }
}

- (void)cancelSaveConsignInfosToDataBase
{
    [self.consignInfos removeAllObjects];
}

- (void)saveConsignInfosToDataBase
{
    if(self.consignInfos.count > 0)
    {
        for(id info in self.consignInfos)
        {
            if([info isKindOfClass:TYDStepRecordInfo.class])
            {
                [self saveStepInfoToDataBaseDirectly:(TYDStepRecordInfo *)info];
            }
            else if([info isKindOfClass:TYDHeartRateRecordInfo.class])
            {
                [self saveHeartRateInfoToDataBaseDirectly:(TYDHeartRateRecordInfo *)info];
            }
        }
        [self.consignInfos removeAllObjects];
    }
}

- (NSPredicate *)timeStampPredicateCreateWithBeginningTimeStamp:(NSUInteger)beginningTimeStamp endTimeStamp:(NSUInteger)endTimeStamp
{
    //return [NSPredicate predicateWithFormat:@"%@ BETWEEN {%@,%@}", sTimeStampAttributeNameInEntity, @(beginningTimeStamp), @(endTimeStamp)];//Error
    return [NSPredicate predicateWithFormat:@"(timeStamp >= %lu) AND (timeStamp <= %lu)", (unsigned long)beginningTimeStamp, (unsigned long)endTimeStamp];
}

- (NSUInteger)heartRateCurrentMaxValue
{
    return _heartRateMax;
}

- (NSUInteger)heartRateCurrentMinValue
{
    return _heartRateMin;
}

- (NSMutableArray *)heartRateRecordInfosDailyWithTimeStamp:(NSTimeInterval)time
{
    NSUInteger dayBeginningTimeStamp = [BOTimeStampAssistor timeStampOfDayBeginningWithTimerStamp:time];
    NSUInteger dayEndTimeStamp = dayBeginningTimeStamp + nTimeIntervalSecondsPerDay - 1;
    NSMutableArray *hrRecordInfos = [NSMutableArray new];
    CoreDataManager *coreDataManager = [CoreDataManager defaultManager];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:sHeartRateInfoEntityName];
    request.predicate = [self timeStampPredicateCreateWithBeginningTimeStamp:dayBeginningTimeStamp endTimeStamp:dayEndTimeStamp];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:sTimeStampAttributeNameInEntity ascending:NO]];
    NSArray *savedInfos = [coreDataManager fetchObjectsWithRequest:request];
    for(HeartRateEntity *hrEntity in savedInfos)
    {
        TYDHeartRateRecordInfo *hrInfo = [TYDHeartRateRecordInfo new];
        hrInfo.heartRate = hrEntity.heartRateValue.unsignedIntegerValue;
        hrInfo.timeStamp = hrEntity.timeStamp.integerValue;
        hrInfo.syncFlag = hrEntity.syncFlag.boolValue;
        [hrRecordInfos addObject:hrInfo];
    }
    return hrRecordInfos;
}

- (NSMutableArray *)stepCountRecordInfosDailyWithTimeStamp:(NSTimeInterval)time
{
    NSUInteger dayBeginningTimeStamp = [BOTimeStampAssistor timeStampOfDayBeginningWithTimerStamp:time];
    NSUInteger dayEndTimeStamp = dayBeginningTimeStamp + nTimeIntervalSecondsPerDay - 1;
    NSMutableArray *scRecordInfos = [NSMutableArray new];
    CoreDataManager *coreDataManager = [CoreDataManager defaultManager];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:sWalkStepInfoEntityName];
    request.predicate = [self timeStampPredicateCreateWithBeginningTimeStamp:dayBeginningTimeStamp endTimeStamp:dayEndTimeStamp];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:sTimeStampAttributeNameInEntity ascending:NO]];
    NSArray *savedInfos = [coreDataManager fetchObjectsWithRequest:request];
    for(WalkStepEntity *wsEntity in savedInfos)
    {
        TYDStepRecordInfo *stepInfo = [TYDStepRecordInfo new];
        stepInfo.timeStamp = wsEntity.timeStamp.integerValue;
        stepInfo.endTimeStamp = wsEntity.endTimeStamp.integerValue;
        stepInfo.stepCount = wsEntity.walkStepCount.unsignedIntegerValue;
        stepInfo.distance = wsEntity.distance.floatValue;
        stepInfo.calorie = wsEntity.calorie.floatValue;
        stepInfo.syncFlag = wsEntity.syncFlag.boolValue;
        [scRecordInfos addObject:stepInfo];
    }
    return scRecordInfos;
}

- (NSArray *)heartRateMarkValuesDailyWithTimeStampFromDataBase:(NSTimeInterval)time
{
    NSUInteger dayBeginningTimeStamp = [BOTimeStampAssistor timeStampOfDayBeginningWithTimerStamp:time];
    NSUInteger dayEndTimeStamp = dayBeginningTimeStamp + nTimeIntervalSecondsPerDay - 1;
    CoreDataManager *coreDataManager = [CoreDataManager defaultManager];
    NSMutableArray *hrMarkValues = [NSMutableArray new];
    for(int i = n15MinutesCountPerHour * nHourCountPerDay; i > 0; i--)
    {
        [hrMarkValues addObject:@0];
    }
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:sHeartRateInfoEntityName];
    request.predicate = [self timeStampPredicateCreateWithBeginningTimeStamp:dayBeginningTimeStamp endTimeStamp:dayEndTimeStamp];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:sTimeStampAttributeNameInEntity ascending:YES]];
    NSArray *savedInfos = [coreDataManager fetchObjectsWithRequest:request];
    for(HeartRateEntity *hrEntity in savedInfos)
    {
        NSInteger time = hrEntity.timeStamp.integerValue - dayBeginningTimeStamp;
        NSUInteger index = time / nTimeIntervalSecondsIn15Minutes;
        if(index < hrMarkValues.count)
        {
            [hrMarkValues replaceObjectAtIndex:index withObject:hrEntity.heartRateValue];
        }
    }
    
    return hrMarkValues;
}

- (NSArray *)stepCountMarkValuesDailyWithTimeStampFromDataBase:(NSTimeInterval)time
{
    NSUInteger dayBeginningTimeStamp = [BOTimeStampAssistor timeStampOfDayBeginningWithTimerStamp:time];
    NSUInteger dayEndTimeStamp = dayBeginningTimeStamp + nTimeIntervalSecondsPerDay - 1;
    CoreDataManager *coreDataManager = [CoreDataManager defaultManager];
    NSMutableArray *wsMarkValues = [NSMutableArray new];
    for(int i = nHourCountPerDay; i > 0; i--)
    {
        [wsMarkValues addObject:@0];
    }
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:sWalkStepInfoEntityName];
    request.predicate = [self timeStampPredicateCreateWithBeginningTimeStamp:dayBeginningTimeStamp endTimeStamp:dayEndTimeStamp];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:sTimeStampAttributeNameInEntity ascending:YES]];
    NSArray *savedInfos = [coreDataManager fetchObjectsWithRequest:request];
    
    TYDStepRecordInfo *templeStepInfo = [TYDStepRecordInfo new];
    for(WalkStepEntity *wsEntity in savedInfos)
    {
        templeStepInfo.timeStamp = wsEntity.timeStamp.integerValue;
        templeStepInfo.endTimeStamp = wsEntity.endTimeStamp.integerValue;
        templeStepInfo.stepCount = wsEntity.walkStepCount.unsignedIntegerValue;
        templeStepInfo.distance = wsEntity.distance.floatValue;
        templeStepInfo.calorie = wsEntity.calorie.floatValue;
        templeStepInfo.syncFlag = wsEntity.syncFlag.boolValue;
        
        [self dailyStepCountMarkValues:wsMarkValues updateWithStepInfo:templeStepInfo dayBeginningTimeStamp:dayBeginningTimeStamp];
    }
    
    return wsMarkValues;
}

- (void)dateChangedWhileTimerInvalidate
{
    [self stepCountValuesReset];
    [self heartRateValuesReset];
    NSUInteger todayBeginning = [BOTimeStampAssistor timeStampOfDayBeginningForToday];
    _todayBeginningTimeStamp = todayBeginning;
    self.stepCountMarkValues = [[self stepCountMarkValuesDailyWithTimeStampFromDataBase:todayBeginning] mutableCopy];
    self.heartRateMarkValues = [[self stepCountMarkValuesDailyWithTimeStampFromDataBase:todayBeginning] mutableCopy];
    for(NSNumber *stepCountPerHour in self.stepCountMarkValues)
    {
        _stepCountStatic += stepCountPerHour.unsignedIntegerValue;
    }
    _stepCountDynamic = [TYDBLEDeviceManager sharedBLEDeviceManager].stepCount;
    _stepCountCurrentValue = _stepCountStatic + _stepCountDynamic;
}

- (NSArray *)heartRateMarkValuesDailyWithTimeStamp:(NSTimeInterval)time
{
    NSUInteger dayBeginningTimeStamp = [BOTimeStampAssistor timeStampOfDayBeginningWithTimerStamp:time];
    NSUInteger todayBeginning = [BOTimeStampAssistor timeStampOfDayBeginningForToday];
    if(_todayBeginningTimeStamp != todayBeginning
       && !self.globalTimer.isValid)
    {
        [self dateChangedWhileTimerInvalidate];
    }
    if(_todayBeginningTimeStamp == dayBeginningTimeStamp
       && self.heartRateMarkValues.count)
    {
        return [self.heartRateMarkValues copy];
    }
    else
    {
        return [self heartRateMarkValuesDailyWithTimeStampFromDataBase:time];
    }
}

- (NSArray *)stepCountMarkValuesDailyWithTimeStamp:(NSTimeInterval)time
{
    NSUInteger dayBeginningTimeStamp = [BOTimeStampAssistor timeStampOfDayBeginningWithTimerStamp:time];
    NSUInteger todayBeginning = [BOTimeStampAssistor timeStampOfDayBeginningForToday];
    if(_todayBeginningTimeStamp != todayBeginning)
    {
        [self dateChangedWhileTimerInvalidate];
    }
    if(_todayBeginningTimeStamp == dayBeginningTimeStamp
       && self.stepCountMarkValues.count)
    {
        return [self.stepCountMarkValues copy];
    }
    else
    {
        return [self stepCountMarkValuesDailyWithTimeStampFromDataBase:time];
    }
}

//0:max 1:min 2:sum 3:count
- (NSArray *)heartRateStatisticsValuesWeeklyWithTimeStamp:(NSTimeInterval)time
{
    NSUInteger weekBeginningTimeStamp = [BOTimeStampAssistor timeStampOfWeekBeginningWithTimerStamp:time];
    NSUInteger weekEndTimeStamp = [BOTimeStampAssistor timeStampOfWeekEndWithTimerStamp:time];
    
    NSUInteger hrSum = 0;
    NSUInteger hrCount = 0;
    NSUInteger hrMax = 0;
    NSUInteger hrMin = 0;
    
    CoreDataManager *coreDataManager = [CoreDataManager defaultManager];
    NSPredicate *predicate = [self timeStampPredicateCreateWithBeginningTimeStamp:weekBeginningTimeStamp endTimeStamp:weekEndTimeStamp];
    NSArray *savedInfos = [coreDataManager fetchObjectsWithEntityName:sHeartRateInfoEntityName sortDescriptors:nil predicate:predicate];
    for(HeartRateEntity *hrEntity in savedInfos)
    {
        NSUInteger heartRate = hrEntity.heartRateValue.unsignedIntegerValue;
        hrSum += heartRate;
        hrCount++;
        
        hrMax = MAX(hrMax, heartRate);
        if(hrMin == 0)
        {
            hrMin = heartRate;
        }
        else
        {
            hrMin = MIN(hrMin, heartRate);
        }
    }
    
    return @[@(hrMax), @(hrMin), @(hrSum), @(hrCount)];
}

- (NSArray *)stepCountMarkValuesWeeklyWithTimeStamp:(NSTimeInterval)time
{
    NSUInteger weekBeginningTimeStamp = [BOTimeStampAssistor timeStampOfWeekBeginningWithTimerStamp:time];
    NSUInteger weekEndTimeStamp = [BOTimeStampAssistor timeStampOfWeekEndWithTimerStamp:time];
    CoreDataManager *coreDataManager = [CoreDataManager defaultManager];
    NSMutableArray *wsMarkValues = [NSMutableArray new];
    for(int i = 7; i > 0; i--)
    {
        [wsMarkValues addObject:@0];
    }
    NSPredicate *predicate = [self timeStampPredicateCreateWithBeginningTimeStamp:weekBeginningTimeStamp endTimeStamp:weekEndTimeStamp];
    NSArray *savedInfos = [coreDataManager fetchObjectsWithEntityName:sWalkStepInfoEntityName sortDescriptors:nil predicate:predicate];
    for(WalkStepEntity *wsEntity in savedInfos)
    {
        NSUInteger time = wsEntity.timeStamp.unsignedIntegerValue - weekBeginningTimeStamp;
        NSUInteger index = time / nTimeIntervalSecondsPerDay;
        if(index < wsMarkValues.count)
        {
            NSInteger step = wsEntity.walkStepCount.unsignedIntegerValue + [wsMarkValues[index] integerValue];
            [wsMarkValues replaceObjectAtIndex:index withObject:@(step)];
        }
    }
    
    return wsMarkValues;
}

- (NSArray *)stepCountMarkValuesMonthlyWithTimeStamp:(NSTimeInterval)time
{
    NSUInteger monthBeginningTimeStamp = [BOTimeStampAssistor timeStampOfMonthBeginningWithTimerStamp:time];
    NSUInteger monthEndTimeStamp = [BOTimeStampAssistor timeStampOfMonthEndWithTimerStamp:time];
    CoreDataManager *coreDataManager = [CoreDataManager defaultManager];
    NSMutableArray *wsMarkValues = [NSMutableArray new];
    for(int i = nDayCountPerMonthMax; i > 0; i--)
    {
        [wsMarkValues addObject:@0];
    }
    NSPredicate *predicate = [self timeStampPredicateCreateWithBeginningTimeStamp:monthBeginningTimeStamp endTimeStamp:monthEndTimeStamp];
    
    NSArray *savedInfos = [coreDataManager fetchObjectsWithEntityName:sWalkStepInfoEntityName sortDescriptors:nil predicate:predicate];
    for(WalkStepEntity *wsEntity in savedInfos)
    {
        NSUInteger time = wsEntity.timeStamp.unsignedIntegerValue - monthBeginningTimeStamp;
        NSUInteger index = time / nTimeIntervalSecondsPerDay;
        if(index < wsMarkValues.count)
        {
            NSUInteger step = wsEntity.walkStepCount.unsignedIntegerValue + [wsMarkValues[index] integerValue];
            [wsMarkValues replaceObjectAtIndex:index withObject:@(step)];
        }
    }
    
    return wsMarkValues;
}

//0:max 1:min 2:sum 3:count
- (NSArray *)heartRateStatisticsValuesMonthlyWithTimeStamp:(NSTimeInterval)time
{
    NSUInteger monthBeginningTimeStamp = [BOTimeStampAssistor timeStampOfMonthBeginningWithTimerStamp:time];
    NSUInteger monthEndTimeStamp = [BOTimeStampAssistor timeStampOfMonthEndWithTimerStamp:time];
    
    NSUInteger hrSum = 0;
    NSUInteger hrCount = 0;
    NSUInteger hrMax = 0;
    NSUInteger hrMin = 0;
    
    CoreDataManager *coreDataManager = [CoreDataManager defaultManager];
    NSPredicate *predicate = [self timeStampPredicateCreateWithBeginningTimeStamp:monthBeginningTimeStamp endTimeStamp:monthEndTimeStamp];
    NSArray *savedInfos = [coreDataManager fetchObjectsWithEntityName:sHeartRateInfoEntityName sortDescriptors:nil predicate:predicate];
    for(HeartRateEntity *hrEntity in savedInfos)
    {
        NSUInteger heartRate = hrEntity.heartRateValue.unsignedIntegerValue;
        hrSum += heartRate;
        hrCount++;
        
        hrMax = MAX(hrMax, heartRate);
        if(hrMin == 0)
        {
            hrMin = heartRate;
        }
        else
        {
            hrMin = MIN(hrMin, heartRate);
        }
    }
    
    return @[@(hrMax), @(hrMin), @(hrSum), @(hrCount)];
}

#pragma mark - Calculate

- (void)refreshDynamicValues
{
    TYDBLEDeviceManager *manager = [TYDBLEDeviceManager sharedBLEDeviceManager];
    if([manager activePeripheralEnable])
    //if(manager.connectState == TYDBLEDeviceManagerStateConnected)
    {
        _isDataValid = YES;
        _batteryLevelCurrentValue = manager.batteryLevel;
        _heartRateCurrentValue = manager.heartRate;
    }
    else
    {
        _isDataValid = NO;
        _batteryLevelCurrentValue = 0.0;
        _heartRateCurrentValue = 0;
    }
}

- (void)heartRateDynamicValuesCalculate
{
    if(self.isDataValid)
    {
        NSUInteger hrValue = self.heartRateCurrentValue;
        if(hrValue > 0)
        {
            _heartRateCount++;
            _heartRateSum += hrValue;
        }
    }
}

- (void)saveHeartRateDynamicValuesPer15Minutes
{
    //每15分保存一次心率数据
    if(_heartRateSum > 0
       && _heartRateCount > 0)
    {
        NSUInteger heartRate = _heartRateSum / _heartRateCount;
        TYDHeartRateRecordInfo *hrInfo = [TYDHeartRateRecordInfo new];
        hrInfo.timeStamp = _startMarkTimeStamp + _todayBeginningTimeStamp;
        hrInfo.heartRate = heartRate;
        hrInfo.syncFlag = NO;
        [self saveHeartRateInfoToDataBase:hrInfo];
        [self saveHeartRateRecoreInfoAdditionalEvent:hrInfo];
        
        _heartRateSum = 0;
        _heartRateCount = 0;
        
        _heartRateMax = MAX(_heartRateMax, heartRate);
        if(_heartRateMin == 0)
        {
            _heartRateMin = heartRate;
        }
        else
        {
            _heartRateMin = MIN(_heartRateMin, heartRate);
        }
        
        NSInteger markIndex = _startMarkTimeStamp / nTimeIntervalSecondsIn15Minutes;
        [self.heartRateMarkValues replaceObjectAtIndex:markIndex withObject:@(heartRate)];
        
        NSLog(@"saveHeartRateInfo:%ld timeStamp:%@", (long)hrInfo.heartRate, [BOTimeStampAssistor getTimeStringWithTimeStamp:hrInfo.timeStamp]);
    }
}

- (void)stepCountMarkValuesRefresh
{
    self.stepCountMarkValues = [[self stepCountMarkValuesDailyWithTimeStampFromDataBase:_todayBeginningTimeStamp] mutableCopy];
}

- (void)next15minutesPeriod
{
    //下一个时间段（15minutes）
    _startMarkTimeStamp = _targetMarkTimeStamp;
    _targetMarkTimeStamp += nTimeIntervalSecondsIn15Minutes;
}

- (void)timeStampVariablesAction
{
    NSUInteger currentTime = [BOTimeStampAssistor getCurrentTime];
    NSUInteger interval = currentTime - _todayBeginningTimeStamp;
    
    //超过一个存储周期，需要存储，时间标签需要更新（递增15分）
    if(interval >= _targetMarkTimeStamp)
    {
        [self saveHeartRateDynamicValuesPer15Minutes];
        [self next15minutesPeriod];
    }
    
    [self stepCountTimeSequence:currentTime];
    if(_stepCountDynamicSegmentNoChangeCount > nStepSegmentCheckInterval)
    {
        [self saveStepCountDynamicSegment];
    }
    
    //日期改变，变量重置
    if(interval >= nTimeIntervalSecondsPerDay)
    {
        if(_stepCountDynamic > _stepCountDynamicLastMarkValue)
        {
            [self saveStepCountDynamicSegment];
        }
        
        [self localTimeStampVariablesReset];
        [self markValuesInit];
        
        [[TYDBLEDeviceManager sharedBLEDeviceManager] refreshStepCountWithNewValue:0];
        [self stepCountValuesReset];
        [self heartRateValuesReset];
        _stepCountCurrentValue = 0;
        
        NSLog(@"CoreDataCenter:NextDay _startMarkTimeStamp:%ld, _targetMarkTimeStamp:%ld", (long)_startMarkTimeStamp, (long)_targetMarkTimeStamp);
    }
}

- (void)stepCountTimeSequence:(NSUInteger)currentTime
{
    NSUInteger deviceStepCount = [TYDBLEDeviceManager sharedBLEDeviceManager].stepCount;
    if(deviceStepCount == _stepCountDynamic)
    {
        //有计步数据，当前停滞
        if(_stepCountDynamic > _stepCountDynamicLastMarkValue)
        {
            _stepCountDynamicSegmentNoChangeCount++;
        }
        else//(_stepCountDynamic == _stepCountDynamicLastMarkValue)
        {//无计步数据
            _stepCountDynamicSegmentNoChangeCount = 0;
            _stepCountDynamicSegmentStartTime = 0;
        }
    }
    else//(deviceStepCount > _stepCountDynamic)
    {
        if(_stepCountDynamic > _stepCountDynamicLastMarkValue)
        {
            //有新计步数据，正在记录
            _stepCountDynamicSegmentNoChangeCount = 0;
        }
        else//(_stepCountDynamic == _stepCountDynamicLastMarkValue)
        {
            //有新计步数据，开始记录
            _stepCountDynamicSegmentStartTime = currentTime ;
            _stepCountDynamicSegmentNoChangeCount = 0;
        }
    }
    _stepCountDynamic = deviceStepCount;
    _stepCountCurrentValue = _stepCountDynamic + _stepCountStatic;
}

- (void)saveStepCountDynamicSegment
{
    NSUInteger stepCount = _stepCountDynamic - _stepCountDynamicLastMarkValue;
    NSUInteger currentTime = [BOTimeStampAssistor getCurrentTime];
    if(_stepCountDynamicSegmentStartTime > 0
       && stepCount > 0)
    {
        TYDUserInfo *userInfo = [TYDUserInfo sharedUserInfo];
        
        TYDStepRecordInfo *stepInfo = [TYDStepRecordInfo new];
        //单位由米转为千米
        CGFloat distance = [TYDUserInfo distanceMeasuredWithUserInfo:userInfo andStepCount:stepCount] / 1000;
        
        stepInfo.timeStamp = _stepCountDynamicSegmentStartTime;
        stepInfo.endTimeStamp = currentTime;
        stepInfo.stepCount = stepCount;
        stepInfo.distance = distance;
        stepInfo.calorie = [TYDUserInfo calorieMeasuredWithUserInfo:userInfo andStepCount:stepCount];
        stepInfo.syncFlag = NO;
        [self saveStepInfoToDataBase:stepInfo];
        [self saveStepRecoreInfoAdditionalEvent:stepInfo];
        NSLog(@"saveStepCountDynamicSegment:%@, %@", [BOTimeStampAssistor getTimeStringWithTimeStamp:_stepCountDynamicSegmentStartTime], @(stepCount));
    }
    _stepCountDynamicLastMarkValue = _stepCountDynamic;
    _stepCountDynamicSegmentStartTime = 0;
    _stepCountDynamicSegmentNoChangeCount = 0;
    [self stepCountMarkValuesRefresh];
}

#pragma mark - GlobalTimer

- (void)dataCenterBasicEvent
{
    NSLog(@"dataCenterBasicEvent");
    
    [self refreshDynamicValues];
    [self heartRateDynamicValuesCalculate];
    [self timeStampVariablesAction];
}

- (void)globalTimerStartPrepareAction
{
    //[self timeStampVariablesAction];
    NSUInteger time = [BOTimeStampAssistor getCurrentTime];
    NSUInteger todayBeginningTimeStamp = [BOTimeStampAssistor timeStampOfDayBeginningWithTimerStamp:time];
    NSUInteger startMarkTimeStamp = (time - todayBeginningTimeStamp) / nTimeIntervalSecondsIn15Minutes * nTimeIntervalSecondsIn15Minutes;
    
    if(_todayBeginningTimeStamp != todayBeginningTimeStamp)//日期变更
    {
        [self saveHeartRateDynamicValuesPer15Minutes];
        //时间重置
        _todayBeginningTimeStamp = todayBeginningTimeStamp;
        _startMarkTimeStamp = startMarkTimeStamp;
        _targetMarkTimeStamp = _startMarkTimeStamp + nTimeIntervalSecondsIn15Minutes;
        [self markValuesInit];
    }
    else if(_startMarkTimeStamp != startMarkTimeStamp)//仅时间变更
    {
        [self saveHeartRateDynamicValuesPer15Minutes];
        //时间重置
        _startMarkTimeStamp = startMarkTimeStamp;
        _targetMarkTimeStamp = _startMarkTimeStamp + nTimeIntervalSecondsIn15Minutes;
    }
}

- (void)globalTimerStart
{
    [self globalTimerInvalidate];
    [self globalTimerStartPrepareAction];
    //interval:1sec
    self.globalTimer = [NSTimer scheduledTimerWithTimeInterval:nBasicTimerInterval target:self selector:@selector(dataCenterBasicEvent) userInfo:nil repeats:YES];
}

- (void)globalTimerCancel
{
    [self globalTimerInvalidate];
    if(_stepCountDynamic > _stepCountDynamicLastMarkValue)
    {
        [self saveStepCountDynamicSegment];
    }
    
    [self refreshDynamicValues];
    _stepCountStatic += _stepCountDynamic;
    _stepCountDynamic = 0;
    _stepCountDynamicLastMarkValue = 0;
}

- (void)globalTimerInvalidate
{
    if([self.globalTimer isValid])
    {
        [self.globalTimer invalidate];
        self.globalTimer = nil;
    }
}

#pragma mark - SingleTon

- (void)localTimeStampVariablesReset
{
    _todayBeginningTimeStamp = [BOTimeStampAssistor timeStampOfDayBeginningForToday];
    _startMarkTimeStamp = 0;
    _targetMarkTimeStamp = nTimeIntervalSecondsIn15Minutes;
}

- (instancetype)init
{
    if(self = [super init])
    {
        [self refreshDynamicValues];
        [self localTimeStampVariablesInit];
        [self markValuesInit];
        [self dateTimeStampForSaving1stInfoItemInit];
        [self remindAlertInfoInit];
        
        [TYDBLEDeviceManager sharedBLEDeviceManager].stepDataDelegate = self;
        _consignInfos = [NSMutableArray new];
        self.cloudSynchronizeLocked = NO;
    }
    return self;
}

+ (instancetype)defaultCenter
{
    static TYDDataCenter *dataCenterInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        dataCenterInstance = [[self alloc] init];
    });
    return dataCenterInstance;
}

- (void)localTimeStampVariablesInit
{
    NSUInteger time = [BOTimeStampAssistor getCurrentTime];
    _todayBeginningTimeStamp = [BOTimeStampAssistor timeStampOfDayBeginningWithTimerStamp:time];
    NSUInteger interval = time - _todayBeginningTimeStamp;
    _startMarkTimeStamp = interval / nTimeIntervalSecondsIn15Minutes * nTimeIntervalSecondsIn15Minutes;
    _targetMarkTimeStamp = _startMarkTimeStamp + nTimeIntervalSecondsIn15Minutes;
}

- (void)stepCountValuesReset
{
    _stepCountDynamic = 0;
    _stepCountDynamicLastMarkValue = 0;
    _stepCountDynamicSegmentStartTime = 0;
    _stepCountDynamicSegmentNoChangeCount = 0;
    
    _stepCountStatic = 0;
}

- (void)heartRateValuesReset
{
    _heartRateCount = 0;
    _heartRateSum = 0;
    _heartRateMax = 0;
    _heartRateMin = 0;
}

- (void)markValuesInit
{
    [self heartRateValuesReset];
    [self stepCountValuesReset];
    
    self.heartRateMarkValues = [[self heartRateMarkValuesDailyWithTimeStampFromDataBase:_todayBeginningTimeStamp] mutableCopy];
    self.stepCountMarkValues = [[self stepCountMarkValuesDailyWithTimeStampFromDataBase:_todayBeginningTimeStamp] mutableCopy];
    for(NSNumber *stepCountPerHour in self.stepCountMarkValues)
    {
        _stepCountStatic += stepCountPerHour.unsignedIntegerValue;
    }
    _stepCountDynamic = [TYDBLEDeviceManager sharedBLEDeviceManager].stepCount;
    _stepCountCurrentValue = _stepCountStatic + _stepCountDynamic;
}

//从数据库中提取最早录入数据条目的时间
- (void)dateTimeStampForSaving1stInfoItemInit
{
    NSUInteger timeMark = [BOTimeStampAssistor timeStampOfDayBeginningForToday];
    CoreDataManager *coreDataManager = [CoreDataManager defaultManager];
    
    //计步
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:sWalkStepInfoEntityName];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:sTimeStampAttributeNameInEntity ascending:YES]];
    request.fetchLimit = 1;
    NSArray *items = [coreDataManager fetchObjectsWithRequest:request];
    if(items.count > 0)
    {
        WalkStepEntity *wsEntity = items[0];
        timeMark = MIN(timeMark, wsEntity.timeStamp.integerValue);
    }
    
    //心率
    request = [[NSFetchRequest alloc] initWithEntityName:sHeartRateInfoEntityName];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:sTimeStampAttributeNameInEntity ascending:YES]];
    request.fetchLimit = 1;
    items = [coreDataManager fetchObjectsWithRequest:request];
    if(items.count > 0)
    {
        HeartRateEntity *hrEntity = items[0];
        timeMark = MIN(timeMark, hrEntity.timeStamp.integerValue);
    }
    
    _firstInfoItemSavedDateTimeStamp = [BOTimeStampAssistor timeStampOfDayBeginningWithTimerStamp:timeMark];
    NSLog(@"firstInfoItemSavedDateTimeStamp:%@", [BOTimeStampAssistor getTimeStringWithTimeStamp:_firstInfoItemSavedDateTimeStamp]);
}

#pragma mark - TYDBLEDeviceManagerStepDataDelegate

- (void)deviceManagerHeartRateMeasureDropCheckReport:(BOOL)isDropped
{
    if(isDropped)
    {
        TYDAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        UIViewController *vc = appDelegate.eventDelegate;
        if([vc respondsToSelector:@selector(setNoticeText:)])
        {
            [vc performSelector:@selector(setNoticeText:) withObject:@"设备脱落或接触不良"];
        }
    }
}

- (void)deviceManagerOfflineStepDataUpdated:(NSUInteger)stepCount startTime:(NSUInteger)startTime endTime:(NSUInteger)endTime
{
    if(stepCount == 0)
    {
        return;
    }
    
    TYDUserInfo *userInfo = [TYDUserInfo sharedUserInfo];
    //单位由米转为千米
    CGFloat distance = [TYDUserInfo distanceMeasuredWithUserInfo:userInfo andStepCount:stepCount] / 1000;
    
    TYDStepRecordInfo *stepInfo = [TYDStepRecordInfo new];
    stepInfo.timeStamp = startTime;
    stepInfo.endTimeStamp = endTime;
    stepInfo.stepCount = stepCount;
    stepInfo.distance = distance;
    stepInfo.calorie = [TYDUserInfo calorieMeasuredWithUserInfo:userInfo andStepCount:stepCount];
    stepInfo.syncFlag = NO;
    [self saveStepInfoToDataBase:stepInfo];
    [self saveStepRecoreInfoAdditionalEvent:stepInfo];
    
    NSLog(@"saveOfflineStepCountInfo:%ld timeStamp:%@", (long)stepCount, [BOTimeStampAssistor getTimeStringWithTimeStamp:startTime]);
    
    if(_todayBeginningTimeStamp == [BOTimeStampAssistor timeStampOfDayBeginningWithTimerStamp:startTime])
    {//当天数据
        _stepCountStatic += stepCount;
        _stepCountCurrentValue = _stepCountStatic + _stepCountDynamic;
        
        [self dailyStepCountMarkValues:self.stepCountMarkValues updateWithStepInfo:stepInfo dayBeginningTimeStamp:_todayBeginningTimeStamp];
    }
}

- (void)dailyStepCountMarkValues:(NSMutableArray *)stepMarkValues updateWithStepInfo:(TYDStepRecordInfo *)stepInfo dayBeginningTimeStamp:(NSUInteger)dayBeginningTimeStamp
{
    NSUInteger stepCount = stepInfo.stepCount;
    NSUInteger startTime = stepInfo.timeStamp;
    startTime -= dayBeginningTimeStamp;
    NSUInteger startMarkIndex = startTime / nTimeIntervalSecondsPerHour;
    [stepMarkValues replaceObjectAtIndex:startMarkIndex withObject:@([stepMarkValues[startMarkIndex] unsignedIntegerValue] + stepCount)];
}

#pragma mark - SaveRecordInfoAdditionalEvent

- (void)saveStepRecoreInfoAdditionalEvent:(TYDStepRecordInfo *)stepInfo
{
    if(stepInfo
       && stepInfo.stepCount > 0
       && [self.saveEventDelegate respondsToSelector:@selector(dataCenterSavedOneStepRecordInfo:)])
    {
        [self.saveEventDelegate dataCenterSavedOneStepRecordInfo:stepInfo];
    }
}

- (void)saveHeartRateRecoreInfoAdditionalEvent:(TYDHeartRateRecordInfo *)hrInfo
{
    if(hrInfo
       && [self.saveEventDelegate respondsToSelector:@selector(dataCenterSavedOneHeartRateRecordInfo:)])
    {
        [self.saveEventDelegate dataCenterSavedOneHeartRateRecordInfo:hrInfo];
    }
}

- (void)reloadInfosFromDataBase
{
    self.heartRateMarkValues = [[self heartRateMarkValuesDailyWithTimeStampFromDataBase:_todayBeginningTimeStamp] mutableCopy];
    self.stepCountMarkValues = [[self stepCountMarkValuesDailyWithTimeStampFromDataBase:_todayBeginningTimeStamp] mutableCopy];
    
//    NSInteger savedInfoOfStepCount = 0;
//    for(NSNumber *stepCountPerHour in self.stepCountMarkValues)
//    {
//        savedInfoOfStepCount += stepCountPerHour.unsignedIntegerValue;
//    }
//    if(_cloudSynchrosizeMarkValueForTimeStamp == _todayBeginningTimeStamp)
//    {
//        if(savedInfoOfStepCount != _cloudSynchrosizeMarkValueForStepCountInDataBase)
//        {
//            self.stepCountStatic = _cloudSynchrosizeMarkValueForStepCountStatic - _cloudSynchrosizeMarkValueForStepCountInDataBase + savedInfoOfStepCount;
//        }
//    }
    
    //更新页面有效
    self.isDataUpdated = YES;
    if([self.refreshedDelegate respondsToSelector:@selector(dataCenterSavedInfosRefreshed:)])
    {
        [self.refreshedDelegate dataCenterSavedInfosRefreshed:self];
    }
}

#pragma mark - DataCenterRefresh

- (void)dataCenterRefreshWhenCloudSynchronizeStart
{
    [self saveStepCountDynamicSegment];
    self.stepCountDynamic = 0;
    [[TYDBLEDeviceManager sharedBLEDeviceManager] refreshStepCountWithNewValue:self.stepCountDynamic];
    _stepCountDynamicLastMarkValue = self.stepCountDynamic;
    _stepCountDynamicSegmentStartTime = 0;
    _stepCountDynamicSegmentNoChangeCount = 0;
    
    NSUInteger stepCountInDataBase = 0;
    for(NSNumber *stepCountPerHour in self.stepCountMarkValues)
    {
        stepCountInDataBase += stepCountPerHour.unsignedIntegerValue;
    }
    self.stepCountStatic = stepCountInDataBase;
    _stepCountCurrentValue = self.stepCountDynamic + self.stepCountStatic;
}

- (void)dataCenterRefreshWhenCloudSynchronizeComplete
{
    self.stepCountStatic = [self savedInfoOfStepCountInDataBaseForToday];
    [self saveConsignInfosToDataBase];
    _stepCountCurrentValue = self.stepCountDynamic + self.stepCountStatic;
    [self reloadInfosFromDataBase];
    [self dateTimeStampForSaving1stInfoItemInit];
}

- (void)dataCenterRefreshWhenLoginCloudSynchronizeComplete
{
    [self cancelSaveConsignInfosToDataBase];
    self.stepCountStatic = [self savedInfoOfStepCountInDataBaseForToday];
    self.stepCountDynamic = 0;
    _stepCountCurrentValue = self.stepCountDynamic + self.stepCountStatic;
    
    _stepCountDynamicLastMarkValue = self.stepCountDynamic;
    _stepCountDynamicSegmentStartTime = 0;
    _stepCountDynamicSegmentNoChangeCount = 0;
    
    [[TYDBLEDeviceManager sharedBLEDeviceManager] refreshStepCountWithNewValue:self.stepCountDynamic];
    [self reloadInfosFromDataBase];
    [self dateTimeStampForSaving1stInfoItemInit];
}

- (void)dataCenterRefreshWhenLogoutCloudSynchronizeStart
{
    [self dataCenterRefreshWhenCloudSynchronizeStart];
}

- (void)dataCenterRefreshWhenLogoutCloudSynchronizeComplete
{
    [self cancelSaveConsignInfosToDataBase];
    [[TYDBLEDeviceManager sharedBLEDeviceManager] refreshStepCountWithNewValue:0];
    self.stepCountDynamic = 0;
    self.stepCountStatic = 0;
    _stepCountCurrentValue = 0;
    _stepCountDynamicLastMarkValue = 0;
    _stepCountDynamicSegmentStartTime = 0;
    _stepCountDynamicSegmentNoChangeCount = 0;
    [self reloadInfosFromDataBase];
    [self dateTimeStampForSaving1stInfoItemInit];
}

#pragma mark - EventForCloudSynchrosize

- (NSUInteger)savedInfoOfStepCountInDataBaseForToday
{
    NSUInteger dayBeginningTimeStamp = _todayBeginningTimeStamp;
    NSUInteger dayEndTimeStamp = dayBeginningTimeStamp + nTimeIntervalSecondsPerDay - 1;
    NSUInteger stepCount = 0;
    CoreDataManager *coreDataManager = [CoreDataManager defaultManager];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:sWalkStepInfoEntityName];
    request.predicate = [self timeStampPredicateCreateWithBeginningTimeStamp:dayBeginningTimeStamp endTimeStamp:dayEndTimeStamp];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:sTimeStampAttributeNameInEntity ascending:YES]];
    NSArray *savedInfos = [coreDataManager fetchObjectsWithRequest:request];
    
    for(WalkStepEntity *wsEntity in savedInfos)
    {
        stepCount += wsEntity.walkStepCount.integerValue;
    }
    return stepCount;
}

#pragma mark - RemindAlertInfo

#define sRemindAlertIsOnKey     @"remindAlertIsOn"
#define sRemindAlertStartTime   @"remindAlertStartTime"
#define sRemindAlertEndTime     @"remindAlertEndTime"
#define sRemindAlertInterval    @"remindAlertInterval"

- (void)remindAlertInfoInit
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.remindAlertIsOn = [userDefaults boolForKey:sRemindAlertIsOnKey];
    self.remindAlertStartTime = [userDefaults integerForKey:sRemindAlertStartTime];
    self.remindAlertEndTime = [userDefaults integerForKey:sRemindAlertEndTime];
    self.remindAlertInterval = [userDefaults integerForKey:sRemindAlertInterval];
}

- (void)remindAlertInfoSave
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:self.remindAlertIsOn forKey:sRemindAlertIsOnKey];
    [userDefaults setInteger:self.remindAlertStartTime forKey:sRemindAlertStartTime];
    [userDefaults setInteger:self.remindAlertEndTime forKey:sRemindAlertEndTime];
    [userDefaults setInteger:self.remindAlertInterval forKey:sRemindAlertInterval];
    [userDefaults synchronize];
    [[TYDBLEDeviceManager sharedBLEDeviceManager] remindAlertStateSet];
}

@end
