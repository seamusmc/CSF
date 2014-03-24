//
// Created by Seamus McGowan on 3/24/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import "InventoryItem.h"

@implementation InventoryItem

- (NSString *)description
{
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: Name: %@ Type: %@ Price: %@ OutOfStock: %@ fractionalUnits: %@",
                                                                     NSStringFromClass([self class]),
                                                                     self.name,
                                                                     self.type,
                                                                     self.price,
                                                                     self.outOfStock ? @"Yes" : @"No",
                                                                     self.fractionalUnits ? @"Yes" : @"No"];
    [description appendString:@">"];
    return description;
}

@end