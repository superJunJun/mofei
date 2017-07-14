//
//  TYDCommonProblemsViewController.m
//  Mofei
//
//  Created by caiyajie on 14-10-31.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import "TYDCommonProblemsViewController.h"
@interface TYDCommonProblemsViewController ()
{
    NSInteger _sectionP;
}

@end

@implementation TYDCommonProblemsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self localDataInitialize];
    [self navigationBarItemsLoad];
    [self subviewsLoad];
}
- (void)localDataInitialize
{
    self.itemTitles = @[@"待机时间多久？", @"如何充电？", @"不能同步数据？",@"有了Venus后，还需要时刻开着应用么?",@"Venus通过什么方式传输数据？"];
    self.itemExplain =
    @[
        @"venus设备内置的是纽扣电池，正常使用情况下，满电能待机15天左右。",
        @"将venus设备（有金属针脚的一面朝下）放置在充电盒子里，金属针脚对齐，合上盖子。当venus指示灯亮起就表示在充电了。",
        @"检查是否打开默菲app：需要打开默菲app才能进行同步。\n检查是否开启蓝牙：需要开启蓝牙才能进行同步。\n检查venus设备电量是否过低：电量过低或电池没电，请更换电池再试。\n检查venus设备与手机距离是否超过15cm:将手机与venus设备放置在一起再试。",
        @"需要，心率记录需要时刻保持应用进程开启。",
        @"venus内置了蓝牙芯片，通过蓝牙进行数据传输。"
    ];
}
- (void)navigationBarItemsLoad
{
    self.title = @"常见问题";
}
- (void)subviewsLoad
{
    [self tableViewLoad];
}
- (void)tableViewLoad
{
    _sectionP=-1;
    CGRect frame = self.view.bounds;
    _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
    _tableView.backgroundColor = [UIColor colorWithHex:0xefeef0];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.separatorColor = [UIColor colorWithHex:0xe5e5e6];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.showsVerticalScrollIndicator = NO;
   
    _tableView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:_tableView];
}
- (void)tapAction:(UITapGestureRecognizer *)tap
{
    UIView * view=(UIView *)tap.view;
    _sectionP=_sectionP==view.tag?-1:view.tag;
    [_tableView reloadData];
}
- (void)buttonClickAction:(UIButton*)button
{
     _sectionP=_sectionP==button.tag-100?-1:button.tag-100;
    [_tableView reloadData];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==_sectionP)
    {
        CGFloat contentWidth=self.tableView.frame.size.width;
        UIFont *font =[UIFont fontWithName:@"Arial" size:13];
        NSString * content=self.itemExplain[indexPath.section];
        CGSize size=[content sizeWithFont:font constrainedToSize:CGSizeMake(contentWidth, 1000) lineBreakMode:NSLineBreakByWordWrapping];
        if(_sectionP==2||_sectionP==4)
        {
            return size.height+35;
        }
        else
        {
            return size.height+20;
        }
    }
    else
    {
        return 0;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIImage * imageNormal=[UIImage imageNamed:@"me_CommonProblemArrowN"];
    UIImage * imagePress=[UIImage imageNamed:@"me_CommonProblemArrowP"];
    UIButton * button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=CGRectMake(260,5,40,40);
    [button setBackgroundImage:imageNormal forState:UIControlStateNormal];
    [button setBackgroundImage:imagePress forState:UIControlStateSelected];
    [button addTarget:self action:@selector(buttonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    button.tag=100+section;
    button.backgroundColor=[UIColor clearColor];
    button.selected=section==_sectionP?YES:NO;
    
    UILabel * label=[[UILabel alloc]initWithFrame:CGRectMake(20, 5, 250, 40)];
    label.text=self.itemTitles[section];
    label.backgroundColor=[UIColor clearColor];
    label.font=[UIFont fontWithName:@"Arial" size:13];
    label.textColor=[UIColor colorWithHex:0x323232];
    
    UIImageView * imgV=[[UIImageView alloc]initWithFrame:CGRectMake(270, 40,20,11)];
    imgV.image=[UIImage imageNamed:@"me_CommonProblemPull"];
    imgV.hidden=_sectionP==section?NO:YES;
   
    //头视图,frame无效
    UIView *view = [[UIView alloc]init];
    view.tag=section;
    UITapGestureRecognizer * tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [view addGestureRecognizer:tap];
    view.userInteractionEnabled=YES;
    view.backgroundColor=[UIColor colorWithHex:0xfcfcff];
    [view addSubview:label];
    [view addSubview:imgV];
    [view addSubview:button];
    return view;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 45;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.itemTitles.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
//-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(19, 0, self.view.bounds.size.width-38, 0.5)];
//    view.backgroundColor = [UIColor redColor];
//    return view;
//}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.5;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * commonProblemCellId=@"commonProblemCellIdentifier";
    UITableViewCell * cell=[tableView dequeueReusableCellWithIdentifier:commonProblemCellId];
    if(!cell)
    {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonProblemCellId];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor=[UIColor colorWithHex:0x848484];
    cell.textLabel.text=self.itemExplain[indexPath.section];
    cell.textLabel.font=[UIFont fontWithName:@"Arial" size:13];
    cell.textLabel.textColor=[UIColor colorWithHex:0xffffff];
    cell.textLabel.numberOfLines=0;
    if(_sectionP == -1 || _sectionP != indexPath.section)
    {
        cell.textLabel.text = @"";
    }
//cell分割线长度282
//    UIView * baseView =[[UIView alloc]initWithFrame:CGRectMake(0, 0,cell.size.width,cell.size.height)];
//    baseView.layer.masksToBounds = YES;
//    baseView.tag = 10000;
//    baseView.backgroundColor = [UIColor colorWithHex:0x848484];
    
    return cell;
}

@end
