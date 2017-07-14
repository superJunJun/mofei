//
//  TYDMensesInfoAssistorSet.h
//  Mofei
//
//  Created by macMini_Dev on 14/12/18.
//  Copyright (c) 2014年 Young. All rights reserved.
//
//  仅用于经期数据库信息条目到上传格式的转换
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TYDMensesInfoItemType)
{
    TYDMensesInfoItemTypeNone   = 0,
    TYDMensesInfoItemTypeStart  = 1,
    TYDMensesInfoItemTypeEnd    = 2
};

@interface TYDMensesTransformInfo : NSObject

@property (strong, nonatomic) NSString *timeStamp;
@property (assign, nonatomic) NSInteger type;
@property (assign, nonatomic) BOOL syncFlag;
@property (assign, nonatomic) BOOL modifiedFlag;

@end

@interface TYDMensesInfoAssistorSet : NSObject

@property (strong, nonatomic) NSString *nextLineFlagString;
@property (strong, nonatomic, readonly) NSString *stringOfLocalInfos;
@property (strong, nonatomic, readonly) NSString *stringOfUpdatedInfos;
@property (strong, nonatomic, readonly) NSString *stringOfModifiedInfos;
- (void)refreshInfosFromDataBase;

@end
