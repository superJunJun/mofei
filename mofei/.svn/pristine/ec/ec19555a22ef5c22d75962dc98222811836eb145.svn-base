//
//  TYDCalendarDateBlock.m
//  Mofei
//
//  Created by macMini_Dev on 14/11/15.
//  Copyright (c) 2014年 Young. All rights reserved.
//
//  贴心闺蜜 - 基础日历块
//

#import "TYDCalendarDateBlock.h"

@interface TYDCalendarDateBlock ()

@property (strong, nonatomic) UILabel *dayLabel;
@property (strong, nonatomic) UIImageView *dayMarkIcon;

@end

@implementation TYDCalendarDateBlock

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor clearColor].CGColor;
        
        UIImageView *markIcon = [UIImageView new];
        [self addSubview:markIcon];
        
        frame = self.bounds;
        UILabel *dayLabel = [[UILabel alloc] initWithFrame:frame];
        dayLabel.backgroundColor = [UIColor clearColor];
        dayLabel.font = [UIFont fontWithName:@"Arial" size:18];
        dayLabel.textColor = [UIColor whiteColor];
        dayLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:dayLabel];
        
        self.dayLabel = dayLabel;
        self.dayMarkIcon = markIcon;
        
        [self addTarget:self action:@selector(calendarDateBlockTap:) forControlEvents:UIControlEventTouchUpInside];
        self.dateBeginningTimeStamp = nCalendarInvalidDate;//invalidate
    }
    return self;
}

#pragma mark - Setting Attribute

- (void)setSelected:(BOOL)selected
{
    super.selected = selected;
    if(selected)
    {
        self.layer.borderColor = [UIColor colorWithHex:0xe23674].CGColor;
        self.layer.borderWidth = 1;
    }
    else
    {
        self.layer.borderColor = [UIColor clearColor].CGColor;
        self.layer.borderWidth = 0.0;
    }
}

- (void)setDateBeginningTimeStamp:(NSInteger)dateBeginningTimeStamp
{
    if(_dateBeginningTimeStamp != dateBeginningTimeStamp)
    {
        _dateBeginningTimeStamp = dateBeginningTimeStamp;
        if(dateBeginningTimeStamp == nCalendarInvalidDate)
        {
            self.selected = NO;
            self.enabled = NO;
            self.dayLabel.backgroundColor = [UIColor clearColor];
            self.dayLabel.text = @"";
            self.dayMarkIcon.image = nil;
        }
        else
        {
            self.dateType = self.dateType;
            self.isMensesBloodDay = NO;
            self.enabled = YES;
            self.dayLabel.text = [BOTimeStampAssistor getDayStringWithTimeStamp:dateBeginningTimeStamp];
        }
    }
}

- (void)setDateType:(MensesInfoDayType)dateType
{
    if(self.dateBeginningTimeStamp == nCalendarInvalidDate)
    {
        return;
    }
    
    _dateType = dateType;
    UIImage *markImage = nil;
    UIColor *blockBgColor = [UIColor clearColor];
    UIColor *dayTextColor = [UIColor colorWithHex:0x808080];
    switch(dateType)
    {
        case MensesInfoDayTypePrediction:
            blockBgColor = [UIColor colorWithHex:0xff86b1 andAlpha:0.2];
            dayTextColor = [UIColor colorWithHex:0xe23674];
            break;
        case MensesInfoDayTypePregnant:
            dayTextColor = [UIColor colorWithHex:0xa351bb];
            break;
        case MensesInfoDayTypeSafe:
            dayTextColor = [UIColor colorWithHex:0x68b635];
            break;
        case MensesInfoDayTypeOvulate:
            markImage = [UIImage imageNamed:@"bestieCalendar_ovulateMarkIcon"];
            dayTextColor = [UIColor colorWithHex:0xffffff];
            break;
        case MensesInfoDayTypeNone:
        default:
            break;
    }
    if(self.isMensesBloodDay)
    {
        dayTextColor = [UIColor colorWithHex:0xffffff];
        markImage = [UIImage imageNamed:@"bestieCalendar_bloodMarkIcon"];
    }
    self.dayLabel.backgroundColor = blockBgColor;
    self.dayLabel.textColor = dayTextColor;
    [self setDayMarkIconImage:markImage];
}

- (void)setIsMensesBloodDay:(BOOL)isMensesBloodDay
{
    if(self.dateBeginningTimeStamp == nCalendarInvalidDate)
    {
        return;
    }
    
    if(_isMensesBloodDay != isMensesBloodDay)
    {
        _isMensesBloodDay = isMensesBloodDay;
        if(isMensesBloodDay)
        {
            [self setDayMarkIconImage:[UIImage imageNamed:@"bestieCalendar_bloodMarkIcon"]];
            self.dayLabel.textColor = [UIColor colorWithHex:0xffffff];
        }
        else
        {
            self.dateType = self.dateType;
        }
    }
}

- (void)setDayMarkIconImage:(UIImage *)image
{
    self.dayMarkIcon.image = image;
    if(image)
    {
        self.dayMarkIcon.size = image.size;
        self.dayMarkIcon.center = self.innerCenter;
    }
}

#pragma mark - TouchEvent

- (void)calendarDateBlockTap:(id)sender
{
    if([self.delegate respondsToSelector:@selector(calendarDateBlockSelected:)])
    {
        [self.delegate calendarDateBlockSelected:self];
    }
}

@end
