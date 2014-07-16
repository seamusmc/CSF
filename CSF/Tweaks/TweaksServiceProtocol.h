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

#pragma mark - Colors
@property(nonatomic, strong, readonly) UIColor *tintColor;
@property(nonatomic, strong, readonly) UIColor *disabledColor;

#pragma mark - Transition Animations

#pragma mark - Fade Animation Transition
@property(nonatomic, assign, readonly) CGFloat fadeAnimationDuration;

#pragma mark - SlideRight Animation Transitions
@property(nonatomic, assign, readonly) CGFloat slideRightAnimationDuration;
@property(nonatomic, assign, readonly) CGFloat slideRightAnimationDelay;
@property(nonatomic, assign, readonly) CGFloat slideRightAnimationDamping;
@property(nonatomic, assign, readonly) CGFloat slideRightAnimationVelocity;

@end
