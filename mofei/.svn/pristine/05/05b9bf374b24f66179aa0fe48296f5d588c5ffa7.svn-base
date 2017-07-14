//
//  TYDBreastClassCell.m
//  Mofei
//
//  Created by caiyajie on 14-10-30.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import "TYDBreastClassCell.h"

@implementation TYDBreastClassCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.pictureImagV=[[UIImageView alloc]initWithFrame:CGRectMake(10, 20, 80, 61)];
        self.iconImagV=[[UIImageView alloc]initWithFrame:CGRectMake(290, 22, 20, 20)];
        self.titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(100, 28, 140, 21)];
        self.titleLabel.font=[UIFont systemFontOfSize:16];
        self.numberLabel=[[UILabel alloc]initWithFrame:CGRectMake(240, 22, 50, 20)];
        self.numberLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:self.pictureImagV];
        [self addSubview:self.iconImagV];
        [self addSubview:self.titleLabel];
        [self addSubview:self.numberLabel];
    }
    return self;
}

-(void)setBreastClass:(TYDBreastListModel *)breastClass
{
    _breastClass = breastClass;
    [_pictureImagV setImageWithURL:[NSURL URLWithString:breastClass.pictureUrl] placeholderImage:[UIImage imageNamed:@"loadFail"]];
//    _iconImagV.image = [UIImage imageNamed:@"2222"];
    _iconImagV.image = breastClass.isAttention==1?[UIImage imageNamed:@"redHeartIcon"]:[UIImage imageNamed:@"grayHeartIcon"];
    _numberLabel.text = [NSString stringWithFormat:@"%@",breastClass.numberText];
    _numberLabel.textAlignment = NSTextAlignmentRight;
    _numberLabel.textColor = [UIColor colorWithHex:0xa5a5a5];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    [_iconImagV addGestureRecognizer:tap];
    _iconImagV.userInteractionEnabled=YES;
     NSString * titleText = [breastClass.titleText stringByReplacingOccurrencesOfString:@"，" withString:@"\n"];
    _titleLabel.text = titleText;
    if(breastClass.didRead)
    {
        _titleLabel.textColor = [UIColor colorWithHex:0x323232 andAlpha:0.6];
    }
    else
    {
        _titleLabel.textColor = [UIColor colorWithHex:0x323232];
    }
    _titleLabel.numberOfLines=2;
    CGSize size=[BOAssistor string:@" \n " sizeWithFont:[UIFont systemFontOfSize:16] constrainedToWidth:120 lineBreakMode:NSLineBreakByWordWrapping];
    _titleLabel.frame=CGRectMake(100,28,120,size.height);
}

-(void)tapAction
{
    _clickModel(_breastClass);
}

@end
