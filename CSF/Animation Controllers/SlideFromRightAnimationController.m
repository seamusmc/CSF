//
// Created by Seamus McGowan on 5/19/14.
// Copyright (c) 2014 Clover. All rights reserved.
//

#import "SlideFromRightAnimationController.h"
#import "TweaksService.h"

@interface SlideFromRightAnimationController ()



@end

@implementation SlideFromRightAnimationController

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return [TweaksService sharedInstance].slideRightAnimationDuration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    CGRect frame = toViewController.view.frame;
    frame.origin.x += frame.size.width;
    toViewController.view.frame = frame;

    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:toViewController.view];

    NSTimeInterval duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration
                          delay:[TweaksService sharedInstance].slideRightAnimationDelay
         usingSpringWithDamping:[TweaksService sharedInstance].slideRightAnimationDamping
          initialSpringVelocity:[TweaksService sharedInstance].slideRightAnimationVelocity
                        options:UIViewAnimationOptionCurveEaseIn animations:^{

        CGRect frame = fromViewController.view.frame;
        frame.origin.x -= frame.size.width;
        fromViewController.view.frame = frame;

        frame = toViewController.view.frame;
        frame.origin.x -= frame.size.width;
        toViewController.view.frame = frame;

    } completion:^(BOOL finished) {
        [fromViewController.view removeFromSuperview];
        [transitionContext completeTransition:YES];
    }];
}

@end