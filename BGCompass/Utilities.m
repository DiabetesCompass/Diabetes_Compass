//
//  Utilities.m
//  Compass
//
//  Created by Jose Carrillo on 12/1/13.
//  Copyright (c) 2014 Clif Alferness. All rights reserved.
//

#import "Utilities.h"
#import "BGReading.h"
#import "InsulinReading.h"
#import "FoodReading.h"
#import "Constants.h"

@implementation Utilities

+ (NSNumber*) roundNumber:(NSNumber*) number withNumberOfDecimalPlaces:(NSUInteger) places {
    return @([self roundFloat:[number floatValue] withNumberOfDecimalPlaces:places]);
}

+ (float) roundFloat:(float) number withNumberOfDecimalPlaces:(NSUInteger) places {
    int multiplier = pow(10, places);
    return floorf(number * multiplier + 0.5) / multiplier;
}


+ (NSString*) createFormattedStringFromNumber:(NSNumber *)number withNumberOfDecimalPlaces:(NSUInteger)decimal {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setMinimumFractionDigits:decimal];
    return [formatter stringFromNumber:number];
}

+ (NSString*) createFormattedStringFromNumber:(NSNumber *)number forReadingType:(Class)type {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    if (type == [BGReading class]) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:SETTING_SHOULD_DISPLAY_BG_IN_MMOL_PER_L]) {
            [formatter setMinimumFractionDigits:1];
            [formatter setMaximumFractionDigits:1];
            NSString *result = [formatter stringFromNumber:number];
            return result;
        } else {
            [formatter setMinimumFractionDigits:0];
            [formatter setMaximumFractionDigits:0];
            NSString *result = [formatter stringFromNumber:number];
            return result;
        }
    } else if (type == [FoodReading class]) {
        [formatter setMinimumFractionDigits:0];
        [formatter setMaximumFractionDigits:0];
        NSString *result = [formatter stringFromNumber:number];
        return result;
    } else if (type == [InsulinReading class]) {
        [formatter setMinimumFractionDigits:2];
        [formatter setMaximumFractionDigits:2];
        NSString *result = [formatter stringFromNumber:number];
        return result;
    } else {
        NSString *result = [formatter stringFromNumber:number];
        return result;
    }
}

+ (NSString*) getUnitsForBG {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:SETTING_SHOULD_DISPLAY_BG_IN_MMOL_PER_L]) {
        return @"mmol/L";
    } else {
        return @"mg/dL";
    }
}


@end
