//
//  NutritionixSearchFood.h
//  Compass
//
//  Created by macbookpro on 4/14/13.
//  Copyright (c) 2013 Clif Alferness. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NutritionixSearchFood : NSObject

// The request parameters
@property (strong, nonatomic) NSString *upc;
@property (strong, nonatomic) NSString *query;
@property (strong, nonatomic) NSDictionary *sort;
@property (strong, nonatomic) NSDictionary *filters;
@property (strong, nonatomic) NSString *results;
@property (strong, nonatomic) NSString *cal_min;
@property (strong, nonatomic) NSString *cal_max;
@property (strong, nonatomic) NSArray *fields;
@property (strong, nonatomic) NSString *appId;
@property (strong, nonatomic) NSString *appKey;

// The result parameters
@property (strong, nonatomic) NSString *itemID;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *brand;
@property (strong, nonatomic) NSNumber *carbs;
@property (strong, nonatomic) NSNumber *numberOfServings;
@property (strong, nonatomic) NSString *servingUnit;
@property (strong, nonatomic) NSString *servingUnitQuantity;

@end
