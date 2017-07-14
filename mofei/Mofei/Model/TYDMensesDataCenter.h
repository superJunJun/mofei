//
//  TYDMensesDataCenter.h
//  Mofei
//
//  Created by macMini_Dev on 14/11/13.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TYDMensesInfo;
@class TYDMensesDataCenter;
@protocol TYDMensesDataCenterRefreshedDelegate <NSObject>
@optional
- (void)mensesDataCenterSavedInfosRefreshed:(TYDMensesDataCenter *)dataCenter;
@end

@interface TYDMensesDataCenter : NSObject

@property (assign, nonatomic) id<TYDMensesDataCenterRefreshedDelegate> refreshedDelegate;

+ (instancetype)defaultCenter;
- (NSArray *)allMensesRecordInfos;

- (TYDMensesInfo *)relativeMensesRecordInfoWithTimeStamp:(NSInteger)timeStamp;
- (void)saveOneMensesRecordInfo:(TYDMensesInfo *)mensesInfo;
- (void)updateMensesRecordInfo:(TYDMensesInfo *)mensesInfo withNewStartTimeStamp:(NSInteger)newStartTimeStamp;
- (void)updateMensesRecordInfo:(TYDMensesInfo *)mensesInfo withNewEndTimeStamp:(NSInteger)newEndTimeStamp;
- (void)removeOneMensesRecordInfo:(TYDMensesInfo *)mensesInfo;

//数据库数据有变动，界面要更新
@property (atomic) BOOL isMensesDataUpdated;

//用户登录时，用户ID改变后，数据库会进行筛查，需重新载入信息
//云同步也会造成数据库更新，也需重新载入信息
- (void)reloadInfosFromDataBase;

- (int)mensesDuration;
- (int)mensesBloodDuration;

@end
