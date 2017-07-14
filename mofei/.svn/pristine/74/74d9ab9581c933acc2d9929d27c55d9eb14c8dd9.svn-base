//
//  TYDBreastDetailModel.m
//  Mofei
//
//  Created by caiyajie on 14-12-2.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import "TYDBreastDetailModel.h"

@implementation TYDBreastDetailModel

- (NSDictionary *)attributeMapDictionary
{
    NSDictionary *mapDic =
    @{
        @"id"               :@"cookbookID",
        @"paragraphContent" :@"paragraphContent",
        @"paragraphImgUrl"  :@"paragraphImgUrl"
    };
    return mapDic;
}

- (void)setAttributes:(NSDictionary *)dataDic
{
    NSDictionary *attrMapDic = [self attributeMapDictionary];
    for(NSString *mapDicKey in attrMapDic)
    {
        SEL sel = [self getSetterSelWithAttibuteName:attrMapDic[mapDicKey]];
        if([self respondsToSelector:sel])
        {
            NSString *dataDicKey = mapDicKey;
            id attributeValue = dataDic[dataDicKey];
            if(!attributeValue) continue;
            
            [self performSelectorOnMainThread:sel
                                   withObject:attributeValue
                                waitUntilDone:[NSThread isMainThread]];
        }
    }
    self.paragraphImgUrl = [self.paragraphImgUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (SEL)getSetterSelWithAttibuteName:(NSString *)attributeName
{
    NSString *capital = [[attributeName substringToIndex:1] uppercaseString];
    NSString *setterSelStr = [NSString stringWithFormat:@"set%@%@:", capital, [attributeName substringFromIndex:1]];
    return NSSelectorFromString(setterSelStr);
}

@end
