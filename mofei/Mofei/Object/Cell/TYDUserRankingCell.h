//
//  TYDUserRankingCell.h
//  Mofei
//
//  Created by macMini_Dev on 14-9-9.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYDUserRankingInfo.h"

#define sUserRankingCellIdentifier      @"userRankingCell"
@interface TYDUserRankingCell : UITableViewCell

@property (strong, nonatomic) TYDUserRankingInfo *userRankingInfo;

+ (CGFloat)cellHeight;

@end
