//
//  JumaDataSender.h
//  JumaBluetoothSDK
//
//  Created by 汪安军 on 15/7/1.
//  Copyright (c) 2015年 JUMA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JumaDataHelper.h"
@class CBPeripheral;
@class CBCharacteristic;

@interface JumaDataSender : NSObject

@property (nonatomic, readonly) JumaDataType dataType;
@property (nonatomic, readonly) BOOL didWriteAllFirmwareData;

- (instancetype)initWithData:(NSData *)data type:(JumaDataType)type;

// 发送普通数据
- (void)sendFirstDataToCharacteristic:(CBCharacteristic *)c peripheral:(CBPeripheral *)p;
- (void)sendRemainingDatasToCharacteristic:(CBCharacteristic *)c peripheral:(CBPeripheral *)p;


// 发送固件数据

/** 发送 OTA Begin 标识, 告诉 peripheral 准备接收固件数据 */
- (void)sendOtaBeginToCharacteristic:(CBCharacteristic *)c peripheral:(CBPeripheral *)p;
/** 发送第一组第一个 */
- (void)sendFirstRowforResponse:(NSData *)responseData characteristic:(CBCharacteristic *)c peripheral:(CBPeripheral *)p;
/** 发送第一组第二个 到 第一组最后一个 */
- (void)sendRemainingRowsToCharacteristic:(CBCharacteristic *)c peripheral:(CBPeripheral *)p;

@end
