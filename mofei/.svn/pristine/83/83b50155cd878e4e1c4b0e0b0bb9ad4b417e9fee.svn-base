//
//  TYDStepRecordInfoCell.m
//  Mofei
//
//  Created by macMini_Dev on 14-10-27.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import "TYDStepRecordInfoCell.h"
#import "TYDStepRecordInfo.h"
#import "TYDUnitLabel.h"

@interface TYDStepRecordInfoCell ()

@property (strong, nonatomic) UILabel *startTimeLabel;
@property (strong, nonatomic) UILabel *durationLabel;
@property (strong, nonatomic) UILabel *stepCountLabel;
@property (strong, nonatomic) UILabel *distanceLabel;
@property (strong, nonatomic) UIView *separatorLine;

@end

@implementation TYDStepRecordInfoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        UIView *baseView = self.contentView;
        
        UIFont *textFont = [UIFont fontWithName:@"Arial" size:12];
        UIColor *textColor = [UIColor colorWithHex:0x398541];
        int labelCount = 4;
        
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
        self.durationLabel = labels[1];
        self.stepCountLabel = labels[2];
        self.distanceLabel = labels[3];
        self.separatorLine = separatorLine;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect frame = self.contentView.bounds;
    self.separatorLine.bottomRight = CGPointMake(frame.size.width, frame.size.height);
    
    frame.size.width /= 4;
    self.startTimeLabel.frame = frame;
    
    frame.origin.x += frame.size.width;
    self.durationLabel.frame = frame;
    
    frame.origin.x += frame.size.width;
    self.stepCountLabel.frame = frame;
    
    frame.origin.x += frame.size.width;
    self.distanceLabel.frame = frame;
}


#pragma mark - AssistorFunc

- (NSString *)durationStringWithDuration:(NSUInteger)duration
{
    NSString *durationString = [NSString stringWithFormat:@"%ld秒", (long)(duration % 60)];
    duration /= 60;
    if(duration > 0)
    {
        durationString = [NSString stringWithFormat:@"%ld分%@", (long)(duration % 60), durationString];
    }
    duration /= 60;
    if(duration > 0)
    {
        durationString = [NSString stringWithFormat:@"%ld时%@", (long)duration, durationString];
    }
    
    return durationString;
}

- (CGFloat)distanceWithStepCount:(NSUInteger)stepCount
{
    return [TYDUserInfo distanceMeasuredWithHeight:[TYDUserInfo sharedUserInfo].height.floatValue andStepCount:stepCount];
}

#pragma mark - OverrideSettingMethod

- (void)setStepRecordInfo:(TYDStepRecordInfo *)stepRecordInfo
{
    _stepRecordInfo = stepRecordInfo;
    
    self.startTimeLabel.text = [BOTimeStampAssistor getTimeStringWithTimeStamp:stepRecordInfo.timeStamp dateStyle:BOTimeStampStringFormatStyleDateNone timeStyle:BOTimeStampStringFormatStyleTime];//BOTimeStampStringFormatStyleTimeShort
    self.durationLabel.text = [self durationStringWithDuration:stepRecordInfo.endTimeStamp - stepRecordInfo.timeStamp];
    self.stepCountLabel.text = [NSString stringWithFormat:@"%lu%@", (unsigned long)stepRecordInfo.stepCount, sStepBasicUnit];
    self.distanceLabel.text = [NSString stringWithFormat:@"%.1f米", [self distanceWithStepCount:stepRecordInfo.stepCount]];
}

#pragma mark - ClassMethod

+ (CGFloat)cellHeight
{
    return 26;
}

@end
