//
// Created by Seamus McGowan on 3/20/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import "Order.h"

@implementation Order

- (instancetype)initWithLocked:(BOOL)locked items:(NSArray *)items
{
    self = [super init];
    if (self)
    {
        _locked = locked;
        _items  = items;
    }

    return self;
}

- (NSString *)description
{
    NSString *locked = (self.locked) ? @"YES" : @"NO";
    NSMutableString *description = [NSMutableString stringWithFormat:@"< %@: Locked: %@ Items: %@",
                                                                     NSStringFromClass([self class]),
                                                                     locked,
                                                                     self.items];
    [description appendString:@" >"];

    return description;
}

@end