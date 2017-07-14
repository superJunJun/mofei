//
//  CoreDataManager.m
//  Mofei
//
//  Created by macMini_Dev on 14-10-9.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import "CoreDataManager.h"

#define sCoreDataSportInfoModeName          @"SportInfo"
#define sCoreDataSportInfoModeExtension     @"momd"//@"mom"
#define sCoreDataSqliteFileName             @"SportInfoCoreData.sqlite"

@interface CoreDataManager ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation CoreDataManager

#pragma mark - SingleTon

+ (instancetype)defaultManager
{
    static CoreDataManager *coreDateManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        coreDateManagerInstance = [[self alloc] init];
    });
    return coreDateManagerInstance;
}

#pragma mark - CoreData stack

- (NSManagedObjectModel *)managedObjectModel
{
    if(_managedObjectModel)
    {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:sCoreDataSportInfoModeName withExtension:sCoreDataSportInfoModeExtension];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if(_managedObjectContext)
    {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    if(coordinator != nil)
    {
        _managedObjectContext = [NSManagedObjectContext new];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if(_persistentStoreCoordinator)
    {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:sCoreDataSqliteFileName];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        NSLog(@"CoreData Unresolved Error:%@", error.localizedDescription);
        abort();
    }
    return _persistentStoreCoordinator;
}

- (NSURL *)applicationDocumentsDirectory
{
    NSLog(@"%@", [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject);
    return [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject;
    //file:///Users/superjunjun/Library/Developer/CoreSimulator/Devices/5447275D-BABD-4835-9E87-D3678E96651E/data/Containers/Data/Application/632F5652-B098-4D03-8D7D-80B9E39CA357/Documents/
}

#pragma mark - CoreDate

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *context = self.managedObjectContext;
    if(context != nil)
    {
        if([context hasChanges] && ![context save:&error])
        {
            NSLog(@"CoreData Save Error:%@", error.localizedDescription);
            abort();
        }
    }
}

//查找
- (NSArray *)fetchObjectsWithEntityName:(NSString *)entityName sortDescriptors:(NSArray *)sortDescriptors predicate:(NSPredicate *)predicate
{
    NSManagedObjectContext *context = self.managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    request.sortDescriptors = sortDescriptors;
    request.predicate = predicate;
    return [context executeFetchRequest:request error:nil];
}

- (NSArray *)fetchObjectsWithRequest:(NSFetchRequest *)request
{
    NSManagedObjectContext *context = self.managedObjectContext;
    return [context executeFetchRequest:request error:nil];
}

//新建一个实例，未保存
- (NSManagedObject *)createObjectWithEntityName:(NSString *)entityName
{
    NSManagedObjectContext *context = self.managedObjectContext;
    return [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];;
}

//删除一项
- (void)deleteOneObject:(NSManagedObject *)object
{
    if(object)
    {
        NSManagedObjectContext *context = self.managedObjectContext;
        NSError *error = nil;
        [context deleteObject:object];
        if(![context save:&error])
        {
            NSLog(@"CoreData Save Error:%@", error.localizedDescription);
        }
    }
}

//删除多项
- (void)deleteObjects:(NSArray *)objects
{
    if(objects.count)
    {
        NSManagedObjectContext *context = self.managedObjectContext;
        NSError *error = nil;
        for(id obj in objects)
        {
            if([obj isKindOfClass:NSManagedObject.class])
            {
                [context deleteObject:(NSManagedObject *)obj];
            }
        }
        if(![context save:&error])
        {
            NSLog(@"CoreData Save Error:%@", error.localizedDescription);
        }
    }
}

- (void)deleteAllObjectsWithEntityName:(NSString *)entityName
{
    NSManagedObjectContext *context = self.managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];

    NSFetchRequest *request = [NSFetchRequest new];
    request.includesPropertyValues = NO;
    request.entity = entity;
    
    NSError *error = nil;
    NSArray *datas = [context executeFetchRequest:request error:&error];
    if(!error && datas.count)
    {
        for(NSManagedObject *obj in datas)
        {
            [context deleteObject:obj];
        }
        if(![context save:&error])
        {
            NSLog(@"CoreData Save Error:%@", error.localizedDescription);
        }
    }
}

//http ://blog.csdn.net/rhljiayou/article/details/18037729
//
////查询
//- (NSMutableArray*)selectData:(int)pageSize andOffset:(int)currentPage
//{
//    NSManagedObjectContext *context = self.managedObjectContext;
//    
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    fetchRequest.fetchLimit = pageSize;     //限定查询结果的数量
//    fetchRequest.fetchOffset = currentPage; //查询的偏移量
//    
//    NSEntityDescription *entity = [NSEntityDescription entityForName:TableName inManagedObjectContext:context];
//    [fetchRequest setEntity:entity];
//    NSError *error;
//    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
//    NSMutableArray *resultArray = [NSMutableArray array];
//    
//    for(News *info in fetchedObjects)
//    {
//        NSLog(@"id:%@", info.newsid);
//        NSLog(@"title:%@", info.title);
//        [resultArray addObject:info];
//    }
//    return resultArray;
//}
//
////删除
//-(void)deleteData
//{
//    NSManagedObjectContext *context = [self managedObjectContext];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:TableName inManagedObjectContext:context];
//    
//    NSFetchRequest *request = [[NSFetchRequest alloc] init];
//    [request setIncludesPropertyValues:NO];
//    [request setEntity:entity];
//    NSError *error = nil;
//    NSArray *datas = [context executeFetchRequest:request error:&error];
//    if (!error && datas && [datas count])
//    {
//        for (NSManagedObject *obj in datas)
//        {
//            [context deleteObject:obj];
//        }
//        if (![context save:&error])
//        {
//            NSLog(@"error:%@",error);
//        }
//    }
//}
////更新
//- (void)updateData:(NSString*)newsId  withIsLook:(NSString*)islook
//{
//    NSManagedObjectContext *context = [self managedObjectContext];
//    
//    NSPredicate *predicate = [NSPredicate
//                              predicateWithFormat:@"newsid like[cd] %@",newsId];
//    
//    //首先你需要建立一个request
//    NSFetchRequest * request = [[NSFetchRequest alloc] init];
//    [request setEntity:[NSEntityDescription entityForName:TableName inManagedObjectContext:context]];
//    [request setPredicate:predicate];//这里相当于sqlite中的查询条件，具体格式参考苹果文档
//    
//    //https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/Predicates/Articles/pCreating.html
//    NSError *error = nil;
//    NSArray *result = [context executeFetchRequest:request error:&error];//这里获取到的是一个数组，你需要取出你要更新的那个obj
//    for (News *info in result) {
//        info.islook = islook;
//    }
//    
//    //保存
//    if ([context save:&error]) {
//        //更新成功
//        NSLog(@"更新成功");
//    }
//}

@end
