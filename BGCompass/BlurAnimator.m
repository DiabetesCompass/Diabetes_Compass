//
//  BlurAnimator.m
//  Compass
//
//  Created by Jose on 2/27/14.
//  Copyright (c) 2014 Clif Alferness. All rights reserved.
//

#import "BlurAnimator.h"
#import "ANBlurredImageView.h"
#import "ItemsNavigationViewController.h"

@implementation BlurAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.15;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    ItemsNavigationViewController* toViewController = (ItemsNavigationViewController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    [[transitionContext containerView] addSubview:toViewController.view];
    if (self.presenting) {
        toViewController.view.alpha = 0;
        
        CGRect frame = [UIScreen mainScreen].bounds;
        UIGraphicsBeginImageContext(frame.size);
        [toViewController.view.window drawViewHierarchyInRect:frame afterScreenUpdates:NO];
        UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        for (UIView *view in toViewController.view.subviews) {
            if([view isKindOfClass:[ANBlurredImageView class]]) {
                [view removeFromSuperview];
            }
        }
        
        toViewController.blur = [[ANBlurredImageView alloc] initWithImage:snapshot];
        toViewController.blur.framesCount = 7;
        toViewController.blur.blurAmount = 0.5;
        toViewController.blur.blurTintColor = [UIColor clearColor];
        
        
        [toViewController.view addSubview:toViewController.blur];
        [toViewController.view sendSubviewToBack:toViewController.blur];
        
    } else {
        toViewController.view.alpha = 0;
    }
    
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        toViewController.view.alpha = 1;
        
    } completion:^(BOOL finished) {
        [fromViewController.view removeFromSuperview];
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        
    }];
    
}

@end
