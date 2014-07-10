//
//  TweaksService.m
//  Charge
//
//  Created by Seamus McGowan on 6/16/14.
//  Copyright (c) 2014 Clover. All rights reserved.
//

#import "TweaksService.h"
#import "FBTweakInline.h"
#import "UIColor+Extended.h"

#define Base 16

// Since FBTweakValue is a MACRO ...
#define TweakColor(category_, collection_, hex_, alpha_) \
((^{ \
    CGFloat alpha = FBTweakValue(category_, collection_, @"Alpha", alpha_, 0.0f, 1.0f); \
    NSString *value = FBTweakValue(category_, collection_, @"Hex", hex_); \
    UInt32 intRGB = (UInt32)strtoul([value UTF8String], NULL, Base); \
    return [UIColor colorWithRGBHex:intRGB alpha:alpha]; \
})()) \

@implementation TweaksService

#pragma mark - Colors
#define TweakCategoryColors @"Colors"

#define TweakGroupTint @"Theme Tint"
- (UIColor *)tintColor {
    return TweakColor(TweakCategoryColors, TweakGroupTint, @"104082", 1.0f);
}

#define TweakGroupFont @"Font Color"
- (UIColor *)fontColor {
    return TweakColor(TweakCategoryColors, TweakGroupFont, @"FFFFFF", 1.0f);
}

#define TweakGroupFontError @"Font Error Color"
- (UIColor *)fontErrorColor {
    return TweakColor(TweakCategoryColors, TweakGroupFontError, @"FF0000", 1.0f);
}


#pragma mark - Transition Animations
#define TweakCategoryAnimationTransition @"Animation Transitions"

#pragma mark - Fade Animation Transition
#define TweakGroupFade @"Fade"

- (CGFloat)fadeAnimationDuration {
    return FBTweakValue(TweakCategoryAnimationTransition, TweakGroupFade, @"Duration", 0.6f, 0.0f, 2.0f);
}

#pragma mark - Slide Right Transitions
#define TweakGroupSlideRight @"Slide Right"

- (CGFloat)slideRightAnimationDuration {
    return FBTweakValue(TweakCategoryAnimationTransition, TweakGroupSlideRight, @"Duration", 0.9f, 0.0f, 2.0f);
}

- (CGFloat)slideRightAnimationDelay {
    return FBTweakValue(TweakCategoryAnimationTransition, TweakGroupSlideRight, @"Delay", 0.0f, 0.0f, 1.0f);
}

- (CGFloat)slideRightAnimationDamping {
    return FBTweakValue(TweakCategoryAnimationTransition, TweakGroupSlideRight, @"Damping", 0.85f, 0.0f, 1.0f);
}

- (CGFloat)slideRightAnimationVelocity {
    return FBTweakValue(TweakCategoryAnimationTransition, TweakGroupSlideRight, @"Velocity", 0.0f, 0.0f, 1.0f);
}


+ (id<TweaksServiceProtocol>)sharedInstance
{
    static TweaksService *sharedInstance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedInstance = [[TweaksService alloc] init];
    });

    return sharedInstance;
}

@end
