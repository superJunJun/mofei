//
//  TYDFindPwdViewController.m
//  Mofei
//
//  Created by macMini_Dev on 14-9-22.
//  Copyright (c) 2014年 Young. All rights reserved.
//
//  找回密码
//

#import "TYDFindPwdViewController.h"
#import "TYDAccountManagePostHttpRequest.h"
#import "OpenPlatformAppRegInfo.h"
#import <QuartzCore/QuartzCore.h>

#define sResetPasswordTokenKey              @"resetPasswordToken"

@interface TYDFindPwdViewController ()

@property (strong, nonatomic) NSString *resetPwdToken;

@end

@implementation TYDFindPwdViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self localDataInitialize];
    [self navigationBarItemsLoad];
    [self subviewsLoad];
}

- (void)localDataInitialize
{
    _resetPwdToken = [[NSUserDefaults standardUserDefaults] stringForKey:sResetPasswordTokenKey];
    if(!_resetPwdToken)
    {
        _resetPwdToken = @"";
    }
}

- (void)navigationBarItemsLoad
{
    self.title = @"找回密码";
}

- (void)subviewsLoad
{
    NSArray *placeholders = @[@"已注册的手机号码", @"验证码", @"新密码"];
    NSInteger itemCount = placeholders.count;
    CGFloat itemHeight = 55;
    CGFloat horOffset = 24;
    
    UIControl *baseView = [[UIControl alloc] initWithFrame:CGRectMake(horOffset, 10, self.view.width - horOffset * 2, itemHeight * itemCount)];
    baseView.backgroundColor = [UIColor clearColor];
    [baseView addTarget:self action:@selector(tapOnSpace:) forControlEvents:UIControlEventTouchUpInside];
    [self.baseView addSubview:baseView];
    
    CGRect frame = CGRectMake(0, 0, baseView.width, 0.5);
    for(int i = 1; i <= itemCount; i++)
    {
        UIView *separatorLine = [[UIView alloc] initWithFrame:frame];
        separatorLine.bottom = itemHeight * i;
        separatorLine.backgroundColor = [UIColor colorWithHex:0xdcdcdd];
        [baseView addSubview:separatorLine];
    }
    
    CGFloat left = 6;
    CGSize textFieldSize = CGSizeMake(baseView.width - left, 30);
    UIFont *textFont = [UIFont fontWithName:@"Arial" size:14];
    UIColor *textColor = [UIColor blackColor];
    UIColor *tintColor = [UIColor colorWithHex:0xe23674];
    
    for(int i = 0; i < itemCount; i++)
    {
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
        textField.left = left;
        textField.bottom = itemHeight * (i + 1) - 2;
        [baseView addSubview:textField];
        
        if([textField respondsToSelector:@selector(tintColor)])
        {
            textField.tintColor = tintColor;
        }
        
        [self.textFields appendOneTextField:textField];
    }
    
    UITextField *vCodeTextField = [self.textFields objectInTextFieldsAtIndex:1];
    UITextField *passwordTextField = [self.textFields objectInTextFieldsAtIndex:2];
    [passwordTextField addTarget:self action:@selector(passwordTextFiledDidChange:) forControlEvents:UIControlEventEditingChanged];
    passwordTextField.returnKeyType = UIReturnKeyDone;
    passwordTextField.secureTextEntry = YES;
    
    UIButton *vCodeButton = [[UIButton alloc] initWithImageName:@"login_vCodeBtn" highlightedImageName:@"login_vCodeBtnH" title:@"获取验证码" titleFont:[UIFont systemFontOfSize:12] titleColor:[UIColor whiteColor]];
    [vCodeButton addTarget:self action:@selector(vCodeButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    vCodeButton.center = vCodeTextField.center;
    vCodeButton.right = baseView.width;
    [baseView addSubview:vCodeButton];
    vCodeTextField.width = vCodeButton.left - vCodeTextField.left - 6;
    
    UIEdgeInsets capInsets = UIEdgeInsetsMake(19, 20, 19, 20);
    UIButton *certainButton = [[UIButton alloc] initWithImageName:@"login_btn" highlightedImageName:@"login_btnH" capInsets:capInsets givenButtonSize:CGSizeMake(280, 40) title:@"确  定" titleFont:[UIFont fontWithName:@"Arial" size:18] titleColor:[UIColor colorWithHex:0xe23674]];
    [certainButton addTarget:self action:@selector(certainButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    certainButton.center = baseView.center;
    certainButton.top = baseView.bottom + 40;
    [self.baseView addSubview:certainButton];
    
    self.baseViewBaseHeight = certainButton.bottom + 40;
}

#pragma mark - Token

- (void)setResetPwdToken:(NSString *)resetPwdToken
{
    if(![_resetPwdToken isEqualToString:resetPwdToken])
    {
        _resetPwdToken = resetPwdToken;
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setValue:resetPwdToken forKey:sResetPasswordTokenKey];
        [userDefaults synchronize];
    }
}

#pragma mark - TouchEvent

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

- (void)vCodeButtonTap:(UIButton *)sender
{
    NSLog(@"vCodeButtonTap");
    [self.textFields allTextFieldsResignFirstResponder];
    [self vCodeObtain];
}

- (void)certainButtonTap:(UIButton *)sender
{
    NSLog(@"certainButtonTap");
    [self.textFields allTextFieldsResignFirstResponder];
    [self findPassword];
}

#pragma mark - ConnectToServer

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
        message = @"请输入手机号";
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
        NSString *vCodeType = sVCodeTypeResetPwd;
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

///lapi/resetpass
//
//base_param:
//
//token:令牌
//passwd:密码
//randcode:验证码
//sign:签名
//
//签名计算：[token passwd rancode]
- (void)findPassword
{
    NSString *vCode = [self.textFields objectInTextFieldsAtIndex:1].text;
    NSString *password = [self.textFields objectInTextFieldsAtIndex:2].text;
    
    NSString *message = nil;
    if(![self networkIsValid])
    {
        message = sNetworkFailed;
    }
    else if(vCode.length == 0
            || password.length == 0)
    {
        message = @"请输入验证码和新密码";
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
        NSString *token = self.resetPwdToken;
        NSString *sign = [TYDAccountManagePostHttpRequest signInfoCreateWithInfos:@[token, password, vCode]];
        
        NSMutableDictionary *params = [NSMutableDictionary new];
        [params setValue:password forKey:@"passwd"];
        [params setValue:vCode forKey:@"randcode"];
        [params setValue:sign forKey:@"sign"];
        [params setValue:token forKey:@"token"];
        
        [self showProgressHUDWithLabelText:nil];
        [TYDAccountManagePostHttpRequest amRequestWithURL:sAMServiceUrlResetPwd
                                                   params:params
                                            completeBlock:^(id result) {
                                                [self findPasswordComplete:result];
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
        self.resetPwdToken = token;
    }
    
    NSString *resultDescription = [result objectForKey:@"desc"];
    [self setNoticeText:resultDescription];
    [self hiddenProgressHUD];
}

- (void)findPasswordComplete:(id)result
{
    NSLog(@"findPasswordComplete:%@", result);
    NSNumber *resultStatus = [result objectForKey:@"result"];
    if(resultStatus.intValue == 0)
    {
        NSString *token = [result objectForKey:@"token"];
        self.resetPwdToken = token;
        
        [self showProgressCompleteWithLabelText:@"密码已重置" isSucceed:YES additionalTarget:self action:@selector(popBackEventWillHappen) object:nil];
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

@end
