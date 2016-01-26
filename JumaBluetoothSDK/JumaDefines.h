////
////  JumaDefines.h
////  JumaBluetoothSDK
////
////  Created by 汪安军 on 15/12/4.
////  Copyright © 2015年 JUMA. All rights reserved.
////
//
//#import <Foundation/Foundation.h>
//
//// 数据头组成 01, 数据类型
//typedef NS_ENUM(unsigned char, JumaDataType) {
//    /** 非 JUMA 开发人员可以使用的数据类型的最大值 (public for all) */
//    JumaDataTypeUserMax = 127,
//    /** 用来检查设备是否已经注册 (private) */
//    JumaDataType80 = 0x80,
//    /** 用来进行固件升级 (private) */
//    JumaDataType81 = 0x81,
//    /** 用来让设备进入 OTA 模式 (private) */
//    JumaDataType82 = 0x82
//};
///** 接收数据出现异常/其他无法给出数据类型的情况 (public for all) */
//FOUNDATION_EXPORT const char JumaDataTypeError;
//
//
//// 数据头组成 02, 数据的长度
//typedef unsigned char JumaDataLength;
//
//
//// 固件数据的标识符, 辅助数据写入的流程控制
//typedef NS_ENUM(unsigned char, JumaUpdateFirmwareIdentifier) {
//    /** 准备升级固件 */
//    JumaUpdateFirmwareIdentifierBegin = 0x00,
//    /** 升级结束 */
//    JumaUpdateFirmwareIdentifierEnd   = 0x01,
//    /** 正在发送数据 */
//    JumaUpdateFirmwareIdentifierData  = 0x02,
//};
