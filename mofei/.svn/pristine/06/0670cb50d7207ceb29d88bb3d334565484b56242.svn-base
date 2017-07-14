//
//  TYDEnrollViewController.m
//  Mofei
//
//  Created by macMini_Dev on 14-9-22.
//  Copyright (c) 2014年 Young. All rights reserved.
//
//  用户注册
//

#import "TYDEnrollViewController.h"
#import "TYDAccountManagePostHttpRequest.h"
#import <QuartzCore/QuartzCore.h>

#define sEnrollTokenKey              @"enrollToken"

@interface TYDEnrollViewController ()

@property (strong, nonatomic) NSString *enrollToken;

@end

@implementation TYDEnrollViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self localDataInitialize];
    [self navigationBarItemsLoad];
    [self subviewsLoad];
}

- (void)localDataInitialize
{
    _enrollToken = [[NSUserDefaults standardUserDefaults] stringForKey:sEnrollTokenKey];
    if(!_enrollToken)
    {
        _enrollToken = @"";
    }
}

- (void)navigationBarItemsLoad
{
    self.title = @"注册";
}

- (void)subviewsLoad
{
    NSArray *titles = @[@"账    号：", @"验证码：", @"密    码："];
    NSArray *placeholders = @[@"请输入手机号", @"请输入验证码", @"请输入6~48位密码"];
    NSInteger itemCount = titles.count;
    CGFloat itemHeight = 55;
    
    CGFloat horOffset = 24;
    UIControl *baseView = [[UIControl alloc] initWithFrame:CGRectMake(horOffset, 10, self.baseView.width - horOffset * 2, itemHeight * itemCount)];
    baseView.backgroundColor = [UIColor clearColor];
    [baseView addTarget:self action:@selector(tapOnSpace:) forControlEvents:UIControlEventTouchUpInside];
    [self.baseView addSubview:baseView];
    
    CGRect frame = CGRectMake(0, 0, baseView.width, 0.5);
    for(int i = 1; i <= itemCount; i++)
    {
        UIView *separatorLine = [[UIView alloc] initWithFrame:frame];
        separatorLine.backgroundColor = [UIColor colorWithHex:0xe1e1e1];
        separatorLine.bottom = itemHeight * i;
        [baseView addSubview:separatorLine];
    }
    
    CGFloat leftOffset = 4;
    CGSize textFieldSize = CGSizeMake(baseView.width, 30);
    UIFont *titleFont = [UIFont fontWithName:@"Arial" size:15];
    UIColor *titleColor = [UIColor colorWithHex:0x323232];
    UIFont *textFont = [UIFont fontWithName:@"Arial" size:14];
    UIColor *textColor = [UIColor colorWithHex:0x323232];
    UIColor *tintColor = [UIColor colorWithHex:0xe23674];
    
    for(int i = 0; i < itemCount; i++)
    {
        UILabel *titleLabel = [UILabel new];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = titleFont;
        titleLabel.textColor = titleColor;
        titleLabel.text = titles[i];
        [titleLabel sizeToFit];
        [baseView addSubview:titleLabel];
        
        UITextField *textField = [UITextField new];
        textField.placeholder = placeholders[i];
        textField.font = textFont;
        textField.textColor = textColor;
        textField.borderStyle = UITextBorderStyleNone;
        textField.returnKeyType = UIReturnKeyNext;
        textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.secureTextEntry = NO;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [textField addTarget:self action:@selector(textFiledEditEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
        textField.size = textFieldSize;
        [baseView addSubview:textField];
        
        [self.textFields appendOneTextField:textField];
        if([textField respondsToSelector:@selector(tintColor)])
        {
            textField.tintColor = tintColor;
        }
        
        titleLabel.left = leftOffset;
        textField.left = titleLabel.right + 4;
        textField.width = baseView.width - textField.left;
        textField.bottom = itemHeight * (i + 1) - 4;
        titleLabel.yCenter = textField.yCenter;
    }
    
    UITextField *vCodeTextField = [self.textFields objectInTextFieldsAtIndex:1];
    UITextField *passwordTextField = [self.textFields objectInTextFieldsAtIndex:2];
    [passwordTextField addTarget:self action:@selector(passwordTextFiledDidChange:) forControlEvents:UIControlEventEditingChanged];
    passwordTextField.secureTextEntry = YES;
    passwordTextField.returnKeyType = UIReturnKeyDone;
    
    UIButton *vCodeButton = [[UIButton alloc] initWithImageName:@"login_vCodeBtn" highlightedImageName:@"login_vCodeBtnH" title:@"获取验证码" titleFont:[UIFont systemFontOfSize:12] titleColor:[UIColor whiteColor]];
    [vCodeButton addTarget:self action:@selector(vCodeButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    vCodeButton.center = vCodeTextField.center;
    vCodeButton.right = baseView.width;
    [baseView addSubview:vCodeButton];
    vCodeTextField.width = vCodeButton.left - vCodeTextField.left - 6;
    
    UIEdgeInsets capInsets = UIEdgeInsetsMake(19, 20, 19, 20);
    UIButton *enrollButton = [[UIButton alloc] initWithImageName:@"login_btn" highlightedImageName:@"login_btnH" capInsets:capInsets givenButtonSize:CGSizeMake(280, 40) title:@"注  册" titleFont:[UIFont fontWithName:@"Arial" size:18] titleColor:[UIColor colorWithHex:0xe23674]];
    [enrollButton addTarget:self action:@selector(enrollButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    enrollButton.center = baseView.center;
    enrollButton.top = baseView.bottom + 40;
    [self.baseView addSubview:enrollButton];
    
    self.baseViewBaseHeight = enrollButton.bottom + 20;
}

#pragma mark - TouchEvent

- (void)enrollButtonTap:(UIButton *)sender
{
    NSLog(@"enrollButtonTap");
    [self.textFields allTextFieldsResignFirstResponder];
    [self enroll];
}

- (void)vCodeButtonTap:(UIButton *)sender
{
    NSLog(@"vCodeButtonTap");
    [self.textFields allTextFieldsResignFirstResponder];
    [self vCodeObtain];
}

- (void)textFiledEditEndOnExit:(UITextField *)sender
{
    [self.textFields nextTextFieldBecomeFirstResponder:sender];
}

- (void)passwordTextFiledDidChange:(UITextField *)sender
{
    UITextField *passwordTextField = [self.textFields objectInTextFieldsAtIndex:1];
    if(passwordTextField == sender)
    {
        NSInteger maxLength = 48;
        if(sender.text.length > maxLength)
        {
            sender.text = [sender.text substringToIndex:maxLength];
        }
    }
}

#pragma mark - ConnectToServer

//lapi/signup
//
//base_param:
//
//token:令牌
//passwd:明文密码
//regtype:注册步骤[smsreg,randreg]
//devinfo:设备信息
//sign:签名
//
//opt_param:
//randcode:验证码
//
//签名计算：[token passwd regtype devinfo randcode]

- (void)enroll
{
    NSString *phone = [self.textFields objectInTextFieldsAtIndex:0].text;
    NSString *vCode = [self.textFields objectInTextFieldsAtIndex:1].text;
    NSString *password = [self.textFields objectInTextFieldsAtIndex:2].text;
    //NSString *nickname = [self.textFields objectInTextFieldsAtIndex:3].text;
    
    NSString *message = nil;
    if(![self networkIsValid])
    {
        message = sNetworkFailed;
    }
    else if(phone.length == 0
            || vCode.length == 0
            || password.length == 0
            //|| nickname.length == 0
            )
    {
        message = @"所有输入条目都为必填项";
    }
    else if(![BOAssistor phoneNumberIsValid:phone])
    {
        message = @"请输入有效手机号";
    }
    else if(![BOAssistor passwordLengthIsValid:password])
    {
        message = @"密码长度6~48位";
    }
    
    if(message)
    {
        [self setNoticeText:message];
    }
    else
    {
        NSString *token = self.enrollToken;
        NSString *enrollType = sEnrollTypeVCode;
        NSString *deviceInfo = [TYDAccountManagePostHttpRequest deviceInfoEncode:[BOAssistor deviceUDID]];
        NSArray *signInfos = @[token, password, enrollType, deviceInfo, vCode];
        NSString *sign = [TYDAccountManagePostHttpRequest signInfoCreateWithInfos:signInfos];
        
        NSMutableDictionary *params = [NSMutableDictionary new];
        [params setValue:password forKey:@"passwd"];
        [params setValue:enrollType forKey:@"regtype"];
        [params setValue:deviceInfo forKey:@"devinfo"];
        [params setValue:sign forKey:@"sign"];
        [params setValue:vCode forKey:@"randcode"];
        [params setValue:token forKey:@"token"];
        
        [self showProgressHUDWithLabelText:nil];
        [TYDAccountManagePostHttpRequest amRequestWithURL:sAMServiceUrlEnroll
                                                   params:params
                                            completeBlock:^(id result) {
                                                [self enrollComplete:result];
                                            }
                                              failedBlock:^(NSString *url, id result) {
                                                  [self amPostHttpRequestFailed:url result:result];
                                              }];
    }
}

///lapi/getrandcode
//
//base_param:
//
//uid:手机号
//codetype:验证码 [userreg,resetpasswd,bindmobile]
//sign:签名
//
//opt_param:
//
//token:令牌
//
//签名计算：[uid codetype token]

- (void)vCodeObtain
{
    NSString *phone = [self.textFields objectInTextFieldsAtIndex:0].text;
    
    NSString *message = nil;
    if(![self networkIsValid])
    {
        message = sNetworkFailed;
    }
    else if(phone.length == 0)
    {
        message = @"请输入账号";
    }
    else if(![BOAssistor phoneNumberIsValid:phone])
    {
        message = @"请输入有效手机号";
    }
    
    if(message)
    {
        [self setNoticeText:message];
    }
    else
    {
        NSString *vCodeType = sVCodeTypeEnroll;
        NSString *deviceInfoString = [NSString stringWithFormat:@"{\"packName\":\"%@\"}", [BOAssistor appBundleID]];
        NSString *deviceInfo = [TYDAccountManagePostHttpRequest deviceInfoEncode:deviceInfoString];
        NSString *sign = [TYDAccountManagePostHttpRequest signInfoCreateWithInfos:@[phone, vCodeType]];
        
        NSMutableDictionary *params = [NSMutableDictionary new];
        [params setValue:phone forKey:@"uid"];
        [params setValue:vCodeType forKey:@"codetype"];
        [params setValue:sign forKey:@"sign"];
        [params setValue:deviceInfo forKey:@"devinfo"];
        
        [self showProgressHUDWithLabelText:nil];
        [TYDAccountManagePostHttpRequest amRequestWithURL:sAMServiceUrlVcode
                                                   params:params
                                            completeBlock:^(id result) {
                                                [self vCodeObtainComplete:result];
                                            }
                                              failedBlock:^(NSString *url, id result) {
                                                  [self amPostHttpRequestFailed:url result:result];
                                              }];
    }
}

#pragma mark - ServerConnectionReceipt

- (void)amPostHttpRequestFailed:(NSString *)url result:(id)result
{
    [self hiddenProgressHUD];
    [self setNoticeText:sNetworkError];
    
    NSError *error = result;
    NSLog(@"amPostHttpRequestFailed! url:%@, Error - %@ %@", url, [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)vCodeObtainComplete:(id)result
{
    NSLog(@"vCodeObtainComplete:%@", result);
    NSNumber *resultStatus = [result objectForKey:@"result"];
    if(resultStatus.intValue == 0)
    {
        NSString *token = [result objectForKey:@"token"];
        self.enrollToken = token;
    }
    
    NSString *resultDescription = [result objectForKey:@"desc"];
    [self setNoticeText:resultDescription];
    [self hiddenProgressHUD];
}

/*
 -1001:接口参数错误
 -2001:用户不存在
 -2002:用户已存在
 */
- (void)enrollComplete:(id)result
{
    NSLog(@"enrollComplete:%@", result);
    NSNumber *resultStatus = [result objectForKey:@"result"];
    if(resultStatus.intValue == 0)
    {
        NSString *token = [result objectForKey:@"token"];
        self.enrollToken = token;
        [self passBackInfos];//回传数据以直接登录
        [self showProgressCompleteWithLabelText:@"注册成功" isSucceed:YES additionalTarget:self action:@selector(popBack) object:nil];
    }
    else
    {
        NSString *resultDescription = [result objectForKey:@"desc"];
        if(resultStatus.intValue == -1001)
        {
            resultDescription = @"请先获取有效验证码";
        }
        [self setNoticeText:resultDescription];
        [self hiddenProgressHUD];
    }
}

#pragma mark - popBack

- (void)popBack
{
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - PassBackInfosForImmediatelyLogin

- (void)passBackInfos
{
    if([self.delegate respondsToSelector:@selector(enrollSucceed:password:)])
    {
        NSString *phone = [self.textFields objectInTextFieldsAtIndex:0].text;
        NSString *password = [self.textFields objectInTextFieldsAtIndex:2].text;
        [self.delegate enrollSucceed:phone password:password];
    }
}

@end
