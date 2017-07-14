//
//  TYDMensesRecordViewController.m
//  Mofei
//
//  Created by macMini_Dev on 14/11/19.
//  Copyright (c) 2014年 Young. All rights reserved.
//
//  经期记录页面
//

#import "TYDMensesRecordViewController.h"
#import "TYDMensesRecordInfoCell.h"
#import "TYDMensesDataCenter.h"
#import "TYDMensesInfo.h"

#define nTableViewSectionHeaderViewHeight   30//24
#define nInfoTitleViewHeight                38
#define nInfoBarViewHeight                  70//46
#define sFontNameForRBNo2Light      @"RBNo2-Light"

@interface TYDMensesRecordViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *infoLabels;

@property (strong, nonatomic) UIView *tableSectionHeaderView;
@property (strong, nonatomic) NSMutableArray *mensesInfos;

@property (strong, nonatomic) NSArray *mensesStatisticsInfos;

@end

@implementation TYDMensesRecordViewController

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
    NSMutableArray *mensesInfos = [[TYDMensesDataCenter defaultCenter].allMensesRecordInfos mutableCopy];
//    if(mensesInfos.count > 0)
//    {
//        TYDMensesInfo *lastestMensesInfo = [mensesInfos lastObject];
//        if(lastestMensesInfo.endTimeStamp > [BOTimeStampAssistor timeStampOfDayBeginningForToday])
//        {//最新的未能完全显示的剔除
//            [mensesInfos removeLastObject];
//        }
//    }
    self.mensesInfos = mensesInfos;
    
    int mensesDurationAve = [TYDMensesDataCenter defaultCenter].mensesDuration;
    int mensesBloodDurationAve = [TYDMensesDataCenter defaultCenter].mensesBloodDuration;
    int mensesDurationMax = mensesDurationAve;
    int mensesDurationMin = mensesDurationAve;
    int mensesBloodDurationMax = mensesBloodDurationAve;
    int mensesBloodDurationMin = mensesBloodDurationAve;
    
    int mensesDurationTotal = 0;        //计算平均
    int mensesBloodDurationTotal = 0;   //计算平均
    if(mensesInfos.count > 0)
    {
        TYDMensesInfo *mensesInfo0 = mensesInfos.firstObject;
        int mensesBloodDuration0 = (int)((mensesInfo0.endTimeStamp - mensesInfo0.timeStamp) / nTimeIntervalSecondsPerDay + 1);
        mensesBloodDurationMax = mensesBloodDuration0;
        mensesBloodDurationMin = mensesBloodDuration0;
        mensesBloodDurationTotal += mensesBloodDuration0;
        
        for(NSInteger index = 1; index < mensesInfos.count; index++)
        {
            TYDMensesInfo *infoItem = mensesInfos[index];
            int mensesBloodDuration = (int)((infoItem.endTimeStamp - infoItem.timeStamp) / nTimeIntervalSecondsPerDay + 1);
            mensesBloodDurationMax = MAX(mensesBloodDurationMax, mensesBloodDuration);
            mensesBloodDurationMin = MIN(mensesBloodDurationMin, mensesBloodDuration);
            mensesBloodDurationTotal += mensesBloodDuration;
        }
        
        for(NSInteger index = 1; index < mensesInfos.count; index++)
        {
            TYDMensesInfo *infoItem0 = mensesInfos[index - 1];
            TYDMensesInfo *infoItem1 = mensesInfos[index];
            int mensesDuration = (int)ABS(((infoItem1.timeStamp - infoItem0.timeStamp) / nTimeIntervalSecondsPerDay));
            mensesDurationTotal += mensesDuration;
            //if(mensesDuration < mensesDurationAve * 2)
            {
                mensesDurationMax = MAX(mensesDurationMax, mensesDuration);
                mensesDurationMin = MIN(mensesDurationMin, mensesDuration);
            }
        }
        mensesBloodDurationAve = mensesBloodDurationTotal / mensesInfos.count;
        if(mensesInfos.count > 1)
        {
            mensesDurationAve = mensesDurationTotal / (mensesInfos.count - 1);
        }
    }
    
    self.mensesStatisticsInfos = @[@(mensesDurationAve), @(mensesDurationMin), @(mensesDurationMax), @(mensesBloodDurationAve), @(mensesBloodDurationMin), @(mensesBloodDurationMax)];
}

- (void)navigationBarItemsLoad
{
    self.title = @"记录";
}

- (void)subviewsLoad
{
    [self tableViewLoad];
    [self tableHeaderViewLoad];
    [self tableFooterViewLoad];
    [self tableSectionHeaderViewLoad];
}

- (void)tableViewLoad
{
    CGRect frame = self.view.bounds;
    UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.separatorColor = [UIColor colorWithHex:0xe0e0e0];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:tableView];
    
    [tableView registerClass:[TYDMensesRecordInfoCell class] forCellReuseIdentifier:sMensesRecordInfoCellIdentifier];
    self.tableView = tableView;
}

- (void)tableHeaderViewLoad
{
    CGRect frame = self.tableView.bounds;
    frame.size.height = nInfoTitleViewHeight * 3 + nInfoBarViewHeight * 2;
    UIView *headerView = [[UIView alloc] initWithFrame:frame];
    headerView.backgroundColor = [UIColor clearColor];
    
    UIView *titleViews0 = [self infoTitleViewCreateWithTitle:@"月经周期"];
    UIView *titleViews1 = [self infoTitleViewCreateWithTitle:@"月经持续天数"];
    UIView *titleViews2 = [self infoTitleViewCreateWithTitle:@"行经历史记录"];
    [headerView addSubview:titleViews0];
    [headerView addSubview:titleViews1];
    [headerView addSubview:titleViews2];
    
    frame.size.height = nInfoBarViewHeight;
    UIView *infoBar0 = [[UIView alloc] initWithFrame:frame];
//    infoBar0.backgroundColor = [UIColor colorWithHex:0xfcfcff];
    infoBar0.backgroundColor = [UIColor clearColor];
    UIView *infoBar1 = [[UIView alloc] initWithFrame:frame];
//    infoBar1.backgroundColor = [UIColor colorWithHex:0xfcfcff];
    infoBar1.backgroundColor = [UIColor clearColor];

    [headerView addSubview:infoBar0];
    [headerView addSubview:infoBar1];
    UIView * line1 =[[UIView alloc]initWithFrame:CGRectMake(10, nInfoTitleViewHeight, self.view.size.width-20, 0.5)];
    line1.backgroundColor = [UIColor colorWithHex:0xdfdfe1];
    [headerView addSubview:line1];
    UIView * line2 =[[UIView alloc]initWithFrame:CGRectMake(10, nInfoTitleViewHeight*2+nInfoBarViewHeight, self.view.size.width-20, 0.5)];
    line2.backgroundColor = [UIColor colorWithHex:0xdfdfe1];
    [headerView addSubview:line2];
    UIView * line3 =[[UIView alloc]initWithFrame:CGRectMake(10, nInfoTitleViewHeight*3+nInfoBarViewHeight*2, self.view.size.width-20, 0.5)];
    line3.backgroundColor = [UIColor colorWithHex:0xdfdfe1];
    [headerView addSubview:line3];
    
    titleViews0.top = 0;
    infoBar0.top = titleViews0.bottom;
    titleViews1.top = infoBar0.bottom;
    infoBar1.top = titleViews1.bottom;
    titleViews2.top = infoBar1.bottom;
    
    frame.size.width /= 3;
    NSMutableArray *infoLabels = [NSMutableArray new];
    NSArray *infotitleTexts = @[@"        平均天数\n", @"        最短天数\n", @"        最长天数\n"];
    for(int i = 0; i < 6; i++)
    {
        UILabel *infoLabel = [[UILabel alloc] initWithFrame:frame];
        infoLabel.numberOfLines = 0;
        infoLabel.backgroundColor = [UIColor clearColor];
        infoLabel.textAlignment = NSTextAlignmentCenter;
        [self infoLabel:infoLabel setTitleText:infotitleTexts[i % infotitleTexts.count] dayCountNumber:[self.mensesStatisticsInfos[i] intValue]];
        
        [headerView addSubview:infoLabel];
        
        [infoLabels addObject:infoLabel];
    }
    UILabel *infoLabel0 = infoLabels[0];
    UILabel *infoLabel1 = infoLabels[1];
    UILabel *infoLabel2 = infoLabels[2];
    UILabel *infoLabel3 = infoLabels[3];
    UILabel *infoLabel4 = infoLabels[4];
    UILabel *infoLabel5 = infoLabels[5];
    
    infoLabel0.center = infoBar0.center;
    infoLabel1.center = infoBar0.center;
    infoLabel2.center = infoBar0.center;
    infoLabel0.left = 0;
    infoLabel2.left = infoLabel1.right;
    
    infoLabel3.center = infoBar1.center;
    infoLabel4.center = infoBar1.center;
    infoLabel5.center = infoBar1.center;
    infoLabel3.left = 0;
    infoLabel5.left = infoLabel4.right;
    
    self.infoLabels = infoLabels;
    self.tableView.tableHeaderView = headerView;
}

- (void)tableFooterViewLoad
{
    CGRect frame = self.tableView.frame;
    frame.size.height = 20;
    UIView *tableFooterView = [[UIView alloc] initWithFrame:frame];
    tableFooterView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = tableFooterView;
}

- (void)tableSectionHeaderViewLoad
{
    CGRect frame = self.tableView.bounds;
    frame.size.height = nTableViewSectionHeaderViewHeight;
    UIView *headerView = [[UIView alloc] initWithFrame:frame];
//    headerView.backgroundColor = [UIColor colorWithHex:0xf6e1b2];
    headerView.backgroundColor =[UIColor clearColor];
    
    UIFont *titleTextFont = [UIFont fontWithName:@"Arial" size:13];
    UIColor *titleTextColor = [UIColor colorWithHex:0x9a9a9a];
    NSArray *titles = @[@"\n开始日期", @"\n结束日期", @"\n行经天数"];
    frame.size.width /= titles.count;
    for(NSString *title in titles)
    {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:frame];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = titleTextFont;
        titleLabel.textColor = titleTextColor;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.numberOfLines = 0;
        titleLabel.text = title;
        [headerView addSubview:titleLabel];
        
        frame.origin.x += frame.size.width;
    }
    self.tableSectionHeaderView = headerView;
}

- (UIView *)infoTitleViewCreateWithTitle:(NSString *)title
{
    CGRect frame = self.tableView.bounds;
    frame.size.height = nInfoTitleViewHeight;
    
    UIView *titleView = [[UIView alloc] initWithFrame:frame];
    titleView.backgroundColor = [UIColor clearColor];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont fontWithName:@"Arial" size:15];
    titleLabel.textColor = [UIColor colorWithHex:0x4a4a4a];
    titleLabel.text = title;
    [titleLabel sizeToFit];
    titleLabel.bottomLeft = CGPointMake(12, titleView.height - 6);
    [titleView addSubview:titleLabel];
    
    return titleView;
}

- (void)infoLabel:(UILabel *)infoLabel
     setTitleText:(NSString *)titleText
   dayCountNumber:(int)dayCount
{
    if(!infoLabel)
    {
        return;
    }
    
    UIFont *normalFont = [UIFont fontWithName:@"Arial" size:13];
//    UIFont *boldFont = [UIFont fontWithName:@"Arial" size:20];
    UIFont *boldFont = [UIFont fontWithName:sFontNameForRBNo2Light size:30];
    UIColor *grayColor = [UIColor colorWithHex:0x9a9a9a];
    UIColor *pinkColor = [UIColor colorWithHex:0x5c5c5c];
    
    NSString *headText = [NSString stringWithFormat:@"%@ ", titleText];
    NSString * numberText =[[NSString alloc]init];
//    NSString *numberText = [NSString stringWithFormat:@"      %d", dayCount];
    NSString *tailText = [NSString stringWithFormat:@" 天"];
    if(dayCount>=10)
    {
      numberText = [NSString stringWithFormat:@"      %d", dayCount];
    }
    else
    {
       numberText = [NSString stringWithFormat:@"       %d", dayCount];
    }
    
    NSString *text = [NSString stringWithFormat:@"%@%@%@", headText, numberText, tailText];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName:grayColor,                                                            NSFontAttributeName:normalFont}];
    [attributedText setAttributes:@{NSForegroundColorAttributeName:pinkColor, NSFontAttributeName:boldFont} range:NSMakeRange(headText.length, numberText.length)];
    [attributedText setAttributes:@{NSForegroundColorAttributeName:pinkColor, NSFontAttributeName:[UIFont fontWithName:@"Arial" size:14]} range:NSMakeRange(headText.length+numberText.length,tailText.length)];
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    [paragraphStyle setLineSpacing:5];
    [attributedText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, text.length)];
    infoLabel.attributedText = attributedText;
}

#pragma mark - UITableViewRelative

- (TYDMensesInfo *)mensesInfoAtIndexPath:(NSIndexPath *)indexPath
{
    TYDMensesInfo *mensesInfo = nil;
    NSUInteger index = self.mensesInfos.count - indexPath.row;
    index--;
    if(index < self.mensesInfos.count)
    {
        mensesInfo = self.mensesInfos[index];
    }
    return mensesInfo;
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return nTableViewSectionHeaderViewHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.tableSectionHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TYDMensesRecordInfoCell.cellHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.mensesInfos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = sMensesRecordInfoCellIdentifier;
    TYDMensesRecordInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.mensesInfo = [self mensesInfoAtIndexPath:indexPath];
    cell.backgroundColor =[UIColor clearColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
