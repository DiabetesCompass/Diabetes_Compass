//
//  BGReading.m
//  Compass
//
//  Created by macbookpro on 4/14/13.
//  Copyright (c) 2013 Clif Alferness. All rights reserved.
//

#import "BGReading.h"

#define CONVERSIONFACTOR 18.0182

@implementation BGReading

NSString *const stringForUnitsInMoles = @"mmol/L";
NSString *const stringForUnitsInMilligrams = @"mg/dL";

@dynamic quantity;


+(BOOL) isInMoles
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"unitsAreInMoles"];
}

+(NSString *) displayString:(NSNumber*) value withConversion:(BOOL) convert
{
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    if ([BGReading isInMoles]) {
        [formatter setMinimumFractionDigits:1];
        [formatter setMaximumFractionDigits:1];
        NSString *result = [formatter stringFromNumber:value];
        return result;
    } else {
        [formatter setMinimumFractionDigits:0];
        [formatter setMaximumFractionDigits:0];
        float multiplier = 1.0;
        if (convert) {
            multiplier = CONVERSIONFACTOR;
        }
        NSString *result = [formatter stringFromNumber:[NSNumber numberWithFloat:(value.floatValue * multiplier)]];
        return result;
    }
}

- (void) setQuantity: (NSNumber*) quantity withConversion: (BOOL)action {
    if (action) {
        self.quantity = [NSNumber numberWithFloat:([quantity floatValue]/CONVERSIONFACTOR)];
    } else {
        self.quantity = quantity;
    }
}

+ (float) getValue:(float)value withConversion: (BOOL) convert
{
    if (convert && ![BGReading isInMoles]) {
        return value*CONVERSIONFACTOR;
    }
    return value;
}

-(NSString *) displayString
{
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    NSString* result;
    if ([BGReading isInMoles]) {
        [formatter setMinimumFractionDigits:1];
        [formatter setMaximumFractionDigits:1];
        result = [formatter stringFromNumber:[NSNumber numberWithFloat:self.quantity.floatValue]];
        return [result stringByAppendingString:@" mmol/L"];
    } else {
        [formatter setMinimumFractionDigits:0];
        [formatter setMaximumFractionDigits:0];
        result = [formatter stringFromNumber:[NSNumber numberWithFloat:(self.quantity.floatValue * CONVERSIONFACTOR)]];
        return [result stringByAppendingString:@" mg/dL"];
    }
}

- (NSString *) itemValue {
    return self.displayString;
}
@end
