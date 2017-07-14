//
//  TYDBreastCookbookCell.m
//  Mofei
//
//  Created by caiyajie on 14-10-22.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import "TYDBreastCookbookCell.h"

@implementation TYDBreastCookbookCell

-(void)tapAction
{
    _clickModel(_cookbook);
}

- (void)setCookbook:(TYDBreastListModel *)cookbook
{
    _cookbook = cookbook;
    [_pictureImagV setImageWithURL:[NSURL URLWithString:cookbook.pictureUrl] placeholderImage:[UIImage imageNamed:@"loadFail"]];
     NSString * titleText = [cookbook.titleText stringByReplacingOccurrencesOfString:@"，" withString:@" "];
    _titleLable.text = titleText;
    _detailLable.text = cookbook.detailText;
  
    if(cookbook.didRead)
    {
        _titleLable.textColor = [UIColor colorWithHex:0x323232 andAlpha:0.6];
        _detailLable.textColor = [UIColor colorWithHex:0xa5a5a5 andAlpha:0.6];
    }
    else
    {
        _titleLable.textColor = [UIColor colorWithHex:0x323232];
        _detailLable.textColor = [UIColor colorWithHex:0xa5a5a5];
    }
    _numberLable.text = [NSString stringWithFormat:@"%@",cookbook.numberText];
    _numberLable.textColor = [UIColor colorWithHex:0xa5a5a5];
//    _iconImagV.image = [UIImage imageNamed:@"2222"];
    _iconImagV.image = cookbook.isAttention==1?[UIImage imageNamed:@"redHeartIcon"]:[UIImage imageNamed:@"grayHeartIcon"];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    [_iconImagV addGestureRecognizer:tap];
    _iconImagV.userInteractionEnabled=YES;
}

@end
