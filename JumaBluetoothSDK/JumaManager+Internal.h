//
//  JumaManager+Internal.h
//  JumaBluetoothSDK
//
//  Created by 汪安军 on 15/7/17.
//  Copyright (c) 2015年 JUMA. All rights reserved.
//

#import "JumaManager.h"
@class CBUUID;

@interface JumaManager (Internal)

+ (NSDictionary *)validInitOptionsFromDict:(NSDictionary *)dict;
+ (NSDictionary *)validScanOptionsFromDict:(NSDictionary *)dict;

+ (BOOL)isValidUUIDArray:(NSArray *)UUIDs;

+ (BOOL)setUUIDString:(NSString *)UUID forKey:(NSString *)key;
+ (BOOL)setNSUUID:(NSUUID *)UUID forKey:(NSString *)key;
+ (BOOL)setCBUUID:(CBUUID *)UUID forKey:(NSString *)key;

+ (NSString *)UUIDStringForKey:(NSString *)key;
+ (NSUUID *)NSUUIDForKey:(NSString *)key;
+ (CBUUID *)CBUUIDForKey:(NSString *)key;

@end
