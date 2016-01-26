//
//  JumaDeviceConstant.h
//  JumaBluetoothSDK
//
//  Created by 汪安军 on 15/7/17.
//  Copyright (c) 2015年 JUMA. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CBUUID;

@interface JumaDeviceConstant : NSObject

+ (CBUUID *)serviceUUID;
+ (NSArray *)services;

+ (CBUUID *)commandCharacteristicUUID;
+ (CBUUID *)notifyCharacteristicUUID;
+ (CBUUID *)bulkOutCharacteristicUUID;
+ (NSArray *)characteristics;

@end
