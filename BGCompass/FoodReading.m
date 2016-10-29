//
//  FoodReading.m
//  Compass
//
//  Created by macbookpro on 4/17/13.
//  Copyright (c) 2013 Clif Alferness. All rights reserved.
//

#import "FoodReading.h"


@implementation FoodReading

@dynamic carbs;
//@dynamic name;
//@dynamic timeStamp;
@dynamic numberOfServings;
@dynamic servingUnitAndQuantity;
//@dynamic isFavorite;

- (NSString *) itemValue {
    NSNumber *value = [NSNumber numberWithFloat:([self.numberOfServings floatValue] * [self.carbs floatValue])];
    return [[NSString stringWithFormat:@"%.1f", [value floatValue]] stringByAppendingString:@" carbs"];
    
}

@end
