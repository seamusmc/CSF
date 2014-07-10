//
// Created by Seamus McGowan on 5/6/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import "ThemeManager.h"
#import "TweaksService.h"

@implementation ThemeManager

- (UIColor *)fontColor {
    return [TweaksService sharedInstance].fontColor;
}

- (UIColor *)fontErrorColor {
    return [TweaksService sharedInstance].fontErrorColor;
}

- (UIColor *)tintColor {
    return [TweaksService sharedInstance].tintColor;
}

- (UIFont *)fontWithSize:(CGFloat)size; {
    return [UIFont fontWithName:@"HelveticaNeue" size:size];
}

+ (instancetype)sharedInstance {
    static ThemeManager    *sharedInstance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedInstance = [[ThemeManager alloc] init];
    });

    return sharedInstance;
}

@end