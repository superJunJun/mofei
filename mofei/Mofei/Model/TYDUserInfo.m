//
//  TYDUserInfo.m
//  Mofei
//
//  Created by macMini_Dev on 14-8-20.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import "TYDUserInfo.h"

#define sUserInfoDicKey                 @"userInfoDicKey"

#define sUserInfoUserNameKey            @"usernameKey"
#define sUserInfoUserIDKey              @"userIDKey"
#define sUserInfoUserAvatarIDKey        @"userAvatarIDKey"
#define sUserInfoUserSexKey             @"userSexKey"
#define sUserInfoUserBirthdayKey        @"userBirthdayKey"
#define sUserInfoUserHeightKey          @"userHeightKey"
#define sUserInfoUserWeightKey          @"userWeightKey"
#define sUserInfoUserSportTargetKey     @"userSportTargetKey"
#define sUserInfoMensesBloodDurationKey @"userMensesBloodDurationKey"
#define sUserInfoMensesDurationKey      @"userMensesDurationKey"

#define nUserSexDefaultValue                    (TYDUserGenderTypeFemale)
#define nUserHeightDefaultValue                 165
#define nUserWeightDefaultValue                 45
#define nUserMensesBloodDurationDefaultValue    5
#define nUserMensesDurationDefaultValue         28
#define nUserSportTargetDefaultValue            300

@interface TYDUserInfo ()

@end

@implementation TYDUserInfo

- (NSDictionary *)attributeMapDictionary
{
    NSDictionary *mapDic =
    @{
        @"accountId"            :@"userID",
        @"name"                 :@"username",
        @"headimgId"            :@"avatarID",
        @"sex"                  :@"sex",
        @"birthday"             :@"birthday",
        @"height"               :@"height",
        @"weight"               :@"weight",
        @"sportsTarget"         :@"sportTarget",
        @"avgMenses"            :@"mensesBloodDuration",
        @"avgPeriod"            :@"mensesDuration"
    };
    return mapDic;
}


- (void)logout
{
    self.userID = @"";
    self.username = @"";
    self.avatarID = @0;
    self.sex = @(nUserSexDefaultValue);
    
    //self.birthday = @(0);
    
    [self saveUserInfo];
}

- (BOOL)isUserAccountEnable
{
    return self.userID.length > 0;
}

- (void)saveUserInfo
{
    NSMutableDictionary *userInfoDic = [NSMutableDictionary new];
    [userInfoDic setValue:self.username forKey:sUserInfoUserNameKey];
    [userInfoDic setValue:self.userID forKey:sUserInfoUserIDKey];
    [userInfoDic setValue:self.avatarID forKey:sUserInfoUserAvatarIDKey];
    [userInfoDic setValue:self.sex forKey:sUserInfoUserSexKey];
    [userInfoDic setValue:self.birthday forKey:sUserInfoUserBirthdayKey];
    [userInfoDic setValue:self.height forKey:sUserInfoUserHeightKey];
    [userInfoDic setValue:self.weight forKey:sUserInfoUserWeightKey];
    [userInfoDic setValue:self.sportTarget forKey:sUserInfoUserSportTargetKey];
    [userInfoDic setValue:self.mensesBloodDuration forKey:sUserInfoMensesBloodDurationKey];
    [userInfoDic setValue:self.mensesDuration forKey:sUserInfoMensesDurationKey];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:userInfoDic forKey:sUserInfoDicKey];
    [userDefaults synchronize];
}

- (void)readUserInfo
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *userInfoDic = [userDefaults objectForKey:sUserInfoDicKey];
    if(userInfoDic)
    {
        self.username = userInfoDic[sUserInfoUserNameKey];
        self.userID = userInfoDic[sUserInfoUserIDKey];
        self.avatarID = userInfoDic[sUserInfoUserAvatarIDKey];
        self.sex = userInfoDic[sUserInfoUserSexKey];
        
        self.birthday = userInfoDic[sUserInfoUserBirthdayKey];
        self.height = userInfoDic[sUserInfoUserHeightKey];
        self.weight = userInfoDic[sUserInfoUserWeightKey];
        self.sportTarget = userInfoDic[sUserInfoUserSportTargetKey];
        self.mensesBloodDuration = userInfoDic[sUserInfoMensesBloodDurationKey];
        self.mensesDuration = userInfoDic[sUserInfoMensesDurationKey];
    }
    else
    {
        self.username = @"";
        self.userID = @"";
        self.avatarID = @0;
        self.sex = @(nUserSexDefaultValue);
        self.birthday = @([BOTimeStampAssistor getTimeStampWithYear:(int)([BOTimeStampAssistor getYearStringWithTimeStamp:[BOTimeStampAssistor getCurrentTime]].integerValue - 20) month:1 day:1]);
        self.height = @(nUserHeightDefaultValue);
        self.weight = @(nUserWeightDefaultValue);
        self.sportTarget = @(nUserSportTargetDefaultValue);
        self.mensesBloodDuration = @(nUserMensesBloodDurationDefaultValue);
        self.mensesDuration = @(nUserMensesDurationDefaultValue);
        
        [self saveUserInfo];
    }
}

#pragma mark - SingleTon

- (instancetype)init
{
    if(self = [super init])
    {
        [self readUserInfo];
    }
    return self;
}

+ (instancetype)sharedUserInfo
{
    static TYDUserInfo *sharedUserInfoInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedUserInfoInstance = [[self alloc] init];
    });
    return sharedUserInfoInstance;
}

#pragma mark - Gender

+ (NSNumber *)userGenderWithGenderString:(NSString *)genderString
{
    if([genderString isEqualToString:@"男"]//QQ
       || [genderString isEqualToString:@"m"])//sinaWeibo
    {
        return @(TYDUserGenderTypeMale);
    }
    return @(TYDUserGenderTypeFemale);
}

#pragma mark - ClassMethod

//单位：米
+ (CGFloat)stepPaceMeasuredWithHeight:(CGFloat)height
{
    CGFloat stepPace = 0;
    if(height < 1.55)
    {
        stepPace = 0.55;
    }
    else if(height < 1.65)
    {
        stepPace = 0.6;
    }
    else if(height < 1.75)
    {
        stepPace = 0.65;
    }
    else if(height < 1.85)
    {
        stepPace = 0.7;
    }
    else if(height < 1.95)
    {
        stepPace = 0.75;
    }
    else
    {
        stepPace = 0.8;
    }
    return stepPace;
}

+ (CGFloat)distanceMeasuredWithHeight:(CGFloat)height andStepCount:(NSUInteger)stepCount
{
    return [self stepPaceMeasuredWithHeight:height] * stepCount;
}

//热量单位：卡路里
+ (CGFloat)calorieMeasuredWithWeight:(CGFloat)weight andDistance:(CGFloat)distance
{
    return weight * distance * 1.175 / 1000;
}

+ (CGFloat)distanceMeasuredWithUserInfo:(TYDUserInfo *)userInfo andStepCount:(NSUInteger)stepCount
{
    return [self distanceMeasuredWithHeight:userInfo.height.floatValue andStepCount:stepCount];
}

+ (CGFloat)calorieMeasuredWithUserInfo:(TYDUserInfo *)userInfo andStepCount:(NSUInteger)stepCount
{
    CGFloat distance = [self distanceMeasuredWithHeight:userInfo.height.floatValue andStepCount:stepCount];
    return [self calorieMeasuredWithWeight:userInfo.weight.floatValue andDistance:distance];
}

+ (CGFloat)distanceMeasuredWithCalorie:(CGFloat)calorie andWeight:(CGFloat)weight
{
    if(calorie <= 0 || weight <= 0)
    {
        return 0;
    }
    return calorie * 1000 / (weight * 1.175);
}

@end
