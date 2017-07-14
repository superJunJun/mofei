//
//  TYDCookbookDetailViewController.h
//  Mofei
//
//  Created by caiyajie on 14-10-20.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import "BaseScrollController.h"
#import "TYDBreastDetailModel.h"
#import "TYDBreastListModel.h"

@class TYDCookbookDetailViewController;
@protocol TYDCookbookDetailViewControllerDelegate <NSObject>
@optional
- (void)cookbookDetailViewControllerCookbookModelUpdated:(TYDCookbookDetailViewController *)vc;
@end

@interface TYDCookbookDetailViewController : BaseScrollController

//@property (strong,nonatomic) TYDBreastDetailModel * model;
@property (assign, nonatomic) id<TYDCookbookDetailViewControllerDelegate> delegate;
@property (nonatomic) NSInteger detailVCModelId;

@property (nonatomic) NSInteger praiseButtonNumberText;
@property (nonatomic) NSInteger attentionMark;
@property (strong,nonatomic) TYDBreastListModel * cookbookModel;

@end
