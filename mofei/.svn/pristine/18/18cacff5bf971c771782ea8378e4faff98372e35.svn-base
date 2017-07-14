//
//  TYDAboutViewController.m
//  Mofei
//
//  Created by caiyajie on 14-10-31.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import "TYDAboutViewController.h"
#import "TYDCommonProblemsViewController.h"
#import "TYDMachineModelViewController.h"
#import "BOAvatarView.h"
#import "SBJson.h"

@interface TYDAboutViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>


@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *itemTitles;

@end

@implementation TYDAboutViewController
{
    BOOL _checkActionLocked;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHex:0xf3f3f4];
    
    [self localDataInitialize];
    [self navigationBarItemsLoad];
    [self subviewsLoad];
}

- (void)localDataInitialize
{
    self.itemTitles = @[@"常见问题", @"支持的机型"];
    _checkActionLocked = NO;
}

- (void)navigationBarItemsLoad
{
    self.title = @"关于";
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
    frame.size.height = 208;
    UIView *aboutHeaderView = [[UIView alloc] initWithFrame:frame];
    aboutHeaderView.backgroundColor = [UIColor colorWithHex:0xe23674];
    
    UIImageView *headerPicture = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"me_aboutHeaderPic"]];
    headerPicture.center = aboutHeaderView.center;
    [aboutHeaderView addSubview:headerPicture];
    
    UILabel *versionLabel = [[UILabel alloc]init];
    versionLabel.size = CGSizeMake(80, 30);
    [aboutHeaderView addSubview:versionLabel];
    versionLabel.backgroundColor = [UIColor clearColor];
    
    NSString *currentVersion = [BOAssistor appShortVersionString];
    versionLabel.text = [NSString stringWithFormat:@"默菲 %@", currentVersion];
    versionLabel.textColor = [UIColor colorWithHex:0xffffff];
    versionLabel.font = [UIFont systemFontOfSize:13];
    versionLabel.textAlignment = NSTextAlignmentCenter;
    
    CGPoint center = aboutHeaderView.innerCenter;
    headerPicture.center = center;
    versionLabel.center = center;
    headerPicture.top = 8;
    versionLabel.yCenter = (headerPicture.bottom + aboutHeaderView.height) * 0.5;
    self.tableView.tableHeaderView = aboutHeaderView;
    
    NSLog(@"%@", [NSBundle mainBundle].infoDictionary);
}

- (void)tableFooterViewLoad
{
    CGRect frame = self.tableView.bounds;
    frame.size.height = 20;
    UIView *footerView = [[UIView alloc] initWithFrame:frame];
    footerView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footerView;
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.itemTitles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"aboutItemCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.backgroundColor = [UIColor colorWithHex:0xfcfcff];
    }
    NSString *itemTitle = self.itemTitles[indexPath.row];
    cell.textLabel.text = itemTitle;
    cell.textLabel.textColor = [UIColor colorWithHex:0x323232];
    cell.textLabel.font = [UIFont fontWithName:@"Arial" size:14];
    
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"breast_rightArrow"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row == 0)
    {
        TYDCommonProblemsViewController *commonProblems = [TYDCommonProblemsViewController new];
        [self.navigationController pushViewController:commonProblems animated:YES];
    }
    else if(indexPath.row == 1)
    {
        TYDMachineModelViewController *machineModel = [TYDMachineModelViewController new];
        [self.navigationController pushViewController:machineModel animated:YES];
    }
//    else if(indexPath.row == 2)
//    {
//        [self performSelectorInBackground:@selector(checkVersion) withObject:nil];
//    }
}

- (void)versionCheckStart
{
    if(!_checkActionLocked)
    {
        _checkActionLocked = YES;
        [self performSelectorInBackground:@selector(checkVersion) withObject:nil];
    }
}

- (void)checkVersion
{
    //NSString *key = (NSString *)kCFBundleVersionKey;
    //NSString *localVersion = [NSBundle mainBundle].infoDictionary[key];
    NSNumber *localVersion = [BOAssistor appVersionNumber];
    NSURL *url = [NSURL URLWithString:@"http://itunes.apple.com/cn/lookup?id=935188718"];
    NSString *jsonResponseString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    SBJsonParser *jsonParser = [SBJsonParser new];
    NSDictionary *responseDic = [jsonParser objectWithString:jsonResponseString];
    NSArray *resultArr = [responseDic valueForKey:@"results"];
    NSString *newVersion = [NSString new];
    for(id dicInArr in resultArr)
    {
        newVersion = [dicInArr valueForKey:@"version"];
    }
    if([newVersion floatValue] > [localVersion floatValue])
    {
        NSString *msg = [NSString stringWithFormat:@"有新的版本更新，是否下载？"];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"下次再说" otherButtonTitles:@"现在升级", nil];
        [alertView show];
    }
    else
    {
//        UIAlertView *UserResponseAlert = [[UIAlertView alloc]initWithTitle:@"已是最新版本!" message:nil delegate:self cancelButtonTitle:@"返回" otherButtonTitles:nil];
//        [UserResponseAlert show];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setNoticeText:@"已是最新版本!"];
        });
    }
    _checkActionLocked = NO;
}

- (void)alertView:(UIAlertView *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/TYDTech_App_Mofei/id935188718?mt=8"]];
        NSLog(@"执行升级方法");
    }
}

@end
