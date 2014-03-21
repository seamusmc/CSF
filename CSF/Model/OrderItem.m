//
// Created by Seamus McGowan on 3/20/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import "OrderItem.h"

@implementation OrderItem

- (NSDecimalNumber *)subtotal
{
    return [self.quantity decimalNumberByMultiplyingBy:self.price];
}

- (NSString *)description
{
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: Name: %@ Type: %@ Price: %@ Qty: %@",
                                                                     NSStringFromClass([self class]),
                                                                     self.name,
                                                                     self.type,
                                                                     self.price,
                                                                     self.quantity];
    [description appendString:@">"];
    return description;
}

@end