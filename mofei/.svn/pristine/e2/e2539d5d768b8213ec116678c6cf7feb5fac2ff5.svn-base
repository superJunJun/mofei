//
//  TYDSimpleHistogramView.m
//  Mofei
//
//  Created by macMini_Dev on 14-9-19.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import "TYDSimpleHistogramView.h"

#define nSolidLineWidth                 1
#define nMaxValueLabelBottomInterval    2
#define nItemViewHeightMin              0//1

@interface TYDSimpleHistogramView ()

@property (strong, nonatomic) NSMutableArray *itemViews;

@property (strong, nonatomic) UIColor *timeStampTextColor;
@property (strong, nonatomic) UIFont *timeStampTextFont;
@property (nonatomic) TYDSimpleHistogramType type;

@property (strong, nonatomic) UIColor *itemBgColor;
@property (nonatomic) CGFloat itemWidth;
@property (nonatomic) CGFloat itemInterval;
@property (nonatomic) NSUInteger itemCount;
@property (nonatomic) NSUInteger valueLevelMax;
@property (nonatomic) CGFloat histogramMaxHeight;
@property (nonatomic) CGFloat histogramTopInterval;

@property (nonatomic) NSUInteger maxValue;
@property (strong, nonatomic) UILabel *maxValueLabel;

@end

@implementation TYDSimpleHistogramView

- (instancetype)initWithCoreViewSize:(CGSize)coreViewSize
                               scale:(CGFloat)scale
                           itemColor:(UIColor *)itemColor
                  timeStampTextColor:(UIColor *)timeStampTextColor
                   timeStampTextFont:(UIFont *)timeStampTextFont
                   maxValueTextColor:(UIColor *)maxValueTextColor
                    maxValueTextFont:(UIFont *)maxValueTextFont
                     maxValueVisible:(BOOL)maxValueVisible
                       valueLevelMax:(NSUInteger)valueLevelMax
                                type:(TYDSimpleHistogramType)type
{
    CGRect frame = CGRectMake(0, 0, coreViewSize.width, coreViewSize.height + [BOAssistor string:@"0" sizeWithFont:timeStampTextFont].height + 6);
    if(self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
        
        self.itemBgColor = itemColor;
        self.timeStampTextColor = timeStampTextColor;
        self.timeStampTextFont = timeStampTextFont;
        
        self.valueLevelMax = valueLevelMax;
        self.type = type;
        
        self.histogramMaxHeight = coreViewSize.height;
        self.histogramTopInterval = 0;
        [self itemCountFix];
        self.itemInterval = coreViewSize.width / (self.itemCount * scale + self.itemCount + 1);
        self.itemWidth = self.itemInterval * scale;
        
        if(maxValueVisible)
        {
            self.histogramTopInterval = ([BOAssistor string:@"0" sizeWithFont:maxValueTextFont].height + nMaxValueLabelBottomInterval);
            self.histogramMaxHeight -= self.histogramTopInterval;
        }
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, coreViewSize.height, coreViewSize.width, 1)];
        line.backgroundColor = [UIColor colorWithHex:0xe23674];
        [self addSubview:line];
        
        if(maxValueVisible)
        {
            UILabel *maxValueLabel = [UILabel new];
            maxValueLabel.backgroundColor = [UIColor clearColor];
            maxValueLabel.font = maxValueTextFont;
            maxValueLabel.textColor = maxValueTextColor;
            maxValueLabel.text = @" ";
            [maxValueLabel sizeToFit];
            [self addSubview:maxValueLabel];
            
            self.maxValueLabel = maxValueLabel;
        }
        
        [self itemViewsLoad];
        [self timeStampLabelsLoad];
        
        self.maxValue = 0;
    }
    return self;
}

- (void)itemCountFix
{
    NSInteger count = 0;
    switch(self.type)
    {
        case TYDSimpleHistogramTypeDaysPerWeek:
            count = 7;
            break;
        case TYDSimpleHistogramTypeDaysPerMonth:
        default:
            count = 31;
            break;
    }
    self.itemCount = count;
}

- (void)itemViewsLoad
{
    NSMutableArray *itemViews = [NSMutableArray new];
    
    CGFloat itemMinHeight = nItemViewHeightMin;
    CGFloat horOffset = self.itemInterval;
    CGFloat itemWidth = self.itemWidth;
    CGFloat itemInterval = self.itemInterval;
    
    CGFloat top = self.histogramTopInterval + self.histogramMaxHeight - itemMinHeight;
    CGRect frame = CGRectMake(horOffset, top, itemWidth, itemMinHeight);
    
    for(NSUInteger count = 0; count < self.itemCount; count++)
    {
        UIView *item = [[UIView alloc] initWithFrame:frame];
        item.backgroundColor = self.itemBgColor;
        [self addSubview:item];
        [itemViews addObject:item];
        
        frame.origin.x += (itemWidth + itemInterval);
    }
    
    self.itemViews = itemViews;
}

- (void)timeStampLabelsLoad
{
    NSArray *texts = nil;
    NSMutableArray *timeStampLabels = [NSMutableArray new];
    NSInteger markInterval = 1;
    CGFloat itemWidth = self.itemWidth;
    CGFloat itemInterval = self.itemInterval;
    UIFont *font = self.timeStampTextFont;
    UIColor *textColor = self.timeStampTextColor;
    
    switch(self.type)
    {
        case TYDSimpleHistogramTypeDaysPerMonth:
            texts = @[@"7", @"14", @"21", @"28"];
            markInterval = 7;
            break;
        case TYDSimpleHistogramTypeDaysPerWeek:
        default:
            texts = @[@"一", @"二", @"三", @"四", @"五", @"六", @"日"];
            markInterval = 1;
            break;
    }
    
    for(NSInteger count = 1; count <= texts.count; count++)
    {
        UILabel *label = [UILabel new];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = textColor;
        label.font = font;
        label.text = [NSString stringWithFormat:@"%@", texts[count - 1]];
        [label sizeToFit];
        label.xCenter = count * markInterval * (itemInterval + itemWidth) - itemWidth * 0.5;
        label.bottom = self.height;
        [self addSubview:label];
        [timeStampLabels addObject:label];
    }
}

#pragma mark - Max Value

- (void)setMaxValueLabelXCenter:(CGFloat)xCenter bottom:(CGFloat)bottom
{
    if(self.maxValueLabel)
    {
        self.maxValueLabel.text = self.maxValue > 0 ? [NSString stringWithFormat:@"%ld", (long)self.maxValue] : @" ";
        [self.maxValueLabel sizeToFit];
        
        self.maxValueLabel.bottom = bottom - nMaxValueLabelBottomInterval;
        self.maxValueLabel.xCenter = xCenter;
        
        self.maxValueLabel.left = MAX(self.maxValueLabel.left, 0);
        self.maxValueLabel.top = MAX(self.maxValueLabel.top, 0);
        self.maxValueLabel.right = MIN(self.maxValueLabel.right, self.maxValueLabel.superview.width);
    }
}

#pragma mark - Refresh Value

- (void)refreshAllValues:(NSArray *)values animated:(BOOL)animated
{
    NSUInteger itemCount = self.itemCount;
    NSUInteger valueCount = MIN(values.count, itemCount);
    NSUInteger index = 0;
    self.maxValue = 0;
    
    for(; index < valueCount; index++)
    {
        [self refreshOneValue:values[index] atIndex:index animated:animated];
    }
    for(; index < itemCount; index++)
    {
        [self refreshOneValue:@0 atIndex:index animated:animated];
    }
    if(self.maxValue == 0)
    {
        [self setMaxValueLabelXCenter:0 bottom:0];
    }
}

- (void)refreshOneValue:(NSNumber *)value atIndex:(NSUInteger)index
{
    [self refreshOneValue:value atIndex:index animated:YES];
}

- (void)clearAllValuesAnimated:(BOOL)animated
{
    self.maxValue = 0;
    for(NSUInteger index = 0; index < self.itemCount; index++)
    {
        [self refreshOneValue:@0 atIndex:index animated:animated];
    }
}

- (void)refreshOneValue:(NSNumber *)value atIndex:(NSUInteger)index animated:(BOOL)animated
{
    if(index < self.itemCount)
    {
        UIView *item = self.itemViews[index];
        CGFloat heightNew = [self itemHeightWithValue:value];
        CGRect frame = item.frame;
        frame.origin.y -= (heightNew - frame.size.height);
        frame.size.height = heightNew;
        
        if(value.integerValue > self.maxValue)
        {
            self.maxValue = value.integerValue;
            [self setMaxValueLabelXCenter:item.xCenter bottom:frame.origin.y];
        }
        
        void (^itemHeightChange)(void) = ^{
            item.frame = frame;
        };
        if(animated)
        {
            [UIView animateWithDuration:0.25 animations:itemHeightChange];
        }
        else
        {
            itemHeightChange();
        }
        itemHeightChange = nil;
    }
}

- (CGFloat)itemHeightWithValue:(NSNumber *)value
{
    CGFloat heightMin = nItemViewHeightMin;
    CGFloat heightMax = self.histogramMaxHeight;
    NSInteger intValue = value.integerValue;
    NSUInteger valueLevelMax = self.valueLevelMax;
    
    intValue = MIN(intValue, valueLevelMax);
    CGFloat height = heightMin;
    if(intValue > 0)
    {
        height = heightMax * intValue / valueLevelMax;
    }
    return height;
}

@end
