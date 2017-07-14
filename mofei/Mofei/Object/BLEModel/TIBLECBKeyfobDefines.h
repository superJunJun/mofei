//
//  TIBLECBKeyfobDefines.h
//  TI-BLE-Demo
//
//  Created by Ole Andreas Torvmark on 10/31/11.
//  Copyright (c) 2011 ST alliance AS. All rights reserved.
//

#ifndef TI_BLE_Demo_TIBLECBKeyfobDefines_h
#define TI_BLE_Demo_TIBLECBKeyfobDefines_h

// Original Defines for the TI CC2540 keyfob peripheral
// Modified for the TI CC2541 keyfob peripheral now

#define TI_KEYFOB_PROXIMITY_ALERT_UUID                      0x1802
#define TI_KEYFOB_PROXIMITY_ALERT_PROPERTY_UUID             0x2A06
#define TI_KEYFOB_PROXIMITY_ALERT_ON_VAL                    0x01
#define TI_KEYFOB_PROXIMITY_ALERT_OFF_VAL                   0x00
#define TI_KEYFOB_PROXIMITY_ALERT_WRITE_LEN                 1
#define TI_KEYFOB_PROXIMITY_TX_PWR_SERVICE_UUID             0x1804
#define TI_KEYFOB_PROXIMITY_TX_PWR_NOTIFICATION_UUID        0x2A07
#define TI_KEYFOB_PROXIMITY_TX_PWR_NOTIFICATION_READ_LEN    1

#define TI_KEYFOB_BATT_SERVICE_UUID                         0x180F
#define TI_KEYFOB_LEVEL_SERVICE_UUID                        0x2A19
#define TI_KEYFOB_LEVEL_SERVICE_READ_LEN                    1

#define TI_KEYFOB_ACCEL_SERVICE_UUID                        0xFFA0
#define TI_KEYFOB_ACCEL_ENABLER_UUID                        0xFFA1
#define TI_KEYFOB_ACCEL_RANGE_UUID                          0xFFA2
#define TI_KEYFOB_ACCEL_READ_LEN                            1
#define TI_KEYFOB_ACCEL_X_UUID                              0xFFA3
#define TI_KEYFOB_ACCEL_Y_UUID                              0xFFA4
#define TI_KEYFOB_ACCEL_Z_UUID                              0xFFA5

#define TI_KEYFOB_KEYS_SERVICE_UUID                         0xFFE0
#define TI_KEYFOB_KEYS_NOTIFICATION_UUID                    0xFFE1
#define TI_KEYFOB_KEYS_NOTIFICATION_READ_LEN                1

//For Venus
//TestVersion
#define TI_KEYFOB_HEARTRATE_SERVICE_UUID                0x180D
#define TI_KEYFOB_HEARTRATE_MEASURE_NOTIFICATION_UUID   0x2A37
//#define TI_KEYFOB_HEARTRATE_BODY_SENSOR_LOCATION_UUID   0x2A38
//#define TI_KEYFOB_HEARTRATE_CONTROL_P_UUID              0x2A39
#define TI_KEYFOB_HEARTRATE_NOTIFICATION_READ_LEN       20

//TI_KEYFOB_ACCEL_SERVICE_UUID
#define TI_KEYFOB_STEP_MEASURE_SERVICE_UUID             0xFFA0
#define TI_KEYFOB_STEP_MEASURE_NOTIFICATION_UUID        0xFFA6
#define TI_KEYFOB_STEP_NOTIFICATION_ONLINE_READ_LEN     11
#define TI_KEYFOB_STEP_NOTIFICATION_OFFLINE_READ_LEN    13
#define TI_KEYFOB_STEP_NOTIFICATION_MAX_READ_LEN        13
//MAX(TI_KEYFOB_STEP_NOTIFICATION_ONLINE_READ_LEN, TI_KEYFOB_STEP_NOTIFICATION_OFFLINE_READ_LEN)
//#define TI_KEYFOB_STEP_MEASURE_ENABLE_UUID              0xFFA7


#define TI_KEYFOB_TIME_SYNCHRONOUS_SERVICE_UUID         0x181A
#define TI_KEYFOB_TIME_SYNCHRONOUS_UUID                 0x2A6C
#define TI_KEYFOB_TIME_SYNCHRONOUS_READ_LEN             4

#define TI_KEYFOB_REMIND_ALERT_SERVICE_UUID             0xFFA0
#define TI_KEYFOB_REMIND_ALERT_UUID                     0xFFA8
#define TI_KEYFOB_REMIND_ALERT_READ_LEN                 9

//long leastSigBits = 0x800000805f9b34fbL;
//UUID HEART_RATE_SERVER = new UUID((0x180DL << 32) | 0x1000, leastSigBits);
//UUID HEART_RATE_MEASUREMENT = new UUID((0x2A37L << 32) | 0x1000, leastSigBits);
//UUID HEART_RATE_NOTIFICATION_ENABLE = new UUID((0x2902L << 32) | 0x1000, leastSigBits);

//UUID STEPS_SERVICE = new UUID((0xFFA0L << 32) | 0x1000, leastSigBits);
//UUID STEPS_MEASUREMENT = new UUID((0xFFA6L << 32) | 0x1000, leastSigBits);
//UUID STEPS_NOTICEFATION_ENABLE = new UUID((0xFFA7L << 32) | 0x1000, leastSigBits);
//
//UUID VIBRATION_REMIND = new UUID((0xFFA8L << 32) | 0x1000, leastSigBits);
//UUID DEVICE_NAME = new UUID((0x2A00L << 32) | 0x1000, leastSigBits);
//UUID BATTERY_LEVEL = new UUID((0x2A19L << 32) | 0x1000, leastSigBits);
//UUID TIME_SYNC = new UUID((0x2A6CL << 32) | 0x1000, leastSigBits);

#endif
