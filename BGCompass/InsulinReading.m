//
//  InsulinReading.m
//  Compass
//
//  Created by macbookpro on 4/15/13.
//  Copyright (c) 2013 Clif Alferness. All rights reserved.
//

#import "InsulinReading.h"


@implementation InsulinReading

@dynamic insulinType;
@dynamic quantity;

-(NSString *) quantityWeightedString
{
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setMinimumFractionDigits:2];
    [formatter setMaximumFractionDigits:2];
    NSString *result = [formatter stringFromNumber:[NSNumber numberWithFloat:self.quantity.floatValue]];
    return result;
}

- (NSString *) itemValue
{
    return [[self quantityWeightedString] stringByAppendingString:@" units"];
    
}
@end
