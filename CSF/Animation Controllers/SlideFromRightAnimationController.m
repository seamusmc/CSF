//
// Created by Seamus McGowan on 5/19/14.
//

#import "SlideFromRightAnimationController.h"
#import "ThemeManager.h"

@implementation SlideFromRightAnimationController

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return [ThemeManager sharedInstance].slideRightAnimationDuration;
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
                          delay:[ThemeManager sharedInstance].slideRightAnimationDelay
         usingSpringWithDamping:[ThemeManager sharedInstance].slideRightAnimationDamping
          initialSpringVelocity:[ThemeManager sharedInstance].slideRightAnimationVelocity
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