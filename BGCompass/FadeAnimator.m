//
//  Animator.m
//  Compass
//
//  Created by Jose on 2/27/14.
//  Copywrite (c) 2014 Clif Alferness. All rights reserved.
//

#import "FadeAnimator.h"

@implementation FadeAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    [[transitionContext containerView] addSubview:toViewController.view];
    toViewController.view.alpha = 0;
    //toViewController.view.transform = CGAffineTransformMakeScale(2,2);
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        //fromViewController.view.transform = CGAffineTransformMakeScale(0.1, 0.1);
        //toViewController.view.transform = CGAffineTransformIdentity;
        toViewController.view.alpha = 1;
        fromViewController.view.alpha = 0;
    } completion:^(BOOL finished) {
        //fromViewController.view.alpha = 1;
        [fromViewController.view removeFromSuperview];
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        
    }];
    
}

@end

