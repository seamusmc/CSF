//
//  TweaksServiceProtocol.h
//  Charge
//
//  Created by Seamus McGowan on 6/16/14.
//  Copyright (c) 2014 Clover. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TweaksServiceProtocol <NSObject>

#pragma mark - Colors
@property(nonatomic, strong, readonly) UIColor *tintColor;

#pragma mark - Transition Animations

#pragma mark - Fade Animation Transition
@property(nonatomic, assign, readonly) CGFloat fadeAnimationDuration;

#pragma mark - SlideRight Animation Transitions
@property(nonatomic, assign, readonly) CGFloat slideRightAnimationDuration;

@end
