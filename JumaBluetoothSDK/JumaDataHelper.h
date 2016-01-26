//
//  JumaDataHelper.h
//  JumaBluetoothSDK
//
//  Created by 汪安军 on 15/6/23.
//  Copyright (c) 2015年 JUMA. All rights reserved.
//

#import <Foundation/Foundation.h>

/* 数据类型是基于简单数字的, 为区分不同数据的不同目的的方式
   数据类型大体上分为两类: 1) 允许用户自定义的部分, 范围是 [0, 127]. 2) 内部使用和保留, 范围是 [128, 255];
   
   第一类, 即用户自定义的数据, 按照 (数据类型 + 数据内容的长度 + 数据内容) 传输
   第二类, 即内部使用的数据, 目前只为升级 peripheral 的固件这一操作指定了类型 0x81, 并且升级固件有它自己的过程.
 */


/* 固件升级流程
   总体上分成 3 个阶段, 准备升级阶段, 发送数据阶段, 升级结束阶段, 并为这个 3 个阶段分别定义了 OTA_Begin, OTA_Data, OTA_End.
 
 1.0 central 向 peripheral 发送 OTA_Begin, peripheral 收到后会进行前期设置, 设置完成后会发出内容是 OTA_Begin 的通知, central 收到 OTA_Begin 后认定可以进行升级.
 
 2.0 central 向 peripheral 发送 OTA_Data,  peripheral 收到后会准备接收固件数据, 准备完成后会发出内容是 OTA_Data 的通知, central 收到 OTA_Data 后就正式发送固件数据.
 2.1 如果一个固件数据的长度大于 196, 就需要对这个数据进行分包, peripheral 每收到一个固件数据包, 就会发出内容是 OTA_Data 的通知.
 2.2 发送余下的固件数据包 ......
 2.3 central 发送完最后一个包, 并且收到了对应的 OTA_Data, 就认定固件数据写入成功.
 
 3.0 固件数据写入成功后, central 以有回应的方式发送 OTA_End, 在 central 收到 OTA_End 写入成功的回调后, 认定固件升级成功.
 */


/* 如何拆分固件数据
   假定有一个数据长度为 n = 196 + + 196 + m ( 0 < m <= 196), 拆分并和数据类型组合, 结果如下
    类型       长度       子类型     索引     实际的固件数据
   [0x81] + [196+2] + [OTA_Data] + [0] + [长度为 196 的数据]
   [0x81] + [196+2] + [OTA_Data] + [1] + [长度为 196 的数据]
   [0x81] + [m  +2] + [OTA_Data] + [2] + [长度为 m   的数据]
 
   为什么有索引: 假如一个固件数据被拆分后发送, peripheral 就需要重新组合这些被拆分的数据, 索引用来提供组合的顺序
   长度为什么要加 2: 因为子类型和索引也算在数据内容当中, 也就是说, 在处理固件数据的时候, 虽然实际上数据头部是由类型, 长度, 子类型和索引构成, 但是名义上的数据头部只有类型和长度
 */


// 数据头组成 01, 数据类型
typedef NS_ENUM(unsigned char, JumaDataType) {
    /** 用户可以自由选择的数据类型的最大值是 127 */
    JumaDataTypeUserMax = 127,
    /** 用来检查设备是否已经注册 */
    JumaDataType80 = 0x80,
    /** 用来进行固件升级 */
    JumaDataType81 = 0x81,
    /** 用来让设备进入 OTA 模式 */
    JumaDataType82 = 0x82
};
/** 接收数据出现异常/其他无法给出数据类型的情况 */
extern const char JumaDataTypeError;


// 数据头组成 02, 数据的长度
typedef unsigned char JumaDataLength;


// 固件数据的子类型, 辅助数据写入的流程控制
typedef NS_ENUM(unsigned char, JumaDataSubtype) {
    JumaDataSubtypeBegin = 0x00, // 开始升级
    JumaDataSubtypeEnd   = 0x01, // 升级结束
    JumaDataSubtypeData  = 0x02, // 数据
};

@interface JumaDataHelper : NSObject

+ (NSMutableArray *)dividedDatasWithType:(JumaDataType)type data:(NSData *)data;
+ (NSMutableArray *)dividedFirmwareDatasWithType:(JumaDataType)type subtype:(JumaDataSubtype)subtype data:(NSData *)data;

@end
