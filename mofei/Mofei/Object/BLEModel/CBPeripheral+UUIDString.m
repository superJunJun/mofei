//
//  CBPeripheral+UUIDString.m
//  Mofei
//
//  Created by macMini_Dev on 14-9-26.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import "CBPeripheral+UUIDString.h"

@implementation CBPeripheral (UUIDString)

- (NSString *)UUIDString
{
    NSString *uuidString = nil;
//    if([self respondsToSelector:@selector(identifier)])
//    {
//        uuidString = self.identifier.UUIDString;
//    }
//    else if(self.UUID)
//    {
//        uuidString = [NSString stringWithUTF8String:CFStringGetCStringPtr(CFUUIDCreateString(NULL, self.UUID), 0)];
//    }
    return uuidString;
}

- (BOOL)isEqual:(CBPeripheral *)peripheral
{
    return [self.UUIDString isEqualToString:peripheral.UUIDString];
}

- (BOOL)isEnableToConnect
{
    BOOL enableToConnect = NO;
    if([self respondsToSelector:@selector(state)])
    {
        enableToConnect = (self.state == CBPeripheralStateDisconnected);
    }
//    else
//    {
//        enableToConnect = !self.isConnected;
//    }
    return enableToConnect;
}

- (BOOL)didConnect
{
    BOOL isConnected = NO;
//    if([self respondsToSelector:@selector(isConnected)])
//    {
//        isConnected = self.isConnected;
//    }
//    else
//    {
//        isConnected = (self.state == CBPeripheralStateConnected);
//    }
    return isConnected;
}

#pragma mark - SearchService & Characteristic

- (CBService *)serviceWithUUID:(CBUUID *)serviceUUID
{
    for(CBService *service in self.services)
    {
        if([service.UUID isEqual:serviceUUID])
        {
            return service;
        }
    }
    return nil;
}

- (CBCharacteristic *)characteristicWithUUID:(CBUUID *)characteristicUUID inService:(CBService *)service
{
    for(CBCharacteristic *characteristic in service.characteristics)
    {
        if([characteristic.UUID isEqual:characteristicUUID])
        {
            return characteristic;
        }
    }
    return nil;
}

- (CBCharacteristic *)characteristicWithUUID:(CBUUID *)characteristicUUID inServiceWithUUID:(CBUUID *)serviceUUID
{
    CBService *service = [self serviceWithUUID:serviceUUID];
    if(service)
    {
        return [self characteristicWithUUID:characteristicUUID inService:service];
    }
    return nil;
}

@end
