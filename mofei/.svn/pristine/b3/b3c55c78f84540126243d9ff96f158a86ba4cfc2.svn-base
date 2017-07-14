//
//  TYDHistogramView.h
//

#import <UIKit/UIKit.h>

#define kHistogramViewStepValueLevels       @[@0, @1000, @4000, @10000, @20000, @40000]
#define kHistogramViewHeartRateValueLevels  @[@0, @60, @120, @180, @240]

typedef NS_ENUM(NSInteger, TYDHistogramTimeStampType)
{
    //TYDHistogramTimeStampTypeNone = 0,
    TYDHistogramTimeStampType15MinutesPerDay = 0,
    TYDHistogramTimeStampType15MinutesPerDayShort,
    TYDHistogramTimeStampTypeHoursPerDay,
    TYDHistogramTimeStampTypeDaysPerWeek,
    TYDHistogramTimeStampTypeDaysPerMonth,
};

@interface TYDHistogramView : UIView

//coreViewSize：中心柱状图可视区域size
- (instancetype)initWithCoreViewSize:(CGSize)coreViewSize
                     backgroundColor:(UIColor *)backgroundColor
                      solidLineColor:(UIColor *)solidLineColor
                       dashLineColor:(UIColor *)dashLineColor
                 valueLevelTextColor:(UIColor *)valueLevelTextColor
                  timeStampTextColor:(UIColor *)timeStampTextColor
                           itemColor:(UIColor *)itemColor
                           itemWidth:(CGFloat)itemWidth
                        itemInterval:(CGFloat)itemInterval
                         valueLevels:(NSArray *)valueLevels
                     maxValueVisible:(BOOL)maxValueVisible
                       timeStampType:(TYDHistogramTimeStampType)timeStampType;

- (void)clearAllValuesAnimated:(BOOL)animated;
- (void)refreshAllValues:(NSArray *)values animated:(BOOL)animated;
- (void)refreshOneValue:(NSNumber *)value atIndex:(NSUInteger)index;

@end
