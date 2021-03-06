//
// Created by Seamus McGowan on 5/19/14.
//

#import "SlideToRightAnimationController.h"
#import "ThemeManager.h"

@implementation SlideToRightAnimationController

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return [ThemeManager sharedInstance].slideRightAnimationDuration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *toViewController   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];

    CGRect frame = toViewController.view.frame;
    frame.origin.x -= frame.size.width;
    toViewController.view.frame = frame;

    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:toViewController.view];

    NSTimeInterval duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration
                          delay:[ThemeManager sharedInstance].slideRightAnimationDelay
         usingSpringWithDamping:[ThemeManager sharedInstance].slideRightAnimationDamping
          initialSpringVelocity:[ThemeManager sharedInstance].slideRightAnimationVelocity
                        options:UIViewAnimationOptionCurveEaseOut animations:^{

        CGRect frame = fromViewController.view.frame;
        frame.origin.x += frame.size.width;
        fromViewController.view.frame = frame;

        frame = toViewController.view.frame;
        frame.origin.x += frame.size.width;
        toViewController.view.frame = frame;

    } completion:^(BOOL finished) {
        [fromViewController.view removeFromSuperview];
        [transitionContext completeTransition:YES];
    }];
}

@end