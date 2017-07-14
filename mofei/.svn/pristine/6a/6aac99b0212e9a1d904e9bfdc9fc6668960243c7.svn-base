//
//  TYDUserRankingInfo.m
//  Mofei
//
//  Created by macMini_Dev on 14-9-9.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import "TYDUserRankingInfo.h"

@implementation TYDUserRankingInfo

- (NSDictionary *)attributeMapDictionary
{
    NSDictionary *mapDic =
    @{
        @"accountId"            :@"userID",
        @"name"                 :@"username",
        @"headimgId"            :@"avatarID",
        @"count"                :@"rankingNumber"
    };
    return mapDic;
}

- (void)calorieValueFix
{
    NSString *numberString = [NSString stringWithFormat:@"%@", self.calorieValue];
    if(numberString.length == 0)
    {
        numberString = @"0";
    }
    
    if(numberString.integerValue > 0)
    {
        self.calorieValue = @(numberString.integerValue);
    }
    else
    {
        CGFloat floatValue = numberString.floatValue;
        if(floatValue <= 0)
        {
            self.calorieValue = @(0);
        }
        else
        {
            self.calorieValue = @(floatValue);
        }
    }
}

@end
