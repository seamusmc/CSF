//
// Created by Seamus McGowan on 5/6/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import "ThemeManager.h"
#import "TweaksService.h"
#import "UIColor+Extended.h"

@implementation ThemeManager
- (UIColor *)imageTintColor {
    return [TweaksService sharedInstance].imageTintColor;
}

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
    return [TweaksService sharedInstance].placeHolderFont;
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

- (CGFloat)shimmerSpeed {
    return [TweaksService sharedInstance].shimmerSpeed;
}

- (CGFloat)shimmeringBeginFadeDuration {
    return [TweaksService sharedInstance].shimmeringBeginFadeDuration;
}

- (CGFloat)shimmeringEndFadeDuration {
    return [TweaksService sharedInstance].shimmeringEndFadeDuration;
}

- (CGFloat)shimmeringOpacity {
    return [TweaksService sharedInstance].shimmeringOpacity;
}

- (UIColor *)shimmeringColor {
    return [TweaksService sharedInstance].shimmeringColor;
}

- (CGFloat)notificationDamping {
    return [TweaksService sharedInstance].notificationDamping;
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