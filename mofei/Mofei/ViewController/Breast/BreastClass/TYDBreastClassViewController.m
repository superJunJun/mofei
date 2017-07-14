//
//  TYDBreastClassViewController.m
//  Mofei
//
//  Created by caiyajie on 14-10-30.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import "TYDBreastClassViewController.h"
#import "TYDBreastClassCell.h"
#import "TYDBreastClassDetailViewController.h"
#import "MJRefresh.h"
#import "TYDBreastListModel.h"
#import "TYDLoginViewController.h"
@interface TYDBreastClassViewController () <UITableViewDelegate,UITableViewDataSource,TYDBreastClassDetailViewControllerDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *breastClassInfos;

@property (nonatomic) BOOL didUserLogin;
@property (strong, nonatomic) NSString * userName;

@end

@implementation TYDBreastClassViewController
{
    NSInteger _loadNumber;
    BOOL _singleTimeLoadMarkValue;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self localDataInitialize];
    [self navigationBarItemsLoad];
    [self subviewsLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self userStatusCheck];
    if(!_singleTimeLoadMarkValue)
    {
        _singleTimeLoadMarkValue = YES;
        [self loadData];
    }
}

- (void)userStatusCheck
{
    self.didUserLogin = [TYDUserInfo sharedUserInfo].isUserAccountEnable;
    self.userName = [TYDUserInfo sharedUserInfo].username;
}

- (void)localDataInitialize
{
    _singleTimeLoadMarkValue = NO;
    self.breastClassInfos = [NSMutableArray new];
    _loadNumber = 5;
}

- (void)navigationBarItemsLoad
{
    self.title = @"美胸课堂";
}

- (void)subviewsLoad
{
    [self tableViewLoad];
    [self setupRefresh];
}

- (void)tableViewLoad
{
    CGRect frame = self.view.bounds;
    UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.separatorColor = [UIColor clearColor];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    if([tableView respondsToSelector:@selector(separatorInset)])
    {
        [tableView setSeparatorInset:UIEdgeInsetsMake(0.5, 10, 0, 10)];
    }
    //    [tableView registerNib:[UINib nibWithNibName:@"TYDBreastDrillCell" bundle:nil] forCellReuseIdentifier:sBreastDrillCellIdentifier];
}
- (void)setupRefresh
{
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
    // 设置文字(也可以不设置,默认的文字在MJRefreshConst中修改)
    self.tableView.headerPullToRefreshText = @"下拉刷新";
    self.tableView.headerReleaseToRefreshText = @"释放立即刷新";
    self.tableView.headerRefreshingText = @"正在刷新......";
    
    self.tableView.footerPullToRefreshText = @"上拉查看更多";
    self.tableView.footerReleaseToRefreshText = @"释放立即加载更多";
    self.tableView.footerRefreshingText = @"正在加载更多......";
}
-(void)headerRereshing
{
    _loadNumber=5;
    [self loadData];
}
-(void)footerRereshing
{
    _loadNumber+=5;
    [self loadData];
}
- (void)loadData
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:@0 forKey:@"from"];
    [params setValue:[NSString stringWithFormat:@"%ld",(long)_loadNumber] forKey:@"to"];
    
    [self showProgressHUDWithLabelText:nil];
    [self postURLRequestWithMessageCode:ServiceMsgCodeBreastClassList HUDLabelText:nil params:params completeBlock:^(id result) {
        [self loadDataComplete:result];
        [self.tableView headerEndRefreshing];
        [self.tableView footerEndRefreshing];
    }];
}
- (void)breastClassPraiseButtonAction:(TYDBreastListModel*)model
{
    if(!_didUserLogin)
    {
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"你还未登录，请先登录！" delegate:self cancelButtonTitle:@"返回" otherButtonTitles:@"确定", nil];
        [alertView show];
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:[NSString stringWithFormat:@"%@",model.cookbookID] forKey:@"categoryId"];
    [params setValue:[NSString stringWithFormat:@"%ld",(long)(model.isAttention)] forKey:@"status"];
    [params setValue:@4 forKey:@"source"];
    [self postURLRequestWithMessageCode:ServiceMsgCodePraiseButton HUDLabelText:nil params:params completeBlock:^(id result) {
        [self loadPraiseButtonInfoComplete:result withModel:model];
    }];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == alertView.firstOtherButtonIndex)
    {
        TYDLoginViewController *vc = [TYDLoginViewController new];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = sBreastClassCellIdentifier;
    TYDBreastClassCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if(!cell)
    {
        cell=[[TYDBreastClassCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.breastClass = self.breastClassInfos[indexPath.row];
    [cell setClickModel:^(TYDBreastListModel *model) {
        
        [self breastClassPraiseButtonAction:model];
        
    }];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.breastClassInfos.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TYDBreastClassDetailViewController *detailVC = [TYDBreastClassDetailViewController new];
    [self.navigationController pushViewController:detailVC animated:YES];
    detailVC.detailVCModelId=[[self.breastClassInfos[indexPath.row] cookbookID]integerValue];
    
    detailVC.praiseButtonNumberText = [[self.breastClassInfos[indexPath.row] numberText]integerValue];
    detailVC.attentionMark = [self.breastClassInfos[indexPath.row] isAttention];
    detailVC.breastListModel = self.breastClassInfos[indexPath.row];
    detailVC.delegate = self;
}

#pragma mark - ServerConnectionComplete

- (void)loadDataComplete:(id)result
{
//    NSLog(@"loadDataComplete:%@", result);
    NSNumber *errorCode = result[@"errorCode"];
    if(errorCode.intValue == 0)
    {
        [self showProgressCompleteWithLabelText:@"获取完成" isSucceed:YES];
        NSMutableArray *breastDrillInfo = [NSMutableArray new];
        if([result isKindOfClass:NSDictionary.class])
        {
            NSDictionary *dic = result;
            NSArray *breastDrillArray = dic[@"breastClassList"];
            for(NSDictionary *breastDrillDic in breastDrillArray)
            {
                TYDBreastListModel * breastDrillModel = [TYDBreastListModel new];
                [breastDrillModel setAttributes:breastDrillDic];
                
                NSString * key =[NSString stringWithFormat:@"id%@IsAttentionBreastClass",breastDrillModel.cookbookID];
                NSUserDefaults * userDefault= [NSUserDefaults standardUserDefaults];
                NSString * didReadKey = [NSString stringWithFormat:@"bClass%@",key];
                breastDrillModel.didRead = [userDefault boolForKey:didReadKey];
                if (_didUserLogin)
                {
                    NSString * userAttentionKey = [NSString stringWithFormat:@"%@%@",_userName,key];
                    breastDrillModel.isAttention = [userDefault integerForKey:userAttentionKey];
                }
                else
                {
                    breastDrillModel.isAttention = 0;
                }

                [breastDrillInfo addObject:breastDrillModel];
                NSLog(@"--->%@",breastDrillModel.pictureUrl);
            }
            NSLog(@"---------------------------------------------");
        }
        [self.breastClassInfos removeAllObjects];
        self.breastClassInfos=breastDrillInfo;
        [self.tableView reloadData];
    }
    else
    {
        [self hiddenProgressHUD];
        [self setNoticeText:@"获取失败"];
    }
    if(self.breastClassInfos.count > 0)
    {
        self.tableView.separatorColor = [UIColor colorWithHex:0xe5e5e6];
    }
    else
    {
        self.tableView.separatorColor = [UIColor clearColor];
    }
}
-(void)loadPraiseButtonInfoComplete:(id)result withModel:(TYDBreastListModel*)model
{
    NSLog(@"loadPraiseButtonInfoComplete:%@", result);
    NSNumber *resultGet = result[@"result"];
    if(resultGet.integerValue==0)
    {
        if(model.isAttention==0)
        {
            [self showProgressCompleteWithLabelText:@" 已点赞 " isSucceed:YES];
            model.isAttention=1;
        }
        else if (model.isAttention==1)
        {
            [self showProgressCompleteWithLabelText:@"点赞取消" isSucceed:YES];
            model.isAttention=0;
        }
        NSString * key=[NSString stringWithFormat:@"id%@IsAttentionBreastClass",model.cookbookID];
        NSString * userAttentionKey = [NSString stringWithFormat:@"%@%@",_userName,key];
        NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setInteger:model.isAttention forKey:userAttentionKey];
        [userDefault synchronize];
        
        model.numberText=result[@"praise"];
        [self.tableView reloadData];
    }
    else if (resultGet.integerValue==-1)
    {
        [self hiddenProgressHUD];
        [self setNoticeText:@"点赞失败"];
        NSLog(@"shibai");
    }
}

#pragma mark - TYDBreastClassDetailViewControllerDelegate

- (void)breastClassDetailViewControllerBreastClassModelUpdated:(TYDBreastClassDetailViewController *)vc
{
    TYDBreastListModel *model = vc.breastListModel;
    NSUInteger index = [self.breastClassInfos indexOfObject:model];
    model.didRead = YES;
    if(_didUserLogin)
    {
        model.isAttention = vc.attentionMark;
    }
    else
    {
        model.isAttention = 0;
    }
    if(index != NSNotFound)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

@end
