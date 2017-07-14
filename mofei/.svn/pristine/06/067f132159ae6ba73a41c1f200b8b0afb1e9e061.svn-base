//
//  TYDBreastClassDetailViewController.h
//  Mofei
//
//  Created by caiyajie on 14-10-30.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import "BaseScrollController.h"
#import "TYDBreastDetailModel.h"
#import "TYDBreastListModel.h"

@class TYDBreastClassDetailViewController;
@protocol TYDBreastClassDetailViewControllerDelegate <NSObject>
@optional
- (void)breastClassDetailViewControllerBreastClassModelUpdated:(TYDBreastClassDetailViewController *)vc;
@end

@interface TYDBreastClassDetailViewController : BaseScrollController
@property (assign, nonatomic) id<TYDBreastClassDetailViewControllerDelegate> delegate;
@property (strong,nonatomic) TYDBreastDetailModel * model;
@property (nonatomic) NSInteger detailVCModelId;

@property (nonatomic) NSInteger praiseButtonNumberText;
@property (nonatomic) NSInteger attentionMark;
@property (strong,nonatomic) TYDBreastListModel * breastListModel;

@end
