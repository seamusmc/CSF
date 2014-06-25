//
// Created by Seamus McGowan on 6/25/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIColor (Extended)

+ (UIColor *)colorWithRGBHex:(UInt32)hex alpha:(CGFloat)alpha;
+ (UIColor *)colorWithRGBHexString:(NSString *)hex alpha:(CGFloat)alpha;

@end