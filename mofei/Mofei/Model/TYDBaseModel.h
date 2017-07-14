//
//  TYDBaseModel.h
//  Mofei
//
//  Created by macMini_Dev on 14-9-9.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TYDBaseModel : NSObject

//属性字典,json解析后的字典key与本地属性名合成的属性字典
- (NSDictionary *)attributeMapDictionary;

//通过字典设置属性
- (void)setAttributes:(NSDictionary *)dataDic;

//NSNumber类型属性校正
- (NSNumber *)numberValueFix:(id)number;

//NSString类型属性校正
- (NSString *)stringValueFix:(id)string;

//将值为@"0"的字串转为@""
- (NSString *)clearZeroValueString:(NSString *)string;

@end
