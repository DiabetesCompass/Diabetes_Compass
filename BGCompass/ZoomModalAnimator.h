//
//  TranslucentModalAnimator.h
//  CompassRose
//
//  Created by Jose Carrillo on 11/27/13.
//  Copywrite (c) 2014 Clif Alferness. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZoomModalAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign, getter = isPresenting) BOOL presenting;

@end
