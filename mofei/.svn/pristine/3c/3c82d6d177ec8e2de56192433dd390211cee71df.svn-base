//
//  TYDUserInfo.h
//  Mofei
//
//  Created by macMini_Dev on 14-8-20.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import "TYDBaseModel.h"

#define sUserNameDefault            @"未命名"

//性别 0：男 1：女
typedef NS_ENUM(NSUInteger, TYDUserGenderType)
{
    TYDUserGenderTypeMale = 0,
    TYDUserGenderTypeFemale = 1
};

@interface TYDUserInfo : TYDBaseModel

@property (strong, nonatomic) NSString *username;       //用户名
@property (strong, nonatomic) NSString *userID;         //用户ID
@property (strong, nonatomic) NSNumber *avatarID;       //用户固定头像ID，查看BOAvatarView
@property (strong, nonatomic) NSNumber *sex;            //性别，0:女 1:男
@property (strong, nonatomic) NSNumber *birthday;       //生日

@property (strong, nonatomic) NSNumber *height;         //身高，单位cm
@property (strong, nonatomic) NSNumber *weight;         //体重，单位kg
@property (strong, nonatomic) NSNumber *sportTarget;    //运动目标：XX卡路里

//@property (strong, nonatomic) NSString *avatarPath;     //用户头像地址
//@property (strong, nonatomic) NSNumber *topChest;       //上胸围
//@property (strong, nonatomic) NSNumber *bottomChest;    //下胸围
//@property (strong, nonatomic) NSString *breastCupSize;  //罩杯
//@property (strong, nonatomic) NSNumber *breastForm;     //胸型

@property (strong, nonatomic) NSNumber *mensesBloodDuration;//行经时长
@property (strong, nonatomic) NSNumber *mensesDuration;   //经期时长

+ (instancetype)sharedUserInfo;
- (void)logout;
- (BOOL)isUserAccountEnable;
- (void)saveUserInfo;

+ (CGFloat)stepPaceMeasuredWithHeight:(CGFloat)height;//单位：米
+ (CGFloat)distanceMeasuredWithHeight:(CGFloat)height andStepCount:(NSUInteger)stepCount;
+ (CGFloat)calorieMeasuredWithWeight:(CGFloat)weight andDistance:(CGFloat)distance;
+ (CGFloat)calorieMeasuredWithUserInfo:(TYDUserInfo *)userInfo andStepCount:(NSUInteger)stepCount;
+ (CGFloat)distanceMeasuredWithCalorie:(CGFloat)calorie andWeight:(CGFloat)weight;
+ (CGFloat)distanceMeasuredWithUserInfo:(TYDUserInfo *)userInfo andStepCount:(NSUInteger)stepCount;
+ (NSNumber *)userGenderWithGenderString:(NSString *)genderString;

@end
