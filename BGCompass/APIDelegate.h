//
//  APIDelegate.h
//  CompassRose
//
//  Created by Jose Carrillo on 11/11/13.
//  Copyright (c) 2014 Clif Alferness. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIDelegate : NSObject

+ (id)sharedInstance;

+ (NSString *)getMainUrl;

- (void)setupAPI;
- (void)searchNutritionixWithString: (NSString*)string withController: (UIViewController*)controller;
- (void)searchNutritionixWithUpc: (NSString*)string withController: (UIViewController*)controller;

@end
