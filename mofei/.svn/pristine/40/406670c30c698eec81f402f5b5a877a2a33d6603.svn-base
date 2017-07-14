//
//  TYDDataCenter.h
//  Mofei
//
//  Created by macMini_Dev on 14-10-10.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import <Foundation/Foundation.h>

#define nDeviceBatteryLevelWarning      10

@class TYDDataCenter;
@class TYDStepRecordInfo;
@class TYDHeartRateRecordInfo;
@protocol TYDDataCenterSaveEventDelegate <NSObject>
@optional
- (void)dataCenterSavedOneStepRecordInfo:(TYDStepRecordInfo *)stepRecordInfo;
- (void)dataCenterSavedOneHeartRateRecordInfo:(TYDHeartRateRecordInfo *)heartRateRecordInfo;
@end

@protocol TYDDataCenterRefreshedDelegate <NSObject>
@optional
- (void)dataCenterSavedInfosRefreshed:(TYDDataCenter *)dataCenter;
@end

@interface TYDDataCenter : NSObject

@property (assign, nonatomic) id<TYDDataCenterSaveEventDelegate> saveEventDelegate;
@property (assign, nonatomic) id<TYDDataCenterRefreshedDelegate> refreshedDelegate;

@property (atomic) BOOL isDataUpdated;//数据库数据有变动，界面要更新
@property (nonatomic, readonly) BOOL isDataValid;
@property (nonatomic, readonly) NSUInteger heartRateCurrentValue;
@property (nonatomic, readonly) NSUInteger stepCountCurrentValue;
@property (nonatomic, readonly) CGFloat batteryLevelCurrentValue;

@property (nonatomic, readonly) NSUInteger firstInfoItemSavedDateTimeStamp;

//锁定标志，云同步锁效果不佳
@property (atomic) BOOL cloudSynchronizeLocked;

+ (instancetype)defaultCenter;
- (void)globalTimerStart;
- (void)globalTimerCancel;

- (NSUInteger)heartRateCurrentMaxValue;
- (NSUInteger)heartRateCurrentMinValue;

- (NSArray *)heartRateMarkValuesDailyWithTimeStamp:(NSTimeInterval)time;
- (NSArray *)stepCountMarkValuesDailyWithTimeStamp:(NSTimeInterval)time;

- (NSArray *)stepCountMarkValuesWeeklyWithTimeStamp:(NSTimeInterval)time;
- (NSArray *)stepCountMarkValuesMonthlyWithTimeStamp:(NSTimeInterval)time;

- (NSMutableArray *)heartRateRecordInfosDailyWithTimeStamp:(NSTimeInterval)time;
- (NSMutableArray *)stepCountRecordInfosDailyWithTimeStamp:(NSTimeInterval)time;

- (NSArray *)heartRateStatisticsValuesWeeklyWithTimeStamp:(NSTimeInterval)time;
- (NSArray *)heartRateStatisticsValuesMonthlyWithTimeStamp:(NSTimeInterval)time;

//保存新数据条目到数据库，外部调用只针对云同步时获得的数据入库
- (void)saveStepInfoToDataBaseDirectly:(TYDStepRecordInfo *)stepInfo;
- (void)saveHeartRateInfoToDataBaseDirectly:(TYDHeartRateRecordInfo *)hrInfo;

//云同步时起始、结束触发事件，保持数据库数据一致
- (void)dataCenterRefreshWhenCloudSynchronizeStart;
- (void)dataCenterRefreshWhenCloudSynchronizeComplete;
- (void)dataCenterRefreshWhenLoginCloudSynchronizeComplete;
- (void)dataCenterRefreshWhenLogoutCloudSynchronizeStart;
- (void)dataCenterRefreshWhenLogoutCloudSynchronizeComplete;

//Local Date
//remindAlertStartTime、remindAlertEndTime都是一天内秒数值，非时间戳
@property (nonatomic) BOOL remindAlertIsOn;             //久坐提醒功能开关
@property (nonatomic) NSUInteger remindAlertStartTime;  //久坐提醒开始时间
@property (nonatomic) NSUInteger remindAlertEndTime;    //久坐提醒结束时间
@property (nonatomic) NSUInteger remindAlertInterval;   //久坐提醒

- (void)remindAlertInfoSave;

@end
