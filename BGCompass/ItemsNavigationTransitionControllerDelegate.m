//
//  ItemsNavigationTransitionControllerDelegate.m
//  Compass
//
//  Created by Jose on 2/27/14.
//  Copywrite (c) 2014 Clif Alferness. All rights reserved.
//

#import "ItemsNavigationTransitionControllerDelegate.h"
#import "FadeAnimator.h"
#import "ItemsNavigationViewController.h"
#import "BlurAnimator.h"
#import "EditItemViewController.h"
#import "HomeViewController.h"
#import "SettingsController.h"


@interface ItemsNavigationTransitionControllerDelegate ()

@property (strong, nonatomic) FadeAnimator* fadeAnimator;
@property (strong, nonatomic) BlurAnimator* blurAnimator;

@end

@implementation ItemsNavigationTransitionControllerDelegate


- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    if (self.fadeAnimator == nil) {
        self.fadeAnimator = [FadeAnimator new];
    }
    
    if (self.blurAnimator == nil) {
        self.blurAnimator = [BlurAnimator new];
    }
    
    if ([toVC isKindOfClass:[EditItemViewController class]] && [fromVC isKindOfClass:[HomeViewController class]]) {
        self.blurAnimator.presenting = YES;
        return self.blurAnimator;
    }
    
    if (operation == UINavigationControllerOperationPush || operation == UINavigationControllerOperationPop) {
        return self.fadeAnimator;
    }
    return nil;
}




@end
