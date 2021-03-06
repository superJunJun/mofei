//
//  TYDBLEDeviceManager.m
//  Mofei
//
//  Created by macMini_Dev on 14-9-26.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import "TYDBLEDeviceManager.h"
#import "TYDDataCenter.h"
#import "HeartRate.h"

#define n16BitsIntegerValueMax      65536//(1 << 16)//(UINT16_MAX + 1)
#define nDropCheckReportThreshold   10//脱落检测阈值，连续10次上报一次

//实时监测连接性需求。。 对将连接的设备进行可连接性检测

@interface TYDBLEDeviceManager () <TYDBLECBKeyfobDelegate>

@property (strong, nonatomic) TYDBLECBKeyfob *keyfob;
@property (strong, nonatomic) NSTimer *scanBLEPeripheralTimer;

@property (nonatomic) NSUInteger walkStepCount;
@property (nonatomic) NSUInteger runStepCount;

@property (nonatomic) BOOL deviceDropFlag;//脱落检测标志

@end

@implementation TYDBLEDeviceManager
{
//防止数据越界
    NSUInteger _walkStepCountLastMarkValue;
    NSUInteger _runStepCountLastMarkValue;
}

#pragma mark - SingleTon

- (instancetype)init
{
    if(self = [super init])
    {
        self.keyfob = [TYDBLECBKeyfob new];
        self.keyfob.delegate = self;
        
        _activePeripheral = nil;
        _centralState = self.keyfob.centralManager.state;
        _connectState = TYDBLEDeviceManagerStateNone;
        _deviceDropFlag = NO;
        [self recordValuesInit];
        
        //初始化心率库
        libInit(5);//leadoffTime参数用来设置脱落的忽略时间
    }
    return self;
}

- (void)recordValuesInit
{
    _batteryLevel = 0.0;//100.0
    _heartRate = 0;
    _stepCount = 0;
    _walkStepCount = 0;
    _runStepCount = 0;
    _walkStepCountLastMarkValue = 0;
    _runStepCountLastMarkValue = 0;
}

+ (instancetype)sharedBLEDeviceManager
{
    static TYDBLEDeviceManager *BLEDeviceManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        BLEDeviceManagerInstance = [[self alloc] init];
    });
    return BLEDeviceManagerInstance;
}

#pragma mark - Scan Peripheral Timer

- (void)invalidateScanBLEPeripheralTimer
{
    if([self.scanBLEPeripheralTimer isValid])
    {
        [self.scanBLEPeripheralTimer invalidate];
        self.scanBLEPeripheralTimer = nil;
    }
}

- (void)scanBLEPeripherals
{
    [self.keyfob scanBLEPeripherals];
    [self invalidateScanBLEPeripheralTimer];
    
    self.scanBLEPeripheralTimer = [NSTimer scheduledTimerWithTimeInterval:nScanBLEPeripheralsTimerInterval target:self selector:@selector(scanBLEPeripheralsComplete) userInfo:nil repeats:NO];
    if([self.delegate respondsToSelector:@selector(centralManagerDidStartScanBLEPeripherals:)])
    {
        [self.delegate centralManagerDidStartScanBLEPeripherals:self.keyfob.centralManager];
    }
}

- (void)scanBLEPeripheralsComplete
{
    if([self.delegate respondsToSelector:@selector(centralManagerDidStopScanBLEPeripherals:)])
    {
        [self.delegate centralManagerDidStopScanBLEPeripherals:self.keyfob.centralManager];
    }
}

- (void)stopScanBLEPeripherals
{
    [self.keyfob stopScanBLEPeripherals];
    [self invalidateScanBLEPeripheralTimer];
}

#pragma mark - Connection

- (void)setNewActivePeripheral:(CBPeripheral *)peripheral
{
    if(![peripheral isEqual:self.activePeripheral])
    {
        CBPeripheral *lastAcitviePeripheral = self.activePeripheral;
        _activePeripheral = peripheral;
        
        [self.keyfob disconnectPeripheral:lastAcitviePeripheral];
        [self.keyfob connectPeripheral:self.activePeripheral];
    }
}

- (void)connectPeripheral:(CBPeripheral *)peripheral
{
    if(peripheral)
    {
        [self stopScanBLEPeripherals];
        [self setNewActivePeripheral:peripheral];
        [self peripheral:peripheral connectStateChange:TYDBLEDeviceManagerStateConnecting];
    }
}

- (void)disconnectActivePeripheral
{
    [self.keyfob disconnectPeripheral:self.activePeripheral];
    //[self setNewActivePeripheral:nil];
    //[self peripheral:nil connectStateChange:TYDBLEDeviceManagerStateNone];
}

#pragma mark - ConnectState

- (void)peripheral:(CBPeripheral *)peripheral connectStateChange:(TYDBLEDeviceManagerState)state
{
    if(peripheral
       && [peripheral isEqual:self.activePeripheral])
    {
        if(state == TYDBLEDeviceManagerStateNone)
        {
            [self setNewActivePeripheral:nil];
        }
        _connectState = state;
        if([self.delegate respondsToSelector:@selector(deviceManager:connectStateUpdated:)])
        {
            [self.delegate deviceManager:self connectStateUpdated:state];
        }
    }
}

#pragma mark - TYDBLECBKeyfobDelegate

- (void)centralManagerStateDidUpdate:(CBCentralManager *)central
{
    _centralState = central.state;
    
    if(_centralState != CBCentralManagerStatePoweredOn)
    {
        [self dataCenterCalculateTimerCancel];//TYDDataCenter Event
        
        _connectState = TYDBLEDeviceManagerStateNone;
        [self setNewActivePeripheral:nil];
        [self recordValuesInit];
        _deviceDropFlag = NO;
    }
    
    if([self.delegate respondsToSelector:@selector(centralManagerStateDidUpdate:)])
    {
        [self.delegate centralManagerStateDidUpdate:central];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral
{
    if([self.delegate respondsToSelector:@selector(centralManager:didDiscoverPeripheral:)])
    {
        [self.delegate centralManager:central didDiscoverPeripheral:peripheral];
    }
}

- (void)centralManager:(CBCentralManager *)central connectPeripheral:(CBPeripheral *)peripheral succeed:(BOOL)succeed
{
    if(succeed)
    {
        [self peripheral:peripheral connectStateChange:TYDBLEDeviceManagerStateDiscoverServices];
    }
    else
    {
        [self peripheral:peripheral connectStateChange:TYDBLEDeviceManagerStateNone];
    }
}

- (void)centralManager:(CBCentralManager *)central disconnectPeripheral:(CBPeripheral *)peripheral
{
    if([self.delegate respondsToSelector:@selector(centralManager:disconnectPeripheral:)])
    {
        [self.delegate centralManager:central disconnectPeripheral:peripheral];
    }
    if([self.disconnectDelegate respondsToSelector:@selector(centralManagerDisconnectPeripheral:)])
    {
        [self.disconnectDelegate centralManagerDisconnectPeripheral:peripheral];
    }
    
    [self dataCenterCalculateTimerCancel];//TYDDataCenterEvent
    [self recordValuesInit];
    _deviceDropFlag = NO;
    [self peripheral:peripheral connectStateChange:TYDBLEDeviceManagerStateNone];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServicesSucceed:(BOOL)succeed
{
    if(succeed)
    {
        [self peripheral:peripheral connectStateChange:TYDBLEDeviceManagerStateDiscoverCharacteristics];
    }
    else
    {
        [self peripheral:peripheral connectStateChange:TYDBLEDeviceManagerStateNone];
    }
}

- (void)peripheralDiscoverCharacteristicsFailed:(CBPeripheral *)peripheral
{
    [self peripheral:peripheral connectStateChange:TYDBLEDeviceManagerStateNone];
}

- (void)peripheralKeyfobReady:(CBPeripheral *)peripheral
{
    CBCentralManager *central = self.keyfob.centralManager;
    [self peripheral:peripheral connectStateChange:TYDBLEDeviceManagerStateConnected];
    
//    [self.keyfob enableAccelerometer:peripheral];
//    [self.keyfob enableTXPower:peripheral];
    NSUInteger systemCurrentTime = [BOTimeStampAssistor getCurrentTime];
//    NSUInteger todayBegining = [BOTimeStampAssistor timeStampOfDayBeginningForToday];
//    NSUInteger todayEnd = todayBegining + nTimeIntervalSecondsPerDay - 1;
//    NSUInteger alertInterval = 60 * 10;
    
    [self.keyfob peripheral:peripheral synchronousTime:systemCurrentTime];
    [self.keyfob readPeripheralTime:peripheral];
    
    [self.keyfob readBattery:peripheral];
    [self.keyfob enableBatteryNotification:peripheral];
    [self.keyfob enableHeartRate:peripheral];
    [self.keyfob enableStepMeasure:peripheral];
    
    //须先行开启计步功能，尔后开启久坐提醒功能
    [self remindAlertStateSet];
    //[self.keyfob disableRemindAlert:peripheral];
    //[self.keyfob enableRemindAlert:peripheral startTime:todayBegining endTime:todayEnd alertInterval:alertInterval];
    //[self.keyfob readRemindAlertInfo:peripheral];
    
    if([self.delegate respondsToSelector:@selector(centralManager:didConnectPeripheral:)])
    {
        [self.delegate centralManager:central didConnectPeripheral:peripheral];
    }
    
    //TYDDataCenter Event
    [self dataCenterCalculateTimerStart];
}

//bit0-bit15：即低两个字节是计算出的心率值，
//bit16是丢包标志位，bit16:1有丢包，bit16:0 无丢包
//bit17是脱落标志位，bit17:1脱落，bit17:0 无脱落
//bit18是信号质量标志位，bit18:1 信号质量良好，bit18:0 信号质量差
//注：测试中若频繁发生丢包，则测试结果不可靠（有误）。
- (void)heartRateDataUpdated:(char *)hrData
{
    int ecgValue = ecgCalLocal(hrData);
    int heartRateValue = ecgValue & 0xffff;
    int tossFlag = ecgValue & (0x1 << 16);//丢包
    int dropFlag = ecgValue & (0x1 << 17);//脱落检测
    //int signalFlag = ecgValue & (0x1 << 18);//信号质量
    
    if(dropFlag != 0)
    {//检测到脱落
        self.deviceDropFlag = YES;
        return;
    }
    else
    {
        self.deviceDropFlag = NO;
    }
    
    if(tossFlag != 0)
    {//有丢包
        return;
    }
    if(heartRateValue > 0)
    {
        NSLog(@"heartRateValueUpdated:%d", heartRateValue);
        _heartRate = heartRateValue;
    }
}

- (void)batteryLevelUpdated:(CGFloat)batteryLevel
{
    NSLog(@"batteryLevelUpdated:%.2f", batteryLevel);
    _batteryLevel = batteryLevel;
    if([self.batteryDelegate respondsToSelector:@selector(deviceBatteryLevelUpdated:)])
    {
        [self.batteryDelegate deviceBatteryLevelUpdated:batteryLevel];
    }
}

- (void)stepDataUpdated:(char *)stepData
{
    char offlineFlag = stepData[0];
    NSUInteger walkStepCount = 0;
    NSUInteger runStepCount = 0;
    
    if(offlineFlag == 0)
    {
        //NSLog(@"stepDataUpdated:%@", [BOAssistor charArrayToHexString:stepData length:11]);
        //walkStepCount = swapUInt16((UInt16)(*((UInt16 *)(stepData + 5))));
        //runStepCount = swapUInt16((UInt16)(*((UInt16 *)(stepData + 7))));
        walkStepCount = *((UInt16 *)(stepData + 5));
        runStepCount = *((UInt16 *)(stepData + 7));
        
        //NSLog(@"%04x", walkStepCount);
        self.walkStepCount = walkStepCount;
        self.runStepCount = runStepCount;
        _stepCount = self.walkStepCount + self.runStepCount;
        
        NSLog(@"stepOnlineDataUpdated:%ld", (unsigned long)_stepCount);
    }
    else
    {
        NSUInteger startTimeStamp = nLocalTimeStampBenchMark;
        NSUInteger endTimeStamp = nLocalTimeStampBenchMark;
        
        //startTimeStamp += [BOAssistor charArrayToUIntValue:stepData + 1 length:4];
        //endTimeStamp += [BOAssistor charArrayToUIntValue:stepData + 5 length:4];
        
        startTimeStamp += *((UInt32 *)(stepData + 1));
        endTimeStamp += *((UInt32 *)(stepData + 5));
        
        walkStepCount = *((UInt16 *)(stepData + 9));
        runStepCount = *((UInt16 *)(stepData + 11));
        [self.stepDataDelegate deviceManagerOfflineStepDataUpdated:walkStepCount + runStepCount startTime:startTimeStamp endTime:endTimeStamp];
        
        NSLog(@"Offline StartTime:%@", [BOTimeStampAssistor getTimeStringWithTimeStamp:startTimeStamp]);
        NSLog(@"stepOfflineDataUpdated:%ld", (unsigned long)(walkStepCount + runStepCount));
    }
}

- (void)peripheralSystemTimeRead:(NSUInteger)time
{
    NSLog(@"peripheralTimeValue:%lu, %@", (unsigned long)time, [BOTimeStampAssistor getTimeStringWithTimeStamp:time]);
}

- (void)peripheralRemindAlertInfoRead:(NSUInteger)startTime endTime:(NSUInteger)endTime alertInterval:(NSUInteger)alertInterval
{
    NSLog(@"peripheralRemindAlertInfoRead, startTime:%@, endTime:%@, interval:%ld", [BOTimeStampAssistor getTimeStringWithTimeStamp:startTime], [BOTimeStampAssistor getTimeStringWithTimeStamp:endTime], (unsigned long)alertInterval);
}

#pragma mark - ReadBatteryLevel

- (void)readBatteryLevel
{
    if(self.activePeripheral)
    {
        [self.keyfob readBattery:self.activePeripheral];
    }
}

#pragma mark - DataCenterTimerEvent

- (void)dataCenterCalculateTimerStart
{
    [[TYDDataCenter defaultCenter] globalTimerStart];
}

- (void)dataCenterCalculateTimerCancel
{
    [[TYDDataCenter defaultCenter] globalTimerCancel];
}

#pragma mark - CheckActivePeripheralEnable

- (BOOL)activePeripheralEnable
{
    return (self.activePeripheral
            && self.activePeripheral.didConnect
            && self.connectState == TYDBLEDeviceManagerStateConnected);
}

#pragma mark - OverrideSettingMethod

- (void)setWalkStepCount:(NSUInteger)walkStepCount
{
    _walkStepCount += (walkStepCount - _walkStepCountLastMarkValue + n16BitsIntegerValueMax) % n16BitsIntegerValueMax;
    _walkStepCountLastMarkValue = walkStepCount;
}

- (void)setRunStepCount:(NSUInteger)runStepCount
{
    _runStepCount += (runStepCount - _runStepCountLastMarkValue + n16BitsIntegerValueMax) % n16BitsIntegerValueMax;
    _runStepCountLastMarkValue = runStepCount;
}

- (void)setDeviceDropFlag:(BOOL)deviceDropFlag
{
    if(_deviceDropFlag != deviceDropFlag)
    {
        _deviceDropFlag = deviceDropFlag;
        if([self.stepDataDelegate respondsToSelector:@selector(deviceManagerHeartRateMeasureDropCheckReport:)])
        {
            [self.stepDataDelegate deviceManagerHeartRateMeasureDropCheckReport:deviceDropFlag];
        }
    }
}

- (void)stepCountClearWhileDateChange
{//good
    _runStepCount = 0;
    _walkStepCount = 0;
    _stepCount = 0;
}

- (void)refreshStepCountWithNewValue:(NSUInteger)stepCountNew
{
    _runStepCount = 0;
    _walkStepCount = stepCountNew;
    _stepCount = stepCountNew;
}

#pragma mark - RemindAlert

//数据源位于TYDDataCenter
- (void)remindAlertStateSet
{
    CBPeripheral *peripheral = self.activePeripheral;
    if(!peripheral)
    {
        NSLog(@"No Peripheral To Set Remind Alert!");
        return;
    }
    
    TYDDataCenter *dataCenter = [TYDDataCenter defaultCenter];
    NSUInteger todayBegining = [BOTimeStampAssistor timeStampOfDayBeginningForToday];
    
    BOOL remindAlertIsOn = dataCenter.remindAlertIsOn;
    NSUInteger remindAlertStartTime = dataCenter.remindAlertStartTime;
    NSUInteger remindAlertEndTime = dataCenter.remindAlertEndTime;
    NSUInteger remindAlertInterval = dataCenter.remindAlertInterval;
    
    int nSecondsPer10Minutes = 600;
    if(!remindAlertIsOn
       || remindAlertInterval < nSecondsPer10Minutes)
    {
        [self.keyfob disableRemindAlert:peripheral];
        NSLog(@"Remind Alert Off");
    }
    else
    {
        remindAlertStartTime += todayBegining;
        remindAlertEndTime += todayBegining;
        [self.keyfob enableRemindAlert:peripheral startTime:remindAlertStartTime endTime:remindAlertEndTime alertInterval:remindAlertInterval];
        [self.keyfob readRemindAlertInfo:peripheral];
        NSLog(@"Remind Alert On");
    }
}

@end
