//
//  BGReadingTestHelper.m
//  BGCompass
//
//  Created by Steve Baker on 1/6/17.
//  Copyright © 2017 Clif Alferness. All rights reserved.
//

#import "BGReadingTestHelper.h"

@implementation BGReadingTestHelper

+ (NSArray *)bgReadings135:(NSDate *)endDate {

    NSMutableArray *bgReadings = [NSMutableArray arrayWithArray:@[]];

    for (int i = 90 * HOURS_IN_ONE_DAY; i > 0 ; i--) {

        // use MagicalRecord/CoreData to create the entity but don't save it
        BGReading *bgReading = [BGReading MR_createEntity];
        bgReading.name = @"BloodGlucose";

        NSTimeInterval secondsPerDay = HOURS_IN_ONE_DAY * SECONDS_IN_ONE_HOUR;
        bgReading.timeStamp = [NSDate dateWithTimeInterval:-secondsPerDay * i
                                                 sinceDate:endDate];

        bgReading.isPending = [NSNumber numberWithBool:NO];

        bgReading.quantity = @(135);

        [bgReadings addObject:bgReading];
    }
    // use copy to return NSArray instead of NSMutableArray
    return [bgReadings copy];
}

+ (NSArray *)bgReadingsAlternating135and170:(NSDate *)endDate {

    NSMutableArray *bgReadings = [NSMutableArray arrayWithArray:@[]];

    for (int i = 90; i > 0 ; i--) {

        // use MagicalRecord/CoreData to create the entity but don't save it
        BGReading *bgReading = [BGReading MR_createEntity];
        bgReading.name = @"BloodGlucose";

        NSTimeInterval secondsPerDay = HOURS_IN_ONE_DAY * SECONDS_IN_ONE_HOUR;
        bgReading.timeStamp = [NSDate dateWithTimeInterval:-secondsPerDay * i
                                                 sinceDate:endDate];

        bgReading.isPending = [NSNumber numberWithBool:NO];

        // use modulo operator %
        if (i % 2 == 0) {
            // i is even
            bgReading.quantity = @(135);
        } else {
            bgReading.quantity = @(170);
        }

        [bgReadings addObject:bgReading];
    }
    // use copy to return NSArray instead of NSMutableArray
    return [bgReadings copy];
}

+ (NSArray *)bgReadings150then50:(NSDate *)endDate {

    NSMutableArray *bgReadings = [NSMutableArray arrayWithArray:@[]];

    int numberOfReadings = 100;
    for (int i = 0; i < numberOfReadings; i++) {

        // use MagicalRecord/CoreData to create the entity but don't save it
        BGReading *bgReading = [BGReading MR_createEntity];
        bgReading.name = @"BloodGlucose";

        NSTimeInterval secondsPerDay = HOURS_IN_ONE_DAY * SECONDS_IN_ONE_HOUR;
        bgReading.timeStamp = [NSDate dateWithTimeInterval:-secondsPerDay * i
                                                 sinceDate:endDate];

        bgReading.isPending = [NSNumber numberWithBool:NO];

        if (i < 30) {
            bgReading.quantity = @(150);
        } else {
            bgReading.quantity = @(50);
        }

        [bgReadings addObject:bgReading];
    }
    // use copy to return NSArray instead of NSMutableArray
    return [bgReadings copy];
}

@end
