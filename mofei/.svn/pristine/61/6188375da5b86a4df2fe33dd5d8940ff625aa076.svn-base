//
//  TYDMachineModelViewController.m
//  Mofei
//
//  Created by caiyajie on 14-11-3.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import "TYDMachineModelViewController.h"

@interface TYDMachineModelViewController ()

@end

@implementation TYDMachineModelViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor colorWithHex:0xefeef0];
    [self navigationBarItemsLoad];
    [self subviewsLoad];
}

- (void)navigationBarItemsLoad
{
    self.title = @"支持机型";
}

- (void)subviewsLoad
{
    [self titleLabelLoad];
    [self machineModelLoad];
}

- (void)titleLabelLoad
{
    UILabel *titleLabel = [UILabel new];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.textColor = [UIColor colorWithHex:0x3c3c3c];
    titleLabel.text = @"IOS6.0及以上系统";
    [titleLabel sizeToFit];
    titleLabel.origin = CGPointMake(16, 18);
    [self.baseView addSubview:titleLabel];
    
    self.baseViewBaseHeight = titleLabel.bottom;
}

- (void)machineModelLoad
{
    UIFont *detailFont = [UIFont systemFontOfSize:16];
    UIColor *detailTextColor = [UIColor colorWithHex:0x6c6c6c];
    UIColor *bgWhiteColor = [UIColor colorWithHex:0xfcfcfc];
    
    CGFloat top = self.baseViewBaseHeight + 18;
    NSString *titleText = @" \n  iphone4s\n  iphone5 / iphone5c / iphone5s\n  iphone6 / iphone6 plus\n ";
    CGFloat intervalHor = 16;
    CGFloat limitWidth = self.view.width - intervalHor * 2;
    CGSize labelSize = [BOAssistor string:titleText sizeWithFont:detailFont constrainedToWidth:limitWidth lineBreakMode:NSLineBreakByWordWrapping];
    
    UILabel *machineModelLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, top, limitWidth, labelSize.height)];
    machineModelLabel.backgroundColor = bgWhiteColor;
    machineModelLabel.font = detailFont;
    machineModelLabel.textColor = detailTextColor;
    machineModelLabel.numberOfLines = 0;
    machineModelLabel.lineBreakMode = NSLineBreakByWordWrapping;
    machineModelLabel.text = titleText;
    machineModelLabel.layer.cornerRadius = 4;
    machineModelLabel.layer.masksToBounds = YES;
    machineModelLabel.xCenter = self.baseView.innerCenter.x;
    [self.baseView addSubview:machineModelLabel];
    
    self.baseViewBaseHeight = machineModelLabel.bottom + 20;
}

@end
