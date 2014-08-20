//
// Created by Seamus McGowan on 3/26/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import "Item.h"

@implementation Item {
    NSNumberFormatter *_currencyFormatter;
}

- (NSNumberFormatter *)currencyFormatter {
    if (_currencyFormatter == nil) {
        _currencyFormatter = [[NSNumberFormatter alloc] init];
        _currencyFormatter.NumberStyle  = NSNumberFormatterCurrencyStyle;
        _currencyFormatter.currencyCode = @"USD";
    }

    return _currencyFormatter;
}

- (NSString *)formattedPrice {
    NSString *formattedPrice;
    if (self.price != nil) {
        formattedPrice = [self.currencyFormatter stringFromNumber:self.price];
    }

    return formattedPrice;
}


@end