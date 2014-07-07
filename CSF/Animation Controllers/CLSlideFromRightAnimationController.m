//
// Created by Seamus McGowan on 5/19/14.
// Copyright (c) 2014 Clover. All rights reserved.
//

#import "CLSlideFromRightAnimationController.h"
//#import "CLTweaksService.h"

@implementation CLSlideFromRightAnimationController

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    //return [CLTweaksService sharedInstance].slideRightAnimationDuration;
    return 0.5;
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
    [UIView animateWithDuration:duration animations:^{

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