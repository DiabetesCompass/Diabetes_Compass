//
//  BGReadingTestHelper.m
//  BGCompass
//
//  Created by Steve Baker on 1/6/17.
//  Copyright © 2017 Clif Alferness. All rights reserved.
//

#import "BGReadingTestHelper.h"

@implementation BGReadingTestHelper

+ (BGReading *)bgReadingWithName:(NSString *)name
                       timeStamp:(NSDate *)timeStamp
                        quantity:(NSNumber *)quantity
                       isPending:(Boolean)isPending {

    // use MagicalRecord/CoreData to create the entity but don't save it
    BGReading *bgReading = [BGReading MR_createEntity];
    bgReading.name = name;
    bgReading.timeStamp = timeStamp;
    bgReading.quantity = quantity;
    bgReading.isPending = [NSNumber numberWithBool:isPending];

    return bgReading;
}

+ (NSArray *)bgReadings135:(NSDate *)endDate {

    NSMutableArray *bgReadings = [NSMutableArray arrayWithArray:@[]];

    int numberOfReadings = 100;
    for (int i = 0; i < numberOfReadings; i++) {

        // use MagicalRecord/CoreData to create the entity but don't save it
        BGReading *bgReading = [BGReading MR_createEntity];
        bgReading.name = @"BloodGlucose";

        bgReading.timeStamp = [NSDate dateWithTimeInterval:-SECONDS_PER_DAY * i
                                                 sinceDate:endDate];

        bgReading.isPending = [NSNumber numberWithBool:NO];

        bgReading.quantity = @(135 / MG_PER_DL_PER_MMOL_PER_L);

        [bgReadings addObject:bgReading];
    }
    // use copy to return NSArray instead of NSMutableArray
    return [bgReadings copy];
}

@end
