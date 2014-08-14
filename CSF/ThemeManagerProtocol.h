//
// Created by Seamus McGowan on 7/10/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ThemeManagerProtocol <NSObject>

#pragma mark - Colors
@property(nonatomic, strong, readonly) UIColor *tintColor;
@property(nonatomic, strong, readonly) UIColor *disabledColor;
@property(nonatomic, strong, readonly) UIColor *imageTintColor;

#pragma mark - Fonts
@property(nonatomic, strong, readonly) UIColor *normalFontColor;
@property(nonatomic, strong, readonly) UIFont *normalFont;

@property(nonatomic, strong, readonly) UIColor *errorFontColor;
@property(nonatomic, strong, readonly) UIFont *errorFont;

@property(nonatomic, strong, readonly) UIColor *placeHolderFontColor;
@property(nonatomic, strong, readonly) UIFont *placeHolderFont;

@property(nonatomic, strong, readonly) UIFont *tableViewTitleFont;
@property(nonatomic, strong, readonly) UIColor *tableViewTitleFontColor;

@property(nonatomic, strong, readonly) UIFont *tableViewDescriptionFont;
@property(nonatomic, strong, readonly) UIColor *tableViewDescriptionFontColor;

#pragma mark - Activity Indicator
@property(nonatomic, assign, readonly) CGFloat shimmerSpeed;
@property(nonatomic, assign, readonly) CGFloat shimmeringBeginFadeDuration;
@property(nonatomic, assign, readonly) CGFloat shimmeringEndFadeDuration;
@property(nonatomic, assign, readonly) CGFloat shimmeringOpacity;
@property(nonatomic, strong, readonly) UIColor * shimmeringColor;

#pragma mark - Notification Animation
@property(nonatomic, assign, readonly) CGFloat notificationDamping;
@property(nonatomic, assign, readonly) CGFloat notificationDuration;
@property(nonatomic, assign, readonly) CGFloat notificationDelay;
@property(nonatomic, assign, readonly) CGFloat notificationInitialVelocity;

@end