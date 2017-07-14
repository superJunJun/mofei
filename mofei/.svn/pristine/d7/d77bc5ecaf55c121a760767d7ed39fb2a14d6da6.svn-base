//
//  TYDDeviceManageViewController.m
//  Mofei
//
//  Created by macMini_Dev on 14-9-24.
//  Copyright (c) 2014年 Young. All rights reserved.
//
//  绑定设备
//

#import "TYDDeviceManageViewController.h"
#import "TYDBLEDeviceManager.h"
#import "TYDDeviceInfoCell.h"

#define sDisconnectActivePeripheral     @"断开当前设备？"
#define sConnectNewPeripheral           @"连接新设备？"
#define sNoConnectedPeripheral          @"还未连接设备，是否退出？"
#define sPeripheralDuringConnecting     @"正在连接设备，退出将终止连接？"


@interface TYDDeviceManageViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, TYDBLEDeviceManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) UIView *sectionHeaderView;
@property (strong, nonatomic) UILabel *headerTitleLabel;
@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;
@property (strong, nonatomic) UILabel *infoLabel;
@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) TYDBLEDeviceManager *deviceManager;
@property (strong, nonatomic) NSMutableArray *peripherals;
@property (nonatomic) TYDBLEDeviceManagerState connectState;

@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@end

@implementation TYDDeviceManageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHex:0xf3f3f4];
    
    [self localDataInitialize];
    [self navigationBarItemsLoad];
    [self subviewsLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self startScanPeripherals];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.deviceManager.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.deviceManager stopScanBLEPeripherals];
    self.deviceManager.delegate = nil;
}

- (void)localDataInitialize
{
    self.deviceManager = [TYDBLEDeviceManager sharedBLEDeviceManager];
    self.peripherals = [NSMutableArray new];
    if(self.deviceManager.activePeripheral)
    {
        [self insertOnePeripherial:self.deviceManager.activePeripheral];
    }
    self.connectState = self.deviceManager.connectState;
}

- (void)navigationBarItemsLoad
{
    self.title = @"搜索设备";
    self.navigationBarTintColor = [UIColor colorWithHex:0x2acacc];
}

- (void)subviewsLoad
{
    [self sectionHeaderViewLoad];
    [self tableViewLoad];
}

- (void)sectionHeaderViewLoad
{
    CGFloat sectionHeaderViewHeight = 32;
    CGRect frame = CGRectMake(0, 0, self.view.width, sectionHeaderViewHeight);
    UIView *headerView = [[UIView alloc] initWithFrame:frame];
    headerView.backgroundColor = [UIColor colorWithHex:0x0 andAlpha:0.15];
    
    CGFloat interval = 8;
    CGPoint center = headerView.innerCenter;
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont fontWithName:@"Arial" size:16];
    titleLabel.textColor = [UIColor colorWithHex:0xf31c77];
    titleLabel.text = @"设备：0000";
    [titleLabel sizeToFit];
    titleLabel.text = @"设备：0";
    titleLabel.center = center;
    titleLabel.left = interval;
    [headerView addSubview:titleLabel];
    
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicatorView.hidesWhenStopped = YES;
    indicatorView.center = center;
    indicatorView.right = headerView.width - interval;
    [headerView addSubview:indicatorView];
    
    UILabel *infoLabel = [UILabel new];
    infoLabel.backgroundColor = [UIColor clearColor];
    infoLabel.font = [UIFont fontWithName:@"Arial" size:14];
    infoLabel.textColor = [UIColor blackColor];
    infoLabel.textAlignment = NSTextAlignmentRight;
    infoLabel.text = @" ";
    [infoLabel sizeToFit];
    infoLabel.width = indicatorView.left - titleLabel.right - interval * 2;
    infoLabel.center = center;
    infoLabel.left = titleLabel.right + interval;
    [headerView addSubview:infoLabel];
    
    self.sectionHeaderView = headerView;
    self.headerTitleLabel = titleLabel;
    self.indicatorView = indicatorView;
    self.infoLabel = infoLabel;
    
    [self refreshDeviceCount];
}

- (void)tableViewLoad
{
    CGRect frame = self.view.bounds;
    UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //tableView.separatorColor = [UIColor colorWithHex:0xcecece];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:tableView];
    
    [tableView registerClass:TYDDeviceInfoCell.class forCellReuseIdentifier:sDeviceInfoCellIdentifier];
    
    UILongPressGestureRecognizer *longPressGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressOnTableView:)];
    longPressGr.minimumPressDuration = 0.6;
    [tableView addGestureRecognizer:longPressGr];
    
    self.tableView = tableView;
}

#pragma mark - UITableViewRelative

- (CBPeripheral *)peripheralAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row < self.peripherals.count)
    {
        return self.peripherals[indexPath.row];
    }
    return nil;
}

- (BOOL)shouldPeripheralConnected:(CBPeripheral *)peripheral
{
    return ([peripheral isEqual:self.deviceManager.activePeripheral]
            && [self.deviceManager activePeripheralEnable]);
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return self.sectionHeaderView.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.sectionHeaderView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.peripherals.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TYDDeviceInfoCell.cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBPeripheral *peripheral = [self peripheralAtIndexPath:indexPath];
    NSString *cellIdentifier = sDeviceInfoCellIdentifier;
    TYDDeviceInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.peripheral = peripheral;
    cell.isMarked = [self shouldPeripheralConnected:peripheral];
    if(self.connectState == TYDBLEDeviceManagerStateConnecting
       && peripheral == self.deviceManager.activePeripheral)
    {
        [cell addCircleViewIcon];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CBPeripheral *peripheral = [self peripheralAtIndexPath:indexPath];
    if(self.connectState == TYDBLEDeviceManagerStateNone)
    {
        self.selectedIndexPath = indexPath;
        [self.deviceManager connectPeripheral:peripheral];
    }
}

#pragma mark - TouchEvent

- (void)longPressOnTableView:(UIGestureRecognizer *)sender
{
    if(sender.state != UIGestureRecognizerStateBegan)
    {
        return;
    }
    UITableView *tableView = (UITableView *)sender.view;
    CGPoint point = [sender locationInView:tableView];
    NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:point];
    if(indexPath)
    {
        [self longPressOnTableViewAtIndexPath:indexPath];
    }
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == alertView.firstOtherButtonIndex)
    {
        NSString *message = alertView.message;
        if([message isEqualToString:sDisconnectActivePeripheral])
        {
            [self.deviceManager disconnectActivePeripheral];
            self.selectedIndexPath = nil;
        }
        else if([message isEqualToString:sConnectNewPeripheral])
        {
            [self.deviceManager connectPeripheral:[self peripheralAtIndexPath:self.selectedIndexPath]];
//            self.selectedIndexPath = nil;
        }
        else if([message isEqualToString:sNoConnectedPeripheral])
        {
            [super popBackEventWillHappen];
        }
        else if([message isEqualToString:sPeripheralDuringConnecting])
        {
            if(![self.deviceManager activePeripheralEnable])
            {
                [self.deviceManager disconnectActivePeripheral];
                [super popBackEventWillHappen];
            }
        }
    }
}

#pragma mark - Event

- (void)longPressOnTableViewAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.connectState == TYDBLEDeviceManagerStateConnecting
       || self.connectState == TYDBLEDeviceManagerStateDiscoverServices
       || self.connectState == TYDBLEDeviceManagerStateDiscoverCharacteristics)
    {
        [self setNoticeText:@"正在连接设备，请稍后再试"];
        return;
    }
    
    self.selectedIndexPath = indexPath;
    CBPeripheral *peripheral = [self peripheralAtIndexPath:indexPath];
    if(peripheral == self.deviceManager.activePeripheral)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"消息" message:sDisconnectActivePeripheral delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"消息" message:sConnectNewPeripheral delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    }
}

- (void)startScanPeripherals
{
    [self.deviceManager stopScanBLEPeripherals];
    
    CBCentralManagerState centralState = self.deviceManager.centralState;
    if(centralState == CBCentralManagerStatePoweredOn)
    {
        [self.peripherals removeAllObjects];
        [self.tableView reloadData];
        [self insertOnePeripherial:self.deviceManager.activePeripheral];
        
        [self.deviceManager scanBLEPeripherals];
    }
    else
    {
        NSLog(@"BlueTooth Not Usable!");
        NSString *title = @"";
        switch(centralState)
        {
            case CBCentralManagerStatePoweredOn:
                break;
            case CBCentralManagerStateUnsupported:
                title = @"不支持蓝牙设备BLE协议";
                break;
            case CBCentralManagerStatePoweredOff:
                title = @"蓝牙设备未开启";
                break;
            case CBCentralManagerStateUnknown:
            case CBCentralManagerStateResetting:
            case CBCentralManagerStateUnauthorized:
            default:
                title = @"蓝牙设备不可用";
                break;
        }
        self.infoLabel.text = title;
    }
}

- (void)insertOnePeripherial:(CBPeripheral *)peripherial
{
    if(peripherial && ![self.peripherals containsObject:peripherial])
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.peripherals.count inSection:0];
        [self.peripherals addObject:peripherial];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

        if(self.peripherals.count > 1)
        {
            indexPath = [NSIndexPath indexPathForRow:self.peripherals.count - 2 inSection:0];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    [self refreshDeviceCount];
}

- (void)refreshDeviceCount
{
    self.headerTitleLabel.text = [NSString stringWithFormat:@"设备：%ld", (long)self.peripherals.count];
}

- (void)setConnectState:(TYDBLEDeviceManagerState)connectState
{
    TYDDeviceInfoCell *cell = (TYDDeviceInfoCell *)[self.tableView cellForRowAtIndexPath:_selectedIndexPath];
    _connectState = connectState;
    BOOL animated = YES;
    NSString *title = @"";
    
    switch(connectState)
    {
        case TYDBLEDeviceManagerStateConnecting:
            title = @"连接设备";
            break;
        case TYDBLEDeviceManagerStateDiscoverServices:
            title = @"搜索设备服务";
            break;
        case TYDBLEDeviceManagerStateDiscoverCharacteristics:
            title = @"搜索设备服务特征值";
            break;
        case TYDBLEDeviceManagerStateConnected:
            title = @"设备连接成功";
            animated = NO;
            break;
        case TYDBLEDeviceManagerStateNone:
        {
            //连接断线、蓝牙关闭、连接失败等
            if(!self.deviceManager.activePeripheral)
            {
                [self.tableView reloadData];
            }
            if(_connectState == TYDBLEDeviceManagerStateConnecting
             || _connectState == TYDBLEDeviceManagerStateDiscoverServices
             || _connectState == TYDBLEDeviceManagerStateDiscoverCharacteristics)
            {
                [self setNoticeText:@"设备连接失败"];
            }
            else if(_connectState == TYDBLEDeviceManagerStateConnected)
            {
                [self setNoticeText:@"设备连接断开"];
            }
            animated = NO;
            break;
        }
        default:
            animated = NO;
            break;
    }
    self.infoLabel.text = title;
    if(animated)
    {
        [self.indicatorView startAnimating];
        [cell addCircleViewIcon];
    }
    else
    {
        [self.indicatorView stopAnimating];
        cell.connectMark = animated;
        [cell removeCircleIcon];
    }
}

#pragma mark - TYDBLEDeviceManagerDelegate

- (void)deviceManager:(TYDBLEDeviceManager *)manager connectStateUpdated:(TYDBLEDeviceManagerState)connectState
{
    self.connectState = connectState;
}

- (void)centralManagerStateDidUpdate:(CBCentralManager *)central
{
    if(central.state != CBCentralManagerStatePoweredOn)
    {
        [self.deviceManager stopScanBLEPeripherals];
        [self.deviceManager disconnectActivePeripheral];
        [self.peripherals removeAllObjects];
        [self.tableView reloadData];
        [self refreshDeviceCount];
        [self.indicatorView stopAnimating];
        _connectState = TYDBLEDeviceManagerStateNone;
    }
    else
    {
        [self startScanPeripherals];
        return;
    }
    
    NSString *title = @"";
    switch(central.state)
    {
        case CBCentralManagerStatePoweredOn:
            break;
        case CBCentralManagerStateUnsupported:
            title = @"不支持蓝牙设备";
            break;
        case CBCentralManagerStatePoweredOff:
            title = @"蓝牙设备未开启";
            break;
        case CBCentralManagerStateUnknown:
        case CBCentralManagerStateResetting:
        case CBCentralManagerStateUnauthorized:
        default:
            title = @"蓝牙设备不可用";
            break;
    }
    self.infoLabel.text = title;
}

- (void)centralManagerDidStartScanBLEPeripherals:(CBCentralManager *)central
{
    self.infoLabel.text = @"搜索设备";
    [self.indicatorView startAnimating];
}

- (void)centralManagerDidStopScanBLEPeripherals:(CBCentralManager *)central
{
    self.infoLabel.text = @"";
    [self.indicatorView stopAnimating];
    [self setNoticeText:@"搜索完成"];
    if(self.peripherals.count == 0)
    {
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"未搜到设备" message:@"请将手机靠近设备，检查设备是否没电" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral
{
    [self insertOnePeripherial:peripheral];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [self.tableView reloadData];
}

- (void)centralManager:(CBCentralManager *)central disconnectPeripheral:(CBPeripheral *)peripheral
{
    [self.tableView reloadData];
}

#pragma mark - Navigation

- (void)popBackEventWillHappen
{
    if([self.deviceManager activePeripheralEnable]
       || self.deviceManager.centralState != CBCentralManagerStatePoweredOn)
    {//TYDBLEDeviceManagerStateConnected
//        [super popBackEventWillHappen];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else
    {
        if(self.deviceManager.connectState == TYDBLEDeviceManagerStateNone)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"消息" message:sNoConnectedPeripheral delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alertView show];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"消息" message:sPeripheralDuringConnecting delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alertView show];
        }
    }
}

@end
