//
//  JumaDeviceConstant.m
//  JumaBluetoothSDK
//
//  Created by 汪安军 on 15/7/17.
//  Copyright (c) 2015年 JUMA. All rights reserved.
//

#import "JumaDeviceConstant.h"
#import <CoreBluetooth/CBUUID.h>

static NSString *const UUID_Service                = @"00008000-60B2-21F8-BCE3-94EEA697F98C";
static NSString *const UUID_Characteristic_Command = @"00008001-60B2-21F8-BCE3-94EEA697F98C"; // write
static NSString *const UUID_Characteristic_Notify  = @"00008002-60B2-21F8-BCE3-94EEA697F98C"; // notify
static NSString *const UUID_Characteristic_BulkOut = @"00008003-60B2-21F8-BCE3-94EEA697F98C"; // write
static NSString *const UUID_Characteristic_BulkIn  = @"00008004-60B2-21F8-BCE3-94EEA697F98C"; // notify

@implementation JumaDeviceConstant

#pragma mark - service

+ (CBUUID *)serviceUUID {
    static CBUUID *serviceUUID = nil;
    if (!serviceUUID) {
        serviceUUID = [CBUUID UUIDWithString:UUID_Service];
    }
    return serviceUUID;
}

+ (NSArray *)services {
    static NSArray *services = nil;
    if (!services) {
        services = @[ [self serviceUUID] ];
    }
    return services;
}

#pragma mark - characteristic

+ (CBUUID *)commandCharacteristicUUID {
    static CBUUID *commandCharacteristicUUID = nil;
    if (!commandCharacteristicUUID) {
        commandCharacteristicUUID = [CBUUID UUIDWithString:UUID_Characteristic_Command];
    }
    return commandCharacteristicUUID;
    
}
+ (CBUUID *)notifyCharacteristicUUID {
    static CBUUID *notifyCharacteristicUUID = nil;
    if (!notifyCharacteristicUUID) {
        notifyCharacteristicUUID = [CBUUID UUIDWithString:UUID_Characteristic_Notify];
    }
    return notifyCharacteristicUUID;
}
+ (CBUUID *)bulkOutCharacteristicUUID {
    static CBUUID *bulkOutCharacteristicUUID = nil;
    if (!bulkOutCharacteristicUUID) {
        bulkOutCharacteristicUUID = [CBUUID UUIDWithString:UUID_Characteristic_BulkOut];
    }
    return bulkOutCharacteristicUUID;
}

+ (NSArray *)characteristics {
    static NSArray *characteristics = nil;
    if (!characteristics) {
        characteristics = @[ [self commandCharacteristicUUID],
                             [self notifyCharacteristicUUID],
                             [self bulkOutCharacteristicUUID] ];
    }
    return characteristics;
}

@end
