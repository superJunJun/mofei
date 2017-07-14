//
//  TYDDeviceInfoCell.m
//  Mofei
//
//  Created by macMini_Dev on 14-9-25.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import "TYDDeviceInfoCell.h"
#import "CBPeripheral+UUIDString.h"

@interface TYDDeviceInfoCell ()

@property (strong, nonatomic) UIImageView *deviceIcon;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *detailLabel;
@property (strong, nonatomic) UIImageView *stateIcon;
@property (strong, nonatomic) UIView *separatorLine;
@property (strong,nonatomic) UIView * cirleView;

@end

@implementation TYDDeviceInfoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    style = UITableViewCellStyleSubtitle;
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        UIView *baseView = self.contentView;
        
        UIImageView *deviceIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"startPage_deviceIcon"]];
        [baseView addSubview:deviceIcon];
        
        UILabel *nameLabel = [UILabel new];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.font = [UIFont fontWithName:@"Arial" size:24];
        nameLabel.textColor = [UIColor colorWithHex:0x777777];
        nameLabel.text = @" ";
        [nameLabel sizeToFit];
        [baseView addSubview:nameLabel];
        
        UILabel *detailLabel = [UILabel new];
        detailLabel.backgroundColor = [UIColor clearColor];
        detailLabel.font = [UIFont fontWithName:@"Arial" size:8];
        detailLabel.textColor = [UIColor colorWithHex:0x949494];
        detailLabel.text = @" ";
        [detailLabel sizeToFit];
        [baseView addSubview:detailLabel];
        UIImageView *stateIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"startPage_deviceConnectOver"]];
        [baseView addSubview:stateIcon];
        
        UIImageView *circleView= [UIImageView new];
        circleView.size = CGSizeMake(20,20);
        circleView.image = [UIImage imageNamed:@"startPage_deviceIsConnect"];
        circleView.center = self.stateIcon.center;
        circleView.backgroundColor = [UIColor clearColor];
        [baseView addSubview:circleView];
        
        UIView *separatorLine = [UIView new];
        separatorLine.backgroundColor = [UIColor colorWithHex:0xcecece];
        separatorLine.size = CGSizeMake(baseView.width, 0.5);
        [baseView addSubview:separatorLine];
        
        
        self.cirleView = circleView;
        self.deviceIcon = deviceIcon;
        self.nameLabel = nameLabel;
        self.detailLabel = detailLabel;
        self.stateIcon = stateIcon;
        self.separatorLine = separatorLine;

    }
    
    self.selectionStyle = UITableViewCellSelectionStyleGray;
    self.backgroundColor = [UIColor colorWithHex:0xfcfcff];
    
    self.stateIcon.hidden = YES;
    self.cirleView.hidden = YES;
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.contentView.bounds;
    CGPoint center = CGRectGetCenter(frame);
    self.separatorLine.bottomRight = CGPointMake(frame.size.width, frame.size.height);
    
    self.deviceIcon.center = center;
    self.deviceIcon.left = 18;
   
    self.stateIcon.center = center;
    self.stateIcon.xCenter = frame.size.width - 8-40 - MAX((self.stateIcon.width), (self.cirleView.width));
    self.cirleView.center = self.stateIcon.center;
    
    CGFloat baseInterval = (frame.size.height - self.nameLabel.height - self.detailLabel.height)/6.0;
    self.nameLabel.left = self.deviceIcon.right + 26;
    self.detailLabel.left = self.nameLabel.left;
    self.nameLabel.top = baseInterval*2.7;
    self.detailLabel.top = self.nameLabel.bottom + baseInterval*1.5;
}

#pragma mark - OverrideSettingMethod

- (void)addCircleViewIcon
{
    NSLog(@"hidennonono");
    self.cirleView.hidden = NO;
    CABasicAnimation*rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2.0 ];
    rotationAnimation.duration = 1.0f;
    rotationAnimation.repeatCount =FLT_MAX;
    [self.cirleView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)removeCircleIcon
{
    if(!self.connectMark)
    {
        NSLog(@"hidenYESYESYESYES ContectedFail");
        self.cirleView.hidden = YES;
    }
}

- (void)setIsMarked:(BOOL)isMarked
{
    _isMarked = isMarked;
    self.stateIcon.hidden = !isMarked;
    if(_isMarked)
    {
        NSLog(@"hidenYEYES ContectedOver");
        self.cirleView.hidden = YES;
    }
}

- (void)setPeripheral:(CBPeripheral *)peripheral
{
    _peripheral = peripheral;
    self.nameLabel.text = peripheral.name;
    [self.nameLabel sizeToFit];
    
    self.detailLabel.text = peripheral.UUIDString;
    [self.detailLabel sizeToFit];
//  self.textLabel.text = peripheral.name;
//  self.detailTextLabel.text = peripheral.UUIDString;
}

#pragma mark - ClassMethod

+ (CGFloat)cellHeight
{
    return 90;
}
@end
