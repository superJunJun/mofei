//
//  TYDBreastViewController.m
//  Mofei
//
//  Created by macMini_Dev on 14-8-12.
//  Copyright (c) 2014年 Young. All rights reserved.
//
//  "美胸达人"首页
//

#import "TYDBreastViewController.h"
#import "TYDHealthyCookbookViewController.h"
#import "TYDBreastCookbookViewController.h"
#import "TYDBreastDrillViewController.h"
#import "TYDBreastClassViewController.h"

#define nBreastAdViewHeight         208
@interface TYDBreastViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *itemInfos;

@end

@implementation TYDBreastViewController

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
    //self.noticeBarCenter = CGPointMake(self.view.width * 0.5, self.view.height - 48 - 40);
    self.noticeBarCenter = CGPointMake(self.view.width * 0.5, self.view.height - 40);
}

- (void)localDataInitialize
{
    self.itemInfos = @[@"健康食谱", @"简易美胸操", @"美胸食谱",@"美胸课堂"];
}

- (void)navigationBarItemsLoad
{
    self.title = @"美胸达人";
    //导航栏颜色e23674
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
    frame.size.height = nBreastAdViewHeight;
    UIView *headerView = [[UIView alloc] initWithFrame:frame];
    headerView.backgroundColor = [UIColor colorWithHex:0xe23674];
    
    UIImageView *headerPicture = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"breast_advertisementPic"]];
    headerPicture.center = headerView.center;
    [headerView addSubview:headerPicture];
    self.tableView.tableHeaderView = headerView;
    
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
    return self.itemInfos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"breastItemInfoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.backgroundColor = [UIColor colorWithHex:0xfcfcff];
        
        cell.textLabel.text = @" ";
        cell.textLabel.textColor = [UIColor colorWithHex:0x323232];
        cell.textLabel.font = [UIFont fontWithName:@"Arial" size:14];
        
//        
//        CGFloat offset = 24;
//        CGFloat height = [tableView rectForRowAtIndexPath:indexPath].size.height;
//        UIView *separatorLine = [UIView new];
//        separatorLine.backgroundColor = [UIColor colorWithHex:0xe5e5e6];
//        separatorLine.size = CGSizeMake(tableView.width - offset, 0.5);
//        separatorLine.bottomRight = CGPointMake(tableView.width, height);
//        [cell.contentView addSubview:separatorLine];
    }
    cell.textLabel.text = _itemInfos[indexPath.row];
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"breast_rightArrow"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row==0)
    {
        TYDHealthyCookbookViewController * healthyCookbookVC=[TYDHealthyCookbookViewController new];
        [self.navigationController pushViewController:healthyCookbookVC animated:YES];
    }
    else if (indexPath.row==1)
    {
        TYDBreastDrillViewController *breastDrillVC=[TYDBreastDrillViewController new];
        [self.navigationController pushViewController:breastDrillVC animated:YES];
    }
    else if (indexPath.row==2)
    {
        TYDBreastCookbookViewController * breastCookbookVC=[TYDBreastCookbookViewController new];
        [self.navigationController pushViewController:breastCookbookVC animated:YES];
    }
    else if (indexPath.row==3)
    {
        TYDBreastClassViewController * breastClassVC=[TYDBreastClassViewController new];
        [self.navigationController pushViewController:breastClassVC animated:YES];
    }
}


@end
