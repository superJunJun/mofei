//
//  TYDFileResourceManager.h
//  Mofei
//
//  Created by macMini_Dev on 14/12/6.
//  Copyright (c) 2014年 Young. All rights reserved.
//
//  用于数据云同步
//

#import <Foundation/Foundation.h>

typedef void(^ZipFileHttpRequestCompleteBlock)(id result);
typedef void(^ZipFileHttpRequestFailedBlock)(NSError *error);

@protocol LoginCloudSynchronizeEventDelegate <NSObject>
@optional
- (void)loginCloudSynchronizeEventComplete:(BOOL)succeed;
@end

@protocol LogoutCloudSynchronizeEventDelegate <NSObject>
@optional
- (void)logoutCloudSynchronizeEventComplete:(BOOL)succeed;
@end

@protocol CloudSynchrousEventDelegate <NSObject>
@optional
- (void)cloudSynchronizeEventStart;
- (void)cloudSynchronizeEventComplete:(BOOL)succeed;
@end

@interface TYDFileResourceManager : NSObject

@property (nonatomic, readonly) NSInteger cloudSynchronizeMarkTime;
@property (assign, nonatomic) id<CloudSynchrousEventDelegate> delegate;
@property (assign, nonatomic) id<LoginCloudSynchronizeEventDelegate> loginDelegate;
@property (assign, nonatomic) id<LogoutCloudSynchronizeEventDelegate> logoutDelegate;
@property (nonatomic, readonly) BOOL isInCloudSynchronizeDuration;//锁

+ (instancetype)defaultManager;
- (void)cloudSynchronize;//云同步
- (void)cloudSynchronizeWhenUserLogout;//退出时上传本地数据
- (void)cloudSynchronizeWhenUserLogin;//登录时从云端获取数据

@end
