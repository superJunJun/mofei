//
//  TYDBreastDrillDetailViewController.h
//  Mofei
//
//  Created by caiyajie on 14-10-22.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import "BaseScrollController.h"
#import "TYDBreastDetailModel.h"
#import "TYDBreastListModel.h"

@class TYDBreastDrillDetailViewController;
@protocol TYDBreastDrillDetailViewControllerDelegate <NSObject>
@optional
- (void)breastDrillViewControllerBreastDrillModelUpdated:(TYDBreastDrillDetailViewController *)vc;
@end


@interface TYDBreastDrillDetailViewController : BaseScrollController
@property (assign, nonatomic) id<TYDBreastDrillDetailViewControllerDelegate> delegate;
@property (strong,nonatomic) TYDBreastDetailModel * model;
@property (nonatomic) NSInteger detailVCModelId;


@property (nonatomic) NSInteger praiseButtonNumberText;
@property (nonatomic) NSInteger attentionMark;
@property (strong,nonatomic) TYDBreastListModel * breastDrillModel;

@end
