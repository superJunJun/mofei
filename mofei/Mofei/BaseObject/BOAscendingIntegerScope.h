//
//  BOAscendingIntegerScope.h
//
//  升序整数 范围类
//

#import <Foundation/Foundation.h>

@interface BOAscendingIntegerScope : NSObject

@property (nonatomic, readonly) NSInteger startValue;
@property (nonatomic, readonly) NSInteger endValue;
@property (nonatomic) NSUInteger scopePace;

@property (nonatomic) NSInteger currentValue;

- (instancetype)initWithStartValue:(NSInteger)startValue
                          endValue:(NSInteger)endValue
                         scopePace:(NSInteger)scopePace;
- (instancetype)initWithStartValue:(NSInteger)startValue
                          endValue:(NSInteger)endValue;
- (NSUInteger)countOfScope;
- (void)modifyStartValue:(NSInteger)startValue endValue:(NSInteger)endValue;

@end
