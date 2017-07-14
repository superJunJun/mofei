//
//  UIColor+Hex.h
//

#import <UIKit/UIKit.h>

@interface UIColor (Hex)

+ (UIColor *) colorWithHex:(long)hex;
+ (UIColor *) colorWithHex:(long)hex andAlpha:(float)alpha;

@end
