//
//  TYDLoginViewController.m
//  Mofei
//
//  Created by macMini_Dev on 14-9-22.
//  Copyright (c) 2014年 Young. All rights reserved.
//
//  登录页
//

#import "TYDLoginViewController.h"
#import "TYDEnrollViewController.h"
#import "TYDFindPwdViewController.h"
#import "TYDAccountManagePostHttpRequest.h"
#import <QuartzCore/QuartzCore.h>

#import "SBJson.h"
#import "NSString+MD5Addition.h"

#import "OpenPlatformAppRegInfo.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/TencentApiInterface.h>
#import "WeiboSDK.h"

#import "CoreDataManager.h"
#import "WalkStepEntity.h"
#import "HeartRateEntity.h"
#import "MensesInfoEntity.h"
#import "TYDDataCenter.h"
#import "TYDMensesDataCenter.h"
#import "TYDBasicInfoConverter.h"
#import "TYDFileResourceManager.h"
#import "TYDBLEDeviceManager.h"

#define sSinaWeiboGetUserInfoTag        @"sinaWeiboGetUserInfo"

@interface TYDLoginViewController () <TencentSessionDelegate, WBHttpRequestDelegate, LoginCloudSynchronizeEventDelegate, TYDEnrollViewControllerDelegate>

@property (strong, nonatomic) UIButton *enrollButton;

@property (strong, nonatomic) TencentOAuth *tencentOAuth;
@property (strong, nonatomic) NSString *sinaWeiboToken;
//@property (strong, nonatomic) NSString *avatarPath;

@property (strong, nonatomic) NSString *userIDTemple;
@property (strong, nonatomic) NSString *usernameTemple;
@property (strong, nonatomic) NSNumber *userGenderTemple;

@property (strong, nonatomic) NSMutableDictionary *userInfoTemple;
@property (nonatomic) BOOL isEnrollSucceed;

@property (strong, nonatomic) UIButton *qqIconButton;
@property (strong, nonatomic) UILabel *qqIconLabel;

@end

@implementation TYDLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self localDataInitialize];
    [self navigationBarItemsLoad];
    [self subviewsLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self qqAppCheck];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(self.isEnrollSucceed)
    {
        self.isEnrollSucceed = NO;
        [self login];
    }
}

- (void)localDataInitialize
{
    //self.avatarPath = nil;
    self.sinaWeiboToken = nil;
    
    self.userIDTemple = @"";
    self.usernameTemple = @"";
    self.userGenderTemple = [TYDUserInfo userGenderWithGenderString:@"女"];
    [TYDFileResourceManager defaultManager].loginDelegate = self;
    self.isEnrollSucceed = NO;
}

- (void)navigationBarItemsLoad
{
    self.title = @"登录";
    
    UIButton *enrollButton = [UIButton new];
    [enrollButton setTitle:@"注册" forState:UIControlStateNormal];
    [enrollButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [enrollButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [enrollButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [enrollButton addTarget:self action:@selector(enrollButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    [enrollButton sizeToFit];
    UIBarButtonItem *enrollBtnItem = [[UIBarButtonItem alloc] initWithCustomView:enrollButton];
    self.navigationItem.rightBarButtonItem = enrollBtnItem;
    self.enrollButton = enrollButton;
}

- (void)subviewsLoad
{
    [self logoImageViewLoad];
    [self inputViewsLoad];
    [self buttonViewsLoad];
}

- (void)logoImageViewLoad
{
    UIView *baseView = self.baseView;
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_logo"]];
    logoImageView.center = baseView.innerCenter;
    logoImageView.top = 40;
    [baseView addSubview:logoImageView];
    
    self.baseViewBaseHeight = logoImageView.bottom + 20;
}

- (void)inputViewsLoad
{
    CGFloat top = self.baseViewBaseHeight;
    CGFloat sideOffset = 28;
    CGFloat innerOffserHor = 12;
    CGFloat iconLeftOffset = 8;
    
    CGRect frame = CGRectMake(sideOffset, top, self.baseView.width - sideOffset * 2, 10);
    UIControl *baseView = [[UIControl alloc] initWithFrame:frame];
    baseView.backgroundColor = [UIColor clearColor];
    [baseView addTarget:self action:@selector(tapOnSpace:) forControlEvents:UIControlEventTouchUpInside];
    [self.baseView addSubview:baseView];
    
    UIImageView *avatarIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_avatarIcon"]];
    [baseView addSubview:avatarIcon];
    UIImageView *lockIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_lockIcon"]];
    [baseView addSubview:lockIcon];
    
    UIView *grayLine1 = [UIView new];
    grayLine1.size = CGSizeMake(baseView.width, 0.5);
    grayLine1.backgroundColor = [UIColor colorWithHex:0xe1e1e1];
    [baseView addSubview:grayLine1];
    
    UIView *grayLine2 = [UIView new];
    grayLine2.size = grayLine1.size;
    grayLine2.backgroundColor = grayLine1.backgroundColor;
    [baseView addSubview:grayLine2];
    
    UIFont *textFont = [UIFont fontWithName:@"Arial" size:14];
    UIColor *textColor = [UIColor colorWithHex:0x323232];
    UIColor *tintColor = [UIColor colorWithHex:0xe23674];
    CGSize textFieldSize = CGSizeMake(baseView.width - avatarIcon.width - iconLeftOffset - innerOffserHor, 30);
    
    UITextField *accountTextField = [UITextField new];
    accountTextField.placeholder = @"请输入账号";
    accountTextField.font = textFont;
    accountTextField.textColor = textColor;
    accountTextField.borderStyle = UITextBorderStyleNone;
    accountTextField.returnKeyType = UIReturnKeyNext;//Return键
    accountTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    accountTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    accountTextField.secureTextEntry = NO;
    accountTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    accountTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    accountTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    accountTextField.size = textFieldSize;
    [baseView addSubview:accountTextField];
    
    UITextField *passwordTextField = [UITextField new];
    passwordTextField.placeholder = @"请输入密码";
    passwordTextField.font = textFont;
    passwordTextField.textColor = textColor;
    passwordTextField.borderStyle = UITextBorderStyleNone;
    passwordTextField.returnKeyType = UIReturnKeyDone;
    passwordTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    passwordTextField.secureTextEntry = YES;
    passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    passwordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    passwordTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    passwordTextField.size = textFieldSize;
    [baseView addSubview:passwordTextField];
    
    if([accountTextField respondsToSelector:@selector(tintColor)])
    {
        accountTextField.tintColor = tintColor;
        passwordTextField.tintColor = tintColor;
    }
    
    [accountTextField addTarget:self action:@selector(textFiledEditEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [passwordTextField addTarget:self action:@selector(textFiledEditEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [passwordTextField addTarget:self action:@selector(passwordTextFiledDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self.textFields appendOneTextField:accountTextField];
    [self.textFields appendOneTextField:passwordTextField];
    
    grayLine1.left = 0;
    grayLine2.left = 0;
    avatarIcon.left = iconLeftOffset;
    lockIcon.left = iconLeftOffset;
    accountTextField.left = avatarIcon.right + innerOffserHor;
    passwordTextField.left = accountTextField.left;
    
    accountTextField.top = 0;
    avatarIcon.yCenter = accountTextField.yCenter;
    grayLine1.top = accountTextField.bottom + 2;
    passwordTextField.top = grayLine1.bottom + 16;
    lockIcon.yCenter = passwordTextField.yCenter;
    grayLine2.top = passwordTextField.bottom + 2;
    
    UIButton *findPasswordButton = [UIButton new];
    findPasswordButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [findPasswordButton setTitle:@" 找回密码 " forState:UIControlStateNormal];
    [findPasswordButton setTitleColor:[UIColor colorWithHex:0xcbcbcb] forState:UIControlStateNormal];
    [findPasswordButton setTitleColor:[UIColor colorWithHex:0xe23674] forState:UIControlStateHighlighted];
    [findPasswordButton addTarget:self action:@selector(findPasswordButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    [findPasswordButton sizeToFit];
    findPasswordButton.top = grayLine2.bottom;
    findPasswordButton.right = baseView.width;
    [baseView addSubview:findPasswordButton];
    
    baseView.height = findPasswordButton.bottom;
    self.baseViewBaseHeight = baseView.bottom;
}

- (void)buttonViewsLoad
{
    CGFloat top = self.baseViewBaseHeight;
    UIView *baseView = self.baseView;
    CGPoint center = baseView.innerCenter;
    
    UIEdgeInsets capInsets = UIEdgeInsetsMake(19, 20, 19, 20);
    UIButton *loginButton = [[UIButton alloc] initWithImageName:@"login_btn" highlightedImageName:@"login_btnH" capInsets:capInsets givenButtonSize:CGSizeMake(280, 40) title:@"登  录" titleFont:[UIFont fontWithName:@"Arial" size:18] titleColor:[UIColor colorWithHex:0xe23674]];
    [loginButton addTarget:self action:@selector(loginButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    loginButton.center = center;
    loginButton.top = top + 30;
    [baseView addSubview:loginButton];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont systemFontOfSize:12];
    titleLabel.textColor = [UIColor colorWithHex:0xacacac];
    titleLabel.text = @"第三方账号登录";
    [titleLabel sizeToFit];
    titleLabel.center = center;
    titleLabel.top = loginButton.bottom + 50;
    [baseView addSubview:titleLabel];
    
    UIButton *qqIconButton = [[UIButton alloc] initWithImageName:@"login_qqBtn" highlightedImageName:@"login_qqBtnH"];
    [qqIconButton setImage:[UIImage imageNamed:@"login_qqBtnDis"] forState:UIControlStateDisabled];
    [qqIconButton addTarget:self action:@selector(qqIconButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    [baseView addSubview:qqIconButton];
    
    UIButton *sinaWeiboIconButton = [[UIButton alloc] initWithImageName:@"login_sinaWeiboBtn" highlightedImageName:@"login_sinaWeiboBtnH"];
    [sinaWeiboIconButton addTarget:self action:@selector(sinaWeiboIconButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    [baseView addSubview:sinaWeiboIconButton];
    
    qqIconButton.top = titleLabel.bottom + 24;
    sinaWeiboIconButton.top = qqIconButton.top;
    qqIconButton.left = (baseView.width - qqIconButton.width - sinaWeiboIconButton.width) * 2 / 5;
    sinaWeiboIconButton.right = baseView.width - qqIconButton.left;
    
    UILabel *qqLabel = [UILabel new];
    qqLabel.backgroundColor = [UIColor clearColor];
    qqLabel.size = CGSizeMake(qqIconButton.left,20);
    qqLabel.text = @"QQ登陆";
    qqLabel.textAlignment = NSTextAlignmentCenter;
    qqLabel.font = [UIFont systemFontOfSize:12];
    qqLabel.textColor = [UIColor colorWithHex:0xacacac];
    [baseView addSubview:qqLabel];
    
    UILabel *sinaLabel = [UILabel new];
    sinaLabel.backgroundColor = [UIColor clearColor];
    sinaLabel.size = qqLabel.size;
    sinaLabel.text = @"微博登陆";
    sinaLabel.textAlignment = NSTextAlignmentCenter;
    sinaLabel.font = [UIFont systemFontOfSize:12];
    sinaLabel.textColor = [UIColor colorWithHex:0xacacac];
    [baseView addSubview:sinaLabel];
    
    qqLabel.center = CGPointMake(qqIconButton.xCenter,qqIconButton.bottom+10);
    sinaLabel.yCenter =qqLabel.yCenter;
    sinaLabel.left = qqLabel.right + baseView.width-2*(qqLabel.width+qqLabel.left);
    self.baseViewBaseHeight = qqIconButton.bottom + 20;
    
    self.qqIconButton = qqIconButton;
    self.qqIconLabel = qqLabel;
}

- (void)qqAppCheck
{
    if(![TencentOAuth iphoneQQInstalled])
    {
        if(self.qqIconButton.enabled)
        {
            self.qqIconButton.enabled = NO;
            
            CGPoint center = self.qqIconLabel.center;
            self.qqIconLabel.text = @"未安装QQ";
            [self.qqIconLabel sizeToFit];
            self.qqIconLabel.center = center;
        }
    }
    else
    {
        if(!self.qqIconButton.enabled)
        {
            self.qqIconButton.enabled = YES;
            
            CGPoint center = self.qqIconLabel.center;
            self.qqIconLabel.text = @"QQ登陆";
            [self.qqIconLabel sizeToFit];
            self.qqIconLabel.center = center;
        }
    }
}

#pragma mark - TouchEvent

- (void)enrollButtonTap:(UIButton *)sender
{
    NSLog(@"enrollButtonTap");
    [self.textFields allTextFieldsResignFirstResponder];
    TYDEnrollViewController *vc = [TYDEnrollViewController new];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)findPasswordButtonTap:(UIButton *)sender
{
    NSLog(@"findPasswordButtonTap");
    [self.textFields allTextFieldsResignFirstResponder];
    TYDFindPwdViewController *vc = [TYDFindPwdViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)loginButtonTap:(UIButton *)sender
{
    NSLog(@"loginButtonTap");
    [self.textFields allTextFieldsResignFirstResponder];
    [self login];
}

- (void)qqIconButtonTap:(UIButton *)sender
{
    NSLog(@"qqIconButtonTap");
    [self.textFields allTextFieldsResignFirstResponder];
    
//    if(![TencentOAuth iphoneQQInstalled])
//    {
//        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"你还没有安装QQ，需要安装QQ后才能使用" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//        [alertView show];
//        return;
//    }
    
    [self showProgressHUDWithLabelText:nil];
    if(![self networkIsValid])
    {
        [self hiddenProgressHUD];
        [self setNoticeText:sNetworkFailed];
        return;
    }
    
    [self performSelectorOnMainThread:@selector(authorizeQQToLogin) withObject:nil waitUntilDone:YES];
    //[self authorizeQQToLogin];
}

- (void)sinaWeiboIconButtonTap:(UIButton *)sender
{
    NSLog(@"sinaWeiboIconButtonTap");
    [self.textFields allTextFieldsResignFirstResponder];
    [self showProgressHUDWithLabelText:nil];
    
    if(![self networkIsValid])
    {
        [self hiddenProgressHUD];
        [self setNoticeText:sNetworkFailed];
        return;
    }
    
    [self performSelectorOnMainThread:@selector(authorizeSinaWeiboToLogin) withObject:nil waitUntilDone:YES];
    //[self authorizeSinaWeiboToLogin];
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

//登录
//lapi/login
//
//base_param:
//
//uid:用户名
//passwd:密码的MD5值
//utype:[zhuoyou]
//devinfo:设备信息
//sign:签名
//
//签名计算：[uid passwd utype devinfo]

- (void)login
{
    NSString *account = [self.textFields objectInTextFieldsAtIndex:0].text;
    NSString *password = [self.textFields objectInTextFieldsAtIndex:1].text;
    
    NSString *message = nil;
    if(![self networkIsValid])
    {
        message = sNetworkFailed;
    }
    else if(account.length == 0
            || password.length == 0)
    {
        message = @"请输入账号及密码";
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
        password = password.MD5String;
        NSString *userType = sLoginUserTypeZhuoyou;
        NSString *deviceInfo = [TYDAccountManagePostHttpRequest deviceInfoEncode:[BOAssistor deviceUDID]];
        NSString *sign = [TYDAccountManagePostHttpRequest signInfoCreateWithInfos:@[account, password, userType, deviceInfo]];
        
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:account forKey:@"uid"];
        [params setValue:password forKey:@"passwd"];
        [params setValue:userType forKey:@"utype"];
        [params setValue:deviceInfo forKey:@"devinfo"];
        [params setValue:sign forKey:@"sign"];
        
        [self showProgressHUDWithLabelText:nil];
        [TYDAccountManagePostHttpRequest amRequestWithURL:sAMServiceUrlLogin
                                                   params:params
                                            completeBlock:^(id result) {
                                                [self loginComplete:result];
                                            }
                                              failedBlock:^(NSString *url, id result) {
                                                  [self amPostHttpRequestFailed:url result:result];
                                              }];
    }
}

//授权第三方登录
//lapi/auth
//
//base_param:
//
//uid:用户名
//passwd:密码
//utype:用户类型[openqq,openweibo]
//data:用户数据
//sign:签名
//
//opt_param:
//
//openid:卓悠ID
//token:令牌
//devinfo:设备信息
//
//签名计算：[uid passwd utype data openid token devinfo]

- (void)authorizeWithInfo:(NSMutableDictionary *)info
{
    if(!self.networkIsValid)
    {
        //self.avatarPath = nil;
        [self setNoticeText:sNetworkFailed];
        [self hiddenProgressHUD];
        return;
    }
    
    [TYDAccountManagePostHttpRequest amRequestWithURL:sAMServiceUrlAuthorize
                                               params:info
                                        completeBlock:^(id result) {
                                            [self authorizeComplete:result];
                                        }
                                          failedBlock:^(NSString *url, id result) {
                                              [self amPostHttpRequestFailed:url result:result];
                                          }];
}

//与默菲服务器交互
- (void)userInfoDownloadWithUserID:(NSString *)userID
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:userID forKey:sPostUrlRequestUserAcountKey];
    
    [self postURLRequestWithMessageCode:ServiceMsgCodeUserInfoDownload
                           HUDLabelText:nil
                                 params:params
                          completeBlock:^(id result) {
                              [self userInfoDownloadComplete:result];
                          }];
}

- (void)userInfoUpload
{
    TYDUserInfo *defaultUserInfo = [TYDUserInfo sharedUserInfo];
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:self.userIDTemple forKey:sPostUrlRequestUserAcountKey];
    [params setValue:self.userGenderTemple forKey:@"sex"];
    [params setValue:self.usernameTemple forKey:@"name"];
    [params setValue:defaultUserInfo.birthday forKey:@"age"];
    [params setValue:defaultUserInfo.height forKey:@"height"];
    [params setValue:defaultUserInfo.weight forKey:@"weight"];
    [params setValue:defaultUserInfo.sportTarget forKey:@"sportsTarget"];
    [params setValue:defaultUserInfo.mensesBloodDuration forKey:@"avgMenses"];
    [params setValue:defaultUserInfo.mensesDuration forKey:@"avgPeriod"];
    [params setValue:defaultUserInfo.avatarID forKey:@"headimgId"];
    
    self.userInfoTemple = [params mutableCopy];
    
    NSDictionary *infoFixDic = [TYDBasicInfoConverter basicInfoConvertToServerInfo:params];
    [params setValuesForKeysWithDictionary:infoFixDic];
    
    [self postURLRequestWithMessageCode:ServiceMsgCodeUserInfoUpload
                           HUDLabelText:nil
                                 params:params
                          completeBlock:^(id result) {
                              [self userInfoUploadComplete:result];
                          }];
}

#pragma mark - ServerConnectionReceipt

- (void)amPostHttpRequestFailed:(NSString *)url result:(id)result
{
    [self hiddenProgressHUD];
    [self setNoticeText:sNetworkError];
    
    NSError *error = result;
    NSLog(@"amPostHttpRequestFailed! url:%@, Error - %@ %@", url, [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)loginComplete:(id)result
{
    NSLog(@"loginComplete:%@", result);
    NSNumber *resultStatus = [result objectForKey:@"result"];
    if(resultStatus.intValue == 0)
    {
        NSString *userID = [result objectForKey:@"openid"];
        NSString *username = [result objectForKey:@"nickname"];//@"username"
        NSString *gender = [result objectForKey:@"gender"];
        
        if(username.length == 0)
        {
            username = sUserNameDefault;
        }
        
        self.userIDTemple = userID;
        self.usernameTemple = username;
        self.userGenderTemple = [TYDUserInfo userGenderWithGenderString:gender];
        
        [self userInfoDownloadWithUserID:userID];
    }
    else
    {
        NSString *resultDescription = [result objectForKey:@"desc"];
        [self setNoticeText:resultDescription];
        [self hiddenProgressHUD];
    }
}

- (void)authorizeComplete:(id)result
{
    NSLog(@"authorizeComplete:%@", result);
//    NSString *avatarPath = self.avatarPath;
//    self.avatarPath = nil;
    
    NSNumber *resultStatus = [result objectForKey:@"result"];
    if(resultStatus.intValue == 0)
    {
        NSString *userID = [result objectForKey:@"openid"];
        NSString *username = [result objectForKey:@"nickname"];
        NSString *gender = [result objectForKey:@"gender"];
        if(username.length == 0)
        {
            username = [result objectForKey:@"openweibo"];
            username = [NSString stringWithFormat:@"微博用户%@", username];
        }
        
        self.userIDTemple = userID;
        self.usernameTemple = username;
        self.userGenderTemple = [TYDUserInfo userGenderWithGenderString:gender];
        
        [self userInfoDownloadWithUserID:userID];
    }
    else
    {
        NSString *resultDescription = [result objectForKey:@"desc"];
        [self setNoticeText:resultDescription];
        [self hiddenProgressHUD];
    }
}

- (void)userInfoDownloadComplete:(id)result
{
    NSLog(@"userInfoDownloadComplete:%@", result);
    NSNumber *errorCode = result[@"errorCode"];
    if(errorCode && errorCode.intValue == 0)
    {
        NSNumber *resultNumber = result[@"result"];
        if(resultNumber && resultNumber.intValue != 0)
        {//数据库无此账号，本地上传
            [self userInfoUpload];
        }
        else//(resultNumber.intValue == 0)
        {//有资料，则保存在本地
            NSMutableDictionary *userInfoDic = [result[@"accountForm"] mutableCopy];
            NSDictionary *appendDic = [TYDBasicInfoConverter serverInfoConvertToBasicInfo:userInfoDic];
            [userInfoDic setValuesForKeysWithDictionary:appendDic];
            self.userInfoTemple = userInfoDic;
            
            [self loginCloudSynchronize];
        }
    }
    else
    {
        [self setNoticeText:@"登录失败"];
        [self hiddenProgressHUD];
    }
}

- (void)userInfoUploadComplete:(id)result
{
    NSLog(@"userInfoUploadComplete:%@", result);
    NSNumber *errorCode = result[@"errorCode"];
    if(errorCode && errorCode.intValue == 0)
    {
        NSNumber *resultNumber = result[@"result"];
        if(resultNumber && resultNumber.intValue == 0)
        {
            [self loginCloudSynchronize];
            return;
        }
    }
    
    [self hiddenProgressHUD];
    [self setNoticeText:@"登录失败"];
}

#pragma mark - loginCloudSynchronize

- (void)loginCloudSynchronize
{
    //if([TYDFileResourceManager defaultManager].isInCloudSynchronizeDuration)
    if([TYDDataCenter defaultCenter].cloudSynchronizeLocked)
    {
        [self hiddenProgressHUD];
        [self setNoticeText:@"登录失败"];
    }
    else
    {
        //用于同步数据存储时，获取用户ID
        [TYDUserInfo sharedUserInfo].userID = self.userIDTemple;
        
        [TYDDataCenter defaultCenter].cloudSynchronizeLocked = YES;
        [[TYDFileResourceManager defaultManager] cloudSynchronizeWhenUserLogin];
    }
}

#pragma mark - LoginCloudSynchronizeEventDelegate

- (void)loginCloudSynchronizeEventComplete:(BOOL)succeed
{
    if(succeed)
    {
        [[TYDDataCenter defaultCenter] dataCenterRefreshWhenLoginCloudSynchronizeComplete];
        
        TYDUserInfo *userInfo = [TYDUserInfo sharedUserInfo];
        [userInfo setAttributes:self.userInfoTemple];
        [userInfo saveUserInfo];
        
        [self showProgressCompleteWithLabelText:@"登录成功" isSucceed:YES additionalTarget:self action:@selector(popBackEventWillHappen) object:nil];
    }
    else
    {
        [TYDUserInfo sharedUserInfo].userID = @"";
        [self hiddenProgressHUD];
        [self setNoticeText:@"登录失败"];
    }
    [TYDDataCenter defaultCenter].cloudSynchronizeLocked = NO;
}

#pragma mark - AuthLogin

- (void)authorizeQQToLogin
{
    if(!self.tencentOAuth)
    {
        self.tencentOAuth = [[TencentOAuth alloc] initWithAppId:sShareSDKQQAppId andDelegate:self];
        self.tencentOAuth.redirectURI = sShareSDKQQRedirectUri;
    }
    [self.tencentOAuth authorize:@[kOPEN_PERMISSION_GET_USER_INFO]];
    
//    @"退出登录";
//    [self.tencentOAuth logout:self];
//    登录常见错误码信息
//    110201：未登录
//    110405：登录请求被限制
//    110404：请求参数缺少appid
//    110401：请求的应用不存在
//    110407：应用已经下架
//    110406：应用没有通过审核
}

- (void)authorizeSinaWeiboToLogin
{
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = sShareSDKSinaWeiboRedirectUri;
    request.scope = @"all";
    request.userInfo = @{@"SSO_Authorize":@"Mofei"};

    [WeiboSDK sendRequest:request];
}

#pragma mark - TencentSessionDelegate

- (void)tencentDidNotNetWork
{
    [self setNoticeText:@"无网络连接，请设置网络"];
}

- (void)tencentDidLogin
{
    //[self setNoticeText:@"登录成功"];
	
    if(self.tencentOAuth.accessToken.length > 0)
    {
        if(![self.tencentOAuth getUserInfo])
        {
            [self setNoticeText:@"登录不成功"];
            [self hiddenProgressHUD];
        }
    }
    else
    {
        //@"登录不成功 没有获取accesstoken";
        [self setNoticeText:@"登录不成功"];
        [self hiddenProgressHUD];
    }
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{
    if(cancelled)
    {
        [self setNoticeText:@"用户取消登录"];
	}
	else
    {
		[self setNoticeText:@"登录失败"];
	}
    [self hiddenProgressHUD];
}

- (void)tencentDidLogout
{
    //@"退出登录成功，请重新登录";
    [self setNoticeText:@"退出登录成功，请重新登录"];
    [self hiddenProgressHUD];
}

- (void)getUserInfoResponse:(APIResponse *)response
{
    //@"获取个人信息完成"
	if(response.retCode == URLREQUEST_SUCCEED)
	{
        SBJsonWriter *jsonWriter = [SBJsonWriter new];
        NSDictionary *jsonResponseDic = response.jsonResponse;
        NSLog(@"QQUserInfo:%@", jsonResponseDic);
        
        NSString *userID = self.tencentOAuth.openId;
        NSString *password = self.tencentOAuth.accessToken;
        NSString *utype = sAuthUserTypeQQ;
        
        NSString *nickname = jsonResponseDic[@"nickname"];
        NSString *gender = jsonResponseDic[@"gender"];
        NSString *avatarUrl = jsonResponseDic[@"figureurl_qq_2"];
        NSDictionary *userDataDic = @{@"gender":gender, @"nickname":nickname, @"avatarurl":avatarUrl};
        NSString *userDataJsonString = [jsonWriter stringWithObject:userDataDic];
        NSString *sign = [TYDAccountManagePostHttpRequest signInfoCreateWithInfos:@[userID, password, utype, userDataJsonString]];
        
        NSMutableDictionary *params = [NSMutableDictionary new];
        [params setValue:userID forKey:@"uid"];
        [params setValue:password forKey:@"passwd"];
        [params setValue:utype forKey:@"utype"];
        [params setValue:userDataJsonString forKey:@"data"];
        [params setValue:sign forKey:@"sign"];
        
        //self.avatarPath = avatarUrl;
        [self authorizeWithInfo:params];
	}
	else
    {
        [self setNoticeText:@"用户信息获取失败"];
        [self hiddenProgressHUD];
	}
}

- (void)tencentOAuth:(TencentOAuth *)tencentOAuth doCloseViewController:(UIViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - SinaWeiboAuthResponsePassBack

- (void)setSinaWeiboAuthResponse:(WBAuthorizeResponse *)authResponse
{
    NSInteger statusCode = authResponse.statusCode;
    NSString *sinaWeiboAuthResultInfo = nil;
    if(statusCode == WeiboSDKResponseStatusCodeSuccess)
    {
        //sinaWeiboAuthResultInfo = @"登录成功";
    }
    else if(statusCode == WeiboSDKResponseStatusCodeUserCancel)
    {
        sinaWeiboAuthResultInfo = @"用户取消登录";
    }
    else if(statusCode == WeiboSDKResponseStatusCodeAuthDeny)
    {
        sinaWeiboAuthResultInfo = @"登录授权被拒绝";
    }
    else
    {
        sinaWeiboAuthResultInfo = @"登录失败";
    }
    
    if(statusCode != WeiboSDKResponseStatusCodeSuccess)
    {
        [self hiddenProgressHUD];
        [self setNoticeText:sinaWeiboAuthResultInfo];
    }
    else
    {
        NSString *token = authResponse.accessToken;
        NSString *userID = authResponse.userID;
        NSString *url = @"https://api.weibo.com/2/users/show.json";
        NSDictionary *params = @{@"access_token":token, @"uid":userID};
        self.sinaWeiboToken = token;
        
        [WBHttpRequest requestWithAccessToken:token
                                          url:url
                                   httpMethod:@"GET"
                                       params:params
                                     delegate:self
                                      withTag:sSinaWeiboGetUserInfoTag];
    }
}

#pragma mark - WBHttpRequestDelegate

- (void)request:(WBHttpRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"SinaWeiboRequestDidFail(%@):%@", request.tag, error.userInfo);
    [self hiddenProgressHUD];
    if([request.tag isEqualToString:sSinaWeiboGetUserInfoTag])
    {
        [self setNoticeText:@"登录失败"];
    }
}

- (void)request:(WBHttpRequest *)request didFinishLoadingWithDataResult:(NSData *)data
{
    if([request.tag isEqualToString:sSinaWeiboGetUserInfoTag])
    {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"sinaWeiboHttpRequest didFinishLoadingWithDataResult:%@", result);
        
        NSNumber *errorCode = result[@"error_code"];
        if(errorCode.integerValue == 20003)
        {
            [self setNoticeText:@"用户微博账号异常！"];
            [self hiddenProgressHUD];
            return;
        }
        
        NSString *token = self.sinaWeiboToken;
        self.sinaWeiboToken = nil;
        
        SBJsonWriter *jsonWriter = [SBJsonWriter new];
        NSString *userID = result[@"idstr"];
        NSString *password = token;
        NSString *utype = sAuthUserTypeWeibo;
        
        NSString *nickname = result[@"screen_name"];
        NSString *gender = result[@"gender"];//性别，m：男、f：女、n：未知
        NSString *avatarUrl = result[@"profile_image_url"];
        if([gender isEqualToString:@"m"])
        {
            gender = @"男";
        }
        else if([gender isEqualToString:@"f"])
        {
            gender = @"女";
        }
        else
        {
            gender = @"未知";
        }
        
        NSDictionary *userDataDic = @{@"gender":gender, @"nickname":nickname, @"avatarurl":avatarUrl};
        NSString *userDataJsonString = [jsonWriter stringWithObject:userDataDic];
        NSString *sign = [TYDAccountManagePostHttpRequest signInfoCreateWithInfos:@[userID, password, utype, userDataJsonString]];
        
        NSMutableDictionary *params = [NSMutableDictionary new];
        [params setValue:userID forKey:@"uid"];
        [params setValue:password forKey:@"passwd"];
        [params setValue:utype forKey:@"utype"];
        [params setValue:userDataJsonString forKey:@"data"];
        [params setValue:sign forKey:@"sign"];
        
        //self.avatarPath = avatarUrl;
        [self authorizeWithInfo:params];
    }
    else
    {
        [self hiddenProgressHUD];
    }
}

#pragma mark - TYDEnrollViewControllerDelegate

- (void)enrollSucceed:(NSString *)account password:(NSString *)password
{
    UITextField *accountTextField = [self.textFields objectInTextFieldsAtIndex:0];
    UITextField *passwordTextField = [self.textFields objectInTextFieldsAtIndex:1];
    accountTextField.text = account;
    passwordTextField.text = password;
    self.isEnrollSucceed = YES;
}

#pragma mark - TYDSuspendEventDelegate

- (void)applicationDidBecomeActive
{
    [self qqAppCheck];
    [self hiddenProgressHUD];
}

@end
