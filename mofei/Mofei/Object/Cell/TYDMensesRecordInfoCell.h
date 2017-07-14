//
//  TYDMensesRecordInfoCell.h
//  Mofei
//
//  Created by macMini_Dev on 14/11/19.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import <UIKit/UIKit.h>

#define sMensesRecordInfoCellIdentifier     @"mensesRecordInfoCell"

@class TYDMensesInfo;
@interface TYDMensesRecordInfoCell : UITableViewCell

@property (strong, nonatomic) TYDMensesInfo *mensesInfo;

+ (CGFloat)cellHeight;

@end
