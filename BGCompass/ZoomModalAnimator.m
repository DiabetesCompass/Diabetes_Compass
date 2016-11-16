//
//  TranslucentModalAnimator.m
//  CompassRose
//
//  Created by Jose Carrillo on 11/27/13.
//  Copyright (c) 2014 Clif Alferness. All rights reserved.
//

#import "ZoomModalAnimator.h"
//#import "TrendsContainerViewController.m"
//#import "HomeViewController.h"

@implementation ZoomModalAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.5f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {

    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIView *container = transitionContext.containerView;
    
	CGRect beginFrame = fromVC.view.frame;
    CGRect beginFrame2 = CGRectMake(230, 0, fromVC.view.frame.size.width/7, fromVC.view.frame.size.height/7);
    
    CGRect endFrame = CGRectMake(-1300, 0, fromVC.view.frame.size.width*6, fromVC.view.frame.size.height*5);
    CGRect endFrame2 = CGRectMake(230, 0, fromVC.view.frame.size.width/7, fromVC.view.frame.size.height/7);
    
    UIView *move = [fromVC.view snapshotViewAfterScreenUpdates:YES];
    UIView *move2 = [toVC.view snapshotViewAfterScreenUpdates:YES];
    if (toVC.isBeingPresented) {
        fromVC.view.frame = beginFrame;
        
        move2.frame = beginFrame2;
        move.frame = beginFrame;
        move2.alpha = 0.0;
        [container addSubview:move];
        [container addSubview:move2];
        [fromVC.view removeFromSuperview];
    } else {
        toVC.view.frame = beginFrame;
        move.frame = beginFrame;
        move2.frame = endFrame;
        move2.alpha = 0.0;
        [container addSubview:move];
        [container addSubview:move2];
        [fromVC.view removeFromSuperview];
    }

    
	
	[UIView animateWithDuration:1 delay:0
         usingSpringWithDamping:1 initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveLinear animations:^{
                            if (toVC.isBeingPresented) {
                                move.frame = endFrame;
                                move2.frame = beginFrame;
                                move2.alpha = 1.0;
                                move.alpha = 0.0;
                            } else {
                                move.frame = endFrame2;
                                move2.frame = beginFrame;
                                move2.alpha = 1.0;
                                move.alpha = 0.0;
                            }
                        }
                     completion:^(BOOL finished) {
                         [move removeFromSuperview];
                         [move2 removeFromSuperview];
                         [container addSubview:toVC.view];
                         
                         [transitionContext completeTransition: YES];
                     }];
}


@end
