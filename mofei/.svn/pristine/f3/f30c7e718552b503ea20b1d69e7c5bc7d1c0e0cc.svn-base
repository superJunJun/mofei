//
//  TYDHeartRateRecordInfoCell.m
//  Mofei
//
//  Created by macMini_Dev on 14-10-27.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import "TYDHeartRateRecordInfoCell.h"
#import "TYDHeartRateRecordInfo.h"
#import "TYDUnitLabel.h"

@interface TYDHeartRateRecordInfoCell ()

@property (strong, nonatomic) UILabel *startTimeLabel;
@property (strong, nonatomic) UILabel *heartRateLabel;
@property (strong, nonatomic) UIView *separatorLine;

@end

@implementation TYDHeartRateRecordInfoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        UIView *baseView = self.contentView;
        
        UIFont *textFont = [UIFont fontWithName:@"Arial" size:12];
        UIColor *textColor = [UIColor colorWithHex:0x70408c];
        int labelCount = 2;
        
        NSMutableArray *labels = [[NSMutableArray alloc] initWithCapacity:labelCount];
        for(int i = 0; i < labelCount; i++)
        {
            UILabel *label = [UILabel new];
            label.backgroundColor = [UIColor clearColor];
            label.font = textFont;
            label.textColor = textColor;
            label.textAlignment = NSTextAlignmentCenter;
            [baseView addSubview:label];
            [labels addObject:label];
        }
        
        UIView *separatorLine = [UIView new];
        separatorLine.backgroundColor = [UIColor colorWithHex:0xcecece];
        separatorLine.size = CGSizeMake(baseView.width - 16, 0.5);
        [baseView addSubview:separatorLine];
        
        self.startTimeLabel = labels[0];
        self.heartRateLabel = labels[1];
        self.separatorLine = separatorLine;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.contentView.bounds;
    self.separatorLine.bottomRight = CGPointMake(frame.size.width, frame.size.height);
    
    frame.size.width /= 2;
    self.startTimeLabel.frame = frame;
    
    frame.origin.x += frame.size.width;
    self.heartRateLabel.frame = frame;
}

#pragma mark - OverrideSettingMethod

- (void)setHeartRateRecordInfo:(TYDHeartRateRecordInfo *)heartRateRecordInfo
{
    _heartRateRecordInfo = heartRateRecordInfo;
    
    self.startTimeLabel.text = [BOTimeStampAssistor getTimeStringWithTimeStamp:heartRateRecordInfo.timeStamp dateStyle:BOTimeStampStringFormatStyleDateNone timeStyle:BOTimeStampStringFormatStyleTimeShort];
    self.heartRateLabel.text = [NSString stringWithFormat:@"%lu%@", (unsigned long)heartRateRecordInfo.heartRate, sHeartRateBasicUnit];
}

#pragma mark - ClassMethod

+ (CGFloat)cellHeight
{
    return 26;
}

@end
