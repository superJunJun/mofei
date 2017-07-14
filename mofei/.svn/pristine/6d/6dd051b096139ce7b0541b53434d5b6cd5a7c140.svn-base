//
//  TYDDeviceHelpViewController.m
//  Mofei
//
//  Created by macMini_Dev on 15/2/3.
//  Copyright (c) 2015年 Young. All rights reserved.
//
//  连接不上设备？页面
//

#import "TYDDeviceHelpViewController.h"

@interface TYDDeviceHelpViewController ()

@property (strong, nonatomic) NSArray *titleInfos;
@property (strong, nonatomic) NSArray *detailInfos;

@end

@implementation TYDDeviceHelpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHex:0x2acacc];
    
    [self localDataInitialize];
    [self navigationBarItemsLoad];
    [self subviewsLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)localDataInitialize
{
    self.titleInfos =
    @[
        @"Venus是否在手机附近？",
        @"Venus电量是否耗尽？",
        @"尝试重新启动蓝牙？",
        @"Venus已和其他手机绑定？"
    ];
    self.detailInfos =
    @[
        @"Venus使用蓝牙和手机连接，所以当连接Venus时，手机和Venus的距离越近越有利于找到Venus。",
        @"如果Venus和手机距离很近还是没有查找到，可能是因为Venus没电了。请将Venus插入充电器进行充电，这时再尝试使用手机连接Venus。",
        @"如果Venus确认有电，且贴近手机仍无法查找到，可以尝试将手机的蓝牙关闭后重新打开，稍等一会后，重新搜索Venus。",
        @"如果Venus已和其他手机绑定，并且绑定的手机仍在Venus附近，这时你需要关闭已绑定手机的蓝牙，然后重新使用新手机搜索Venus。"
    ];
}

- (void)navigationBarItemsLoad
{
    self.titleText = @"帮助";
    self.navigationBarTintColor = [UIColor colorWithHex:0x2acacc];
}

- (void)subviewsLoad
{
    [self textInfoLabelsLoad];
}

- (void)textInfoLabelsLoad
{
    UIView *baseView = self.baseView;
    CGFloat horInterval = 16;
    CGFloat verInterval = 6;
    CGFloat verItemInterval = 18;
    CGFloat widthMax = baseView.width - horInterval * 2;
    CGPoint origin = CGPointMake(horInterval, 18);
    
    UIFont *titleFont = [UIFont systemFontOfSize:18];
    UIFont *detailFont = [UIFont systemFontOfSize:14];
    UIColor *textColor = [UIColor whiteColor];
    for(int i = 0; i < self.titleInfos.count; i++)
    {
        NSString *title = self.titleInfos[i];
        NSString *detailText = self.detailInfos[i];
        UILabel *titleLabel = [UILabel new];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = titleFont;
        titleLabel.textColor = textColor;
        titleLabel.text = title;
        [titleLabel sizeToFit];
        titleLabel.origin = origin;
        [baseView addSubview:titleLabel];
        
        origin.y = titleLabel.bottom + verInterval;
        UILabel *detailLabel = [UILabel new];
        detailLabel.backgroundColor = [UIColor clearColor];
        detailLabel.font = detailFont;
        detailLabel.textColor = textColor;
        detailLabel.text = detailText;
        detailLabel.numberOfLines = 0;
        detailLabel.lineBreakMode = NSLineBreakByWordWrapping;
        detailLabel.size = [BOAssistor string:detailText sizeWithFont:detailFont constrainedToWidth:widthMax lineBreakMode:NSLineBreakByWordWrapping];
        detailLabel.origin = origin;
        [baseView addSubview:detailLabel];
        origin.y = detailLabel.bottom + verItemInterval;
    }
    self.baseViewBaseHeight = origin.y;
}

@end
