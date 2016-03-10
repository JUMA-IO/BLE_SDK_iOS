//
//  JumaInternalDevice.m
//  JumaBluetoothSDK
//
//  Created by 汪安军 on 15/7/22.
//  Copyright (c) 2015年 JUMA. All rights reserved.
//

#import "JumaInternalDevice.h"
#import "JumaManager.h"
#import "JumaConfig.h"
#import "JumaDeviceConstant.h"
#import "JumaDataSender.h"

#import "NSData+Category.h"
#import "NSError+Juma.h"

@import CoreBluetooth;

@interface JumaInternalDevice () <CBPeripheralDelegate>
{
    JumaDeviceState _state;
}

@property (nonatomic, readwrite) BOOL canEstablishConnection;
@property (nonatomic, strong, readwrite) NSError *canNotEstablishConnectionError;

@property (nonatomic, weak) JumaManager *manager;
@property (nonatomic, strong) CBPeripheral *peripheral;


/** 发通知的 characteristic */
@property (nonatomic, strong) CBCharacteristic *notifyCharacteristic;
/** 写入时有  response 的 characteristic, 用于写入包含类型信息的数据 */
@property (nonatomic, strong) CBCharacteristic *commandCharacteristic;
/** 写入时没有 response 的 characteristic, 用于写入不包含类型信息的数据 */
@property (nonatomic, strong) CBCharacteristic *bulkOutCharacteristic;


//@property (nonatomic, copy) JumaWriteDataBlock writeDataHandler;
@property (nonatomic, copy) JumaUpdateFirmwareBlock updateFirmwareHandler;
@property (nonatomic, copy) JumaReadRssiBlock readRssiHandler;


/** 向 peripheral 发送大数据的发送器 */
@property (nonatomic, strong) JumaDataSender *dataSender;

@end

@implementation JumaInternalDevice

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral manager:(JumaManager *)manager {
    
    if ( (!peripheral) || (!manager) ) return nil;
    if (self = [super init]) {
        _manager = manager;
        _peripheral = peripheral;
        _peripheral.delegate = self;
    }
    return self;
}

+ (instancetype)deviceWithPeripheral:(CBPeripheral *)peripheral manager:(JumaManager *)manager {
    return [[self alloc] initWithPeripheral:peripheral manager:manager];
}

#pragma mark - setter and getter

- (NSString *)UUID {
    return _peripheral.identifier.UUIDString;
}

- (NSString *)name {
    NSString *name = _peripheral.name;
    NSString *localName = self.advertisementData[CBAdvertisementDataLocalNameKey];
    
    // http://beantalk.punchthrough.com/t/update-ios-ble-gatt-cache-or-clear/2325
    if (localName && ![name isEqualToString:localName]) {
        name = localName;
    }
    
    return name;
}

- (JumaDeviceState)state {
    return _state;
}

#pragma mark - public method

- (void)connectedByManager {
    self.canEstablishConnection = NO;
    self.canNotEstablishConnectionError = nil;
    _state = JumaDeviceStateConnecting;
}

- (void)didConnectedByManager {
    [_peripheral discoverServices:[JumaDeviceConstant services]];
}

- (void)disconnectedByManager {
    _state = JumaDeviceStateDisconnected;
}

- (void)didDisconnectedByManager {
    
    _state = JumaDeviceStateDisconnected;
    self.readRssiHandler = nil;
//    self.writeDataHandler = nil;
    self.updateFirmwareHandler = nil;
    self.dataSender = nil;
    self.notifyCharacteristic = nil;
    self.commandCharacteristic = nil;
    self.bulkOutCharacteristic = nil;
}

- (void)disconnectFromManager {
    [_manager disconnectDevice:self];
}

- (void)readRSSI {
    [_peripheral readRSSI];
}

- (void)readRSSI:(JumaReadRssiBlock)handler {
    self.readRssiHandler = handler;
    [self readRSSI];
}

- (void)writeData:(NSData *)data type:(UInt8)typeCode {
    
    NSParameterAssert(data != nil);
    NSParameterAssert(data.length < 199);
    NSParameterAssert(typeCode < 128);
    
    [self sendOperationWithDataType:typeCode implementation:^{
        
        self.dataSender = [[JumaDataSender alloc] initWithData:data type:typeCode];
        
        // 发送第一个数据
        [_dataSender sendFirstDataToCharacteristic:_commandCharacteristic
                                        peripheral:_peripheral];
    }];
}

//- (void)writeData:(NSData *)data type:(UInt8)typeCode completionHandler:(JumaWriteDataBlock)handler {
//    self.writeDataHandler = handler;
//    [self writeData:data type:typeCode];
//}

- (void)setOtaMode {
    char bytes[] = { 'O', 'T', 'A', '_', 'M', 'O', 'D', 'E', 0 };
    NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)]; // <4f54415f 4d4f4445 00>
    
    [self sendOperationWithDataType:JumaDataType82 implementation:^{
        
        self.dataSender = [[JumaDataSender alloc] initWithData:data type:JumaDataType82];
        [_dataSender sendFirstDataToCharacteristic:_commandCharacteristic peripheral:_peripheral];
    }];
}

- (void)updateFirmware:(NSData *)firmwareData {
    
    NSParameterAssert(firmwareData != nil);
    
    [self sendOperationWithDataType:JumaDataType81 implementation:^{
        
        self.dataSender = [[JumaDataSender alloc] initWithData:firmwareData  type:JumaDataType81];
        
        // 发送 OTA Begin 标识, 准备进行固件升级
        [_dataSender sendOtaBeginToCharacteristic:_commandCharacteristic
                                       peripheral:_peripheral];
    }];
}

- (void)updateFirmware:(NSData *)firmwareData completionHandler:(JumaUpdateFirmwareBlock)handler {
    
    self.updateFirmwareHandler = handler;
    [self updateFirmware:firmwareData];
}

#pragma mark - private method

- (void)sendOperationWithDataType:(JumaDataType)type implementation:(void (^)(void))handler {
    
    if (_peripheral.state == CBPeripheralStateConnected)
    {
        if (_commandCharacteristic && _bulkOutCharacteristic)
        {
            // 在上一个数据发送完之前, 不允许再发送新的数据
            if (!_dataSender)
            {
                handler();
            }
            else
            {
                NSError *error = [NSError jumaSDK_errorWithDescription:@"The last data transfer is not completed."];
                [self outputError:error dataType:type];
            }
        }
        else
        {
            NSError *error = [NSError jumaSDK_errorWithDescription:@"Unknow error"];
            [self outputError:error dataType:type];
            
            // 断开连接
            [self disconnectFromManager];
        }
    }
    else
    {
        NSDictionary *info = @{ NSLocalizedDescriptionKey : @"The specified device is not connected." };
        NSError *error = [NSError errorWithDomain:CBErrorDomain code:CBErrorNotConnected userInfo:info];
        [self outputError:error dataType:type];
    }
}

- (void)outputError:(NSError *)error dataType:(JumaDataType)type {
    
    if (JumaDataTypeUserMax >= type || JumaDataType82 == type) {
        [self sendDelegateResultOfWriting:error];
    }
    else if (JumaDataType81 == type) {
        [self sendDelegateResultOfUpdating:error];
    }
}

#pragma mark -
- (void)sendDelegateRSSI:(NSNumber *)RSSI error:(NSError *)error {
    
    if (error) { RSSI = nil; }
    
    if (_readRssiHandler) {
        
        _readRssiHandler(RSSI, error);
        self.readRssiHandler = nil;
        
    } else {
        
        if ([self.delegate respondsToSelector:@selector(device:didReadRSSI:error:)]) {
            [self.delegate device:self didReadRSSI:RSSI error:error];
        }
    }
}

- (void)sendDelegateResultOfWriting:(NSError *)error {
    
    if ([self.delegate respondsToSelector:@selector(device:didWriteData:)]) {
        [self.delegate device:self didWriteData:error];
    }
}

- (void)sendDelegateUpdateData:(NSData *)data type:(char)typeCode error:(NSError *)error {

//    if (_writeDataHandler) {
//        _writeDataHandler(data, typeCode, error);
//        self.writeDataHandler = nil;
//        return;
//    }
    
    if ([self.delegate respondsToSelector:@selector(device:didUpdateData:type:error:)]) {
        [self.delegate device:self didUpdateData:data type:typeCode error:error];
    }
}

- (void)sendDelegateResultOfUpdating:(NSError *)error {
    
    if (_updateFirmwareHandler) {
        
        _updateFirmwareHandler(error);
        self.updateFirmwareHandler = nil;
        
    } else {
        
        if ([self.delegate respondsToSelector:@selector(device:didUpdateFirmware:)]) {
            [self.delegate device:self didUpdateFirmware:error];
        }
    }
}

#pragma mark - CBPeripheralDelegate

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    [self sendDelegateRSSI:RSSI error:error];
}
#else
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
    [self sendDelegateRSSI:peripheral.RSSI error:error];
}
#endif

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    //JMLog(@"%s, %@, %@", __func__, peripheral, error);
    
    if (!error)
    {
        for (CBService *service in peripheral.services) {
            
            if ([service.UUID isEqual: [JumaDeviceConstant serviceUUID]]) {
                
                [peripheral discoverCharacteristics:[JumaDeviceConstant characteristics] forService:service];
                return;
            }
        }
        
        NSString *desc = [NSString stringWithFormat:@"The device named %@ is not supported by JUMA", peripheral.name];
        self.canNotEstablishConnectionError = [NSError jumaSDK_errorWithDescription:desc];
        [_manager disconnectDevice:self];
    }
    else
    {
        self.canNotEstablishConnectionError = error;
        [_manager disconnectDevice:self];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    //JMLog(@"%s, %@, %@, %@", __func__, peripheral, service, error);
    
    if (!error)
    {
        CBUUID *notifyUUID  = [JumaDeviceConstant notifyCharacteristicUUID];
        CBUUID *commandUUID = [JumaDeviceConstant commandCharacteristicUUID];
        CBUUID *bulkOutUUID = [JumaDeviceConstant bulkOutCharacteristicUUID];
        
        self.commandCharacteristic = nil;
        self.notifyCharacteristic  = nil;
        self.bulkOutCharacteristic = nil;
        
        for (CBCharacteristic *c in service.characteristics)
        {
            CBUUID *UUID = c.UUID;
            
            if (     [UUID isEqual: notifyUUID])  { self.notifyCharacteristic  = c; } // 发出通知
            else if ([UUID isEqual: commandUUID]) { self.commandCharacteristic = c; } // 写入包含类型信息的数据
            else if ([UUID isEqual: bulkOutUUID]) { self.bulkOutCharacteristic = c; } // 写入不包含类型信息的数据
        }
        
        if (_notifyCharacteristic && _commandCharacteristic && _bulkOutCharacteristic)
        {
            [peripheral setNotifyValue:YES forCharacteristic:_notifyCharacteristic];
        }
        else
        {
            NSString *desc = [NSString stringWithFormat:@"The device named %@ is not supported by JUMA", peripheral.name];
            self.canNotEstablishConnectionError = [NSError jumaSDK_errorWithDescription:desc];
            [_manager disconnectDevice:self];
        }
    }
    else
    {
        self.canNotEstablishConnectionError = error;
        [_manager disconnectDevice:self];
    }
}

//#warning 需要确定, 如果 setNotify:NO, 是否会调用这个方法
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
//    JMLog(@"%s, %@, %@, %@, %@", __func__, peripheral, characteristic, error, [NSThread currentThread]);
    
    if ([characteristic.UUID isEqual: [JumaDeviceConstant notifyCharacteristicUUID]])
    {
        if (!error)
        {
            if (characteristic.isNotifying)
            {
                [self didEstablishConnection];
            }
            else
            {
                NSString *desc = [NSString stringWithFormat:@"The device named %@ can not notify temporarily", peripheral.name];
                self.canNotEstablishConnectionError = [NSError jumaSDK_errorWithDescription:desc];
                [_manager disconnectDevice:self];
            }
        }
        else
        {
            self.canNotEstablishConnectionError = error;
            [_manager disconnectDevice:self];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    //    JMLog(@"%s, %@, %@, %@", __func__, peripheral, characteristic, error);
    
    if ([characteristic.UUID isEqual: [JumaDeviceConstant commandCharacteristicUUID]])
    {
        const JumaDataType dataType = _dataSender.dataType;
        
        // 用户发送了自定义类型的数据 || 设置 OTA 模式
        if (dataType <= JumaDataTypeUserMax || dataType == JumaDataType82)
        {
            if (!error)
            {
                // 第一个已经写入成功, 写入剩余数据
                [_dataSender sendRemainingDatasToCharacteristic:_bulkOutCharacteristic
                                                     peripheral:peripheral];
                
                // 数据发送完毕之后, 清除保存的发送器, 为下一次发送做准备
                self.dataSender = nil;
                [self sendDelegateResultOfWriting:nil];
            }
            else
            {
                // 数据发送失败, 清除保存的发送器
                self.dataSender = nil;
                [self sendDelegateResultOfWriting:error];
                [_manager disconnectDevice:self];
            }
        }
        // 用户发送了固件类型数据
        else if (dataType == JumaDataType81)
        {
            if (!error)
            {
                // 固件数据没有全部写完
                if (!_dataSender.didWriteAllFirmwareData)
                {
                    // 第一组第一个已经写入成功, 写入第一组后面的数据
                    [_dataSender sendRemainingRowsToCharacteristic:_bulkOutCharacteristic
                                                        peripheral:peripheral];
                }
                // 固件数据全部写入完成
                else
                {
                    //JMLog(@"did write OTA_End. Update firmware successfully.");
                    self.dataSender = nil;
                    [self sendDelegateResultOfUpdating:nil];
                }
            }
            else
            {
                self.dataSender = nil;
                [self sendDelegateResultOfUpdating:error];
                [_manager disconnectDevice:self];
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    //JMLog(@"%s, %@, %@, %@", __func__, peripheral, characteristic, error);
    
    if ([characteristic.UUID isEqual: [JumaDeviceConstant notifyCharacteristicUUID]])
    {
        if (!error)
        {
            NSData *receivedData = characteristic.value;
            
            if (receivedData.length)
            {
                // 类型
                JumaDataType type = 0;
                [receivedData getBytes:&type length:sizeof(type)];
                
                if (JumaDataTypeUserMax >= type)
                {
                    // 内容
                    NSData *content = receivedData.length > 2 ? [receivedData juma_subdataFromIndex:2] : nil;
                    
                    [self sendDelegateUpdateData:content type:(char)type error:nil];
                }
                else if (JumaDataType81 == type)
                {
                    // 根据 peripheral 回应的数据来发送相应的固件数据
                    [_dataSender sendFirstRowforResponse:receivedData
                                          characteristic:_commandCharacteristic
                                              peripheral:peripheral];
                }
            }
        }
        else
        {
            // 升级固件的过程中出错
            if (_dataSender.dataType == JumaDataType81)
            {
                self.dataSender = nil;
                [self sendDelegateResultOfUpdating:error];
            }
            // 目前 JUMA 内部只使用了 81 用来标记升级固件这个操作, 而且 81 暂时无法有效使用, 所以错误应该全部属于 [0, 127] 段
            else
            {
                [self sendDelegateUpdateData:nil type:JumaDataTypeError error:error];
            }
            
            [_manager disconnectDevice:self];
        }
    }
}

- (void)didEstablishConnection {
    
    self.canEstablishConnection = YES;
    _state = JumaDeviceStateConnected;
    if ([_manager.delegate respondsToSelector:@selector(manager:didConnectDevice:)]) {
        [_manager.delegate manager:_manager didConnectDevice:self];
    }
}

@end
