//
//  TYDSportCircleView.h
//
//  "运动"首页 运动目标完成环装效果视图
//

#import <UIKit/UIKit.h>

@interface TYDSportCircleView : UIView

@property (nonatomic) NSUInteger calorieTargetValue;
@property (nonatomic) NSUInteger calorieBurnedValue;

- (instancetype)init;

- (void)setCalorieTargetValue:(NSInteger)targetValue andBurnedValue:(NSInteger)burnedValue;

@end
