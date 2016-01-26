//
//  NSData+Category.m
//  Juma SDK lite
//
//  Created by 汪安军 on 15/6/16.
//  Copyright (c) 2015年 JUMA. All rights reserved.
//

#import "NSData+Category.h"

@implementation NSData (Category)

- (void)juma_raiseRangeExceptionWithFunctionName:(const char[])name range:(NSRange)range {
    [NSException raise:NSRangeException
                format:@"*** %s: range %@ exceeds data length %lu", name, NSStringFromRange(range), (unsigned long)self.length];
}

- (void)juma_raiseIndexExceptionWithFunctionName:(const char[])name index:(NSUInteger)index {
    [NSException raise:NSRangeException
                format:@"*** %s: index %lu exceeds data length %lu", name, (unsigned long)index, (unsigned long)self.length];
}

- (NSData *)juma_subdataFromIndex:(NSUInteger)from {
    if (from <= self.length) {
        return [self subdataWithRange:NSMakeRange(from, self.length-from)];
    }
    
    [self juma_raiseIndexExceptionWithFunctionName:__func__ index:from];
    return nil;
}

- (NSData *)juma_subdataToIndex:(NSUInteger)to {
    if (to <= self.length) {
        return [self subdataWithRange:NSMakeRange(0, to)];
    }
    
    [self juma_raiseIndexExceptionWithFunctionName:__func__ index:to];
    return nil;
}


- (NSData *)juma_dataByAppendingData:(NSData *)data {
    
    NSMutableData *temp = self.mutableCopy;
    [temp appendData:data];
    return temp.copy;
}

@end

#pragma mark -

@implementation NSMutableData (Category)

#pragma mark   增

- (void)juma_insertData:(NSData *)data atIndex:(NSUInteger)index {
    if (index <= self.length) {
        [self juma_replaceBytesInRange:NSMakeRange(index, 0) withData:data];
    }
    else {
        [self juma_raiseIndexExceptionWithFunctionName:__func__ index:index];
    }
}

#pragma mark - 删

- (void)juma_removeBytesFromIndex:(NSUInteger)from {
    if (from <= self.length) {
        [self juma_removeBytesInRange:NSMakeRange(from, self.length - from)];
    }
    else {
        [self juma_raiseIndexExceptionWithFunctionName:__func__ index:from];
    }
}

- (void)juma_removeBytesToIndex:(NSUInteger)to {
    if (to <= self.length) {
        [self juma_removeBytesInRange:NSMakeRange(0, to)];
    }
    else {
        [self juma_raiseIndexExceptionWithFunctionName:__func__ index:to];
    }
}

- (void)juma_removeBytesInRange:(NSRange)range {
    if (range.location <= self.length && range.length <= self.length) {
        [self juma_replaceBytesInRange:range withData:nil];
    }
    else {
        [self juma_raiseRangeExceptionWithFunctionName:__func__ range:range];
    }
}

#pragma mark - 查

#pragma mark - 改

- (void)juma_replaceBytesInRange:(NSRange)range withData:(NSData *)data {
    
    if (range.length == 0 && data.length == 0) return;
    
    if (range.location <= self.length && range.length <= self.length) {
        [self replaceBytesInRange:range withBytes:data.bytes length:data.length];
    }
    else {
        [self juma_raiseRangeExceptionWithFunctionName:__func__ range:range];
    }
}

@end
