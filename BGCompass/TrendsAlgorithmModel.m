//
//  TrendsAlgorithmModel.m
//  CompassRose
//
//  Created by Christopher Balcells on 11/22/13.
//  Copyright (c) 2014 Clif Alferness. All rights reserved.
//

#import "TrendsAlgorithmModel.h"
#import "Constants.h"

// import <project name>-Swift.h so Objective C can see Swift code
// note don't import <class name>-Swift.h, that won't work
// http://stackoverflow.com/questions/24078043/call-swift-function-from-objective-c-class#24087280
#import "BGCompass-Swift.h"

@interface TrendsAlgorithmModel()

@end

@implementation TrendsAlgorithmModel

+ (id)sharedInstance {
    static TrendsAlgorithmModel *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        self.trend_queue = dispatch_queue_create("trend_queue", DISPATCH_QUEUE_SERIAL);
        [self addObservers];
        [self loadArrays];
    }
    return self;
}

// - observer

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotifications:) name:NOTE_REJECTED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotifications:) name:NOTE_SETTINGS_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotifications:) name:NOTE_BGREADING_ADDED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotifications:) name:NOTE_BGREADING_EDITED object:nil];
}

- (void) handleNotifications:(NSNotification*) note {
    NSLog(@"Received notification name: %@", [note name]);
    if ([[note name] isEqualToString:NOTE_BGREADING_ADDED]) {
        NSDate* timeStamp = [note.userInfo valueForKey:@"timeStamp"];
        dispatch_async(self.trend_queue, ^{
            [self computeHA1c:timeStamp];
        });
    } else if ([[note name] isEqualToString:NOTE_BGREADING_EDITED]) {
        NSDate* timeStamp = [note.userInfo valueForKey:@"timeStamp"];
        dispatch_async(self.trend_queue, ^{
            [self computeHA1c:timeStamp];
        });
    }
}

- (void) loadArrays {
    [self loadHa1cArray];
    [self loadBgArray];
}

- (void) loadBgArray {
    self.bgArray = [BGReading MR_findAllSortedBy:@"timeStamp" ascending:YES inContext:[NSManagedObjectContext MR_defaultContext]];
}

- (void) loadHa1cArray {
    self.ha1cArray = [Ha1cReading MR_findAllSortedBy:@"timeStamp" ascending:YES inContext:[NSManagedObjectContext MR_defaultContext]];
}

//count HA1c readings?
- (NSNumber*) ha1cArrayCount {
    NSNumber* result;
    if (self.ha1cArray) {
        result = @([self.ha1cArray count]);
        NSLog(@"There are HA1c readings:%@", result);
    } else {
        result = @(0);
    }
    
    return result;
}

//count BG readings?
- (NSNumber*) bgArrayCount {
    NSNumber* result;
    if (self.bgArray) {
        result = @([self.bgArray count]);
    } else {
        result = @(0);
    }
    return result;
}

/// - returns: HA1cArray object at index
- (Ha1cReading *)getFromHa1cArray:(NSUInteger)index {
    Ha1cReading* result;
    if (self.ha1cArray) {
        result = [self.ha1cArray objectAtIndex:index];
    } else {
        result = nil;
    }
    return result;
}

/// - returns: BGArray object at index
- (BGReading *)getFromBGArray:(NSUInteger)index {
    BGReading* result;
    if (self.bgArray && self.bgArray.count != 0) {
        result = [self.bgArray objectAtIndex:index];
    } else {
        result = nil;
    }
    return result;
}

- (void) computeHA1c:(NSDate*) timeStamp {

    // TODO: check if sort order is correct for use in enumeration
    NSArray *fetchedReadings = [TrendsAlgorithmModel
                                bgReadingsWithinHemoglobinLifeSpanBeforeEndDate: timeStamp];

    float twHA1c = [TrendsAlgorithmModel ha1cValueForBgReadings:fetchedReadings
                                                        endDate:timeStamp
                                               decayLifeSeconds:TrendsAlgorithmModel.hemoglobinLifespanSeconds];
    // log & add result to CoreData
    NSLog(@"computeHA1c weighted average HA1c: %f", twHA1c);

    Ha1cReading* reading = [Ha1cReading MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    reading.quantity = @(twHA1c);
    reading.timeStamp = timeStamp;
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];

    [self loadArrays];
}

/*
- (void) computeHA1c:(NSDate*) timeStamp {

    // TODO: check if sort order is correct for use in enumeration
    NSArray *fetchedReadings = [TrendsAlgorithmModel
                                bgReadingsWithinHemoglobinLifeSpanBeforeEndDate: timeStamp];

    BGReading* lastReading = fetchedReadings.firstObject;

    u_long count = fetchedReadings.count;
    NSLog(@"# of readings: %lu", (unsigned long)count);

    int intervalSeconds = SECONDS_IN_ONE_MINUTE;
    BGReading* previousReading = nil;
    int bigIndex = 0;
    float ramp = 1.0;
    float delta = 1/TrendsAlgorithmModel.hemoglobinLifespanSeconds;
    float sum =0.0;
    float sumRamp = 0.0;
    float twBGAve = 0.0;
    float twHA1c = 0.0;

    for (BGReading* reading in fetchedReadings) {
        NSLog(@"calculating for BG: %f", MG_PER_DL_PER_MMOL_PER_L*reading.quantity.floatValue);
        if (bigIndex == 0){
            sum = reading.quantity.floatValue;
            previousReading = reading;
            twBGAve = sum/ramp;
            sumRamp = sumRamp + ramp;
            ramp = ramp - delta;
            //            NSLog(@"sum: %f", sum);
            bigIndex++; }
        else {
            float interpolatedValue = 0;
            NSTimeInterval secondsBetweenReadings = [reading.timeStamp
                                                     timeIntervalSinceDate:previousReading.timeStamp];
            secondsBetweenReadings = fabs(secondsBetweenReadings);
            for (int index = 0; index < (int)secondsBetweenReadings/intervalSeconds; index++ ) {
                interpolatedValue = previousReading.quantity.floatValue + ((1+index)*(reading.quantity.floatValue - previousReading.quantity.floatValue)/(secondsBetweenReadings/intervalSeconds));
                sum = sum + interpolatedValue*ramp;
                sumRamp = sumRamp + ramp;
                twBGAve = sum/sumRamp;
                //NSLog(@"weighted average BG: %f", MG_PER_DL_PER_MMOL_PER_L*twBGAve);
                //twHA1c = (46.7 + MG_PER_DL_PER_MMOL_PER_L*twBGAve)/28.7;
                //NSLog(@"weighted average HA1c: %f", twHA1c);
                ramp = ramp - delta;
                bigIndex++;
            }
        }
    }

    float twBgMgPerDl = MG_PER_DL_PER_MMOL_PER_L * twBGAve;
    twHA1c = [TrendsAlgorithmModel hA1cFromBloodGlucose: twBgMgPerDl];
    //log &Add final result to CoreData
    NSLog(@"weighted average HA1c: %f", twHA1c);
    Ha1cReading* reading = [Ha1cReading MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    reading.quantity = @(twHA1c);
    //set the timestamp of this HA1c to the timestamp of the last BG reading?
    reading.timeStamp = lastReading.timeStamp;
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    [self loadArrays];
}
 */

/**
 - returns: blood glucose readings between (endDate - hemoglobin lifespan) and endDate
 */
+ (NSArray *)bgReadingsWithinHemoglobinLifeSpanBeforeEndDate:(NSDate *)endDate {

    // startDate is hemoglobin lifespan before endDate
    NSDate* startDate = [endDate
                         dateByAddingTimeInterval: -TrendsAlgorithmModel.hemoglobinLifespanSeconds];

    NSArray *readings = [TrendsAlgorithmModel bloodGlucoseReadingsForStartDate:startDate
                                                                       endDate:endDate];
    return readings;
}

/**
 - returns: blood glucose readings between startDate (inclusive) and endDate (inclusive)
 */
+ (NSArray *)bloodGlucoseReadingsForStartDate:(NSDate *)startDate
                                      endDate:(NSDate *)endDate {

    NSPredicate *startDatePredicate = [NSPredicate predicateWithFormat:@"timeStamp >= %@",
                                       startDate];
    NSPredicate *endDatePredicate = [NSPredicate predicateWithFormat:@"timeStamp <= %@",
                                     endDate];
    // andPredicate specifies logical &&
    NSPredicate *compoundPredicate = [NSCompoundPredicate
                                      andPredicateWithSubpredicates:@[startDatePredicate, endDatePredicate]];

    NSArray *readings = [BGReading MR_findAllSortedBy:@"timeStamp"
                                            ascending:NO
                                        withPredicate:compoundPredicate
                                            inContext:[NSManagedObjectContext MR_defaultContext]];
    return readings;
}



//TODO: check if this method works!
/**
 Clears and populates ha1cReadings based on averages of decayed BG reading.quantity
 First ha1cReading timeStamp is chronologically first bgReading timeStamp.
 End date is chronologically last bgReading timeStamp plus decayLifeSeconds.
 Last ha1cReading timeStamp will be approximately equal to end date.
 The readings are managed objects, stored in CoreData.

 - parameter bgReadings: blood glucose readings to average. quantity units mmol/L
 readings may appear in any chronological order,
 the method sorts them chronologically and reads their timeStamp

 - parameter decayLifeSeconds: time for blood glucose from a reading to decay to 0.0.
 Typically hemoglobin lifespan seconds.

 - parameter timeIntervalSeconds: number of seconds between calculated readings
 Typically >= 600
 */
- (void)populateHa1cReadingsFromBgReadings:(NSArray*)bgReadings
                          decayLifeSeconds:(NSTimeInterval)decayLifeSeconds
                       timeIntervalSeconds:(NSTimeInterval)timeIntervalSeconds {

    // if inputs aren't valid, return
    if ( (bgReadings.count == 0)
        || (decayLifeSeconds < 0.0)
        || (timeIntervalSeconds <= 0.0) ) {
        return;
    }

    [self deleteAllHa1cReadings];

    // http://stackoverflow.com/questions/805547/how-to-sort-an-nsmutablearray-with-custom-objects-in-it?noredirect=1&lq=1j
    NSArray *bgReadingsChronologicallyIncreasing = [bgReadings
                                                    sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                                                        NSDate *first = [(BGReading*)a timeStamp];
                                                        NSDate *second = [(BGReading*)b timeStamp];
                                                        return [first compare:second];
                                                    }];

    NSDate *startDate = [(BGReading *)bgReadingsChronologicallyIncreasing[0] timeStamp];
    NSDate *bgLastDate = [(BGReading *)[bgReadingsChronologicallyIncreasing lastObject] timeStamp];
    NSDate *endDate = [bgLastDate dateByAddingTimeInterval:timeIntervalSeconds];

    // divide date range into time intervals and add an ha1cReading at every interval
    NSDate *date = startDate;
    while ([date compare:endDate] == NSOrderedAscending) {
        // date is on or before endDate

        // call method defined in TrendsAlgorithmModel.swift from Objective C
        double ha1cValue = [TrendsAlgorithmModel
                            ha1cValueForBgReadings:bgReadingsChronologicallyIncreasing
                            endDate: date
                            decayLifeSeconds: decayLifeSeconds];

        Ha1cReading* reading = [Ha1cReading MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
        reading.quantity = @(ha1cValue);
        reading.timeStamp = date;
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];

        // increment while loop control
        date = [date dateByAddingTimeInterval:timeIntervalSeconds];
    }
    
    [self loadHa1cArray];
}

- (void)deleteAllHa1cReadings {
    // http://stackoverflow.com/questions/22313929/how-to-delete-every-core-data-entity-without-faulting-errorsj
    [Ha1cReading MR_truncateAll];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    [self loadHa1cArray];
}

@end
