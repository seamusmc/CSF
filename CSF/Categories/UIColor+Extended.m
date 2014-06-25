//
// Created by Seamus McGowan on 6/25/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import "UIColor+Extended.h"

#define Base 16     // For Hex string without 0x

@implementation UIColor (Extended)

+ (UIColor *)colorWithRGBHex:(UInt32)hex alpha:(CGFloat)alpha {
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;

    return [UIColor colorWithRed:r / 255.0f
                           green:g / 255.0f
                            blue:b / 255.0f
                           alpha:alpha];
}

+ (UIColor *)colorWithRGBHexString:(NSString *)hex alpha:(CGFloat)alpha {
    UInt32 intRGB = (UInt32)strtoul([hex UTF8String], NULL, Base);
    return [UIColor colorWithRGBHex:intRGB alpha:alpha];
}


@end