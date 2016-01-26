//
//  JumaDataSender.m
//  JumaBluetoothSDK
//
//  Created by 汪安军 on 15/7/1.
//  Copyright (c) 2015年 JUMA. All rights reserved.
//

#import "JumaDataSender.h"
#import "JumaConfig.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface JumaDataSender ()
{
    NSData *_otaIdentifierBegin;
    NSData *_otaIdentifierData;
    NSData *_otaIdentifierEnd;
}

@property (nonatomic, readwrite) JumaDataType dataType;
@property (nonatomic, strong) NSMutableArray *datas;
@property (nonatomic, strong) NSMutableArray *firmwareDatas;

@end

@implementation JumaDataSender

- (instancetype)initWithData:(NSData *)data type:(JumaDataType)type {
    
    if (self = [super init]) {
        
        self.dataType = type;
        
        if (JumaDataTypeUserMax >= type || JumaDataType82 == type)
        {
            _datas = [JumaDataHelper dividedDatasWithType:type data:data];
        }
        else
        {
            if (JumaDataType81 == type)
            {
                _firmwareDatas = [JumaDataHelper dividedFirmwareDatasWithType:JumaDataType81
                                                                          subtype:JumaDataSubtypeData
                                                                             data:data];
                
                _otaIdentifierBegin = [self otaIdentifierWithSubtype:JumaDataSubtypeBegin];
                _otaIdentifierData  = [self otaIdentifierWithSubtype:JumaDataSubtypeData];
                _otaIdentifierEnd   = [self otaIdentifierWithSubtype:JumaDataSubtypeEnd];
                
                [_firmwareDatas insertObject:_otaIdentifierBegin atIndex:0]; // OTA Begin
                [_firmwareDatas insertObject:_otaIdentifierData  atIndex:1]; // OTA Data
                [_firmwareDatas insertObject:_otaIdentifierEnd   atIndex:2]; // OTA End
            }
        }
    }
    return self;
}

- (BOOL)didWriteAllFirmwareData {
    return !self.firmwareDatas;
}

- (void)sendFirstDataToCharacteristic:(CBCharacteristic *)c peripheral:(CBPeripheral *)p {
    [p writeValue:self.datas[0] forCharacteristic:c type:CBCharacteristicWriteWithResponse];
}

- (void)sendRemainingDatasToCharacteristic:(CBCharacteristic *)c peripheral:(CBPeripheral *)p {
    for (NSUInteger i = 1; i < self.datas.count; i++) {
        [p writeValue:self.datas[i]  forCharacteristic:c type:CBCharacteristicWriteWithoutResponse];
    }
    self.datas = nil;
}

- (void)sendOtaBeginToCharacteristic:(CBCharacteristic *)c peripheral:(CBPeripheral *)p {
    
    JMLog(@"write OTA Begin");
    [p writeValue:_otaIdentifierBegin forCharacteristic:c type:CBCharacteristicWriteWithResponse];
}

- (void)sendFirstRowforResponse:(NSData *)responseData characteristic:(CBCharacteristic *)c peripheral:(CBPeripheral *)p {
    
    // peripheral 的回应是 OTA Begin
    if ([responseData isEqualToData:_otaIdentifierBegin])
    {
        JMLog(@"did write OTA Begin");
        
        // 删除 OTA Begin 标识
        [self.firmwareDatas removeObjectAtIndex:0];
        
        // 写入第一组第一个
        [p writeValue:self.firmwareDatas[2][0] forCharacteristic:c type:CBCharacteristicWriteWithResponse];
    }
    
    // peripheral 的回应是 OTA Data
    if ([responseData isEqualToData:_otaIdentifierData])
    {
        // 删除第一组
        [self.firmwareDatas removeObjectAtIndex:2];
        
        // 还有等待写入 peripheral 的固件数据
        if (self.firmwareDatas.count > 2)
        {
            // 写入第一组第一个
            [p writeValue:self.firmwareDatas[2][0] forCharacteristic:c type:CBCharacteristicWriteWithResponse];
        }
        
        // 所有固件数据全部写入成功
        else if (self.firmwareDatas.count == 2)
        {
            JMLog(@"did write firmware data");
            
            // 删除 OTA Data 标识
            [self.firmwareDatas removeObjectAtIndex:0];
            
            // 发送 OTA End 标识
            [p writeValue:self.firmwareDatas[0] forCharacteristic:c type:CBCharacteristicWriteWithResponse];
            
            // 和固件相关的数据全部写入完毕
            self.firmwareDatas = nil;
            
            JMLog(@"write OTA_End");
        }
    }
}


- (void)sendRemainingRowsToCharacteristic:(CBCharacteristic *)c peripheral:(CBPeripheral *)p {
    
    // 数组中得第一个 OTA 标识符
    NSData *identifier = self.firmwareDatas.firstObject;
    
    // OTA Begin 标识符写入成功
    if ([identifier isEqualToData:_otaIdentifierBegin])
    {
        JMLog(@"did write OTA Begin");
    }
    
    // 第 1 组第 1 个固件数据写入成功
    if ([identifier isEqualToData:_otaIdentifierData])
    {
        JMLog(@"did write fireware data : %@", self.firmwareDatas[2][0]);
        
        // 写入第 1 个后面的固件数据
        NSArray *section = self.firmwareDatas[2];
        for (NSUInteger i = 1; i < section.count; i++)
        {
            [p writeValue:section[i] forCharacteristic:c type:CBCharacteristicWriteWithoutResponse];
        }
    }
}

- (NSData *)otaIdentifierWithSubtype:(JumaDataSubtype)subtype {
    
    NSMutableData *data = [NSMutableData data];
    // 数据主类型
    JumaDataType type = JumaDataType81;
    [data appendData:[NSData dataWithBytes:&type length:sizeof(type)]];
    
    // 数据长度
    JumaDataLength len = sizeof(subtype);
    [data appendData:[NSData dataWithBytes:&len length:sizeof(len)]];
    
    // 数据子类型
    [data appendData:[NSData dataWithBytes:&subtype length:sizeof(subtype)]];
    
    return data.copy;
}


@end
