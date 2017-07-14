//
//  CBPeripheral+UUIDString.h
//  Mofei
//
//  Created by macMini_Dev on 14-9-26.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

@interface CBPeripheral (UUIDString)

- (NSString *)UUIDString;
- (BOOL)didConnect;
- (BOOL)isEnableToConnect;
- (BOOL)isEqual:(CBPeripheral *)peripheral;

- (CBService *)serviceWithUUID:(CBUUID *)serviceUUID;
- (CBCharacteristic *)characteristicWithUUID:(CBUUID *)characteristicUUID inService:(CBService *)service;
- (CBCharacteristic *)characteristicWithUUID:(CBUUID *)characteristicUUID inServiceWithUUID:(CBUUID *)serviceUUID;

@end
