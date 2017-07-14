//
//  TYDMeViewController.m
//  Mofei
//
//  Created by macMini_Dev on 14-8-12.
//  Copyright (c) 2014年 Young. All rights reserved.
//
//  "我的"首页
//

#import "TYDMeViewController.h"
#import "TYDLoginViewController.h"
#import "TYDDeviceManageViewController.h"
#import "TYDMeSettingViewController.h"
#import "TYDAboutViewController.h"
#import "TYDUserInfoSettingController.h"

#import "BOAvatarView.h"
#import "TYDDataCenter.h"
#import "TYDMensesDataCenter.h"
#import "TYDBLEDeviceManager.h"
#import "TYDFileResourceManager.h"
#import "CoreDataManager.h"

typedef NS_ENUM(NSInteger, MeItemIndex)
{
    MeItemIndexUserInfo     = 0,
    MeItemIndexBattery      = 1,
    MeItemIndexCloudSyn     = 2,
    MeItemIndexRemind       = 3,
    MeItemIndexAbout        = 4
};

#define nMeTopBgImageHeight             208

@interface TYDMeViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, TYDBLEDeviceManagerBatteryDelegate, CloudSynchrousEventDelegate, LogoutCloudSynchronizeEventDelegate>

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) BOAvatarView *avaterView;
@property (strong, nonatomic) UILabel *usernameLabel;
@property (strong, nonatomic) UIButton *loginButton;
@property (strong, nonatomic) UIImageView *userInfoEditIcon;

@property (strong, nonatomic) UIButton *logoutButton;
@property (nonatomic) BOOL didUserLogin;
@property (strong, nonatomic) NSArray *itemTitleTexts;
@property (strong, nonatomic) NSMutableArray *itemDetailTexts;

@end

#define sDeviceNotConnect                   @"设备未连接"
#define sConfirmToLogout                    @"注销登录将删除本地数据，是否退出？"
#define sLogoutItemTitle                    @"退出登录"
#define sItemCellIdentifier                 @"meItemCell"
#define sLogoutFailedInquire                @"退出失败，直接退出将丢失未同步数据，是否继续？"

#define sRemindAlertSettingSegueIdentifier  @"remindAlertSettingSegue"

@implementation TYDMeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHex:0xf3f3f4];
    
    [self localDataInitialize];
    [self navigationBarItemsLoad];
    [self subviewsLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self userStatusCheck];
    [self deviceStatusCheck];
    [TYDBLEDeviceManager sharedBLEDeviceManager].batteryDelegate = self;
    self.cloudSynchronizeCell.detailTextLabel.text = self.cloudSynchronizeTimeString;
    
    self.navigationBarTintColor = [UIColor colorWithHex:0xe23674];
    self.tableView.contentOffset = CGPointZero;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //self.noticeBarCenter = CGPointMake(self.view.width * 0.5, self.view.height - 48 - 40);
    self.noticeBarCenter = CGPointMake(self.view.width * 0.5, self.view.height - 40);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [TYDBLEDeviceManager sharedBLEDeviceManager].batteryDelegate = nil;
}

- (void)localDataInitialize
{
    [TYDFileResourceManager defaultManager].delegate = self;
    [TYDFileResourceManager defaultManager].logoutDelegate = self;
    NSString *cloudSynchronizeTimeString = self.cloudSynchronizeTimeString;
    self.itemTitleTexts = @[@"个人信息", @"电池剩余", @"数据云同步", @"久坐提醒", @"关于"];
    self.itemDetailTexts = [@[@"", sDeviceNotConnect, cloudSynchronizeTimeString, sDeviceNotConnect, @""] mutableCopy];
}

- (void)navigationBarItemsLoad
{
    self.title = @"我的";
}

- (void)subviewsLoad
{
    [self tableViewLoad];
    [self tableHeaderViewLoad];
    [self tableFooterViewLoad];
}

- (void)tableViewLoad
{
    CGRect frame = self.view.bounds;
    UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.separatorColor = [UIColor colorWithHex:0xe5e5e6];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    if([tableView respondsToSelector:@selector(separatorInset)])
    {
        [tableView setSeparatorInset:UIEdgeInsetsMake(0.5, 19, 0, 19)];
    }
}

- (void)tableHeaderViewLoad
{
    CGRect frame = self.tableView.bounds;
    frame.size.height = nMeTopBgImageHeight;
    UIView *userInfoView = [[UIView alloc] initWithFrame:frame];
    userInfoView.backgroundColor = [UIColor colorWithHex:0xe23674];
    
    BOAvatarView *avatarView = [[BOAvatarView alloc] initWithAvatarRadius:50];
    avatarView.shadowEnable = NO;
    [userInfoView addSubview:avatarView];
    
    UILabel *usernameLabel = [UILabel new];
    usernameLabel.backgroundColor = [UIColor clearColor];
    usernameLabel.font = [UIFont systemFontOfSize:14];
    usernameLabel.textColor = [UIColor whiteColor];
    usernameLabel.text = @" ";
    [usernameLabel sizeToFit];
    [userInfoView addSubview:usernameLabel];
    
    UIImageView *editIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"me_editIcon"]];
    [userInfoView addSubview:editIcon];
    
    UIEdgeInsets capInsets = UIEdgeInsetsMake(13, 16, 13, 16);
    UIButton *loginButton = [[UIButton alloc] initWithImageName:@"me_loginBtn" highlightedImageName:@"me_loginBtnH" capInsets:capInsets givenButtonSize:CGSizeMake(80, 30) title:@"登录" titleFont:[UIFont systemFontOfSize:16] titleColor:[UIColor whiteColor]];
    [loginButton addTarget:self action:@selector(loginButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    [userInfoView addSubview:loginButton];
    
    CGPoint center = userInfoView.innerCenter;
    avatarView.center = center;
    loginButton.center = center;
    
    CGFloat interval = (userInfoView.height - avatarView.height - loginButton.height) * 0.2;
    avatarView.top =  interval * 2;
    loginButton.top = avatarView.bottom + interval;
    usernameLabel.center = loginButton.center;
    editIcon.bottom = usernameLabel.bottom;
    editIcon.left = usernameLabel.right + 2;
    
    self.avaterView = avatarView;
    self.usernameLabel = usernameLabel;
    self.loginButton = loginButton;
    self.userInfoEditIcon = editIcon;
    
    self.tableView.tableHeaderView = userInfoView;
    
    UITapGestureRecognizer *avatarTapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avtarViewTap:)];
    avatarView.userInteractionEnabled = YES;
    [avatarView addGestureRecognizer:avatarTapGr];
    
    UITapGestureRecognizer *nameLabelTapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(usernameLabelTap:)];
    usernameLabel.userInteractionEnabled = YES;
    [usernameLabel addGestureRecognizer:nameLabelTapGr];
}

- (void)tableFooterViewLoad
{
    CGRect frame = CGRectMake(0, 0, self.tableView.width, 60);
    UIView *footerView = [[UIView alloc] initWithFrame:frame];
    footerView.backgroundColor = [UIColor colorWithHex:0xfcfcff];
    
    UIEdgeInsets capInsets = UIEdgeInsetsMake(19, 20, 19, 20);
    UIButton *logoutButton = [[UIButton alloc] initWithImageName:@"me_logoutBtn" highlightedImageName:@"me_logoutBtnH" capInsets:capInsets givenButtonSize:CGSizeMake(280, 40) title:@"退出账号" titleFont:[UIFont fontWithName:@"Arial" size:18] titleColor:[UIColor colorWithHex:0xe23674]];
    logoutButton.center = footerView.innerCenter;
    logoutButton.hidden = YES;
    [logoutButton addTarget:self action:@selector(logoutButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:logoutButton];
    
    self.tableView.tableFooterView = footerView;
    self.logoutButton = logoutButton;
}

#pragma mark - Check Device Status

- (void)deviceStatusCheck
{
    TYDDataCenter *dataCenter = [TYDDataCenter defaultCenter];
    NSString *batteryInfo = sDeviceNotConnect;
    NSString *remindInfo = sDeviceNotConnect;
    if([TYDBLEDeviceManager sharedBLEDeviceManager].activePeripheralEnable)
    {
        batteryInfo = [NSString stringWithFormat:@"%d%%", (int)dataCenter.batteryLevelCurrentValue];
        
        remindInfo = @"未开启";
        if(dataCenter.remindAlertIsOn)
        {
            remindInfo = [NSString stringWithFormat:@"%d分", (int)(dataCenter.remindAlertInterval / 60)];
        }
    }
    
    [self.itemDetailTexts replaceObjectAtIndex:MeItemIndexBattery withObject:batteryInfo];
    [self.itemDetailTexts replaceObjectAtIndex:MeItemIndexRemind withObject:remindInfo];
    
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:MeItemIndexBattery inSection:0], [NSIndexPath indexPathForRow:MeItemIndexRemind inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - CheckUserStatus

- (void)userStatusCheck
{
    self.didUserLogin = [TYDUserInfo sharedUserInfo].isUserAccountEnable;
    //self.didUserLogin = YES;//Test
}

- (void)setDidUserLogin:(BOOL)didUserLogin
{
    _didUserLogin = didUserLogin;
    TYDUserInfo *userInfo = [TYDUserInfo sharedUserInfo];
    NSString *username = userInfo.username.length > 0 ? userInfo.username : sUserNameDefault;
    if(didUserLogin)
    {
        self.usernameLabel.text = username;
        self.avaterView.image = [UIImage imageNamed:[BOAvatarView avatarNameWithAvatarID:userInfo.avatarID]];
        self.usernameLabel.hidden = NO;
        self.userInfoEditIcon.hidden = NO;
        self.loginButton.hidden = YES;
        self.logoutButton.hidden = NO;
    }
    else
    {
        self.usernameLabel.text = username;
        self.avaterView.image = nil;
        self.usernameLabel.hidden = YES;
        self.userInfoEditIcon.hidden = YES;
        self.loginButton.hidden = NO;
        self.logoutButton.hidden = YES;
    }
    [self.usernameLabel sizeToFit];
    self.usernameLabel.center = self.loginButton.center;
    self.userInfoEditIcon.left = self.usernameLabel.right + 2;
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.itemTitleTexts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = sItemCellIdentifier;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.backgroundColor = [UIColor colorWithHex:0xfcfcff];
    }
    
    NSInteger row = indexPath.row;
    cell.textLabel.text = self.itemTitleTexts[row];
    cell.textLabel.textColor = [UIColor colorWithHex:0x323232];
    cell.textLabel.font = [UIFont fontWithName:@"Arial" size:14];
    
    cell.detailTextLabel.text = self.itemDetailTexts[row];
    cell.detailTextLabel.textColor = [UIColor colorWithHex:0x949494];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Arial" size:11];
    
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"breast_rightArrow"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    switch(row)
    {
        case MeItemIndexRemind:
        {
            //if([TYDFileResourceManager defaultManager].isInCloudSynchronizeDuration)
            if([TYDDataCenter defaultCenter].cloudSynchronizeLocked)
            {
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
            else
            {
                [tableView deselectRowAtIndexPath:indexPath animated:NO];
            }
        }
            break;
        case MeItemIndexUserInfo:
        case MeItemIndexBattery:
        case MeItemIndexCloudSyn:
        case MeItemIndexAbout:
        default:
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            break;
    }
    //if([TYDFileResourceManager defaultManager].isInCloudSynchronizeDuration)
    if([TYDDataCenter defaultCenter].cloudSynchronizeLocked)
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"正在同步数据，请稍候......" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    switch(row)
    {
        case MeItemIndexUserInfo:
        {
            TYDUserInfoSettingController *vc = [TYDUserInfoSettingController new];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case MeItemIndexBattery:
        {
            NSString *title = self.itemDetailTexts[indexPath.row];
            if([title isEqualToString:sDeviceNotConnect])
            {
                TYDDeviceManageViewController *vc = [TYDDeviceManageViewController new];
                [self.navigationController pushViewController:vc animated:YES];
            }
            else
            {
//              [self performSegueWithIdentifier:sRemindAlertSettingSegueIdentifier sender:nil];
                UIAlertView * battery =[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"电池剩余%@",title] message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [battery show];
            }
            break;
        }
        case MeItemIndexCloudSyn:
        {
            [self synchronizeToCloud];
            break;
        }
        case MeItemIndexRemind:
        {
            NSString *title = self.itemDetailTexts[indexPath.row];
            if([title isEqualToString:sDeviceNotConnect])
            {
                TYDDeviceManageViewController *vc = [TYDDeviceManageViewController new];
                [self.navigationController pushViewController:vc animated:YES];
            }
            else
            {
                [self performSegueWithIdentifier:sRemindAlertSettingSegueIdentifier sender:nil];
            }
            break;
        }
        case MeItemIndexAbout:
        {
            TYDAboutViewController *vc = [TYDAboutViewController new];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
    }
}

#pragma mark - TouchEvent

- (void)loginButtonTap:(UIButton *)sender
{
    NSLog(@"loginButtonTap");
    TYDLoginViewController *vc = [TYDLoginViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)logoutButtonTap:(UIButton *)sender
{
    NSLog(@"logoutButtonTap");
    //if([TYDFileResourceManager defaultManager].isInCloudSynchronizeDuration)
    if([TYDDataCenter defaultCenter].cloudSynchronizeLocked)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"消息" message:@"正在同步数据，请稍候......" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"消息" message:sConfirmToLogout delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    }
}

- (void)avtarViewTap:(UIGestureRecognizer *)sender
{
    NSLog(@"avtarViewTap");
    if(self.didUserLogin)
    {
        TYDMeSettingViewController *vc = [TYDMeSettingViewController new];
        vc.isToEditName = NO;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)usernameLabelTap:(UIGestureRecognizer *)sender
{
    NSLog(@"usernameLabelTap");
    if(self.didUserLogin)
    {
        TYDMeSettingViewController *vc = [TYDMeSettingViewController new];
        vc.isToEditName = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - TYDBLEDeviceManagerBatteryDelegate

- (void)deviceBatteryLevelUpdated:(CGFloat)batteryLevel
{
    NSInteger index = MeItemIndexBattery;
    NSIndexPath *batteryItemIndexPath = [NSIndexPath indexPathForRow:MeItemIndexBattery inSection:0];
    int value = MIN(100, (uint)batteryLevel);
    [self.itemDetailTexts replaceObjectAtIndex:index withObject:[NSString stringWithFormat:@"%d%%", value]];
    [self.tableView reloadRowsAtIndexPaths:@[batteryItemIndexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == alertView.firstOtherButtonIndex)
    {
        if([alertView.message isEqualToString:sConfirmToLogout])
        {
            [self userLogout];
        }
        else if([alertView.message isEqualToString:sLogoutFailedInquire])
        {
            [self userLogoutDirectly];
        }
    }
}

#pragma mark - SynchronizeToCloud

- (void)synchronizeToCloud
{
    NSLog(@"SynchronousToCloud");
    TYDUserInfo *userInfo = [TYDUserInfo sharedUserInfo];
    if(!userInfo.isUserAccountEnable)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"账号登录后才能云同步数据" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
    else
    {
        if(self.networkIsValid)
        {
            if([TYDDataCenter defaultCenter].cloudSynchronizeLocked)
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"正在同步数据，请稍候......" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alertView show];
            }
            else
            {
                [[TYDDataCenter defaultCenter] dataCenterRefreshWhenCloudSynchronizeStart];
                [TYDDataCenter defaultCenter].cloudSynchronizeLocked = YES;
                self.cloudSynchronizeCell.detailTextLabel.text = @"正在同步数据";
                [self performSelectorInBackground:@selector(synchronizeToCloudLocal) withObject:nil];
            }
        }
        else
        {
            [self setNoticeText:@"网络不可用"];
        }
    }
}

- (void)synchronizeToCloudLocal
{
    [[TYDFileResourceManager defaultManager] cloudSynchronize];
}

#pragma mark - UserLogout

- (void)userLogout
{
    [self showProgressHUDWithLabelText:nil];
    [[TYDDataCenter defaultCenter] dataCenterRefreshWhenLogoutCloudSynchronizeStart];
    if([TYDDataCenter defaultCenter].cloudSynchronizeLocked)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"正在同步数据，请稍候......" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
    else
    {
        [TYDDataCenter defaultCenter].cloudSynchronizeLocked = YES;
        [[TYDFileResourceManager defaultManager] cloudSynchronizeWhenUserLogout];
    }
}

- (void)userLogoutDirectly
{
    [self clearUserInfoWhenLogout];
    [self setNoticeText:@"登录已注销"];
}

- (void)clearUserInfoWhenLogout
{
    CoreDataManager *coreDataManager = [CoreDataManager defaultManager];
    [coreDataManager deleteAllObjectsWithEntityName:sWalkStepInfoEntityName];
    [coreDataManager deleteAllObjectsWithEntityName:sHeartRateInfoEntityName];
    [coreDataManager deleteAllObjectsWithEntityName:sMensesInfoEntityName];
    
    [[TYDDataCenter defaultCenter] dataCenterRefreshWhenLogoutCloudSynchronizeComplete];
    [[TYDMensesDataCenter defaultCenter] reloadInfosFromDataBase];
    [[TYDUserInfo sharedUserInfo] logout];
    [self userStatusCheck];
}

#pragma mark - LogoutCloudSynchronizeEventDelegate

- (void)logoutCloudSynchronizeEventComplete:(BOOL)succeed
{
    [self hiddenProgressHUD];
    if(succeed)
    {
        self.cloudSynchronizeCell.detailTextLabel.text = self.cloudSynchronizeTimeString;
        [self setNoticeText:@"登录已注销"];
        [self clearUserInfoWhenLogout];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:sLogoutFailedInquire delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    }
    [TYDDataCenter defaultCenter].cloudSynchronizeLocked = NO;
}

#pragma mark - CloudSynchrousEventDelegate

- (NSString *)cloudSynchronizeTimeString
{
    if(![TYDUserInfo sharedUserInfo].isUserAccountEnable)
    {
        return @" ";
    }
    NSInteger markTime = [TYDFileResourceManager defaultManager].cloudSynchronizeMarkTime;
    NSString *noticeString = @"未同步";
    //if([TYDFileResourceManager defaultManager].isInCloudSynchronizeDuration)
    if([TYDDataCenter defaultCenter].cloudSynchronizeLocked)
    {
        noticeString = @"正在同步数据";
    }
    else if(markTime > 0)
    {
        NSInteger currentTime = [BOTimeStampAssistor getCurrentTime];
        NSInteger interval = ABS((currentTime - markTime));
        if(currentTime <= markTime
           || interval < 60)
        {
            noticeString = @"刚刚";
        }
        else
        {
            interval /= 60;//分钟
            if(interval < 60)
            {
                noticeString = [NSString stringWithFormat:@"%d分钟前", (int)interval];
            }
            else
            {
                interval /= 60;//小时
                if(interval < 24)
                {
                    noticeString = [NSString stringWithFormat:@"%d小时前", (int)interval];
                }
                else
                {
                    NSInteger dayInterval = (currentTime - markTime) / nTimeIntervalSecondsPerDay;
                    if(dayInterval < 10)
                    {
                        noticeString = [NSString stringWithFormat:@"%d天前", (int)dayInterval];
                    }
                    else
                    {
                        noticeString = [BOTimeStampAssistor getDateStringWithTimeStamp:markTime];
                    }
                }
            }
        }
    }
    return noticeString;
}

- (UITableViewCell *)cloudSynchronizeCell
{
    return [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:MeItemIndexCloudSyn inSection:0]];
}

//- (void)cloudSynchronizeEventStart
//{
//    NSLog(@"cloudSynchronizeEventStart");
//    self.cloudSynchronizeCell.detailTextLabel.text = @"正在同步数据";
//    [[TYDDataCenter defaultCenter] dataCenterRefreshWhenCloudSynchronizeStart];
//    NSLog(@"cloudSynchronizeEventStart1");
//}

- (void)cloudSynchronizeEventComplete:(BOOL)succeed
{
    NSLog(@"cloudSynchronizeEventComplete:%d", succeed);
    [[TYDDataCenter defaultCenter] dataCenterRefreshWhenCloudSynchronizeComplete];
    NSString *noticeString = succeed ? @"同步完成" : @"同步失败";
    [self setNoticeText:noticeString];
    if(!succeed)
    {
        self.cloudSynchronizeCell.detailTextLabel.text = [self cloudSynchronizeTimeString];
    }
    else
    {
        self.cloudSynchronizeCell.detailTextLabel.text = @"刚刚";
    }
    [TYDDataCenter defaultCenter].cloudSynchronizeLocked = NO;
}

#pragma mark - TYDSuspendEventDelegate

- (void)applicationDidBecomeActive
{
    [self deviceStatusCheck];
}

@end
