//
//  TYDUnitLabel.h
//  Mofei
//
//  Created by macMini_Dev on 14-9-10.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import <UIKit/UIKit.h>

#define sFontNameForRBNo2Light      @"RBNo2-Light"

@interface TYDUnitLabel : UILabel

//spaceCount:numberText与unitText直接间距 所需空格数量
- (instancetype)initWithNumberText:(NSString *)numberText
                    numberTextFont:(UIFont *)numberTextFont
                   numberTextColor:(UIColor *)numberTextColor
                          unitText:(NSString *)unitText
                      unitTextFont:(UIFont *)unitTextFont
                     unitTextColor:(UIColor *)unitTextColor
                     alignmentType:(UIViewAlignmentType)alignmentType
             spaceCountForInterval:(NSUInteger)spaceCount;

@property (strong, nonatomic) NSString *numberText;
@property (nonatomic) UIViewAlignmentType alignmentType;

@end
