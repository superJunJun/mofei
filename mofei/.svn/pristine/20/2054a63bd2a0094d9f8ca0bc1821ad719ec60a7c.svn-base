//
//  TYDMensesRecordInfoCell.m
//  Mofei
//
//  Created by macMini_Dev on 14/11/19.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import "TYDMensesRecordInfoCell.h"
#import "TYDMensesInfo.h"
#define sFontNameForRBNo2Light      @"RBNo2-Light"
#define sDateStringModel    @"2014-12-12"

@interface TYDMensesRecordInfoCell ()

@property (strong, nonatomic) UILabel *startTimeLabel;
@property (strong, nonatomic) UILabel *endTimeLabel;
@property (strong, nonatomic) UILabel *durationLabel;

@end

@implementation TYDMensesRecordInfoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.backgroundColor = [UIColor colorWithHex:0xfcfcff];
        
        UIFont *textFont = [UIFont fontWithName:sFontNameForRBNo2Light size:20];
//        UIColor *textColor = [UIColor colorWithHex:0x323232];
        UIColor *textColor = [UIColor colorWithHex:0x282828];
        UILabel *startTimeLabel = [self labelWithSizeMeasureText:sDateStringModel textFont:textFont textColor:textColor];
        UILabel *endTimeLabel = [self labelWithSizeMeasureText:sDateStringModel textFont:textFont textColor:textColor];
        UILabel *durationLabel = [self labelWithSizeMeasureText:@"000" textFont:textFont textColor:textColor];
        durationLabel.textAlignment = NSTextAlignmentCenter;
        
        [self.contentView addSubview:startTimeLabel];
        [self.contentView addSubview:endTimeLabel];
        [self.contentView addSubview:durationLabel];
        
        self.startTimeLabel = startTimeLabel;
        self.endTimeLabel = endTimeLabel;
        self.durationLabel = durationLabel;
    }
    return self;
}

- (UILabel *)labelWithSizeMeasureText:(NSString *)text
                             textFont:(UIFont *)textFont
                            textColor:(UIColor *)textColor
{
    UILabel *label = [UILabel new];
    label.backgroundColor = [UIColor clearColor];
    label.font = textFont;
    label.textColor = textColor;
    label.text = text;
    [label sizeToFit];
    label.text = nil;
    return label;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect frame = self.contentView.bounds;
    
    frame.size.width /= 3;
    self.startTimeLabel.center = CGRectGetCenter(frame);
    
    frame.origin.x += frame.size.width;
    self.endTimeLabel.center = CGRectGetCenter(frame);
    
    frame.origin.x += frame.size.width;
    self.durationLabel.center = CGRectGetCenter(frame);
}

#pragma mark - OverrideSettingMethod

- (void)setMensesInfo:(TYDMensesInfo *)mensesInfo
{
    if(_mensesInfo == mensesInfo)
    {
        return;
    }
    
    _mensesInfo = mensesInfo;
    
    self.startTimeLabel.text = [BOTimeStampAssistor getDateStringWithTimeStamp:mensesInfo.timeStamp];
    self.endTimeLabel.text = [BOTimeStampAssistor getDateStringWithTimeStamp:mensesInfo.endTimeStamp];
    self.durationLabel.text = [NSString stringWithFormat:@"%d", (int)((mensesInfo.endTimeStamp - mensesInfo.timeStamp) / nTimeIntervalSecondsPerDay + 1)];
    if(mensesInfo.endTimeStamp > [BOTimeStampAssistor timeStampOfDayBeginningForToday])
    {
        self.endTimeLabel.textAlignment = NSTextAlignmentCenter;
        self.endTimeLabel.text = @"—";
        self.durationLabel.text = @"—";
        CGPoint center = self.durationLabel.center;
        [self.durationLabel sizeToFit];
        self.durationLabel.center = center;
    }
    else
    {
        self.endTimeLabel.textAlignment = NSTextAlignmentLeft;
    }
}

#pragma mark - ClassMethod

+ (CGFloat)cellHeight
{
    return 34;
}


@end
