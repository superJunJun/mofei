//
//  TYDHealthyCookbookCell.m
//  Mofei
//
//  Created by caiyajie on 14-10-21.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import "TYDHealthyCookbookCell.h"
#import "BaseViewController.h"
@implementation TYDHealthyCookbookCell

- (void)tapAction
{
    _clickModel(_cookbook);
}

#pragma mark - ServerConnectionComplete

- (void)setCookbook:(TYDBreastListModel *)cookbook
{
    _cookbook = cookbook;
    [_pictureImagV setImageWithURL:[NSURL URLWithString:cookbook.pictureUrl] placeholderImage:[UIImage imageNamed:@"loadFail"]];
    NSString * titleText = [cookbook.titleText stringByReplacingOccurrencesOfString:@"，" withString:@" "];
    _titleLable.text = titleText;
    _detailLable.text = cookbook.detailText;
    _numberLable.text = [NSString stringWithFormat:@"%@",cookbook.numberText];
    _numberLable.textColor = [UIColor colorWithHex:0xa5a5a5];
    
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
    
    _iconImagV.image = cookbook.isAttention==1?[UIImage imageNamed:@"redHeartIcon"]:[UIImage imageNamed:@"grayHeartIcon"];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    [_iconImagV addGestureRecognizer:tap];
    _iconImagV.userInteractionEnabled=YES;
}

@end
