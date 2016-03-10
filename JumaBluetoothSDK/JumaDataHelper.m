//
//  JumaDataHelper.m
//  JumaBluetoothSDK
//
//  Created by 汪安军 on 15/6/23.
//  Copyright (c) 2015年 JUMA. All rights reserved.
//

#import "JumaDataHelper.h" 
#import "NSData+Category.h"

const SInt8 JumaDataTypeError = -1;

static const JumaDataLength MaxSectionLength = 200; // peripheral 一次最多可以处理 200 个 byte, 超过 200 的部分需要拆分
static const JumaDataLength MaxSectionContentLength = MaxSectionLength - sizeof(JumaDataType) - sizeof(JumaDataLength);
static const JumaDataLength MaxPacketLength = 20; // peripheral 一次最多可以接收 20 个 byte

// 每一组固件数据的 index
typedef UInt8 SectionIndex;

@implementation JumaDataHelper

+ (NSMutableArray *)dividedDatasWithType:(JumaDataType)type data:(NSData *)data {
    
    // 1 类型
    NSMutableData *header = [NSMutableData dataWithBytes:&type length:sizeof(type)];
    
    // 2 长度
    JumaDataLength len = (JumaDataLength)data.length;
    [header appendData:[NSData dataWithBytes:&len length:sizeof(len)]];
    
    // 3 内容
    [header appendData:data];
    
    // 分割
    return [self divideData:header length:MaxPacketLength];
}

/** 每一组固件数据的头部 */
+ (NSMutableData *)headerWithType:(JumaDataType)type
                           length:(JumaDataLength)length
                          subtype:(JumaDataSubtype)subtype
                     sectionIndex:(SectionIndex)index
{
    NSMutableData *header = [[NSMutableData alloc] init];
    [header appendBytes:&type    length:sizeof(type)];    // 这一组的 类型
    [header appendBytes:&length  length:sizeof(length)];  // 这一组的 长度
    [header appendBytes:&subtype length:sizeof(subtype)]; // 这一组的 子类型
    [header appendBytes:&index   length:sizeof(index)];   // 这一组的 index
    
    return header;
}

+ (NSMutableArray *)dividedFirmwareDatasWithType:(JumaDataType)type subtype:(JumaDataSubtype)subtype data:(NSData *)data {
    
    NSMutableArray *sections = [[NSMutableArray alloc] init];
    
    // 按组分割数据, 组合头部和内容
    {
        NSMutableData *temp = [NSMutableData dataWithData:data];
        
        // 每一组数据的头部的实际长度
        const JumaDataLength headerLength = [self headerWithType:0 length:0 subtype:0 sectionIndex:0].length;
        
        // 每一组中固件数据部分的最大长度
        const JumaDataLength maxLength = MaxSectionLength - headerLength;
        
        // 按组分割得到的组数
        SectionIndex count =   (SectionIndex)(data.length / maxLength)
                             + (SectionIndex)(data.length % maxLength == 0 ? 0 : 1);
        
        // 第 1 组到倒数第 2 组
        for (SectionIndex i = 0; i < count - 1; i++) {
            
            // 头部
            NSMutableData *header = [self headerWithType:JumaDataType81
                                                  length:MaxSectionContentLength
                                                 subtype:subtype
                                            sectionIndex:i];
            // 内容
            NSData *content = [temp subdataWithRange:NSMakeRange(i * maxLength, maxLength)];
            
            [header appendData:content];
            [sections addObject:header];
        }
        // 最后一组
        {
            // 内容
            [temp juma_removeBytesToIndex:maxLength * (count - 1)];
            
            // 头部
            JumaDataLength len = MaxSectionContentLength - maxLength + (JumaDataLength)temp.length;
            NSMutableData *header = [self headerWithType:JumaDataType81
                                                  length:len
                                                 subtype:subtype
                                            sectionIndex:count-1];
            [header appendData:temp];
            [sections addObject:header];
        }
    }
    
    // 分割每一组
    for (NSUInteger i = 0; i < sections.count; i++) {
        
        NSMutableData *data = sections[i];
        NSMutableArray *rows = [self divideData:data length:MaxPacketLength];
        [sections replaceObjectAtIndex:i withObject:rows];
    }
    
    return sections;
}

+ (NSMutableArray *)divideData:(NSMutableData *)data length:(NSUInteger)len {
    
    NSMutableArray *datas = [[NSMutableArray alloc] init];
    
    while (data.length > len) {
        [datas addObject:[data juma_subdataToIndex:len]];
        [data juma_removeBytesToIndex:len];
    }
    if (data.length > 0) {
        [datas addObject:[data copy]];
    }
    
    return datas;
}

@end
