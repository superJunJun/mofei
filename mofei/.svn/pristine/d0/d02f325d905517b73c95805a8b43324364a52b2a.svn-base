//
//  TYDBLECBKeyfob.m
//  Mofei
//
//  Created by macMini_Dev on 14-9-11.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import "TYDBLECBKeyfob.h"
#import "TIBLECBKeyfobDefines.h"
#import "CBUUID+UUIDString.h"
#import "CBPeripheral+UUIDString.h"

@interface TYDBLECBKeyfob () <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic) char x;
@property (nonatomic) char y;
@property (nonatomic) char z;

@end

@implementation TYDBLECBKeyfob

//#pragma mark - SingleTon
//
//+ (instancetype)sharedBLEKeyfob
//{
//    static TYDBLECBKeyfob *BLEKeyfobInstance = nil;
//    static dispatch_once_t predicate;
//    dispatch_once(&predicate, ^{
//        BLEKeyfobInstance = [[self alloc] init];
//    });
//    return BLEKeyfobInstance;
//}

- (instancetype)init
{
    if(self = [super init])
    {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];//dispatch_get_main_queue()
        //_activePeripheral = nil;
    }
    return self;
}

#pragma mark - Scan Peripherals

- (void)scanBLEPeripherals
{
    NSLog(@"scanBLEPeripherals");
    if(self.centralManager.state != CBCentralManagerStatePoweredOn)
    {
        NSLog(@"scanBLEPeripherals Failed:%@", [self centralManagerStateToString:self.centralManager.state]);
        return;
    }
    
    [self.centralManager scanForPeripheralsWithServices:nil options:0];
}

- (void)stopScanBLEPeripherals
{
    NSLog(@"stopScanBLEPeripherals");
    [self.centralManager stopScan];
}

#pragma mark - Find Service & Characteristic

- (CBService *)findServiceWithUUID:(CBUUID *)UUID inPeripheral:(CBPeripheral *)peripheral
{
    for(CBService *service in peripheral.services)
    {
        if([service.UUID isEqual:UUID])
        {
            return service;
        }
    }
    return nil;
}

- (CBCharacteristic *)findCharacteristicWithUUID:(CBUUID *)UUID inService:(CBService *)service
{
    for(CBCharacteristic *characteristic in service.characteristics)
    {
        if([characteristic.UUID isEqual:UUID])
        {
            return characteristic;
        }
    }
    return nil;
}

- (void)getAllServicesOfPeripheral:(CBPeripheral *)peripheral
{
    if(peripheral)
    {
        peripheral.delegate = self;
        [peripheral discoverServices:nil];
    }
}

- (void)getAllCharacteristicsOfPeripheral:(CBPeripheral *)peripheral
{
    for(CBService *service in peripheral.services)
    {
        NSLog(@"Fetching characteristics for service with UUID:%@", service.UUID.description);
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

#pragma mark - ConnectRelative

- (void)connectPeripheral:(CBPeripheral *)peripheral
{
    if(peripheral.isEnableToConnect)
    {// 连接设备
        [self.centralManager connectPeripheral:peripheral options:nil];
        //_activePeripheral = peripheral;
    }
}

- (void)disconnectPeripheral:(CBPeripheral *)peripheral
{
    if(peripheral)
    {// 断开连接
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
//    if(peripheral == self.activePeripheral)
//    {
//        _activePeripheral = nil;
//    }
}

//- (void)disconnectActivePeripheral
//{
//    if(self.activePeripheral)
//    {
//        [self.centralManager cancelPeripheralConnection:self.activePeripheral];
//    }
//}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSLog(@"centralManagerDidUpdateState:%@", [self centralManagerStateToString:central.state]);
    
    if([self.delegate respondsToSelector:@selector(centralManagerStateDidUpdate:)])
    {
        [self.delegate centralManagerStateDidUpdate:central];
    }
}

//发现设备
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"discoverPeripheral:%@ UUID:%@", peripheral.name, peripheral.UUIDString);
    if([peripheral.name rangeOfString:sGivenPeripheralName options:NSCaseInsensitiveSearch].length > 0)
    {
        if([self.delegate respondsToSelector:@selector(centralManager:didDiscoverPeripheral:)])
        {
            [self.delegate centralManager:central didDiscoverPeripheral:peripheral];
        }
    }
}

//连接设备成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    if([self.delegate respondsToSelector:@selector(centralManager:connectPeripheral:succeed:)])
    {
        [self.delegate centralManager:central connectPeripheral:peripheral succeed:YES];
    }
    
    [self getAllServicesOfPeripheral:peripheral];
}

//连接设备失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if([self.delegate respondsToSelector:@selector(centralManager:connectPeripheral:succeed:)])
    {
        [self.delegate centralManager:central connectPeripheral:peripheral succeed:NO];
    }
}

//设备断连回调
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"didDisconnectPeripheral");
    //_activePeripheral = nil;
    if([self.delegate respondsToSelector:@selector(centralManager:disconnectPeripheral:)])
    {
        [self.delegate centralManager:central disconnectPeripheral:peripheral];
    }
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if([self.delegate respondsToSelector:@selector(peripheral:didDiscoverServicesSucceed:)])
    {
        [self.delegate peripheral:peripheral didDiscoverServicesSucceed:!error];
    }
    
    if(!error)
    {
        NSLog(@"discovered services of peripheral with UUID:%@", peripheral.UUIDString);
        [self getAllCharacteristicsOfPeripheral:peripheral];
    }
    else
    {
        NSLog(@"Service discovery was unsuccessfull:%@", error);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if(!error)
    {
        NSLog(@"Found characteristics of service with UUID:%@", service.UUID.description);
        for(CBCharacteristic *characteristic in service.characteristics)
        {
            NSLog(@"Found characteristics:%@", characteristic.UUID.description);
        }
        
        CBService *lastService = [peripheral.services lastObject];
        //if([self compareCBUUID:service.UUID withUUID2:lastService.UUID])
        if([service.UUID isEqual:lastService.UUID])
        {
            if([self.delegate respondsToSelector:@selector(peripheralKeyfobReady:)])
            {
                [self.delegate peripheralKeyfobReady:peripheral];
            }
        }
    }
    else
    {
        NSLog(@"Characteristic discorvery unsuccessfull");
        if([self.delegate respondsToSelector:@selector(peripheralDiscoverCharacteristicsFailed:)])
        {
            [self.delegate peripheralDiscoverCharacteristicsFailed:peripheral];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    UInt16 characteristicUUID = characteristic.UUID.intValue;
    if(!error)
    {
        switch(characteristicUUID)
        {
            case TI_KEYFOB_LEVEL_SERVICE_UUID:
            {
                char batlevel;
                [characteristic.value getBytes:&batlevel length:TI_KEYFOB_LEVEL_SERVICE_READ_LEN];
                if([self.delegate respondsToSelector:@selector(batteryLevelUpdated:)])
                {
                    [self.delegate batteryLevelUpdated:batlevel];
                }
                break;
            }
            case TI_KEYFOB_KEYS_NOTIFICATION_UUID:
            {
                break;
            }
            case TI_KEYFOB_ACCEL_X_UUID:
            {
                char xValue;
                [characteristic.value getBytes:&xValue length:TI_KEYFOB_ACCEL_READ_LEN];
                self.x = xValue;
                if([self.delegate respondsToSelector:@selector(accelerometerValuesUpdatedX:y:z:)])
                {
                    [self.delegate accelerometerValuesUpdatedX:self.x y:self.y z:self.z];
                }
                break;
            }
            case TI_KEYFOB_ACCEL_Y_UUID:
            {
                char yValue;
                [characteristic.value getBytes:&yValue length:TI_KEYFOB_ACCEL_READ_LEN];
                self.y = yValue;
                if([self.delegate respondsToSelector:@selector(accelerometerValuesUpdatedX:y:z:)])
                {
                    [self.delegate accelerometerValuesUpdatedX:self.x y:self.y z:self.z];
                }
                break;
            }
            case TI_KEYFOB_ACCEL_Z_UUID:
            {
                char zValue;
                [characteristic.value getBytes:&zValue length:TI_KEYFOB_ACCEL_READ_LEN];
                self.z = zValue;
                if([self.delegate respondsToSelector:@selector(accelerometerValuesUpdatedX:y:z:)])
                {
                    [self.delegate accelerometerValuesUpdatedX:self.x y:self.y z:self.z];
                }
                break;
            }
            case TI_KEYFOB_PROXIMITY_TX_PWR_NOTIFICATION_UUID:
            {
                char TXLevel;
                [characteristic.value getBytes:&TXLevel length:TI_KEYFOB_PROXIMITY_TX_PWR_NOTIFICATION_READ_LEN];
                if([self.delegate respondsToSelector:@selector(TXPowerLevelUpdated:)])
                {
                    [self.delegate TXPowerLevelUpdated:TXLevel];
                }
                break;
            }
            case TI_KEYFOB_HEARTRATE_MEASURE_NOTIFICATION_UUID:
            {
                NSUInteger length = TI_KEYFOB_HEARTRATE_NOTIFICATION_READ_LEN;
                char heartRateValue[length];
                [characteristic.value getBytes:heartRateValue length:length];
                if([self.delegate respondsToSelector:@selector(heartRateDataUpdated:)])
                {
                    [self.delegate heartRateDataUpdated:heartRateValue];
                }
                break;
            }
            case TI_KEYFOB_TIME_SYNCHRONOUS_UUID:
            {
                int length = TI_KEYFOB_TIME_SYNCHRONOUS_READ_LEN;
                char value[length];
                [characteristic.value getBytes:value length:length];
                UInt32 *timeInterval = (UInt32 *)value;
                NSUInteger time = *timeInterval + nLocalTimeStampBenchMark;
                
                if([self.delegate respondsToSelector:@selector(peripheralSystemTimeRead:)])
                {
                    [self.delegate peripheralSystemTimeRead:time];
                }
                break;
            }
            case TI_KEYFOB_STEP_MEASURE_NOTIFICATION_UUID:
            {
                int length = TI_KEYFOB_STEP_NOTIFICATION_MAX_READ_LEN;
                char value[length];
                [characteristic.value getBytes:value length:length];
                if([self.delegate respondsToSelector:@selector(stepDataUpdated:)])
                {
                    [self.delegate stepDataUpdated:value];
                }
                break;
            }
            case TI_KEYFOB_REMIND_ALERT_UUID:
            {
                NSUInteger length = TI_KEYFOB_REMIND_ALERT_READ_LEN;
                char info[length];
                [characteristic.value getBytes:info length:length];
                UInt32 *ptr = (UInt32 *)info;
                NSUInteger startTime = *ptr + nLocalTimeStampBenchMark;
                NSUInteger endTime = *(ptr + 1) + nLocalTimeStampBenchMark;
                NSUInteger interval = 600 * info[length - 1];
                if([self.delegate respondsToSelector:@selector(peripheralRemindAlertInfoRead:endTime:alertInterval:)])
                {
                    [self.delegate peripheralRemindAlertInfoRead:startTime endTime:endTime alertInterval:interval];
                }
                break;
            }
        }
    }    
    else
    {
        printf("UpdateValueForCharacteristic failed !");
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(!error)
    {
        NSLog(@"Updated notification state for characteristic with UUID %@ service with  UUID %@ on peripheral with UUID %@", characteristic.UUID.description, characteristic.service.UUID.description, peripheral.UUIDString);
    }
    else
    {
        NSLog(@"Error in setting notification state for characteristic with UUID %@ service with  UUID %@ on peripheral with UUID %@", characteristic.UUID.description, characteristic.service.UUID.description, peripheral.UUIDString);
        NSLog(@"Error code:%@", error);
    }
}

#pragma mark - AssistorFunc

- (NSString *)centralManagerStateToString:(CBCentralManagerState)state
{
    NSString *stateString = @"CentralManagerStateUnknown";
    switch(state)
    {
        case CBCentralManagerStateUnknown:
            stateString = @"CentralManagerStateUnknown";
            break;
        case CBCentralManagerStateResetting:
            stateString = @"CentralManagerStateResetting";
            break;
        case CBCentralManagerStateUnsupported:
            stateString = @"CentralManagerStateUnsupported";
            break;
        case CBCentralManagerStateUnauthorized:
            stateString = @"CentralManagerStateUnauthorized";
            break;
        case CBCentralManagerStatePoweredOff:
            stateString = @"CentralManagerStatePoweredOff";
            break;
        case CBCentralManagerStatePoweredOn:
            stateString = @"CentralManagerStatePoweredOn";
            break;
        default:
            stateString = @"CentralManagerStateDefault";
    }
    return stateString;
}

#pragma mark - Event

- (CBCharacteristic *)findCharacteristicWithServiceUUID:(int)serviceUUID characteristicUUID:(int)characteristicUUID inPeripheral:(CBPeripheral *)peripheral
{
    CBUUID *sUUID = [CBUUID UUIDWithString:[NSString stringWithFormat:@"%x", serviceUUID]];
    CBUUID *cUUID = [CBUUID UUIDWithString:[NSString stringWithFormat:@"%x", characteristicUUID]];
    CBService *service = [self findServiceWithUUID:sUUID inPeripheral:peripheral];
    CBCharacteristic *characteristic = [self findCharacteristicWithUUID:cUUID inService:service];
    if(!characteristic)
    {
        NSLog(@"Could not find characteristic with UUID %@ on service with UUID %@ on peripheral with UUID %@", cUUID.description, sUUID.description, peripheral.UUIDString);
    }
    
    return characteristic;
    
//    CBService *service = [self findServiceWithUUID:sUUID inPeripheral:peripheral];
//    if(!service)
//    {
//        NSLog(@"Could not find service with UUID %@ on peripheral with UUID %@", [self CBUUIDToString:sUUID], [self UUIDStringOfPeripheral:peripheral]);
//        return;
//    }
//    CBCharacteristic *characteristic = [self findCharacteristicWithUUID:cUUID inService:service];
//    if(!characteristic)
//    {
//        NSLog(@"Could not find characteristic with UUID %@ on service with UUID %@ on peripheral with UUID %@", [self CBUUIDToString:cUUID], [self CBUUIDToString:sUUID], [self UUIDStringOfPeripheral:peripheral]);
//        return;
//    }
}

- (void)writeValue:(int)serviceUUID characteristicUUID:(int)characteristicUUID peripheral:(CBPeripheral *)peripheral data:(NSData *)data
{
    CBCharacteristic *characteristic = [self findCharacteristicWithServiceUUID:serviceUUID characteristicUUID:characteristicUUID inPeripheral:peripheral];
    if(characteristic)
    {
        [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
    }
}

- (void)readValue:(int)serviceUUID characteristicUUID:(int)characteristicUUID peripheral:(CBPeripheral *)peripheral
{
    CBCharacteristic *characteristic = [self findCharacteristicWithServiceUUID:serviceUUID characteristicUUID:characteristicUUID inPeripheral:peripheral];
    if(characteristic)
    {
        [peripheral readValueForCharacteristic:characteristic];
    }
}

- (void)notification:(int)serviceUUID characteristicUUID:(int)characteristicUUID peripheral:(CBPeripheral *)peripheral on:(BOOL)on
{
    CBCharacteristic *characteristic = [self findCharacteristicWithServiceUUID:serviceUUID characteristicUUID:characteristicUUID inPeripheral:peripheral];
    if(characteristic)
    {
        [peripheral setNotifyValue:on forCharacteristic:characteristic];
    }
}

- (void)soundBuzzer:(CBPeripheral *)peripheral
{
    NSLog(@"soundBuzzer");
    Byte buzzerValue = 0x02;
    NSData *data = [[NSData alloc] initWithBytes:&buzzerValue length:TI_KEYFOB_PROXIMITY_ALERT_WRITE_LEN];
    [self writeValue:TI_KEYFOB_PROXIMITY_ALERT_UUID characteristicUUID:TI_KEYFOB_PROXIMITY_ALERT_PROPERTY_UUID peripheral:peripheral data:data];
}

- (void)readBattery:(CBPeripheral *)peripheral
{
    NSLog(@"readBattery");
    [self readValue:TI_KEYFOB_BATT_SERVICE_UUID characteristicUUID:TI_KEYFOB_LEVEL_SERVICE_UUID peripheral:peripheral];
}

- (void)enableBatteryNotification:(CBPeripheral *)peripheral
{
    NSLog(@"enableBatteryNotification");
    [self notification:TI_KEYFOB_BATT_SERVICE_UUID characteristicUUID:TI_KEYFOB_LEVEL_SERVICE_UUID peripheral:peripheral on:YES];
}

- (void)disableBatteryNotification:(CBPeripheral *)peripheral
{
    NSLog(@"disableBatteryNotification");
    [self notification:TI_KEYFOB_BATT_SERVICE_UUID characteristicUUID:TI_KEYFOB_LEVEL_SERVICE_UUID peripheral:peripheral on:NO];
}

- (void)enableAccelerometer:(CBPeripheral *)peripheral
{
    NSLog(@"enableAccelerometer");
    Byte value = 0x01;
    NSData *data = [[NSData alloc] initWithBytes:&value length:1];
    [self writeValue:TI_KEYFOB_ACCEL_SERVICE_UUID characteristicUUID:TI_KEYFOB_ACCEL_ENABLER_UUID peripheral:peripheral data:data];
    [self notification:TI_KEYFOB_ACCEL_SERVICE_UUID characteristicUUID:TI_KEYFOB_ACCEL_X_UUID peripheral:peripheral on:YES];
    [self notification:TI_KEYFOB_ACCEL_SERVICE_UUID characteristicUUID:TI_KEYFOB_ACCEL_Y_UUID peripheral:peripheral on:YES];
    [self notification:TI_KEYFOB_ACCEL_SERVICE_UUID characteristicUUID:TI_KEYFOB_ACCEL_Z_UUID peripheral:peripheral on:YES];
}

- (void)disableAccelerometer:(CBPeripheral *)peripheral
{
    NSLog(@"disableAccelerometer");
    Byte value = 0x00;
    NSData *data = [[NSData alloc] initWithBytes:&value length:1];
    [self writeValue:TI_KEYFOB_ACCEL_SERVICE_UUID characteristicUUID:TI_KEYFOB_ACCEL_ENABLER_UUID peripheral:peripheral data:data];
    [self notification:TI_KEYFOB_ACCEL_SERVICE_UUID characteristicUUID:TI_KEYFOB_ACCEL_X_UUID peripheral:peripheral on:NO];
    [self notification:TI_KEYFOB_ACCEL_SERVICE_UUID characteristicUUID:TI_KEYFOB_ACCEL_Y_UUID peripheral:peripheral on:NO];
    [self notification:TI_KEYFOB_ACCEL_SERVICE_UUID characteristicUUID:TI_KEYFOB_ACCEL_Z_UUID peripheral:peripheral on:NO];
}

- (void)enableHeartRate:(CBPeripheral *)peripheral
{
    NSLog(@"enableHeartRate");
    [self notification:TI_KEYFOB_HEARTRATE_SERVICE_UUID characteristicUUID:TI_KEYFOB_HEARTRATE_MEASURE_NOTIFICATION_UUID peripheral:peripheral on:YES];
}

- (void)disableHeartRate:(CBPeripheral *)peripheral
{
    NSLog(@"disableHeartRate");
    [self notification:TI_KEYFOB_HEARTRATE_SERVICE_UUID characteristicUUID:TI_KEYFOB_HEARTRATE_MEASURE_NOTIFICATION_UUID peripheral:peripheral on:NO];
}

- (void)enableTXPower:(CBPeripheral *)peripheral
{
    NSLog(@"enableTXPower");
    [self notification:TI_KEYFOB_PROXIMITY_TX_PWR_SERVICE_UUID characteristicUUID:TI_KEYFOB_PROXIMITY_TX_PWR_NOTIFICATION_UUID peripheral:peripheral on:YES];
}

- (void)disableTXPower:(CBPeripheral *)peripheral
{
    NSLog(@"disableTXPower");
    [self notification:TI_KEYFOB_PROXIMITY_TX_PWR_SERVICE_UUID characteristicUUID:TI_KEYFOB_PROXIMITY_TX_PWR_NOTIFICATION_UUID peripheral:peripheral on:NO];
}

- (void)peripheral:(CBPeripheral *)peripheral synchronousTime:(NSUInteger)time
{
    NSLog(@"synchronousTime");
    UInt32 value = (UInt32)(time - nLocalTimeStampBenchMark);
    NSData *data = [[NSData alloc] initWithBytes:&value length:TI_KEYFOB_TIME_SYNCHRONOUS_READ_LEN];
    [self writeValue:TI_KEYFOB_TIME_SYNCHRONOUS_SERVICE_UUID characteristicUUID:TI_KEYFOB_TIME_SYNCHRONOUS_UUID peripheral:peripheral data:data];
}

- (void)readPeripheralTime:(CBPeripheral *)peripheral
{
    NSLog(@"readPeripheralTime");
    [self readValue:TI_KEYFOB_TIME_SYNCHRONOUS_SERVICE_UUID characteristicUUID:TI_KEYFOB_TIME_SYNCHRONOUS_UUID peripheral:peripheral];
}

- (void)enableStepMeasure:(CBPeripheral *)peripheral
{
    NSLog(@"enableStepMeasure");
//    Byte value = 0x01;
//    NSData *data = [[NSData alloc] initWithBytes:&value length:1];
//    [self writeValue:TI_KEYFOB_ACCEL_SERVICE_UUID characteristicUUID:TI_KEYFOB_ACCEL_ENABLER_UUID peripheral:peripheral data:data];
//    [self notification:TI_KEYFOB_ACCEL_SERVICE_UUID characteristicUUID:TI_KEYFOB_ACCEL_X_UUID peripheral:peripheral on:YES];
//    [self notification:TI_KEYFOB_ACCEL_SERVICE_UUID characteristicUUID:TI_KEYFOB_ACCEL_Y_UUID peripheral:peripheral on:YES];
//    [self notification:TI_KEYFOB_ACCEL_SERVICE_UUID characteristicUUID:TI_KEYFOB_ACCEL_Z_UUID peripheral:peripheral on:YES];
    
    
//    Byte value = 0x01;
//    NSData *data = [[NSData alloc] initWithBytes:&value length:1];
//    [self writeValue:TI_KEYFOB_STEP_MEASURE_SERVICE_UUID characteristicUUID:TI_KEYFOB_STEP_MEASURE_ENABLE_UUID peripheral:peripheral data:data];
    [self notification:TI_KEYFOB_STEP_MEASURE_SERVICE_UUID characteristicUUID:TI_KEYFOB_STEP_MEASURE_NOTIFICATION_UUID peripheral:peripheral on:YES];
//    [self readValue:TI_KEYFOB_STEP_MEASURE_SERVICE_UUID characteristicUUID:TI_KEYFOB_STEP_MEASURE_ENABLE_UUID peripheral:peripheral];
}

- (void)disableStepMeasure:(CBPeripheral *)peripheral
{
    NSLog(@"disableStepMeasure");
//    Byte value = 0x00;
//    NSData *data = [[NSData alloc] initWithBytes:&value length:1];
//    [self writeValue:TI_KEYFOB_ACCEL_SERVICE_UUID characteristicUUID:TI_KEYFOB_ACCEL_ENABLER_UUID peripheral:peripheral data:data];
//    [self notification:TI_KEYFOB_ACCEL_SERVICE_UUID characteristicUUID:TI_KEYFOB_ACCEL_X_UUID peripheral:peripheral on:NO];
//    [self notification:TI_KEYFOB_ACCEL_SERVICE_UUID characteristicUUID:TI_KEYFOB_ACCEL_Y_UUID peripheral:peripheral on:NO];
//    [self notification:TI_KEYFOB_ACCEL_SERVICE_UUID characteristicUUID:TI_KEYFOB_ACCEL_Z_UUID peripheral:peripheral on:NO];
    
//    Byte value = 0x00;
//    NSData *data = [[NSData alloc] initWithBytes:&value length:1];
//    [self writeValue:TI_KEYFOB_STEP_MEASURE_SERVICE_UUID characteristicUUID:TI_KEYFOB_STEP_MEASURE_ENABLE_UUID peripheral:peripheral data:data];
    [self notification:TI_KEYFOB_STEP_MEASURE_SERVICE_UUID characteristicUUID:TI_KEYFOB_STEP_MEASURE_NOTIFICATION_UUID peripheral:peripheral on:NO];
}

- (void)enableRemindAlert:(CBPeripheral *)peripheral startTime:(NSUInteger)startTime endTime:(NSUInteger)endTime alertInterval:(NSUInteger)alertInterval
{
    NSLog(@"enableRemindAlert");
    
    int nSecondsPer10Minutes = 600;
    int length = TI_KEYFOB_REMIND_ALERT_READ_LEN;
    UInt32 startTimeStamp = (UInt32)(startTime - nLocalTimeStampBenchMark);
    UInt32 endTimeStamp = (UInt32)(endTime - nLocalTimeStampBenchMark);
    
    char infoString[length];
    UInt32 *ptr = (UInt32 *)infoString;
    *ptr = startTimeStamp;
    *(ptr + 1) = endTimeStamp;
    
    char count = (char)(alertInterval / nSecondsPer10Minutes);
    infoString[length - 1] = count;
    NSData *data = [[NSData alloc] initWithBytes:infoString length:length];
    [self writeValue:TI_KEYFOB_REMIND_ALERT_SERVICE_UUID characteristicUUID:TI_KEYFOB_REMIND_ALERT_UUID peripheral:peripheral data:data];
}

- (void)readRemindAlertInfo:(CBPeripheral *)peripheral
{
    [self readValue:TI_KEYFOB_REMIND_ALERT_SERVICE_UUID characteristicUUID:TI_KEYFOB_REMIND_ALERT_UUID peripheral:peripheral];
}

- (void)disableRemindAlert:(CBPeripheral *)peripheral
{
    NSLog(@"disableRemindAlert");
    
    int length = TI_KEYFOB_REMIND_ALERT_READ_LEN;
    char infoString[length];
    UInt32 *ptr = (UInt32 *)infoString;
    *ptr++ = nLocalTimeStampBenchMark;
    *ptr = nLocalTimeStampBenchMark;
    
    infoString[length - 1] = 0;//0:无效
    NSData *data = [[NSData alloc] initWithBytes:infoString length:length];
    [self writeValue:TI_KEYFOB_REMIND_ALERT_SERVICE_UUID characteristicUUID:TI_KEYFOB_REMIND_ALERT_UUID peripheral:peripheral data:data];
}

@end
