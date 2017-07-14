//
//  TYDBreastListModel.h
//  Mofei
//
//  Created by caiyajie on 14-12-2.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import "TYDBaseModel.h"

@interface TYDBreastListModel : TYDBaseModel

@property (strong, nonatomic) NSNumber *cookbookID;
@property (strong, nonatomic) NSString *pictureUrl;
@property (strong, nonatomic) NSString *iconUrl;
@property (strong, nonatomic) NSString *titleText;
@property (strong, nonatomic) NSString *detailText;
@property (strong, nonatomic) NSNumber *numberText;

@property (nonatomic) NSInteger isAttention;
@property (nonatomic) BOOL didRead;
//@property ()
@end
