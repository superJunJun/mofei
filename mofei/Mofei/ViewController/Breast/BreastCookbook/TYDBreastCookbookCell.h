//
//  TYDBreastCookbookCell.h
//  Mofei
//
//  Created by caiyajie on 14-10-22.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import <UIKit/UIKit.h>
#define sBreastCookbookCellIdentifier  @"breastCookbookCell"
#import "TYDBreastListModel.h"

@interface TYDBreastCookbookCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *pictureImagV;
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UILabel *detailLable;
@property (weak, nonatomic) IBOutlet UILabel *numberLable;
@property (weak, nonatomic) IBOutlet UIImageView *iconImagV;

@property (strong, nonatomic) TYDBreastListModel *cookbook;

@property (nonatomic,copy) void(^clickModel)(TYDBreastListModel *);
@end
