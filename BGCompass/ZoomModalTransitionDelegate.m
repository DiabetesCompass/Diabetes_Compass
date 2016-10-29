//
//  TranslucentModalTransitionDelegate.m
//  CompassRose
//
//  Created by Jose Carrillo on 11/27/13.
//  Copywrite (c) 2014 Clif Alferness. All rights reserved.
//

#import "ZoomModalTransitionDelegate.h"
#import "ZoomModalAnimator.h"

@implementation ZoomModalTransitionDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    ZoomModalAnimator *controller = [ZoomModalAnimator new];
    controller.presenting = YES;
    return controller;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    ZoomModalAnimator *controller = [ZoomModalAnimator new];
    controller.presenting = YES;
    return controller;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
    return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    return nil;
}

@end
