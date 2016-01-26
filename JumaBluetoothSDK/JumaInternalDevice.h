//
//  JumaInternalDevice.h
//  JumaBluetoothSDK
//
//  Created by 汪安军 on 15/7/22.
//  Copyright (c) 2015年 JUMA. All rights reserved.
//

#import "JumaDevice.h"
@class JumaManager;
@class CBPeripheral;

@interface JumaInternalDevice : JumaDevice

/** 改变 CBPeripheral 的名称之后, 再次扫描时 CBPeripheral.name 属性的值不正确, 但是 advertisementData 中的 local name 是正确的, 为了取得正确的名称, 记下了这个数据 */
@property (nonatomic, strong) NSDictionary *advertisementData;

/** 能否和这个设备建立连接 */
@property (nonatomic, readonly) BOOL canEstablishConnection;
/** 不能和这个设备建立连接的原因 */
@property (nonatomic, strong, readonly) NSError *canNotEstablishConnectionError;

@property (nonatomic, strong, readonly) CBPeripheral *peripheral;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral manager:(JumaManager *)manager;
+ (instancetype)deviceWithPeripheral:(CBPeripheral *)peripheral manager:(JumaManager *)manager;

- (void)connectedByManager;
- (void)didConnectedByManager;

- (void)disconnectedByManager;
- (void)didDisconnectedByManager;

/*!
 *  @method disconnectFromManager
 *
 *  @discussion Convince method for the JumaManager to disconnect a JumaDevice.
 */
- (void)disconnectFromManager;

@end
