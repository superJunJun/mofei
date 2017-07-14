//
//  TYDUserRankingInfo.h
//  Mofei
//
//  Created by macMini_Dev on 14-9-9.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import "TYDBaseModel.h"

@interface TYDUserRankingInfo : TYDBaseModel

@property (strong, nonatomic) NSString *username;       //用户名
@property (strong, nonatomic) NSNumber *userID;         //用户ID
@property (strong, nonatomic) NSNumber *avatarID;       //用户头像

@property (strong, nonatomic) NSNumber *rankingNumber;  //用户排名
@property (strong, nonatomic) NSNumber *calorieValue;   //消耗卡路里值

- (void)calorieValueFix;

@end
