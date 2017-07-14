//
//  TYDUnitLabel.m
//  Mofei
//
//  Created by macMini_Dev on 14-9-10.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import "TYDUnitLabel.h"

@interface TYDUnitLabel ()

@property (strong, nonatomic) UIFont *numberTextFont;
@property (strong, nonatomic) UIColor *numberTextColor;
@property (strong, nonatomic) NSString *unitText;
@property (strong, nonatomic) UIFont *unitTextFont;
@property (strong, nonatomic) UIColor *unitTextColor;

@end

@implementation TYDUnitLabel

- (instancetype)initWithNumberText:(NSString *)numberText
                    numberTextFont:(UIFont *)numberTextFont
                   numberTextColor:(UIColor *)numberTextColor
                          unitText:(NSString *)unitText
                      unitTextFont:(UIFont *)unitTextFont
                     unitTextColor:(UIColor *)unitTextColor
                     alignmentType:(UIViewAlignmentType)alignmentType
             spaceCountForInterval:(NSUInteger)spaceCount
{
    if(self = [super init])
    {
        self.backgroundColor = [UIColor clearColor];
        self.numberTextFont = numberTextFont;
        self.numberTextColor = numberTextColor;
        self.unitTextFont = unitTextFont;
        self.unitTextColor = unitTextColor;
        self.alignmentType = alignmentType;
        
        self.unitText = @"";
        if(unitText.length > 0)
        {
            NSMutableString *spaceString = [@"" mutableCopy];
            for(; spaceCount > 0; spaceCount--)
            {
                [spaceString appendString:@" "];
            }
            self.unitText = [spaceString stringByAppendingString:unitText];
        }
        self.numberText = numberText;
    }
    
    return self;
}

#pragma mark - OverrideSettingMethod

- (void)setNumberText:(NSString *)numberText
{
    _numberText = numberText;
    
    CGRect frame = self.frame;
    NSString *text = [numberText stringByAppendingString:self.unitText];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName:self.unitTextColor,                                                            NSFontAttributeName:self.unitTextFont}];
    [attributedText setAttributes:@{NSForegroundColorAttributeName:self.numberTextColor, NSFontAttributeName:self.numberTextFont} range:NSMakeRange(0, numberText.length)];
    self.attributedText = attributedText;
    [self sizeToFit];
    
    switch(self.alignmentType)
    {
        case UIViewAlignmentRight:
            self.right = frame.origin.x + frame.size.width;
            break;
        case UIViewAlignmentCenter:
            self.xCenter = frame.origin.x + frame.size.width * 0.5;
            break;
        case UIViewAlignmentLeft:
        default:
            break;
    }
}

- (void)setAlignmentType:(UIViewAlignmentType)type
{
    switch(type)
    {
        case UIViewAlignmentLeft:
        case UIViewAlignmentCenter:
        case UIViewAlignmentRight:
            break;
        default:
            type = UIViewAlignmentLeft;
    }
    _alignmentType = type;
}

//居中绘制-无效
//#pragma mark - Override DrawTextInRect
//
//- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
//{
//    CGRect textRect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
//    textRect.origin.y = bounds.origin.y + (bounds.size.height - textRect.size.height) * 0.5;
//    
//    [BOAssistor rectangleShow:bounds withTitle:@"textRectForBounds"];
//    [BOAssistor rectangleShow:textRect withTitle:@"textRect"];
//    
//    return textRect;
//}
//
//- (void)drawTextInRect:(CGRect)requestedRect
//{
//    CGRect actualRect = [self textRectForBounds:requestedRect limitedToNumberOfLines:self.numberOfLines];
//    [super drawTextInRect:actualRect];
//}

@end
