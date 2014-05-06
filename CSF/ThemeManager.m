//
// Created by Seamus McGowan on 5/6/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import "ThemeManager.h"

@implementation ThemeManager

+ (id)sharedInstance
{
    static ThemeManager *sharedInstance = nil;
    static dispatch_once_t     onceToken;

    dispatch_once(&onceToken, ^
    {
        sharedInstance = [[ThemeManager alloc] init];
    });

    return sharedInstance;
}

@end