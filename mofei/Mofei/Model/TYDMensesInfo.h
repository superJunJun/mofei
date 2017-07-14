//
//  TYDMensesInfo.h
//  Mofei
//
//  Created by macMini_Dev on 14/11/13.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TYDMensesInfo : NSObject// <NSCopying>

@property (nonatomic) NSInteger timeStamp;
@property (nonatomic) NSInteger endTimeStamp;
@property (nonatomic) BOOL syncFlag;
@property (nonatomic) BOOL modifiedFlag;

@end
