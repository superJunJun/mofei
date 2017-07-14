//
//  TYDBreastListModel.m
//  Mofei
//
//  Created by caiyajie on 14-12-2.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import "TYDBreastListModel.h"

@implementation TYDBreastListModel

- (NSDictionary *)attributeMapDictionary
{
    NSDictionary *mapDic =
    @{
        @"id"               :@"cookbookID",
        @"title"            :@"titleText",
        @"description"      :@"detailText",
        @"imgUrl"           :@"pictureUrl",
        @"praise"           :@"numberText"
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
}

- (BOOL)isEqual:(TYDBreastListModel *)object
{
    return (object && [self.cookbookID isEqualToNumber:object.cookbookID]);
}

@end
