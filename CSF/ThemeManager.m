//
// Created by Seamus McGowan on 5/6/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import "ThemeManager.h"
#import "FBTweakInline.h"
#import "UIColor+Extended.h"

#define Base 16

// Since FBTweakValue is a MACRO ...
#define TweakColor(category_, collection_, hex_, alpha_) \
((^{ \
    CGFloat alpha = FBTweakValue(category_, collection_, @"Alpha", alpha_, 0.0f, 1.0f); \
    NSString *value = FBTweakValue(category_, collection_, @"Color - Hex", hex_); \
    UInt32 intRGB = (UInt32)strtoul([value UTF8String], NULL, Base); \
    return [UIColor colorWithRGBHex:intRGB alpha:alpha]; \
})()) \

@implementation ThemeManager

#pragma mark - Fonts
#define TweakCategoryFonts @"Fonts"

#define TweakGroupNormalFont @"Normal Font"
- (UIFont *)normalFont {
    CGFloat value = FBTweakValue(TweakCategoryFonts, TweakGroupNormalFont, @"Size", 20.0f, 1.0f, 50.0f);
    return [UIFont fontWithName:@"Avenir-Roman" size:value];
}

- (UIColor *)normalFontColor {
    return TweakColor(TweakCategoryFonts, TweakGroupNormalFont, @"FFFFFF", 0.90f);
}

#define TweakGroupErrorFont @"Error Font"
- (UIFont *)errorFont {
    CGFloat value = FBTweakValue(TweakCategoryFonts, TweakGroupErrorFont, @"Size", 20.0f, 1.0f, 50.0f);
    return [UIFont fontWithName:@"Avenir-Roman" size:value];
}

- (UIColor *)errorFontColor {
    return TweakColor(TweakCategoryFonts, TweakGroupErrorFont, @"E3E300", 1.0f);
}

#define TweakGroupSuccessFont @"Success Font"
- (UIFont *)successFont {
    CGFloat value = FBTweakValue(TweakCategoryFonts, TweakGroupSuccessFont, @"Size", 20.0f, 1.0f, 50.0f);
    return [UIFont fontWithName:@"Avenir-Roman" size:value];
}

- (UIColor *)successFontColor {
    return TweakColor(TweakCategoryFonts, TweakGroupSuccessFont, @"00FF00", 1.0f);
}

#define TweakGroupPlaceHolderFont @"PlaceHolder Font"
- (UIFont *)placeHolderFont {
    CGFloat value = FBTweakValue(TweakCategoryFonts, TweakGroupPlaceHolderFont, @"Size", 20.0f, 1.0f, 50.0f);
    return [UIFont fontWithName:@"Avenir-Roman" size:value];
}

- (UIColor *)placeHolderFontColor {
    return TweakColor(TweakCategoryFonts, TweakGroupPlaceHolderFont, @"A4A4A4", 1.0f);
}

#define TweakGroupTableViewTitleFont @"TableView Title Font"
- (UIFont *)tableViewTitleFont {
    CGFloat value = FBTweakValue(TweakCategoryFonts, TweakGroupTableViewTitleFont, @"Size", 21.0f, 1.0f, 50.0f);
    return [UIFont fontWithName:@"Avenir-Light" size:value];
}

- (UIColor *)tableViewTitleFontColor {
    return TweakColor(TweakCategoryFonts, TweakGroupTableViewTitleFont, @"FFFFFF", 1.0f);
}


#define TweakGroupTableViewDescriptionFont @"TableView Description Font"
- (UIFont *)tableViewDescriptionFont {
    CGFloat value = FBTweakValue(TweakCategoryFonts, TweakGroupTableViewDescriptionFont, @"Size", 17.0f, 1.0f, 50.0f);
    return [UIFont fontWithName:@"Avenir-LightOblique" size:value];
}

- (UIColor *)tableViewDescriptionFontColor {
    return TweakColor(TweakCategoryFonts, TweakGroupTableViewDescriptionFont, @"FFFFFF", 0.60f);
}

#pragma mark - Colors
#define TweakCategoryColors @"Colors"

#define TweakGroupTint @"Tint"
- (UIColor *)tintColor {
    return TweakColor(TweakCategoryColors, TweakGroupTint, @"FFFFFF", 0.1f);
}

#define TweakGroupDisabled @"Disabled"
- (UIColor *)disabledColor {
    return TweakColor(TweakCategoryColors, TweakGroupDisabled, @"A4A4A4", 1.0f);
}

#define TweakGroupImageTint @"Image Tint"
- (UIColor *)imageTintColor {
    return TweakColor(TweakCategoryColors, TweakGroupImageTint, @"000000", 0.5f);
}

#pragma mark - Notification Animations
#define TweakCategoryNotificationAnimations @"Notification Animations"

#pragma mark - Notification Label Dynamic Animation
#define TweakGroupNotification @"Notification"

- (CGFloat)notificationDuration {
    return FBTweakValue(TweakCategoryNotificationAnimations, TweakGroupNotification, @"Duration", 0.5f, 0.0f, 10.0f);
}

- (CGFloat)notificationDelay {
    return FBTweakValue(TweakCategoryNotificationAnimations, TweakGroupNotification, @"Delay", 0.2f, 0.0f, 1.0f);
}

- (CGFloat)notificationDamping {
    return FBTweakValue(TweakCategoryNotificationAnimations, TweakGroupNotification, @"Damping", 0.7f, 0.0f, 1.0f);
}

- (CGFloat)notificationInitialVelocity {
    return FBTweakValue(TweakCategoryNotificationAnimations, TweakGroupNotification, @"Velocity", 0.0f, 0.0f, 1.0f);
}

#pragma mark - Transition Animations
#define TweakCategoryAnimationTransition @"Animation Transitions"

#pragma mark - Slide Right Transitions
#define TweakGroupSlideRight @"Slide Right"

- (CGFloat)slideRightAnimationDuration {
    return FBTweakValue(TweakCategoryAnimationTransition, TweakGroupSlideRight, @"Duration", 0.7f, 0.0f, 2.0f);
}

- (CGFloat)slideRightAnimationDelay {
    return FBTweakValue(TweakCategoryAnimationTransition, TweakGroupSlideRight, @"Delay", 0.0f, 0.0f, 1.0f);
}

- (CGFloat)slideRightAnimationDamping {
    return FBTweakValue(TweakCategoryAnimationTransition, TweakGroupSlideRight, @"Damping", 0.8f, 0.0f, 1.0f);
}

- (CGFloat)slideRightAnimationVelocity {
    return FBTweakValue(TweakCategoryAnimationTransition, TweakGroupSlideRight, @"Velocity", 0.0f, 0.0f, 1.0f);
}

#pragma mark - Acitvity Indicator
#define TweakCategoryActivityIndicator @"Activity Indicator"

#define TweakGroupShimmering @"Shimmering"
- (CGFloat)shimmerSpeed {
    return FBTweakValue(TweakCategoryActivityIndicator, TweakGroupShimmering, @"Speed", 230.0f, 0.0f, 500.0f);
}

- (CGFloat)shimmeringBeginFadeDuration {
    return FBTweakValue(TweakCategoryActivityIndicator, TweakGroupShimmering, @"Begin Duration", 0.0f, 0.0f, 1.0f);
}

- (CGFloat)shimmeringEndFadeDuration {
    return FBTweakValue(TweakCategoryActivityIndicator, TweakGroupShimmering, @"End Duration", 0.0f, 0.0f, 1.0f);
}

- (CGFloat)shimmeringOpacity {
    return FBTweakValue(TweakCategoryActivityIndicator, TweakGroupShimmering, @"Opacity", 0.0f, 0.0f, 1.0f);
}

#define TweakGroupColor @"Color"
- (UIColor *)shimmeringColor {
    return TweakColor(TweakCategoryActivityIndicator, TweakGroupColor, @"FFFFFF", 1.0f);
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