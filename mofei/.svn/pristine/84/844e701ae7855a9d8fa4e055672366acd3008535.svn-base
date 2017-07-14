//
//  BOAscendingIntegerScope.m
//
//  升序整数 范围类
//

#import "BOAscendingIntegerScope.h"

@implementation BOAscendingIntegerScope

- (instancetype)initWithStartValue:(NSInteger)startValue
                          endValue:(NSInteger)endValue
                         scopePace:(NSInteger)scopePace
{
    if(self = [super init])
    {
        [self modifyStartValue:startValue endValue:endValue];
        self.scopePace = scopePace;
        self.currentValue = startValue;
    }
    return self;
}

- (instancetype)init
{
    if(self = [super init])
    {
        [self modifyStartValue:1 endValue:1];
        self.scopePace = 1;
        self.currentValue = 1;
    }
    return self;
}

- (instancetype)initWithStartValue:(NSInteger)startValue
                          endValue:(NSInteger)endValue
{
    if(self = [super init])
    {
        [self modifyStartValue:startValue endValue:endValue];
        self.scopePace = 1;
        self.currentValue = startValue;
    }
    return self;
}

- (void)modifyStartValue:(NSInteger)startValue endValue:(NSInteger)endValue
{
    if(startValue > endValue)
    {
        _startValue = endValue;
        _endValue = startValue;
    }
    else
    {
        _startValue = startValue;
        _endValue = endValue;
    }
}

- (NSUInteger)countOfScope
{
    return (self.endValue - self.startValue + self.scopePace - 1) / self.scopePace + 1;
}

#pragma mark - OverridePropertyMethod

- (void)setScopePace:(NSUInteger)value
{
    value = MAX(value, 1);
    _scopePace = value;
}

- (void)setCurrentValue:(NSInteger)currentValue
{
    if(_currentValue != currentValue)
    {
        currentValue = MIN((self.endValue), (MAX((self.startValue), currentValue)));
        _currentValue = currentValue;
    }
}

@end
