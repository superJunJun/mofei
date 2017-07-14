//
//  TYDMensesDataCenter.m
//  Mofei
//
//  Created by macMini_Dev on 14/11/13.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import "TYDMensesDataCenter.h"
#import "CoreDataManager.h"
#import "TYDMensesInfo.h"
#import "MensesInfoEntity.h"


//syncFlag:YES,与云端同步过的数据条目
//syncFlag:NO,本地新生产的数据条目
//modifiedFlag:YES,只对syncFlag为YES的条目有用

@interface TYDMensesDataCenter ()

@property (strong, nonatomic) NSMutableArray *mensesRecordInfos;
//@property (strong, nonatomic) NSMutableArray *mensesModifiedInfos;

@end

@implementation TYDMensesDataCenter

- (void)insertOneMensesRecordInfo:(TYDMensesInfo *)mensesInfo
{
    if(!mensesInfo)
    {
        return;
    }
    
    NSInteger index = 0;
    for(; index < self.mensesRecordInfos.count; index++)
    {
        TYDMensesInfo *recordedInfo = self.mensesRecordInfos[index];
        if(mensesInfo.timeStamp <= recordedInfo.timeStamp)
        {
            break;
        }
    }
    [self.mensesRecordInfos insertObject:mensesInfo atIndex:index];
}

#pragma mark - Interface

- (NSArray *)allMensesRecordInfos
{
    return self.mensesRecordInfos;
}

- (TYDMensesInfo *)relativeMensesRecordInfoWithTimeStamp:(NSInteger)timeStamp
{
    if(self.mensesRecordInfos.count == 0)
    {
        return nil;
    }
    
    TYDMensesInfo *mensesInfoSearched = nil;
    NSInteger index = 0;
    for(; index < self.mensesRecordInfos.count; index++)
    {
        TYDMensesInfo *info = self.mensesRecordInfos[index];
        if(info.timeStamp <= timeStamp
           && info.endTimeStamp >= timeStamp)
        {
            break;
        }
        else if(timeStamp < info.timeStamp)
        {
            break;
        }
    }
    if(index < self.mensesRecordInfos.count)
    {
        mensesInfoSearched = self.mensesRecordInfos[index];
    }
    return mensesInfoSearched;
}

- (MensesInfoEntity *)searchForEntityWithMensesRecordInfo:(TYDMensesInfo *)mensesInfo
{
    MensesInfoEntity *miEntity = nil;
    if(mensesInfo)
    {
        CoreDataManager *coreDataManager = [CoreDataManager defaultManager];
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:sMensesInfoEntityName];
        request.predicate = [NSPredicate predicateWithFormat:@"(timeStamp == %ld) && (endTimeStamp == %ld)", (long)mensesInfo.timeStamp, (long)mensesInfo.endTimeStamp];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:sTimeStampAttributeNameInEntity ascending:YES]];
        request.fetchLimit = 1;
        NSArray *items = [coreDataManager fetchObjectsWithRequest:request];
        if(items.count > 0)
        {
            miEntity = items[0];
        }
    }
    return miEntity;
}

- (void)saveOneMensesRecordInfo:(TYDMensesInfo *)mensesInfo
{
    if(!mensesInfo)
    {
        return;
    }
    
    CoreDataManager *coreDataManager = [CoreDataManager defaultManager];
    MensesInfoEntity *infoEntity = [self searchForEntityWithMensesRecordInfo:mensesInfo];
    if(infoEntity)
    {
        if(infoEntity.syncFlag.boolValue == YES)
        {//同步过的条目
            infoEntity.modifiedFlag = @NO;//标定条目有效
            [coreDataManager saveContext];
        }
        else
        {//本地新生成的条目，基本不存在
            //infoEntity.modifiedFlag = @NO;
            //[coreDataManager saveContext];
        }
    }
    else
    {//作为新插入条目
        if(![self newMensesInfoCheck:mensesInfo])
        {
            return;
        }
        MensesInfoEntity *infoEntity = (MensesInfoEntity *)[coreDataManager createObjectWithEntityName:sMensesInfoEntityName];
        infoEntity.timeStamp = @(mensesInfo.timeStamp);
        infoEntity.endTimeStamp = @(mensesInfo.endTimeStamp);
        infoEntity.userID = [TYDUserInfo sharedUserInfo].userID;
        infoEntity.syncFlag = @(mensesInfo.syncFlag);
        infoEntity.modifiedFlag = @(mensesInfo.modifiedFlag);
        [coreDataManager saveContext];
    }
    
    [self insertOneMensesRecordInfo:mensesInfo];
}

- (BOOL)newMensesInfoCheck:(TYDMensesInfo *)newInfo
{
    BOOL isOK = YES;
    NSInteger intervalMin = 5 * nTimeIntervalSecondsPerDay;
    for(TYDMensesInfo *info in self.mensesRecordInfos)
    {
        TYDMensesInfo *info1 = info;
        TYDMensesInfo *info2 = newInfo;
        if(info.timeStamp > newInfo.timeStamp)
        {
            info1 = newInfo;
            info2 = info;
        }
        
        if(info2.timeStamp <= info1.endTimeStamp + intervalMin)
        {
            isOK = NO;
            break;
        }
    }
    return isOK;
}

- (void)updateMensesRecordInfo:(TYDMensesInfo *)mensesInfo withNewStartTimeStamp:(NSInteger)newStartTimeStamp
{
    if(!mensesInfo)
    {
        return;
    }
    
    CoreDataManager *coreDataManager = [CoreDataManager defaultManager];
    //原有数据条目处理
    MensesInfoEntity *infoEntity = [self searchForEntityWithMensesRecordInfo:mensesInfo];
    if(infoEntity)
    {
        if(infoEntity.syncFlag.boolValue == YES)
        {//同步过的条目，标记为已更改
            infoEntity.modifiedFlag = @YES;
            [coreDataManager saveContext];
        }
        else
        {//新加的数据条目，直接删除
            [coreDataManager deleteOneObject:infoEntity];
        }
    }
    else
    {//未在数据库中找到，在外部却有数据的情形，应该是不存在的。
        NSLog(@"updateMensesRecordInfo Cannot Fetch MensesInfoEntity");
    }
    
    //新条目处理
    mensesInfo.timeStamp = newStartTimeStamp;
    infoEntity = [self searchForEntityWithMensesRecordInfo:mensesInfo];
    if(infoEntity)
    {
        if(infoEntity.syncFlag.boolValue == YES)
        {//同步过的条目，标记为有效
            infoEntity.modifiedFlag = @NO;
            [coreDataManager saveContext];
        }
        else
        {//新加的数据条目，基本不存在
            //infoEntity.modifiedFlag = @NO;
            //[coreDataManager saveContext];
        }
    }
    else
    {
        MensesInfoEntity *newInfoEntity = (MensesInfoEntity *)[coreDataManager createObjectWithEntityName:sMensesInfoEntityName];
        newInfoEntity.timeStamp = @(mensesInfo.timeStamp);
        newInfoEntity.endTimeStamp = @(mensesInfo.endTimeStamp);
        newInfoEntity.syncFlag = @NO;
        newInfoEntity.modifiedFlag = @NO;
        [coreDataManager saveContext];
    }
}

- (void)updateMensesRecordInfo:(TYDMensesInfo *)mensesInfo withNewEndTimeStamp:(NSInteger)newEndTimeStamp
{
    if(!mensesInfo)
    {
        return;
    }
    
    CoreDataManager *coreDataManager = [CoreDataManager defaultManager];
    //原有数据条目处理
    MensesInfoEntity *infoEntity = [self searchForEntityWithMensesRecordInfo:mensesInfo];
    if(infoEntity)
    {
        if(infoEntity.syncFlag.boolValue == YES)
        {//同步过的条目，标记为已更改
            infoEntity.modifiedFlag = @YES;
            [coreDataManager saveContext];
        }
        else
        {//新加的数据条目，直接删除
            [coreDataManager deleteOneObject:infoEntity];
        }
    }
    else
    {//未在数据库中找到，在外部却有数据的情形，应该是不存在的。
        NSLog(@"updateMensesRecordInfo Cannot Fetch MensesInfoEntity");
    }
    
    //新条目处理
    mensesInfo.endTimeStamp = newEndTimeStamp;
    infoEntity = [self searchForEntityWithMensesRecordInfo:mensesInfo];
    if(infoEntity)
    {
        if(infoEntity.syncFlag.boolValue == YES)
        {//同步过的条目，标记为有效
            infoEntity.modifiedFlag = @NO;
            [coreDataManager saveContext];
        }
        else
        {//新加的数据条目，基本不存在
            //infoEntity.modifiedFlag = @NO;
            //[coreDataManager saveContext];
        }
    }
    else
    {
        MensesInfoEntity *newInfoEntity = (MensesInfoEntity *)[coreDataManager createObjectWithEntityName:sMensesInfoEntityName];
        newInfoEntity.timeStamp = @(mensesInfo.timeStamp);
        newInfoEntity.endTimeStamp = @(mensesInfo.endTimeStamp);
        newInfoEntity.syncFlag = @NO;
        newInfoEntity.modifiedFlag = @NO;
        [coreDataManager saveContext];
    }
}

- (void)removeOneMensesRecordInfo:(TYDMensesInfo *)mensesInfo
{
    if(!mensesInfo)
    {
        return;
    }
    
    [self.mensesRecordInfos removeObject:mensesInfo];
    
    CoreDataManager *coreDataManager = [CoreDataManager defaultManager];
    MensesInfoEntity *infoEntity = [self searchForEntityWithMensesRecordInfo:mensesInfo];
    if(infoEntity)
    {
        if(infoEntity.syncFlag.boolValue)
        {//同步过的条目，标记为已更改
            infoEntity.modifiedFlag = @YES;
            [coreDataManager saveContext];
        }
        else
        {//新加的数据条目，直接删除
            [coreDataManager deleteOneObject:infoEntity];
        }
    }
    else
    {//未在数据库中找到，在外部却有数据的情形，应该是不存在的。
        NSLog(@"removeOneMensesRecordInfo Cannot Fetch MensesInfoEntity");
    }
}

- (void)reloadInfosFromDataBase
{
    [self basicDataInit];
    self.isMensesDataUpdated = YES;
    if([self.refreshedDelegate respondsToSelector:@selector(mensesDataCenterSavedInfosRefreshed:)])
    {
        [self.refreshedDelegate mensesDataCenterSavedInfosRefreshed:self];
    }
}

#pragma mark - SingleTon

+ (instancetype)defaultCenter
{
    static TYDMensesDataCenter *dataCenterInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        dataCenterInstance = [[self alloc] init];
    });
    return dataCenterInstance;
}

- (instancetype)init
{
    if(self = [super init])
    {
        [self basicDataInit];
    }
    return self;
}

- (void)basicDataInit
{
    self.mensesRecordInfos = [NSMutableArray new];
    
    CoreDataManager *coreDataManager = [CoreDataManager defaultManager];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:sMensesInfoEntityName];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:sTimeStampAttributeNameInEntity ascending:YES]];
    NSArray *items = [coreDataManager fetchObjectsWithRequest:request];
    for(MensesInfoEntity *entity in items)
    {
        TYDMensesInfo *info = [TYDMensesInfo new];
        info.timeStamp = entity.timeStamp.unsignedIntegerValue;
        info.endTimeStamp = entity.endTimeStamp.unsignedIntegerValue;
        info.syncFlag = entity.syncFlag.boolValue;
        info.modifiedFlag = entity.modifiedFlag.boolValue;
        if(info.modifiedFlag == NO)//已被标记删除（更改）
        {
            [self.mensesRecordInfos addObject:info];
        }
    }
}

#pragma mark - MensesDurationBasicInfo

- (int)mensesDuration
{
    return [TYDUserInfo sharedUserInfo].mensesDuration.intValue;
}

- (int)mensesBloodDuration
{
    return [TYDUserInfo sharedUserInfo].mensesBloodDuration.intValue;
}

@end
