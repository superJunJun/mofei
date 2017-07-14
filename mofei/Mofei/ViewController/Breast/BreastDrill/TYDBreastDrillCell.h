//
//  TYDBreastDrillCell.h
//  Mofei
//
//  Created by caiyajie on 14-10-30.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYDBreastListModel.h"
#define sBreastDrillCellIdentifier  @"breastDrillCell"

@interface TYDBreastDrillCell : UITableViewCell

@property (strong, nonatomic) UIImageView *pictureImagV;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic)  UILabel *numberLabel;
@property (strong, nonatomic)UIImageView *iconImagV;
@property (strong, nonatomic) TYDBreastListModel * breastDrill;

@property (nonatomic,copy) void(^clickModel)(TYDBreastListModel *);

@end
