//
//  TYDUserRankingCell.m
//  Mofei
//
//  Created by macMini_Dev on 14-9-9.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import "TYDUserRankingCell.h"
#import "BOAvatarView.h"
#import "TYDUnitLabel.h"

@interface TYDUserRankingCell ()

@property (strong, nonatomic) UILabel *rankingLabel;
@property (strong, nonatomic) BOAvatarView *avatarView;
@property (strong, nonatomic) UILabel *usernameLabel;
@property (strong, nonatomic) TYDUnitLabel *calorieLabel;

@end

@implementation TYDUserRankingCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        UIView *baseView = self.contentView;
        
        UILabel *rankingLabel = [UILabel new];
        rankingLabel.backgroundColor = [UIColor clearColor];
        rankingLabel.font = [UIFont systemFontOfSize:15];
        rankingLabel.textColor = [UIColor colorWithHex:0x5c5c5c];
        rankingLabel.textAlignment = NSTextAlignmentCenter;
        rankingLabel.text = @"0000";
        [rankingLabel sizeToFit];
        rankingLabel.text = @" ";
        [baseView addSubview:rankingLabel];
        
        BOAvatarView *avatarView = [[BOAvatarView alloc] initWithAvatarRadius:20];
        avatarView.shadowEnable = NO;
        avatarView.borderWidth = 0;
        [baseView addSubview:avatarView];
        
        UILabel *usernameLabel = [UILabel new];
        usernameLabel.backgroundColor = [UIColor clearColor];
        usernameLabel.font = [UIFont fontWithName:@"Arial" size:15];
        usernameLabel.textColor = [UIColor colorWithHex:0x3d3d3d];
        usernameLabel.text = @"用户名标签测试名";
        [usernameLabel sizeToFit];
        usernameLabel.text = @" ";
        [baseView addSubview:usernameLabel];
        
        UIFont *numberTextFont = [UIFont fontWithName:sFontNameForRBNo2Light size:30];
        UIColor *numberTextColor = [UIColor colorWithHex:0x454545];
        UIFont *unitTextFont = [UIFont systemFontOfSize:12];
        UIColor *unitTextColor = [UIColor colorWithHex:0x898989];
        TYDUnitLabel *calorieLabel = [[TYDUnitLabel alloc] initWithNumberText:@"362" numberTextFont:numberTextFont numberTextColor:numberTextColor unitText:sCalorieBasicUnit unitTextFont:unitTextFont unitTextColor:unitTextColor alignmentType:UIViewAlignmentRight spaceCountForInterval:1];
        [baseView addSubview:calorieLabel];
        
        self.rankingLabel = rankingLabel;
        self.avatarView = avatarView;
        self.usernameLabel = usernameLabel;
        self.calorieLabel = calorieLabel;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect frame = self.contentView.bounds;
    CGPoint center = CGRectGetCenter(frame);
    
    self.rankingLabel.center = CGPointMake(20, center.y);
    
    self.avatarView.center = center;
    self.avatarView.left = 40;
    self.rankingLabel.xCenter = self.avatarView.left * 0.5;
    
    self.usernameLabel.center = center;
    self.usernameLabel.left = self.avatarView.right + 4;
    
    self.calorieLabel.center = center;
    self.calorieLabel.right = frame.size.width - 16;
    self.calorieLabel.yCenter += 3;//偏移
    
    //校正
    if(self.usernameLabel.text.length > 0)
    {
        [self.usernameLabel sizeToFit];
        if(self.usernameLabel.right > self.calorieLabel.left - 4)
        {
            self.usernameLabel.width = self.calorieLabel.left - 4 - self.usernameLabel.left;
        }
    }
}

#pragma mark - OverrideSettingMethod

- (void)setUserRankingInfo:(TYDUserRankingInfo *)userRankingInfo
{
    _userRankingInfo = userRankingInfo;
    
    self.rankingLabel.text = userRankingInfo.rankingNumber.stringValue;
    [self.avatarView setAvatarImageWithAvatarID:userRankingInfo.avatarID];
    
    CGFloat right = self.calorieLabel.right;
    self.calorieLabel.numberText = [NSString stringWithFormat:@"%ld", (long)userRankingInfo.calorieValue.floatValue];
    self.calorieLabel.right = right;
    
    self.usernameLabel.text = userRankingInfo.username.length > 0 ? userRankingInfo.username : sUserNameDefault;
    [self.usernameLabel sizeToFit];
    if(self.usernameLabel.right > self.calorieLabel.left - 4)
    {
        self.usernameLabel.width = self.calorieLabel.left - 4 - self.usernameLabel.left;
    }
}

#pragma mark - ClassMethod

+ (CGFloat)cellHeight
{
    return 60;
}

@end