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
        bgReading.quantity = @(135);
        bgReading.timeStamp = [NSDate dateWithTimeInterval:-i*SECONDS_IN_ONE_HOUR
                                                 sinceDate:endDate];
        bgReading.isPending = [NSNumber numberWithBool:NO];

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
        NSTimeInterval timeInterval = -(HOURS_IN_ONE_DAY * SECONDS_IN_ONE_HOUR * i);
        bgReading.timeStamp = [NSDate dateWithTimeInterval:timeInterval
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

@end
