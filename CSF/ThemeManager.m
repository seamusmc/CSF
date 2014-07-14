//
// Created by Seamus McGowan on 5/6/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import "ThemeManager.h"
#import "TweaksService.h"

@implementation ThemeManager

- (UIColor *)disabledColor {
    return [TweaksService sharedInstance].disabledColor;
}

- (UIColor *)tintColor {
    return [TweaksService sharedInstance].tintColor;
}

- (UIColor *)placeHolderFontColor {
    return [TweaksService sharedInstance].placeHolderFontColor;
}

- (UIFont *)placeHolderFont {
    return [UIFont fontWithName:@"HelveticaNeue-ThinItalic" size:21.0f];;
}

- (UIColor *)errorFontColor {
    return [TweaksService sharedInstance].errorFontColor;
}

- (UIFont *)errorFont {
    return [TweaksService sharedInstance].errorFont;
}

- (UIFont *)normalFont {
    return [TweaksService sharedInstance].normalFont;
}

- (UIColor *)normalFontColor {
    return [TweaksService sharedInstance].normalFontColor;
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