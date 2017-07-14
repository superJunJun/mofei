//
//  CoreDataManager.h
//  Mofei
//
//  Created by macMini_Dev on 14-10-9.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define sWalkStepInfoEntityName             @"WalkStepEntity"
#define sHeartRateInfoEntityName            @"HeartRateEntity"
#define sMensesInfoEntityName               @"MensesInfoEntity"
#define sTimeStampAttributeNameInEntity     @"timeStamp"
#define sUserIDAttributeNameInEntity        @"userID"
#define sSyncFlagAttributeNameInEntity      @"syncFlag"
#define sModifiedFlagAttributeNameInEntity  @"modifiedFlag"


@interface CoreDataManager : NSObject

+ (instancetype)defaultManager;

- (NSManagedObject *)createObjectWithEntityName:(NSString *)entityName;
- (void)deleteOneObject:(NSManagedObject *)object;
- (void)deleteObjects:(NSArray *)objects;
- (void)deleteAllObjectsWithEntityName:(NSString *)entityName;
- (NSArray *)fetchObjectsWithEntityName:(NSString *)entityName sortDescriptors:(NSArray *)sortDescriptors predicate:(NSPredicate *)predicate;
- (NSArray *)fetchObjectsWithRequest:(NSFetchRequest *)request;
- (void)saveContext;

@end
