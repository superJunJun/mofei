//
//  TYDBreastClassDetailViewController.m
//  Mofei
//
//  Created by caiyajie on 14-10-30.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import "TYDBreastClassDetailViewController.h"
#import "BOAssistor.h"
#import "TYDLoginViewController.h"
@interface TYDBreastClassDetailViewController ()<UIAlertViewDelegate>

@property (strong, nonatomic) NSMutableArray *breastDrillDetailInfos;
@property (strong, nonatomic) NSDictionary *DIC;

@end

@implementation TYDBreastClassDetailViewController

{
    BOOL _singleTimeLoadMarkValue;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self userDidRead];
    [self navigationBarItemsLoad];
    [self localDataInitialize];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(!_singleTimeLoadMarkValue)
    {
        _singleTimeLoadMarkValue = YES;
        [self loadData];
    }
}

-(void)userDidRead
{
    NSString * key =[NSString stringWithFormat:@"id%@IsAttentionBreastClass",_breastListModel.cookbookID];
    NSString * didReadKey = [NSString stringWithFormat:@"bClass%@",key];
    NSUserDefaults * userDefaults = [NSUserDefaults new];
    [userDefaults setBool:YES forKey:didReadKey];
    [userDefaults synchronize];
    if([self.delegate respondsToSelector:@selector(breastClassDetailViewControllerBreastClassModelUpdated:)])
    {
        [self.delegate breastClassDetailViewControllerBreastClassModelUpdated:self];
    }
   
}

- (void)loadData
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:[NSString stringWithFormat:@"%ld",(long)_detailVCModelId] forKey:@"mxktId"];
    
    [self showProgressHUDWithLabelText:nil];
    [self postURLRequestWithMessageCode:ServiceMsgCodeBreastClassDetail HUDLabelText:nil params:params completeBlock:^(id result) {
        [self loadDataComplete:result];
        [self subviewsLoad];
    }];
}

- (void)loadDataComplete:(id)result
{
    NSLog(@"loadDataComplete:%@", result);
    NSNumber *errorCode = result[@"errorCode"];
    if(errorCode.intValue == 0)
    {
        [self showProgressCompleteWithLabelText:@"获取完成" isSucceed:YES];
        if([result isKindOfClass:NSDictionary.class])
        {
            NSDictionary *dic = result;
            _DIC = dic[@"breastClassDetail"];
            NSArray * plistArray=_DIC[@"breastClassList"];
            for(NSDictionary *dicInPlist in plistArray)
            {
                TYDBreastDetailModel *breastClassDetailModel = [TYDBreastDetailModel new];
                [breastClassDetailModel setAttributes:dicInPlist];
                NSLog(@"1--->%@",breastClassDetailModel.paragraphContent);
                NSLog(@"小图：%@",breastClassDetailModel.paragraphImgUrl);
                [_breastDrillDetailInfos addObject:breastClassDetailModel];
            }
        }
        
    }
    else
    {
        [self hiddenProgressHUD];
        [self setNoticeText:@"获取失败"];
    }
}
- (void)localDataInitialize
{
    _breastDrillDetailInfos=[NSMutableArray new];
    _singleTimeLoadMarkValue=NO;
}
-(void)navigationBarItemsLoad
{
    self.title=@"美胸课堂详情";
}

-(void)subviewsLoad
{
    self.baseViewBaseHeight = [self loadHeaderPicture];
    self.baseViewBaseHeight = [self loadTitleLable:self.baseViewBaseHeight];
    self.baseViewBaseHeight = [self loadTitleDetail:self.baseViewBaseHeight];
    self.baseViewBaseHeight = [self loadLine:self.baseViewBaseHeight];
    self.baseViewBaseHeight = [self loadEveryStepPictureAndExplain:self.baseViewBaseHeight];
    self.baseViewBaseHeight  = [self loadPraiseButton:self.baseViewBaseHeight];
    self.baseViewBaseHeight += 20;
    
}

-(CGFloat)loadHeaderPicture
{
    UIImageView * headerPicture = [[UIImageView alloc] initWithFrame:CGRectMake(15, 0, self.view.bounds.size.width-30, 240)];
    NSString * urlStr=[_DIC[@"imgUrl"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [headerPicture setImageWithURLString: urlStr placeholderImage:[UIImage imageNamed:@"loadFail"]];
    NSLog(@"大图：%@",_DIC[@"imgUrl"]);
    NSLog(@"---------------------------------");
    [self.baseView addSubview:headerPicture];
    return 240;
}

-(CGFloat)loadTitleLable:(CGFloat)startY
{
    UILabel * titleLable=[[UILabel alloc]initWithFrame:CGRectMake(15, startY, self.view.bounds.size.width-30, 50)];
    titleLable.backgroundColor=[UIColor clearColor];
    titleLable.font=[UIFont systemFontOfSize:18];
    titleLable.text=_DIC[@"title"];
    titleLable.textColor=[UIColor colorWithHex:0x323232];
    [self.baseView addSubview:titleLable];
    return startY+50;
}

-(CGFloat)loadTitleDetail:(CGFloat)startY
{
    
    UILabel * titleDetail=[UILabel new];
    NSString * text=_DIC[@"description"];
    UIFont *textFont = [UIFont systemFontOfSize:13];
    UIColor *textColor = [UIColor colorWithHex:0xa5a5a5];
    titleDetail.backgroundColor=[UIColor clearColor];
    
    CGSize size=[BOAssistor string:text sizeWithFont:textFont constrainedToWidth:self.view.bounds.size.width-30 lineBreakMode:NSLineBreakByWordWrapping];
    titleDetail.frame=CGRectMake(15, startY,self.view.bounds.size.width-30,size.height);
    titleDetail.numberOfLines=0;
    
    titleDetail.text=text;
    titleDetail.font=textFont;
    titleDetail.textColor=textColor;
    [self.baseView addSubview:titleDetail];
    return startY+size.height;
}

-(CGFloat)loadLine:(CGFloat)startY
{
    UIView * lineView=[[UIView alloc]initWithFrame:CGRectMake(15, startY+15,self.view.bounds.size.width-30, 0.5)];
    lineView.backgroundColor=[UIColor colorWithHex:0xe5e5e6];
    [self.baseView addSubview:lineView];
    
    TYDBreastDetailModel * model =self.breastDrillDetailInfos[0];
    if(!model.paragraphImgUrl&&!model.paragraphContent)
    {
        lineView.hidden = YES;
        return startY;
    }
    else
    {
        return startY+16;
    }
}

-(CGFloat)loadEveryStepPictureAndExplain:(float)startY
{
    CGFloat allStartY=0;
    for(int i=0;i<[self.breastDrillDetailInfos count];i++)
    {
        TYDBreastDetailModel *model = self.breastDrillDetailInfos[i];
        if(model.paragraphImgUrl)
        {
            UIImageView * imagV=[[UIImageView alloc]initWithFrame:CGRectMake(15, startY+allStartY, self.view.bounds.size.width-30, 200)];
            NSString *urlString = model.paragraphImgUrl;
            [imagV setImageWithURLString:urlString placeholderImage:[UIImage imageNamed:@"loadFail"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                
            }];
            [self.baseView addSubview:imagV];
            allStartY+=(200+10)*(model.paragraphImgUrl!=nil);
        }
        else
        {
            NSLog(@"不存在更多的图片了");
        }
        if(model.paragraphContent)
        {
            UILabel * stepLable=[UILabel new];
            NSString * text=model.paragraphContent;
            UIFont *textFont = [UIFont systemFontOfSize:13];
            UIColor *textColor = [UIColor colorWithHex:0xa5a5a5];
            stepLable.backgroundColor=[UIColor clearColor];
            
            CGSize size=[BOAssistor string:text sizeWithFont:textFont constrainedToWidth:self.view.bounds.size.width-30 lineBreakMode:NSLineBreakByWordWrapping];
            stepLable.frame=CGRectMake(15, startY+allStartY,self.view.bounds.size.width-30,size.height);
            stepLable.numberOfLines=0;
            
            stepLable.tag=i;
            stepLable.text=text;
            stepLable.font=textFont;
            stepLable.textColor=textColor;
            [self.baseView addSubview:stepLable];
            allStartY+=size.height+5;
        }
        else
        {
            NSLog(@"不存在更多的说明了");
        }
    }
    return startY+allStartY;
}

-(void)praiseButtonTapAction
{
    if(![TYDUserInfo sharedUserInfo].isUserAccountEnable)
    {
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"你还未登录，请先登录！" delegate:self cancelButtonTitle:@"返回" otherButtonTitles:@"确定", nil];
        [alertView show];
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:[NSString stringWithFormat:@"%ld", (long)_detailVCModelId] forKey:@"categoryId"];
    [params setValue:[NSString stringWithFormat:@"%ld", (long)_attentionMark] forKey:@"status"];
    [params setValue:@4 forKey:@"source"];
    [self postURLRequestWithMessageCode:ServiceMsgCodePraiseButton HUDLabelText:nil params:params completeBlock:^(id result) {
        [self loadPraiseButtonInfoComplete:result withModel:_breastListModel];
        NSLog(@"%@",result);
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
- (CGFloat)loadPraiseButton:(CGFloat)startY
{
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectMake(15, startY+5,self.view.bounds.size.width-30, 0.5)];
    lineView.backgroundColor = [UIColor colorWithHex:0xe5e5e6];
    [self.baseView addSubview:lineView];
    UIView * baseView =[[UIView alloc]initWithFrame:CGRectMake(0, startY+5, self.view.bounds.size.width, 45)];
    baseView.backgroundColor =[UIColor clearColor];
    
    UIButton * praiseButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,70,35)];
    [praiseButton setBackgroundImage:[UIImage imageNamed:@"praisebg"] forState:UIControlStateNormal];
    UIImageView *heartIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"grayHeartIcon"] highlightedImage:[UIImage imageNamed:@"redHeartIcon"]];
    heartIcon.tag=4001;
    heartIcon.frame = CGRectMake(15, 7, 20, 20);
    heartIcon.highlighted = (_attentionMark == 1);
    [praiseButton addSubview:heartIcon];
    UILabel * lable = [[UILabel alloc]initWithFrame:CGRectMake(35, 10, 30, 13)];
    lable.backgroundColor = [UIColor clearColor];
    lable.text=[NSString stringWithFormat:@"%ld",(long)_praiseButtonNumberText];
    lable.adjustsFontSizeToFitWidth=YES;
    lable.tag=4000;
    lable.textColor = [UIColor colorWithHex:0x767676];
    lable.textAlignment = NSTextAlignmentCenter;
    lable.font = [UIFont systemFontOfSize:14];
    [praiseButton addSubview:lable];
    
    UITapGestureRecognizer * tap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(praiseButtonTapAction)];
    praiseButton.userInteractionEnabled=YES;
    [praiseButton addGestureRecognizer:tap];
    
    praiseButton.center = CGPointMake(self.view.width/2,baseView.size.height/2);
    [baseView addSubview:praiseButton];
    [self.baseView addSubview:baseView];
    return startY+50;
}

-(void)loadPraiseButtonInfoComplete:(id)result withModel:(TYDBreastListModel*)model
{
    NSLog(@"loadPraiseButtonInfoComplete:%@", result);
    NSNumber *resultGet = result[@"result"];
    if(resultGet.integerValue==0)
    {
        UIImageView * view=(UIImageView * )[self.view viewWithTag:4001];
        if(_attentionMark==0)
        {
            [self showProgressCompleteWithLabelText:@" 已点赞 " isSucceed:YES];
            _attentionMark = 1;
            view.highlighted = YES;
        }
        else if (_attentionMark==1)
        {
            [self showProgressCompleteWithLabelText:@"点赞取消" isSucceed:YES];
            _attentionMark = 0;
            view.highlighted = NO;
        }
        NSString * key=[NSString stringWithFormat:@"id%@IsAttentionBreastClass",model.cookbookID];
        NSString * userName = [TYDUserInfo sharedUserInfo].username;
        NSString * userAttentionKey = [NSString stringWithFormat:@"%@%@",userName,key];
        NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setInteger:_attentionMark forKey:userAttentionKey];
        [userDefault synchronize];

        model.numberText=result[@"praise"];
        UILabel * label=(UILabel * )[self.view viewWithTag:4000];
        label.text=[NSString stringWithFormat:@"%ld",(long)model.numberText.integerValue];
        if([self.delegate respondsToSelector:@selector(breastClassDetailViewControllerBreastClassModelUpdated:)])
        {
            [self.delegate breastClassDetailViewControllerBreastClassModelUpdated:self];
        }
        
    }
    else if (resultGet.integerValue==-1)
    {
        [self hiddenProgressHUD];
        [self setNoticeText:@"点赞失败"];
    }
    
}

@end
