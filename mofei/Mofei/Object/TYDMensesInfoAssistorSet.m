//
//  TYDMensesInfoAssistorSet.m
//  Mofei
//
//  Created by macMini_Dev on 14/12/18.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import "TYDMensesInfoAssistorSet.h"
#import "CoreDataManager.h"
#import "MensesInfoEntity.h"

@implementation TYDMensesTransformInfo

#pragma mark - Description

//- (NSString *)description
//{
//    return [NSString stringWithFormat:@"%@,type:%d,synFlag:%d,modifiedFlag:%d", self.timeStamp, (int)self.type, self.syncFlag, self.modifiedFlag];
//}

@end

@interface TYDMensesInfoAssistorSet ()

//@property (strong, nonatomic) NSMutableDictionary *mensesInfoPool;

@end

@implementation TYDMensesInfoAssistorSet

- (NSString *)nextLineFlagString
{
    if(_nextLineFlagString.length == 0)
    {
        _nextLineFlagString = @"\r\n";
    }
    return _nextLineFlagString;
}

- (TYDMensesTransformInfo *)searchInfoInArray:(NSArray *)array
                                withTimeStamp:(NSString *)timeStamp
{
    TYDMensesTransformInfo *info = nil;
    for(TYDMensesTransformInfo *item in array)
    {
        if([item.timeStamp isEqualToString:timeStamp])
        {
            info = item;
            break;
        }
    }
    return info;
}

- (void)refreshInfosFromDataBase
{
    NSMutableArray *localMensesInfos = [NSMutableArray new];
    NSMutableArray *updatedMensesInfos = [NSMutableArray new];
    NSMutableArray *modifiedMensesInfos = [NSMutableArray new];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:sMensesInfoEntityName];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:sTimeStampAttributeNameInEntity ascending:YES]];
    NSArray *items = [[CoreDataManager defaultManager] fetchObjectsWithRequest:request];
    for(MensesInfoEntity *miEntity in items)
    {
        TYDMensesTransformInfo *infoStart = [TYDMensesTransformInfo new];
        TYDMensesTransformInfo *infoEnd = [TYDMensesTransformInfo new];
        
        infoStart.timeStamp = [[self class] mensesInfoTimeStampToString:miEntity.timeStamp.integerValue];
        infoStart.type = TYDMensesInfoItemTypeStart;
        infoStart.syncFlag = miEntity.syncFlag.boolValue;
        infoStart.modifiedFlag = miEntity.modifiedFlag.boolValue;
        
        infoEnd.timeStamp = [[self class] mensesInfoTimeStampToString:miEntity.endTimeStamp.integerValue];
        infoEnd.type = TYDMensesInfoItemTypeEnd;
        infoEnd.syncFlag = infoStart.syncFlag;
        infoEnd.modifiedFlag = infoStart.modifiedFlag;
        
        if(miEntity.syncFlag.boolValue)
        {
            if(miEntity.modifiedFlag.boolValue)
            {
                [modifiedMensesInfos addObject:infoStart];
                [modifiedMensesInfos addObject:infoEnd];
            }
            [localMensesInfos addObject:infoStart];
            [localMensesInfos addObject:infoEnd];
        }
        else
        {
            [updatedMensesInfos addObject:infoStart];
            [updatedMensesInfos addObject:infoEnd];
        }
    }
    //放置预备要删除的新加数据条目
    NSMutableArray *notUpdatedMensesInfos = [NSMutableArray new];
    //放置同步过且非更改（直接标记删除）的数据条目
    NSMutableArray *completeRemovedMensesInfos = [modifiedMensesInfos mutableCopy];
    for(TYDMensesTransformInfo *updateInfo in updatedMensesInfos)
    {
        TYDMensesTransformInfo *searchedInfo = [self searchInfoInArray:modifiedMensesInfos withTimeStamp:updateInfo.timeStamp];
        if(searchedInfo)
        {
            [notUpdatedMensesInfos addObject:updateInfo];//预剔除
            [completeRemovedMensesInfos removeObject:searchedInfo];//剔除不属于标记为删除的
            if(searchedInfo.type == updateInfo.type)
            {
                searchedInfo.modifiedFlag = NO;
                [modifiedMensesInfos removeObject:searchedInfo];
            }
            else
            {
                searchedInfo.type = updateInfo.type;
            }
        }
        else{}
    }
    [updatedMensesInfos removeObjectsInArray:notUpdatedMensesInfos];
    for(TYDMensesTransformInfo *info in completeRemovedMensesInfos)
    {
        info.type = TYDMensesInfoItemTypeNone;
    }
    
    _stringOfLocalInfos = [self localMensesInfoItemsStringWithMensesInfos:localMensesInfos];
    _stringOfUpdatedInfos = [self mensesInfoItemsStringWithMensesInfos:updatedMensesInfos];
    _stringOfModifiedInfos = [self mensesInfoItemsStringWithMensesInfos:modifiedMensesInfos];
    
    NSLog(@"\nMensesLocal:%@\nMensesUpdate:%@\nMensesModify:%@",_stringOfLocalInfos, _stringOfUpdatedInfos, _stringOfModifiedInfos);
}

- (NSString *)localMensesInfoItemsStringWithMensesInfos:(NSArray *)mensesInfos
{
    NSMutableString *string = [@"" mutableCopy];
    for(TYDMensesTransformInfo *info in mensesInfos)
    {
        [string appendFormat:@"%@%@", info.timeStamp, self.nextLineFlagString];
    }
    return string;
}

- (NSString *)mensesInfoItemsStringWithMensesInfos:(NSArray *)mensesInfos
{
    NSMutableString *string = [@"" mutableCopy];
    for(TYDMensesTransformInfo *info in mensesInfos)
    {
        [string appendFormat:@"%@,%@,%d%@", [TYDUserInfo sharedUserInfo].userID, info.timeStamp, (int)info.type, self.nextLineFlagString];
    }
    return string;
}

#pragma mark - ClassMethod

+ (NSString *)mensesInfoTimeStampToString:(NSInteger)time
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyyMMdd";
    //dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    return [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:time]];
}

+ (NSTimeInterval)mensesInfoTimeStringToTimeStamp:(NSString *)timeString
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyyMMdd";
    //dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    return [[dateFormatter dateFromString:timeString] timeIntervalSince1970];
}

@end
