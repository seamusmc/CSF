//
// Created by Seamus McGowan on 3/20/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import "Order.h"

@implementation Order

- (instancetype)initWithLockedFlag:(BOOL)locked items:(NSArray *)items total:(NSString *)total {
    self = [super init];
    if (self) {
        _locked = locked;
        _items  = items;
        _total = total;
    }

    return self;
}

- (NSString *)description
{
    NSString *locked = (self.locked) ? @"YES" : @"NO";
    NSMutableString *description = [NSMutableString stringWithFormat:@"< %@: Locked: %@ Total: %@ Items: %@",
                                                                     NSStringFromClass([self class]),
                                                                     locked,
                                                                     self.total,
                                                                     self.items];
    [description appendString:@" >"];

    return description;
}

@end