//
//  TYDSportLeadingViewController.m
//  Mofei
//
//  Created by macMini_Dev on 14-10-11.
//  Copyright (c) 2014年 Young. All rights reserved.
//
//  运动目标设定引导页，一次性页面
//

#import "TYDSportLeadingViewController.h"
#import "BOSwitchableIcon.h"

#define nTextFieldTag                       300
#define nSportTargetViewIntervalVer         8

@interface TYDSportLeadingViewController () <BOSwitchableIconDelegate>

@property (strong, nonatomic) UIView *mainImageBaseView;
@property (strong, nonatomic) UIImageView *mainImageView;
@property (strong, nonatomic) UIView *speechBaseView;
@property (strong, nonatomic) UIImageView *speechImageView;
@property (strong, nonatomic) UILabel *speechInfoLabel;

@property (strong, nonatomic) UIView *targetIconBaseView;
@property (strong, nonatomic) NSArray *targetIcons;
@property (strong, nonatomic) UILabel *targetInfoLabel;
@property (strong, nonatomic) UIView *stepTitleView;
@property (strong, nonatomic) UIView *calorieTitleView;
@property (strong, nonatomic) UIView *stepTextFieldView;
@property (strong, nonatomic) UIView *calorieTextFieldView;

@property (strong, nonatomic) BOSwitchableIcon *selectedTargetIcon;

@property (strong, nonatomic) NSArray *speechInfos;
@property (strong, nonatomic) NSArray *targetInfos;
@property (strong, nonatomic) NSArray *mainImageNames;
@property (strong, nonatomic) NSMutableArray *targetStepValues;
@property (strong, nonatomic) NSMutableArray *targetCalorieValues;

@end

@implementation TYDSportLeadingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHex:0xf2f2f2];
    
    [self localDataInitialize];
    [self navigationBarItemsLoad];
    [self basicViewsLoad];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self subviewsLocalLayout];
}

- (void)subviewsLocalLayout
{
    CGFloat viewHeight = self.view.height;
    self.baseViewBaseHeight = viewHeight;
    
    CGFloat halfHeight = viewHeight * 0.5;
    if(self.mainImageBaseView.height > halfHeight)//对3.5吋屏裁剪
    {
        self.mainImageBaseView.height = halfHeight;
        self.mainImageView.center = self.mainImageBaseView.innerCenter;
    }
    
    self.targetIconBaseView.top = self.mainImageBaseView.bottom;
    
    CGFloat heightBottom = viewHeight - self.targetIconBaseView.bottom;
    CGFloat innerInterval = self.calorieTextFieldView.top - self.stepTextFieldView.bottom;
    CGFloat topInterval = (heightBottom - innerInterval - self.calorieTextFieldView.height - self.stepTextFieldView.height) * 0.5;
    topInterval = MIN(24, topInterval);
    self.stepTextFieldView.top = self.targetIconBaseView.bottom + topInterval;
    self.calorieTextFieldView.top = self.stepTextFieldView.bottom + innerInterval;
    self.stepTitleView.yCenter = self.stepTextFieldView.yCenter;
    self.calorieTitleView.yCenter = self.calorieTextFieldView.yCenter;
}

- (void)localDataInitialize
{
    self.speechInfos = @[@"很少运动", @"经常走动", @"经常运动"];
    self.targetInfos = @[@"很少运动，没什么时间", @"经常走动，偶尔出去运动", @"经常运动，健康活力每一天"];
    
    BOOL isFemale = ([TYDUserInfo sharedUserInfo].sex.integerValue == TYDUserGenderTypeFemale);
    self.mainImageNames = @[@"sportTarget_imgFemaleSit", @"sportTarget_imgFemaleWalk", @"sportTarget_imgFemaleSport"];
    if(!isFemale)
    {
        self.mainImageNames = @[@"sportTarget_imgMaleSit", @"sportTarget_imgMaleWalk", @"sportTarget_imgMaleSport"];
    }
    
    self.targetStepValues = [@[@7000, @10000, @15000] mutableCopy];
    NSMutableArray *targetCalorieValues = [NSMutableArray new];
    for(NSNumber *targetStep in self.targetStepValues)
    {
        [targetCalorieValues addObject:[self calorieTargetWithStepCount:targetStep]];
    }
    self.targetCalorieValues = targetCalorieValues;
}

- (void)navigationBarItemsLoad
{
    self.title = @"运动目标";
    self.backButtonVisible = NO;
    
    UIButton *saveButton = [UIButton new];
    [saveButton setTitle:@"保存" forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [saveButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [saveButton addTarget:self action:@selector(saveButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    [saveButton sizeToFit];
    UIBarButtonItem *saveBtnItem = [[UIBarButtonItem alloc] initWithCustomView:saveButton];
    self.navigationItem.rightBarButtonItem = saveBtnItem;
}

- (void)basicViewsLoad
{
    [self mainImageViewLoad];
    [self targetIconViewsLoad];
    [self targetDetailViewsLoad];
    self.selectedTargetIcon = self.targetIcons.firstObject;
}

- (void)mainImageViewLoad
{
    CGRect frame = CGRectZero;
    frame.size = [UIImage imageNamed:self.mainImageNames[0]].size;
    
    UIView *mainImageBaseView = [[UIView alloc] initWithFrame:frame];
    mainImageBaseView.backgroundColor = [UIColor clearColor];
    mainImageBaseView.layer.masksToBounds = YES;
    mainImageBaseView.userInteractionEnabled = NO;
    [self.baseView addSubview:mainImageBaseView];
    
    UIImageView *mainImageView = [[UIImageView alloc] initWithFrame:frame];
    mainImageView.center = self.baseView.innerCenter;
    mainImageView.top = 0;
    [mainImageBaseView addSubview:mainImageView];
    
    UIImage *speechBarImage = [UIImage imageNamed:@"sportTarget_textBar"];
    UIView *speechBaseView = [UIView new];
    speechBaseView.backgroundColor = [UIColor clearColor];
    speechBaseView.size = speechBarImage.size;
    [mainImageView addSubview:speechBaseView];
    
    UIImageView *speechImageView = [[UIImageView alloc] initWithFrame:speechBaseView.bounds];
    speechImageView.image = speechBarImage;
    [speechBaseView addSubview:speechImageView];
    UILabel *speechInfoLabel = [UILabel new];
    speechInfoLabel.backgroundColor = [UIColor clearColor];
    speechInfoLabel.font = [UIFont boldSystemFontOfSize:14];
    speechInfoLabel.textColor = [UIColor whiteColor];
    speechInfoLabel.text = @" ";
    [speechInfoLabel sizeToFit];
    speechInfoLabel.center = speechBaseView.center;
    [speechBaseView addSubview:speechInfoLabel];
    
    self.mainImageBaseView = mainImageBaseView;
    self.mainImageView = mainImageView;
    self.speechBaseView = speechBaseView;
    self.speechImageView = speechImageView;
    self.speechInfoLabel = speechInfoLabel;
    
    self.baseViewBaseHeight = mainImageBaseView.bottom;
}

- (void)targetIconViewsLoad
{
    NSArray *imageNames = @[@"sportTarget_sitIcon", @"sportTarget_walkIcon", @"sportTarget_sportIcon"];
    NSArray *imageHNames = @[@"sportTarget_sitIconH", @"sportTarget_walkIconH", @"sportTarget_sportIconH"];
    NSMutableArray *targetIcons = [NSMutableArray new];
    
    CGRect frame = self.baseView.bounds;
    frame.origin.y = self.baseViewBaseHeight;
    UIControl *targetBaseView = [[UIControl alloc] initWithFrame:frame];
    targetBaseView.backgroundColor = [UIColor colorWithHex:0xd2d2d2];
    [targetBaseView addTarget:self action:@selector(tapOnSpace:) forControlEvents:UIControlEventTouchUpInside];
    [self.baseView addSubview:targetBaseView];
    
    CGFloat verInterval = nSportTargetViewIntervalVer;
    CGSize targetIconSize = [UIImage imageNamed:imageNames[0]].size;
    CGFloat horInterval = (targetBaseView.width - targetIconSize.width * imageNames.count) / (imageNames.count + 1);
    CGPoint origin = CGPointMake(horInterval, verInterval);
    for(int i = 0; i < imageNames.count; i++)
    {
        UIImage *image = [UIImage imageNamed:imageNames[i]];
        UIImage *imageH = [UIImage imageNamed:imageHNames[i]];
        BOSwitchableIcon *targetIcon = [[BOSwitchableIcon alloc] initWithImage:image imageH:imageH keepHighlightedState:YES];
        targetIcon.tag = i;
        targetIcon.delegate = self;
        targetIcon.origin = origin;
        [targetBaseView addSubview:targetIcon];
        [targetIcons addObject:targetIcon];
        
        origin.x += targetIcon.width + horInterval;
    }
    
    UILabel *targetInfoLabel = [UILabel new];
    targetInfoLabel.backgroundColor = [UIColor clearColor];
    targetInfoLabel.font = [UIFont fontWithName:@"Arial" size:12];
    targetInfoLabel.textColor = [UIColor colorWithHex:0x545454];
    targetInfoLabel.textAlignment = NSTextAlignmentCenter;
    targetInfoLabel.text = @" ";
    [targetInfoLabel sizeToFit];
    targetInfoLabel.width = targetBaseView.width;
    targetInfoLabel.top = origin.y + targetIconSize.height + verInterval;
    [targetBaseView addSubview:targetInfoLabel];
    
    self.targetIconBaseView = targetBaseView;
    self.targetIcons = targetIcons;
    self.targetInfoLabel = targetInfoLabel;
    
    targetBaseView.height = targetInfoLabel.bottom + verInterval;
    self.baseViewBaseHeight = targetBaseView.bottom;
}

- (void)targetDetailViewsLoad
{
    UIView *baseView = self.baseView;
    CGFloat top = self.baseViewBaseHeight + 20;
    
    UIView *stepTitleView = [self iconTextViewCreateWithImageName:@"sportTarget_stepIcon" text:@"步数"];
    UIView *calorieTitleView = [self iconTextViewCreateWithImageName:@"sportTarget_fireIcon" text:@"卡路里"];
    [baseView addSubview:stepTitleView];
    [baseView addSubview:calorieTitleView];
    
    CGFloat horOffset = 40;
    CGFloat horInterval = 6;
    CGFloat innerIntervalVer = 8;
    CGSize textFieldSize = CGSizeMake(baseView.width - horOffset * 2 - horInterval - MAX(stepTitleView.width, calorieTitleView.width), 30);
    UIView *stepTextFieldView = [self textFieldViewCreateWithSize:textFieldSize];
    UIView *calorieTextFieldView = [self textFieldViewCreateWithSize:textFieldSize];
    [baseView addSubview:stepTextFieldView];
    [baseView addSubview:calorieTextFieldView];
    
    stepTextFieldView.top = top;
    calorieTextFieldView.top = stepTextFieldView.bottom + innerIntervalVer;
    stepTextFieldView.right = baseView.width - horOffset;
    calorieTextFieldView.right = stepTextFieldView.right;
    
    stepTitleView.yCenter = stepTextFieldView.yCenter;
    calorieTitleView.yCenter = calorieTextFieldView.yCenter;
    stepTitleView.left = horOffset;
    calorieTitleView.left = stepTitleView.left;
    
    UITextField *stepTextField = (UITextField *)[stepTextFieldView viewWithTag:nTextFieldTag];
    UITextField *calorieTextField = (UITextField *)[calorieTextFieldView viewWithTag:nTextFieldTag];
//    stepTextField.returnKeyType = UIReturnKeyNext;
//    calorieTextField.returnKeyType = UIReturnKeyDone;
    
    [self.textFields appendTextFieldsWithArray:@[stepTextField, calorieTextField]];
    
    self.stepTitleView = stepTitleView;
    self.calorieTitleView = calorieTitleView;
    self.stepTextFieldView = stepTextFieldView;
    self.calorieTextFieldView = calorieTextFieldView;
    
    self.baseViewBaseHeight = calorieTextFieldView.bottom + 20;
}

- (UIView *)textFieldViewCreateWithSize:(CGSize)size
{
    UIColor *textColor = [UIColor colorWithHex:0xe4007f];
    UIColor *tintColor = [UIColor colorWithHex:0x0080ee];
    UIFont *textFont = [UIFont fontWithName:@"Arial" size:14];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    view.backgroundColor = [UIColor whiteColor];
    view.layer.cornerRadius = 3;
    view.layer.borderWidth = 0.5;
    view.layer.borderColor = [UIColor colorWithHex:0xcfcfd0].CGColor;
    view.layer.masksToBounds = YES;
    
    size.width -= 8;
    UITextField *textField = [UITextField new];
    textField.placeholder = @"";
    textField.font = textFont;
    textField.textColor = textColor;
    textField.borderStyle = UITextBorderStyleNone;
    textField.returnKeyType = UIReturnKeyDone;
    //textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.secureTextEntry = NO;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [textField addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    [textField addTarget:self action:@selector(textFiledEditEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
    textField.tag = nTextFieldTag;
    textField.size = size;
    textField.center = view.innerCenter;
    [view addSubview:textField];
    
    if([textField respondsToSelector:@selector(tintColor)])
    {
        textField.tintColor = tintColor;
    }
    
    return view;
}

- (UIView *)iconTextViewCreateWithImageName:(NSString *)imageName text:(NSString *)text
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    [view addSubview:icon];
    
    UILabel *textLabel = [UILabel new];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.font = [UIFont systemFontOfSize:14];
    textLabel.textColor = [UIColor colorWithHex:0x585858];
    textLabel.text = text;
    [textLabel sizeToFit];
    [view addSubview:textLabel];
    
    view.size = CGSizeMake(icon.width + textLabel.width + 3, MAX(icon.height, textLabel.height));
    icon.center = view.innerCenter;
    textLabel.center = view.innerCenter;
    icon.left = 0;
    textLabel.right = view.width;
    
    return view;
}

#pragma mark - TargetMeasure

- (NSNumber *)calorieTargetWithStepCount:(NSNumber *)stepNumber
{
    TYDUserInfo *userInfo = [TYDUserInfo sharedUserInfo];
    NSUInteger stepCount = stepNumber.unsignedIntegerValue;
    CGFloat height = userInfo.height.floatValue / 100;
    int weight = userInfo.weight.intValue;
    
    CGFloat distance = [TYDUserInfo distanceMeasuredWithHeight:height andStepCount:stepCount];
    NSUInteger calorie = [TYDUserInfo calorieMeasuredWithWeight:weight andDistance:distance];
    return @(calorie);
}

- (NSNumber *)stepNumberWithCalorieTarget:(NSNumber *)calorieTarget
{
    TYDUserInfo *userInfo = [TYDUserInfo sharedUserInfo];
    CGFloat height = userInfo.height.floatValue / 100;
    int weight = userInfo.weight.intValue;
    CGFloat calorie = calorieTarget.floatValue;
    
    CGFloat distance = [TYDUserInfo distanceMeasuredWithCalorie:calorie andWeight:weight];
    CGFloat stepPace = [TYDUserInfo stepPaceMeasuredWithHeight:height];
    NSUInteger step = distance / stepPace;
    return @(step);
}

#pragma mark - Override Setting Method

- (void)setSelectedTargetIcon:(BOSwitchableIcon *)selectedTargetIcon
{
    _selectedTargetIcon = selectedTargetIcon;
    for(BOSwitchableIcon *icon in self.targetIcons)
    {
        if(icon != selectedTargetIcon)
        {
            icon.selected = NO;
        }
        else
        {
            icon.selected = YES;
        }
    }
    NSUInteger index = [self.targetIcons indexOfObject:selectedTargetIcon];
    if(index != NSNotFound)
    {
        if(index < self.speechInfos.count)
        {
            CGPoint center = self.speechInfoLabel.center;
            self.speechInfoLabel.text = self.speechInfos[index];
            [self.speechInfoLabel sizeToFit];
            self.speechInfoLabel.center = center;
        }
        if(index < self.targetInfos.count)
        {
            self.targetInfoLabel.text = self.targetInfos[index];
        }
        if(index < self.targetStepValues.count)
        {
            NSNumber *targetStep = self.targetStepValues[index];
            UITextField *stepTextField = [self.textFields objectInTextFieldsAtIndex:0];
            stepTextField.text = targetStep.stringValue;
        }
        if(index < self.targetCalorieValues.count)
        {
            NSNumber *targetCalorie = self.targetCalorieValues[index];
            UITextField *calorieTextField = [self.textFields objectInTextFieldsAtIndex:1];
            calorieTextField.text = targetCalorie.stringValue;
        }
        if(index < self.mainImageNames.count)
        {
            CATransform3D transfrom = CATransform3DIdentity;
            CGPoint speechBaseViewOrigin = CGPointMake(206, 56);
            CGPoint centerOffset = CGPointMake(6, 2);
            
            if(index == 0)
            {
                speechBaseViewOrigin = CGPointMake(34, 75);
                centerOffset.x = -centerOffset.x;
                
                //(后面3个 数字分别代表不同的轴来翻转，本处为y轴)
                transfrom = CATransform3DMakeRotation(M_PI, 0.0, 1.0, 0.0);
            }
            //设定翻转时的中心点，(0.5, 0.5)为视图layer的正中
            self.mainImageView.image = [UIImage imageNamed:self.mainImageNames[index]];
            self.speechBaseView.origin = speechBaseViewOrigin;
            self.speechImageView.layer.anchorPoint = CGPointMake(0.5, 0.5);
            self.speechImageView.layer.transform = transfrom;
            
            CGPoint infoLabelCenter = self.speechImageView.center;
            infoLabelCenter.x += centerOffset.x;
            infoLabelCenter.y += centerOffset.y;
            self.speechInfoLabel.center = infoLabelCenter;
        }
    }
}

#pragma mark - Touch Event

- (void)tapOnSpace:(id)sender
{
    [self targetValuesEditComplete];
    [super tapOnSpace:sender];
}

- (void)saveButtonTap:(UIButton *)sender
{
    NSLog(@"saveButtonTap");
    if([self calorieTargetValueValidCheck])
    {
        sender.enabled = NO;
        [self showProgressHUDWithLabelText:@""];
        [self saveUserSportTargetInfo];
        [self showProgressCompleteWithLabelText:@"保存完成" isSucceed:YES additionalTarget:self.navigationController action:@selector(popToRootViewControllerAnimated:) object:@(YES)];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"消息" message:@"运动目标卡路里消耗不应小于100" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)textFiledEditEndOnExit:(UITextField *)sender
{
    [self targetValuesEditComplete];
    //[self.textFields nextTextFieldBecomeFirstResponder:sender];
}

- (void)textFieldValueChanged:(UITextField *)sender
{
    UITextField *stepTextField = [self.textFields objectInTextFieldsAtIndex:0];
    UITextField *calorieTextField = [self.textFields objectInTextFieldsAtIndex:1];
    
    NSUInteger index = [self.targetIcons indexOfObject:self.selectedTargetIcon];
    if(stepTextField == sender)
    {
        if(index < self.targetStepValues.count)
        {
            NSNumber *stepTargetOriginal = self.targetStepValues[index];
            NSNumber *stepTargetCurrent = @(ABS(stepTextField.text.integerValue));
            if(![stepTargetOriginal isEqualToNumber:stepTargetCurrent])
            {
                self.targetStepValues[index] = stepTargetCurrent;
                
                NSNumber *targetCalorieCurrentValue = [self calorieTargetWithStepCount:stepTargetCurrent];
                self.targetCalorieValues[index] = targetCalorieCurrentValue;
                calorieTextField.text = targetCalorieCurrentValue.stringValue;
            }
        }
    }
    else//(calorieTextField == sender)
    {
        if(index < self.targetCalorieValues.count)
        {
            NSNumber *calorieTargetOriginal = self.targetCalorieValues[index];
            NSNumber *calorieTargetCurrent = @(ABS(calorieTextField.text.integerValue));
            if(![calorieTargetOriginal isEqualToNumber:calorieTargetCurrent])
            {
                self.targetCalorieValues[index] = calorieTargetCurrent;
                
                NSNumber *targetStepCurrentValue = [self stepNumberWithCalorieTarget:calorieTargetCurrent];
                self.targetStepValues[index] = targetStepCurrentValue;
                stepTextField.text = targetStepCurrentValue.stringValue;
            }
        }
    }
}

- (void)targetValuesEditComplete
{
    NSUInteger index = [self.targetIcons indexOfObject:self.selectedTargetIcon];
    if(index != NSNotFound)
    {
        UITextField *stepTextField = [self.textFields objectInTextFieldsAtIndex:0];
        UITextField *calorieTextField = [self.textFields objectInTextFieldsAtIndex:1];
        if(index < self.targetStepValues.count)
        {
            NSNumber *stepTargetOriginal = self.targetStepValues[index];
            NSNumber *stepTargetCurrent = @(ABS(stepTextField.text.integerValue));
            if([stepTargetOriginal isEqualToNumber:stepTargetCurrent])
            {
                stepTextField.text = stepTargetOriginal.stringValue;
            }
            else
            {
                [self.targetStepValues replaceObjectAtIndex:index withObject:stepTargetCurrent];
                stepTextField.text = stepTargetCurrent.stringValue;
            }
        }
        if(index < self.targetCalorieValues.count)
        {
            NSNumber *calorieTargetOriginal = self.targetCalorieValues[index];
            NSNumber *calorieTargetCurrent = @(ABS(calorieTextField.text.integerValue));
            if([calorieTargetOriginal isEqualToNumber:calorieTargetCurrent])
            {
                calorieTextField.text = calorieTargetOriginal.stringValue;
            }
            else
            {
                [self.targetCalorieValues replaceObjectAtIndex:index withObject:calorieTargetCurrent];
                calorieTextField.text = calorieTargetCurrent.stringValue;
            }
        }
    }
}

#pragma mark - BOSwitchableIcon Delegate

- (void)switchableIconStateChanged:(BOSwitchableIcon *)switchableIcon
{
    [self targetValuesEditComplete];
    [self.textFields allTextFieldsResignFirstResponder];
    self.selectedTargetIcon = switchableIcon;
}

#pragma mark - Complete

- (BOOL)calorieTargetValueValidCheck
{
    NSUInteger index = [self.targetIcons indexOfObject:self.selectedTargetIcon];
    if(index >= self.targetCalorieValues.count)
    {
        index = 0;
    }
    NSNumber *calorieTarget = self.targetCalorieValues[index];
    if(calorieTarget.integerValue < 100)
    {
        return NO;
    }
    return YES;
}

- (void)saveUserSportTargetInfo
{
    TYDUserInfo *userInfo = [TYDUserInfo sharedUserInfo];
    NSUInteger index = [self.targetIcons indexOfObject:self.selectedTargetIcon];
    if(index >= self.targetCalorieValues.count)
    {
        index = 0;
    }
    NSNumber *calorieTarget = self.targetCalorieValues[index];
    
    userInfo.sportTarget = calorieTarget;
    [userInfo saveUserInfo];
}

@end
