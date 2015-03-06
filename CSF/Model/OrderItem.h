//
// Created by Seamus McGowan on 3/20/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Item.h"

@interface OrderItem : Item

@property(nonatomic, strong) NSDecimalNumber *quantity;

@property(nonatomic, copy) NSString *comment;

- (instancetype)initWithName:(NSString *)name
                        type:(NSString *)type
                       price:(NSDecimalNumber *)price
                    quantity:(NSDecimalNumber *)quantity
                     comment:(NSString *)comment;
@end