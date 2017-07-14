//
//  TYDMeSettingViewController.m
//  Mofei
//
//  Created by macMini_Dev on 14/11/26.
//  Copyright (c) 2014年 Young. All rights reserved.
//
//  设置用户头像及名字，末端页面
//

#import "TYDMeSettingViewController.h"
#import "BOAvatarView.h"

#define sUserInfoModifiedInquireToSave  @"用户信息已更改\n是否保存？"
#define sUsernameFormatInvalidNotice    @"用户名4-20常见字符，1个汉字为2个字符"

@interface TYDMeSettingViewController () <UIAlertViewDelegate>

@property (strong, nonatomic) UIButton *saveButton;
@property (strong, nonatomic) NSArray *avatarViews;
@property (strong, nonatomic) UIView *selectedCircle;
@property (strong, nonatomic) UIView *selectedAvatarView;

@property (strong, nonatomic) UIView *nameShowBar;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UITextField *nameTextField;

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSNumber *avatarID;

@end

@implementation TYDMeSettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHex:0xf3f3f4];
    
    [self localDataInitialize];
    [self navigationBarItemsLoad];
    [self subviewsLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(self.isToEditName)
    {
        self.nameShowBar.hidden = YES;
        self.nameTextField.hidden = NO;
        [self.nameTextField becomeFirstResponder];
    }
}

- (void)localDataInitialize
{
    TYDUserInfo *userInfo = [TYDUserInfo sharedUserInfo];
    self.username = userInfo.username;
    self.avatarID = userInfo.avatarID;
}

- (void)navigationBarItemsLoad
{
    self.title = @"设置";//@"头像和名字设置";
    
    UIButton *saveButton = [UIButton new];
    [saveButton setTitle:@"保存" forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [saveButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [saveButton addTarget:self action:@selector(saveButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    [saveButton sizeToFit];
    UIBarButtonItem *saveBtnItem = [[UIBarButtonItem alloc] initWithCustomView:saveButton];
    self.navigationItem.rightBarButtonItem = saveBtnItem;
    self.saveButton = saveButton;
}

- (void)subviewsLoad
{
    [self avatarBoardLoad];
    [self nameBarLoad];
}

- (void)avatarBoardLoad
{
    UIView *baseView = self.baseView;
    
    CGRect frame = baseView.bounds;
    frame.origin.y = 16;
    UIControl *avatarBoard = [[UIControl alloc] initWithFrame:frame];
    avatarBoard.backgroundColor = [UIColor colorWithHex:0xfcfcff];
    [avatarBoard addTarget:self action:@selector(tapOnSpace:) forControlEvents:UIControlEventTouchUpInside];
    [baseView addSubview:avatarBoard];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont fontWithName:@"Arial" size:16];
    titleLabel.textColor = [UIColor colorWithHex:0x323232];
    titleLabel.text = @"头像";
    [titleLabel sizeToFit];
    titleLabel.origin = CGPointMake(16, 12);
    [avatarBoard addSubview:titleLabel];
    
    NSArray *avatarNames = [BOAvatarView avatarImageNames];
    
    int avatarCountPerRow = 4;
    CGFloat avatarRadius = (frame.size.width / avatarCountPerRow - 20) * 0.5;
    CGSize avatarSize = CGSizeMake(avatarRadius * 2, avatarRadius * 2);
    NSMutableArray *avatarViews = [NSMutableArray new];
    for(NSString *avatarName in avatarNames)
    {
        UIImageView *avatarView = [UIImageView new];
        avatarView.size = avatarSize;
        avatarView.layer.cornerRadius = avatarRadius;
        avatarView.layer.masksToBounds = YES;
        avatarView.image = [UIImage imageNamed:avatarName];
        [avatarBoard addSubview:avatarView];
        [avatarViews addObject:avatarView];
        
        avatarView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectedOneAvatar:)];
        [avatarView addGestureRecognizer:tapGr];
    }
    
    CGFloat circleRadius = avatarRadius + 4;
    CGFloat circleWidth = circleRadius * 2;
    UIView *pinkCircle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, circleWidth, circleWidth)];
    pinkCircle.backgroundColor = [UIColor clearColor];
    pinkCircle.layer.cornerRadius = circleRadius;
    pinkCircle.layer.borderColor = [UIColor colorWithHex:0xe23674].CGColor;
    pinkCircle.layer.borderWidth = 1;
    pinkCircle.layer.masksToBounds = YES;
    pinkCircle.hidden = YES;
    [avatarBoard insertSubview:pinkCircle atIndex:0];
    
    CGFloat top = titleLabel.bottom + 12;
    frame = CGRectMake(0, top, avatarBoard.width / avatarCountPerRow, avatarRadius * 2);
    CGFloat intervalVertical = 12;
    int avatarCountInOneRow = 0;
    for(UIView *avatarView in avatarViews)
    {
        avatarView.center = CGRectGetCenter(frame);
        avatarCountInOneRow++;
        if(avatarCountInOneRow < avatarCountPerRow)
        {
            frame.origin.x += frame.size.width;
        }
        else
        {
            frame.origin.x = 0;
            frame.origin.y += (frame.size.height + intervalVertical);
            avatarCountInOneRow = 0;
        }
    }
    
    self.avatarViews = avatarViews;
    self.selectedCircle = pinkCircle;
    
    NSString *avatarName = [BOAvatarView avatarNameWithAvatarID:self.avatarID];
    NSUInteger index = [avatarNames indexOfObject:avatarName];
    self.selectedAvatarView = avatarViews[index];
    
    int rows = (int)((avatarViews.count + avatarCountPerRow - 1) / avatarCountPerRow);
    avatarBoard.height = top + rows * (avatarRadius * 2 + intervalVertical) - intervalVertical + 16;
    self.baseViewBaseHeight = avatarBoard.bottom;
}

- (void)nameBarLoad
{
    UIView *baseView = self.baseView;
    CGFloat top = self.baseViewBaseHeight + 16;
    CGRect frame = CGRectMake(0, top, baseView.width, 44);
    UIControl *nameBar = [[UIControl alloc] initWithFrame:frame];
    nameBar.backgroundColor = [UIColor colorWithHex:0xfcfcff];
    [nameBar addTarget:self action:@selector(nameBarTap:) forControlEvents:UIControlEventTouchUpInside];
    [baseView addSubview:nameBar];
    
    frame = nameBar.bounds;
    UIView *nameShowBar = [[UIView alloc] initWithFrame:frame];
    nameShowBar.backgroundColor = [UIColor clearColor];
    nameShowBar.userInteractionEnabled = NO;
    [nameBar addSubview:nameShowBar];
    
    CGPoint center = nameShowBar.innerCenter;
    UILabel *titleLabel = [UILabel new];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont fontWithName:@"Arial" size:16];
    titleLabel.textColor = [UIColor colorWithHex:0x323232];
    titleLabel.text = @"名字";
    [titleLabel sizeToFit];
    titleLabel.center = center;
    titleLabel.left = 16;
    [nameShowBar addSubview:titleLabel];
    
    CGFloat nameLabelRight = nameShowBar.width - 16;
    UILabel *nameLabel = [UILabel new];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.font = [UIFont fontWithName:@"Arial" size:16];
    nameLabel.textColor = [UIColor colorWithHex:0xe23674];
    nameLabel.textAlignment = NSTextAlignmentRight;
    nameLabel.text = self.username;
    [nameLabel sizeToFit];
    nameLabel.center = center;
    nameLabel.width = nameLabelRight - titleLabel.right - 8;
    nameLabel.right = nameLabelRight;
    [nameShowBar addSubview:nameLabel];
    
    UITextField *nameEditTextField = [UITextField new];
    //nameEditTextField.tintColor = tintColor;
    nameEditTextField.placeholder = @"请输入名字";
    nameEditTextField.font = [UIFont fontWithName:@"Arial" size:16];
    nameEditTextField.textColor = [UIColor colorWithHex:0x323232];
    nameEditTextField.borderStyle = UITextBorderStyleNone;
    nameEditTextField.returnKeyType = UIReturnKeyDone;//Return键
    //nameEditTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    nameEditTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    nameEditTextField.secureTextEntry = NO;
    nameEditTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    nameEditTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    nameEditTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [nameEditTextField addTarget:self action:@selector(textFiledEditDidBegin:) forControlEvents:UIControlEventEditingDidBegin];
    [nameEditTextField addTarget:self action:@selector(textFiledEditEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
    nameEditTextField.size = CGSizeMake(nameBar.width - 32, 30);
    nameEditTextField.center = nameBar.innerCenter;
    nameEditTextField.hidden = YES;
    [nameBar addSubview:nameEditTextField];
    
    [self nameLabelSetUsername:self.username];
    nameEditTextField.text = self.username;
    [self.textFields appendOneTextField:nameEditTextField];
    
    self.nameShowBar = nameShowBar;
    self.nameLabel = nameLabel;
    self.nameTextField = nameEditTextField;
    
    self.baseViewBaseHeight = nameBar.bottom + 40;
}

- (void)nameLabelSetUsername:(NSString *)username
{
    if(username.length == 0)
    {
        self.nameLabel.text = @"";
    }
    else
    {
        CGFloat right = self.nameLabel.right;
        self.nameLabel.text = username;
        //[self.nameLabel sizeToFit];
        self.nameLabel.right = right;
    }
}

- (void)textFielsEditNameFinished
{
    if([self.nameTextField isFirstResponder])
    {
        [self.nameTextField resignFirstResponder];
        
        NSString *nameNew = self.nameTextField.text;
        nameNew = [BOAssistor stringTrim:nameNew];
        
        self.username = nameNew;
        [self nameLabelSetUsername:nameNew];
        self.nameTextField.text = nameNew;
        
        self.nameTextField.hidden = YES;
        self.nameShowBar.hidden = NO;
    }
}

- (BOOL)userNameAndAvatarChangedCheck
{
    TYDUserInfo *userInfo = [TYDUserInfo sharedUserInfo];
    return (![userInfo.username isEqualToString:self.username]
            || userInfo.avatarID.integerValue != self.avatarID.integerValue);
}

- (void)saveUserNameAndAvatarLocal
{
    TYDUserInfo *userInfo = [TYDUserInfo sharedUserInfo];
    userInfo.username = self.username;
    userInfo.avatarID = self.avatarID;
    [userInfo saveUserInfo];
}

#pragma mark - OverrideSettingMethod

- (void)setSelectedAvatarView:(UIView *)selectedAvatarView
{
    if(_selectedAvatarView != selectedAvatarView
       && selectedAvatarView)
    {
        _selectedAvatarView = selectedAvatarView;
        self.selectedCircle.hidden = NO;
        self.selectedCircle.center = selectedAvatarView.center;
        
        NSUInteger avatarIndex = [self.avatarViews indexOfObject:selectedAvatarView];
        self.avatarID = @(avatarIndex);
    }
}

#pragma mark - TouchEvent

- (void)textFiledEditDidBegin:(UITextField *)sender
{
    self.nameShowBar.hidden = YES;
    self.nameTextField.hidden = NO;
}

- (void)textFiledEditEndOnExit:(UITextField *)sender
{
    [self textFielsEditNameFinished];
}

- (void)selectedOneAvatar:(UIGestureRecognizer *)sender
{
    NSLog(@"selectedOneAvatar");
    [self textFielsEditNameFinished];
    self.selectedAvatarView = sender.view;
}

- (void)nameBarTap:(id)sender
{
    NSLog(@"nameBarTap");
    if(![self.nameTextField isFirstResponder])
    {
        self.nameShowBar.hidden = YES;
        self.nameTextField.hidden = NO;
        [self.nameTextField becomeFirstResponder];
    }
}

- (void)tapOnSpace:(id)sender
{
    [self textFielsEditNameFinished];
}

- (void)saveButtonTap:(UIButton *)sender
{
    NSLog(@"saveButtonTap");
    [self textFielsEditNameFinished];
    [self saveUserNameAndAvatar];
}

- (void)popBackEventWillHappen
{
    [self textFielsEditNameFinished];
    if([self userNameAndAvatarChangedCheck])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:sUserInfoModifiedInquireToSave delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    }
    else
    {
        [super popBackEventWillHappen];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if([alertView.message isEqualToString:sUserInfoModifiedInquireToSave])
    {
        if(buttonIndex == alertView.firstOtherButtonIndex)
        {
            [self saveUserNameAndAvatar];
        }
        else
        {
            [super popBackEventWillHappen];
        }
    }
}

#pragma mark - ConnectToServer

- (void)saveUserNameAndAvatar
{
    NSString *message = nil;
    if(![self networkIsValid])
    {
        message = sNetworkFailed;
    }
    else if(![BOAssistor usernameIsValid:self.username])
    {
        message = sUsernameFormatInvalidNotice;
    }
    
    if(message)
    {
        [self setNoticeText:message];
        return;
    }
    self.saveButton.enabled = NO;
    
    TYDUserInfo *userInfo = [TYDUserInfo sharedUserInfo];
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:userInfo.userID forKey:sPostUrlRequestUserAcountKey];
    [params setValue:self.username forKey:@"name"];
    [params setValue:self.avatarID forKey:@"headimgId"];
    
    [self postURLRequestWithMessageCode:ServiceMsgCodeUserInfoUpload
                           HUDLabelText:nil
                                 params:params
                          completeBlock:^(id result) {
                              [self saveUsernameAndAvatarComplete:result];
                          }];
}

#pragma mark - ServerConnectionReceipt

- (void)postURLRequestFailed:(NSUInteger)msgCode result:(id)result
{
    [super postURLRequestFailed:msgCode result:result];
    if(msgCode == ServiceMsgCodeUserInfoUpload)
    {
        self.saveButton.enabled = YES;
    }
}

- (void)saveUsernameAndAvatarComplete:(id)result
{
    NSLog(@"saveUsernameAndAvatarComplete:%@", result);
    NSNumber *errorCode = result[@"errorCode"];
    if(errorCode.intValue == 0)
    {
        NSNumber *resultNumber = result[@"result"];
        if(resultNumber.intValue == 0)
        {
            [self saveUserNameAndAvatarLocal];
            [self showProgressCompleteWithLabelText:@"保存完成" isSucceed:YES additionalTarget:self.navigationController action:@selector(popViewControllerAnimated:) object:@(YES)];
            return;
        }
    }
    
    self.saveButton.enabled = YES;
    [self showProgressCompleteWithLabelText:@"保存失败" isSucceed:NO];
}

@end
