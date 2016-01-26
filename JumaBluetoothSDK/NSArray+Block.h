//
//  NSArray+Block.h
//  iOS-Categories (https://github.com/shaojiankui/iOS-Categories)
//
//  Created by Jakey on 14/12/15.
//  Copyright (c) 2014年 www.skyfox.org. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Block)

- (NSArray *)jumaSDK_map:(id (^)(id object))block;
- (NSArray *)jumaSDK_filter:(BOOL (^)(id object))block;
//- (NSArray *)jumaSDK_reject:(BOOL (^)(id object))block;
- (id)jumaSDK_detect:(BOOL (^)(id object))block;
//- (id)jumaSDK_reduce:(id (^)(id accumulator, id object))block;
//- (id)jumaSDK_reduce:(id)initial withBlock:(id (^)(id accumulator, id object))block;
@end
