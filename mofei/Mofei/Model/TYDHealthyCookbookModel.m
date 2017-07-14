//
//  TYDHealthyCookbookModel.m
//  Mofei
//
//  Created by caiyajie on 14-10-21.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import "TYDHealthyCookbookModel.h"

@implementation TYDHealthyCookbookModel

- (NSDictionary *)attributeMapDictionary
{
    NSDictionary *mapDic =
    @{
        @"id"               :@"cookbookID",
        @"title"            :@"titleText",
        @"description"      :@"detailText",
        @"imgUrl"           :@"pictureUrl",
        @"praise"           :@"numberText",
        @"paragraphContent" :@"paragraphContent",
        @"paragraphImgUrl"  :@"paragraphImgUrl"
    };
    return mapDic;
}

- (void)setAttributes:(NSDictionary *)dataDic
{
    [super setAttributes:dataDic];
    [self attributeFix];
}

- (void)attributeFix
{
    self.pictureUrl = [self.pictureUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    self.paragraphImgUrl = [self.paragraphImgUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

//- (BOOL)isEqual:(TYDHealthyCookbookModel *)object
//{
//    return (object && [self.cookbookID isEqualToNumber:object.cookbookID]);
//}

@end
