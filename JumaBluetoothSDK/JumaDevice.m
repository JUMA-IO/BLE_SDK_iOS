//
//  JumaDevice.m
//  JumaBluetoothSDK
//
//  Created by 汪安军 on 15/7/16.
//  Copyright (c) 2015年 JUMA. All rights reserved.
//

#import "JumaDevice.h"

//typedef void (^JumaWriteDataBlock)(NSData *receivedData, const SInt8 typeCode, NSError *error);

@interface JumaDevice ()

@end

@implementation JumaDevice


- (id)copyWithZone:(NSZone *)zone { return self; }
- (id)copy                        { return self; }


- (BOOL)isEqual:(id)object { return self == object; }
- (NSUInteger)hash         { return (NSUInteger)self; }


- (NSString *)UUID { return nil; }
- (NSString *)name { return nil; }

- (void)readRSSI {}
- (void)readRSSI:(JumaReadRssiBlock)handler {}
- (void)writeData:(NSData *)data type:(UInt8)typeCode {}
- (void)setOtaMode {};
- (void)updateFirmware:(NSData *)firmwareData {}
- (void)updateFirmware:(NSData *)firmwareData completionHandler:(JumaUpdateFirmwareBlock)handler {}

/*!
 *  @method writeData:type:completionHandler:
 *
 *  @param data       The data to send, the max length of the data is 198 bytes.
 *  @param typeCode   The data to send, the available range is [0, 127].
 *  @param handler    A block which receives the results of the sending operation.
 *
 *  @discussion       Sends data to the connected device.
 *                    If <i>handler<i> is <i>nil<i>, this method will result in a call to { device:didUpdateData:error: },
 *                    otherwise, only this block will be called.
 *
 *  @see              device:didUpdateData:error:
 */
//- (void)writeData:(NSData *)data type:(UInt8)typeCode completionHandler:(JumaWriteDataBlock)handler;

- (NSString *)description {
    NSString *stateDesc = nil;
    switch (self.state) {
        case JumaDeviceStateConnected: stateDesc = @"connected"; break;
        case JumaDeviceStateConnecting: stateDesc = @"connecting"; break;
        case JumaDeviceStateDisconnected: stateDesc = @"disconnected"; break;
#if DEBUG
        default: NSAssert(NO, @"JumaDeviceState 中有未处理的枚举值"); break;
#endif
    }
    return [NSString stringWithFormat:@"<JumaDevice: %p, UUID = %@, name = %@, state = %@>", self, self.UUID, self.name, stateDesc];
}

@end
