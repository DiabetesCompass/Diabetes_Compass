//
//  BlurTransitionDelegate.m
//  Compass
//
//  Created by Jose on 2/27/14.
//  Copyright (c) 2014 Clif Alferness. All rights reserved.
//

#import "BlurTransitionDelegate.h"
#import "BlurAnimator.h"

@implementation BlurTransitionDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    BlurAnimator *controller = [BlurAnimator new];
    controller.presenting = YES;
    return controller;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    BlurAnimator *controller = [BlurAnimator new];
    controller.presenting = NO;
    return controller;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
    return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    return nil;
}

@end
