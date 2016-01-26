//
//  JumaBluetoothSDK.m
//  JumaSDK
//
//  Created by 汪安军 on 15/9/24.
//  Copyright © 2015年 JUMA. All rights reserved.
//

#import "JumaBluetoothSDK.h"

NSString * const JumaBluetoothSDKVersionString = @"03.00.00.01.151203";

/* 发布新版后, 设置中需要修改的地方
 
 Building Settings -> Versioning -> Current Project Version
 
 */

/* change log   "03.00.00.00.150925" -> now
 
 修正了 JumaDevice.state == JumaDeviceStateConnected 时, [JumaDevice description] 中任然显示 state = disconnected 的 bug
 
 在 JumaDeviceDelegate 中添加了 device:didWriteData: 回调来标识数据是否写入成功
 
 在 JumaDevice.h 中添加了一个进入 OTA 模式的接口, - (void)setOtaMode;
 
 在 JumaInternalDevice 中保存了扫描蓝牙设备时的广播数据
 
 */
