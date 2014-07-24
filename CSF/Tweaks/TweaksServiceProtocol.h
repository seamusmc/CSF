//
//  TweaksServiceProtocol.h
//  Charge
//
//  Created by Seamus McGowan on 6/16/14.
//  Copyright (c) 2014 Clover. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TweaksServiceProtocol <NSObject>

#pragma mark - Fonts
@property(nonatomic, strong, readonly) UIFont *normalFont;
@property(nonatomic, strong, readonly) UIColor *normalFontColor;

@property(nonatomic, strong, readonly) UIFont *errorFont;
@property(nonatomic, strong, readonly) UIColor *errorFontColor;

@property(nonatomic, strong, readonly) UIFont *placeHolderFont;
@property(nonatomic, strong, readonly) UIColor *placeHolderFontColor;

@property(nonatomic, strong, readonly) UIFont *tableViewTitleFont;
@property(nonatomic, strong, readonly) UIColor *tableViewTitleFontColor;

@property(nonatomic, strong, readonly) UIFont *tableViewDescriptionFont;
@property(nonatomic, strong, readonly) UIColor *tableViewDescriptionFontColor;

#pragma mark - Colors
@property(nonatomic, strong, readonly) UIColor *tintColor;
@property(nonatomic, strong, readonly) UIColor *disabledColor;
@property(nonatomic, strong, readonly) UIColor *imageTintColor;

#pragma mark - Activity Indicator
@property(nonatomic, assign, readonly) CGFloat shimmerSpeed;
@property(nonatomic, assign, readonly) CGFloat shimmeringBeginFadeDuration;
@property(nonatomic, assign, readonly) CGFloat shimmeringEndFadeDuration;
@property(nonatomic, assign, readonly) CGFloat shimmeringOpacity;
@property(nonatomic, strong, readonly) UIColor * shimmeringColor;

#pragma mark - Dynamic Animations

#pragma mark - Notification Label Animation
@property(nonatomic, assign, readonly) CGFloat notificationDamping;

#pragma mark - Transition Animations

#pragma mark - SlideRight Animation Transitions
@property(nonatomic, assign, readonly) CGFloat slideRightAnimationDuration;
@property(nonatomic, assign, readonly) CGFloat slideRightAnimationDelay;
@property(nonatomic, assign, readonly) CGFloat slideRightAnimationDamping;
@property(nonatomic, assign, readonly) CGFloat slideRightAnimationVelocity;

@end
