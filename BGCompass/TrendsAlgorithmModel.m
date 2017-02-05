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

- (void)handleNotifications:(NSNotification*) notification {
    NSLog(@"Received notification name: %@", [notification name]);
    if ([[notification name] isEqualToString:NOTE_BGREADING_ADDED]
        || [[notification name] isEqualToString:NOTE_BGREADING_EDITED]) {

        //NSDate* timeStamp = [notification.userInfo valueForKey:@"timeStamp"];
        
        dispatch_async(self.trend_queue, ^{


            //[self computeHA1c:timeStamp];
            // TODO: Check this works correctly.
            // Recalculate all ha1c instead of just one.
            // This was crashing with error array index out of bounds.
            // may have been fixed in git commit b314d
            // I think one or more view controllers such as GraphViewController are observing changes to any Reading.
             [self populateHa1cReadingsFromBgReadings:self.bgArray
                                     decayLifeSeconds:TrendsAlgorithmModel.hemoglobinLifespanSeconds
                                  timeIntervalSeconds:HOURS_IN_ONE_DAY * SECONDS_IN_ONE_HOUR];

            [self loadArrays];
        });
    }
}

- (void) loadArrays {
    [self loadBgArray];
    [self loadHa1cArray];
}

- (void) loadBgArray {
    self.bgArray = [BGReading MR_findAllSortedBy:@"timeStamp" ascending:YES inContext:[NSManagedObjectContext MR_defaultContext]];
}

- (void) loadHa1cArray {
    self.ha1cArray = [Ha1cReading MR_findAllSortedBy:@"timeStamp" ascending:YES inContext:[NSManagedObjectContext MR_defaultContext]];
}

/**
 - returns: bgArray count.
 returns 0 if bgArray is nil.
*/
- (NSNumber*) bgArrayCount {
    NSNumber* result;
    if (self.bgArray) {
        result = @([self.bgArray count]);
    } else {
        result = @(0);
    }
    return result;
}

/**
 - returns: ha1cArray count.
 returns 0 if ha1cArray is nil.
*/
- (NSNumber*) ha1cArrayCount {
    NSNumber* result;
    if (self.ha1cArray) {
        result = @([self.ha1cArray count]);
    } else {
        result = @(0);
    }
    return result;
}

/** - returns: BGArray object at index
 returns nil if self.bgArray is nil or empty
 */
- (BGReading *)getFromBGArray:(NSUInteger)index {
    BGReading* result;
    if ([self.bgArrayCount isEqual: @0]) {
        result = nil;
    } else {
        result = [self.bgArray objectAtIndex:index];
    }
    return result;
}

/** - returns: HA1cArray object at index
 returns nil if self.ha1cArray is nil or empty
 */
- (Ha1cReading *)getFromHa1cArray:(NSUInteger)index {
    Ha1cReading* result;
    if ([self.ha1cArrayCount isEqual: @0]) {
        result = nil;
    } else {
        result = [self.ha1cArray objectAtIndex:index];
    }
    return result;
}

// MARK: - get BGReadings

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

// MARK: -

- (void)deleteAllHa1cReadings {

    [self loadHa1cArray];
    NSLog(@"deleteAllHa1cReadings ha1cArray.count %lu", (unsigned long)self.ha1cArray.count);


    // Magical Record doesn't directly support batch delete?
    // https://github.com/magicalpanda/MagicalRecord/issues/1246

    // this didn't work, not sure why
    // http://stackoverflow.com/questions/22313929/how-to-delete-every-core-data-entity-without-faulting-errorsj
    //[Ha1cReading MR_truncateAll];
    //[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];

    for (Ha1cReading *ha1cReading in self.ha1cArray) {
        [ha1cReading MR_deleteEntity];
        // [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {}];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    }
    
    [self loadHa1cArray];
    NSLog(@"ha1cArray.count %lu", (unsigned long)self.ha1cArray.count);
}

// MARK: -

/**
   Fetches BGReadings, adds one Ha1cReading and loads ha1cArray
 - parameter timeStamp: used to fetch all BGReadings within hemoglobin lifespan before timeStamp
 */
- (void)computeHA1c:(NSDate*) timeStamp {
    NSArray *fetchedReadings = [TrendsAlgorithmModel
                                bgReadingsWithinHemoglobinLifeSpanBeforeEndDate: timeStamp];

    [self addHa1cReadingForBgReadings:fetchedReadings
                              date:timeStamp
                     decayLifeSeconds:TrendsAlgorithmModel.hemoglobinLifespanSeconds];

    [self loadHa1cArray];
}

//TODO: check if this method works!
//TODO: check method doesn't crash if other code inserts a ha1c reading while this method is running
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

    NSDate *bgDateEarliest = [(BGReading *)bgReadingsChronologicallyIncreasing[0] timeStamp];
    NSDate *bgDateLatest = [(BGReading *)[bgReadingsChronologicallyIncreasing lastObject] timeStamp];
    // bgReadings only affect ha1cReadings until dateAllBgDecayed
    NSDate *dateAllBgDecayed = [bgDateLatest dateByAddingTimeInterval: decayLifeSeconds];

    // divide date range into time intervals and add an ha1cReading at every interval
    NSDate *date = bgDateEarliest;
    while ([date compare: dateAllBgDecayed] == NSOrderedAscending) {
        // date is on or before dateAllBgDecayed

        [self addHa1cReadingForBgReadings:bgReadingsChronologicallyIncreasing
                                     date:date
                         decayLifeSeconds:decayLifeSeconds];

        // increment while loop control
        date = [date dateByAddingTimeInterval:timeIntervalSeconds];
    }
    
    [self loadHa1cArray];
}

/** Calculates time weighted average ha1c, creates an Ha1cReading and adds it to Core Data
 After calling this method, typically caller will call loadHa1cArray
 = parameter bgReadings: readings may be in any chronological order
 - parameter date: date for the ha1cReading. bgReadings with timeStamp after date are ignored.
 */
- (void)addHa1cReadingForBgReadings:(NSArray *)bgReadings
                               date:(NSDate *)date
                   decayLifeSeconds:(NSTimeInterval)decayLifeSeconds {

    // call method defined in TrendsAlgorithmModel.swift from Objective C
    float ha1cTimeWeightedAverage = [TrendsAlgorithmModel ha1cValueForBgReadings:bgReadings
                                                                            date:date
                                                                decayLifeSeconds:decayLifeSeconds];

    NSLog(@"adding HA1c %@: qty: %f", date, ha1cTimeWeightedAverage);

    // save to Core Data
    Ha1cReading* reading = [Ha1cReading MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    reading.quantity = @(ha1cTimeWeightedAverage);
    reading.timeStamp = date;
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

@end
