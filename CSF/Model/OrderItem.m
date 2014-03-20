//
// Created by Seamus McGowan on 3/20/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import "OrderItem.h"

@implementation OrderItem

- (NSDecimalNumber*) subtotal
{
    return [self.quantity decimalNumberByMultiplyingBy:self.price];
}

@end