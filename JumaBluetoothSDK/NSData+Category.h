//
//  NSData+Category.h
//  Juma SDK lite
//
//  Created by 汪安军 on 15/6/16.
//  Copyright (c) 2015年 JUMA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Category)

- (NSData *)juma_subdataFromIndex:(NSUInteger)from;
- (NSData *)juma_subdataToIndex:(NSUInteger)to;

- (NSData *)juma_dataByAppendingData:(NSData *)data;

@end

@interface NSMutableData (Category)

- (void)juma_insertData:(NSData *)data atIndex:(NSUInteger)index;

- (void)juma_removeBytesFromIndex:(NSUInteger)from;
- (void)juma_removeBytesToIndex:(NSUInteger)to;
- (void)juma_removeBytesInRange:(NSRange)range;

- (void)juma_replaceBytesInRange:(NSRange)range withData:(NSData *)data;

@end
