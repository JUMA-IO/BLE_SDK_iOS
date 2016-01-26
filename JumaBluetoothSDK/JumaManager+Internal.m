//
//  JumaManager+Internal.m
//  JumaBluetoothSDK
//
//  Created by 汪安军 on 15/7/17.
//  Copyright (c) 2015年 JUMA. All rights reserved.
//

#import "JumaManager+Internal.h"
#import "JumaManagerConstant.h"
#import <CoreBluetooth/CoreBluetooth.h>

@implementation JumaManager (Internal)

+ (NSDictionary *)validInitOptionsFromDict:(NSDictionary *)dict {
    
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    
    id value = dict[JumaManagerOptionShowPowerAlertKey];
    
    if (value) {
        NSAssert([value isKindOfClass:[NSNumber class]], @"the value for key 'JumaManagerOptionShowPowerAlertKey' must be a number");
        options[CBCentralManagerOptionShowPowerAlertKey] = value;
    }
    
    
    value = dict[JumaManagerOptionRestoreIdentifierKey];
    
    if (value) {
        NSAssert([value isKindOfClass:[NSString class]], @"the value for key 'JumaManagerOptionRestoreIdentifierKey' must be a string");
        options[CBCentralManagerOptionRestoreIdentifierKey] = value;
    }
    return options.copy;
}

+ (NSDictionary *)validScanOptionsFromDict:(NSDictionary *)dict {
    
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    
    id value = dict[JumaManagerScanOptionAllowDuplicatesKey];
    
    if (value) {
        NSAssert([value isKindOfClass:[NSNumber class]], @"the value for key 'JumaManagerScanOptionAllowDuplicatesKey' must be a number");
        options[CBCentralManagerScanOptionAllowDuplicatesKey] = value;
    }
    
//    value = dict[JumaManagerScanOptionTimeoutKey];
//    
//    if (value) {
//        BOOL isPositive = [value isKindOfClass:[NSNumber class]] && [value doubleValue] > 0;
//        NSAssert(isPositive, @"the value for key 'JumaManagerScanOptionTimeoutKey' must be a positive number");
//        options[JumaManagerScanOptionTimeoutKey] = value;
//    }
    return options.copy;
}

+ (BOOL)isValidUUIDArray:(NSArray *)UUIDs {
    
    for (id object in UUIDs) {
        if (![object isKindOfClass:[NSString class]]) {
            return NO;
        }
    }
    return YES;
}

#pragma mark -

+ (BOOL)setUUIDString:(NSString *)UUID forKey:(NSString *)key {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (UUID) {
        [defaults setObject:UUID forKey:key];
    }
    else {
        [defaults removeObjectForKey:key];
    }
    
    return [defaults synchronize] || [defaults synchronize];
}
+ (BOOL)setNSUUID:(NSUUID *)UUID forKey:(NSString *)key {
    return [self setUUIDString:UUID.UUIDString forKey:key];
}
+ (BOOL)setCBUUID:(CBUUID *)UUID forKey:(NSString *)key {
    return [self setUUIDString:UUID.UUIDString forKey:key];
}


+ (NSString *)UUIDStringForKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] stringForKey:key];
}
+ (NSUUID *)NSUUIDForKey:(NSString *)key {
    return [[NSUUID alloc] initWithUUIDString:[self UUIDStringForKey:key]];
}
+ (CBUUID *)CBUUIDForKey:(NSString *)key {
    return [CBUUID UUIDWithString:[self UUIDStringForKey:key]];
}

@end
