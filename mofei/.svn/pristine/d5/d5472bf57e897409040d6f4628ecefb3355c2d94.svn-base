//
//  HeartRate.h
//  SensorTagEX
//
//  Created by macMini_Dev on 14-9-16.
//  Copyright (c) 2014年 Texas Instruments. All rights reserved.
//

#ifndef SensorTagEX_HeartRate_h
#define SensorTagEX_HeartRate_h

//初始化函数，每次开启应用程序，调用算法库之前，务必要执行此初始化函数，
//且只能执行一次。
//leadoffTime参数用来设置脱落的忽略时间（即检测到了脱落，但算法库不上报）。该值的设置有效范围是
//leadoffTime>=0 && leadoffTime<=20，若传进来的参数不在有效范围内，则使用默认值3。
void libInit(int leadoffTime);

//算法库入口函数
//data是char型（unsigned byte）指针，请保证其大小至少是20个byte。
//返回值：
//说明：bit0-bit15：即低两个字节是计算出的心率值，
//bit16是丢包标志位，bit16:1有丢包，bit16:0 无丢包
//bit17是脱落标志位，bit17:1脱落，bit17:0 无脱落
//bit18是信号质量标志位，bit18:1 信号质量良好，bit18:0 信号质量差
//注：测试中若频繁发生丢包，则测试结果不可靠（有误）。
int ecgCalLocal(char *data);


#endif
