//
// Created by Seamus McGowan on 5/6/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import "ThemeManager.h"

@implementation ThemeManager

- (UIColor *)tintColor
{
    return [UIColor colorWithRed:0.09f green:0.34f blue:0.58f alpha:1.0f];
}

- (UIFont *)fontWithSize:(CGFloat)size;
{
    return [UIFont fontWithName:@"HelveticaNeue" size:size];
}

+ (instancetype)sharedInstance
{
    static ThemeManager    *sharedInstance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^
    {
        sharedInstance = [[ThemeManager alloc] init];
    });

    return sharedInstance;
}

@end