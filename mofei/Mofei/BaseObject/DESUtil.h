//
//  DESUtil.h
//  Mofei
//
//  Created by notebook37 on 14/11/17.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DESUtil : NSObject

+ (NSData *)DESEncrypt:(NSData *)data WithKey:(NSString *)key;
+ (NSData *)DESDecrypt:(NSData *)data WithKey:(NSString *)key;

@end
