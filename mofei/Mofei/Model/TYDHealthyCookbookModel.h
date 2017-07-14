//
//  TYDHealthyCookbookModel.h
//  Mofei
//
//  Created by caiyajie on 14-10-21.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import "TYDBaseModel.h"

@interface TYDHealthyCookbookModel : TYDBaseModel

@property (strong, nonatomic) NSNumber *cookbookID;
@property (strong, nonatomic) NSString *pictureUrl;
@property (strong, nonatomic) NSString *iconUrl;
@property (strong, nonatomic) NSString *titleText;
@property (strong, nonatomic) NSString *detailText;
@property (strong, nonatomic) NSNumber *numberText;

@property (strong, nonatomic) NSString *paragraphContent;
@property (strong, nonatomic) NSString *paragraphImgUrl;
@end
