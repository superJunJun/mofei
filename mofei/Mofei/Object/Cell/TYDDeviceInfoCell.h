//
//  TYDDeviceInfoCell.h
//  Mofei
//
//  Created by macMini_Dev on 14-9-25.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import <UIKit/UIKit.h>

#define sDeviceInfoCellIdentifier       @"deviceInfoCell"

@class CBPeripheral;
@interface TYDDeviceInfoCell : UITableViewCell

@property (strong, nonatomic) CBPeripheral *peripheral;
@property (nonatomic) BOOL isMarked;

@property (nonatomic) BOOL connectMark;

-(void)addCircleViewIcon;
-(void)removeCircleIcon;
+ (CGFloat)cellHeight;

@end
