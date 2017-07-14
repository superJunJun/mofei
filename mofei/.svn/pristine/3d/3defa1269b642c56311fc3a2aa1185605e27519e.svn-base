//
//  CBUUID+UUIDString.m
//  EMove
//
//  Created by macMini_Dev on 15/4/1.
//  Copyright (c) 2015年 Young. All rights reserved.
//

#import "CBUUID+UUIDString.h"

@implementation CBUUID (UUIDString)

+ (instancetype)CBUUIDWithIntUUID:(int)iUUID
{
    return [CBUUID UUIDWithString:[NSString stringWithFormat:@"%0x", iUUID]];
}

- (int)intValue
{
    char b1[16];
    [self.data getBytes:b1];
    return ((b1[0] << 8) | b1[1]);
}

- (NSString *)description
{
    if([self respondsToSelector:@selector(UUIDString)])
    {
        return self.UUIDString;
    }
    else
    {
        return self.data.description;
    }
}

@end
