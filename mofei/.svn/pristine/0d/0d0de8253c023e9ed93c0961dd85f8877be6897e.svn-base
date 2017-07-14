//
//  TYDCookbookParticularViewController.h
//  Mofei
//
//  Created by caiyajie on 14-10-22.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import "BaseScrollController.h"
#import "TYDBreastDetailModel.h"
#import "TYDBreastListModel.h"

@class TYDCookbookParticularViewController;
@protocol TYDCookbookParticularViewControllerDelegate <NSObject>
@optional
- (void)cookbookParticularViewControllerCookbookModelUpdated:(TYDCookbookParticularViewController *)vc;
@end



@interface TYDCookbookParticularViewController : BaseScrollController
@property (assign, nonatomic) id<TYDCookbookParticularViewControllerDelegate> delegate;

@property (strong,nonatomic) TYDBreastDetailModel * model;
@property (nonatomic) NSInteger detailVCModelId;


@property (nonatomic) NSInteger praiseButtonNumberText;
@property (nonatomic) NSInteger attentionMark;
@property (strong,nonatomic) TYDBreastListModel * cookbookModel;
@end
