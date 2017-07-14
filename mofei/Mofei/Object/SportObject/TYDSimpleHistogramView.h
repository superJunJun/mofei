//
//  TYDSimpleHistogramView.h
//  Mofei
//
//  Created by macMini_Dev on 14-9-19.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TYDSimpleHistogramType)
{
    //TYDSimpleHistogramTypeNone = 0,
    TYDSimpleHistogramTypeDaysPerWeek = 0,
    TYDSimpleHistogramTypeDaysPerMonth
};

@interface TYDSimpleHistogramView : UIView

//scale:itemWidth/itemInterval
- (instancetype)initWithCoreViewSize:(CGSize)coreViewSize
                               scale:(CGFloat)scale
                           itemColor:(UIColor *)itemColor
                  timeStampTextColor:(UIColor *)timeStampTextColor
                   timeStampTextFont:(UIFont *)timeStampTextFont
                   maxValueTextColor:(UIColor *)maxValueTextColor
                    maxValueTextFont:(UIFont *)maxValueTextFont
                     maxValueVisible:(BOOL)maxValueVisible
                       valueLevelMax:(NSUInteger)valueLevelMax
                                type:(TYDSimpleHistogramType)type;

- (void)clearAllValuesAnimated:(BOOL)animated;
- (void)refreshAllValues:(NSArray *)values animated:(BOOL)animated;
- (void)refreshOneValue:(NSNumber *)value atIndex:(NSUInteger)index;

@end
