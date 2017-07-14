//
//  TYDBLEDeviceManager.h
//  Mofei
//
//  Created by macMini_Dev on 14-9-26.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYDBLECBKeyfob.h"

typedef NS_ENUM(NSInteger, TYDBLEDeviceManagerState)
{
    TYDBLEDeviceManagerStateNone = 0,
    TYDBLEDeviceManagerStateConnecting,
    TYDBLEDeviceManagerStateDiscoverServices,
    TYDBLEDeviceManagerStateDiscoverCharacteristics,
    TYDBLEDeviceManagerStateConnected
};

@class TYDBLEDeviceManager;
@protocol TYDBLEDeviceManagerDelegate <NSObject>
@optional
- (void)centralManagerStateDidUpdate:(CBCentralManager *)central;
- (void)centralManagerDidStartScanBLEPeripherals:(CBCentralManager *)central;
- (void)centralManagerDidStopScanBLEPeripherals:(CBCentralManager *)central;

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral;
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral;
- (void)centralManager:(CBCentralManager *)central disconnectPeripheral:(CBPeripheral *)peripheral;

- (void)deviceManager:(TYDBLEDeviceManager *)manager connectStateUpdated:(TYDBLEDeviceManagerState)connectState;
@end

@protocol TYDBLEDeviceManagerBatteryDelegate <NSObject>
@optional
- (void)deviceBatteryLevelUpdated:(CGFloat)batteryLevel;
@end

@protocol TYDBLEDeviceManagerDeviceDisconnectDelegate <NSObject>
@optional
- (void)centralManagerDisconnectPeripheral:(CBPeripheral *)peripheral;
@end

@protocol TYDBLEDeviceManagerStepDataDelegate <NSObject>
- (void)deviceManagerOfflineStepDataUpdated:(NSUInteger)stepCount startTime:(NSUInteger)startTime endTime:(NSUInteger)endTime;
- (void)deviceManagerHeartRateMeasureDropCheckReport:(BOOL)isDropped;
@end

@interface TYDBLEDeviceManager : NSObject

@property (assign, nonatomic) id<TYDBLEDeviceManagerDelegate> delegate;
@property (strong, nonatomic, readonly) CBPeripheral *activePeripheral;
@property (nonatomic, readonly) CBCentralManagerState centralState;

@property (nonatomic, readonly) TYDBLEDeviceManagerState connectState;
@property (nonatomic, readonly) CGFloat batteryLevel;
@property (nonatomic, readonly) NSUInteger heartRate;
@property (nonatomic, readonly) NSUInteger stepCount;

@property (assign, nonatomic) id<TYDBLEDeviceManagerBatteryDelegate> batteryDelegate;
@property (assign, nonatomic) id<TYDBLEDeviceManagerStepDataDelegate> stepDataDelegate;
@property (assign, nonatomic) id<TYDBLEDeviceManagerDeviceDisconnectDelegate> disconnectDelegate;

+ (instancetype)sharedBLEDeviceManager;

- (BOOL)activePeripheralEnable;
- (void)scanBLEPeripherals;
- (void)stopScanBLEPeripherals;
- (void)connectPeripheral:(CBPeripheral *)peripheral;
- (void)disconnectActivePeripheral;
- (void)readBatteryLevel;

- (void)remindAlertStateSet;
- (void)refreshStepCountWithNewValue:(NSUInteger)stepCountNew;

@end
