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
            //FIXME: recalculate all ha1c instead
            [self computeHA1c:timeStamp];
            [self loadArrays];
        });
    } else if ([[note name] isEqualToString:NOTE_BGREADING_EDITED]) {
        NSDate* timeStamp = [note.userInfo valueForKey:@"timeStamp"];
        dispatch_async(self.trend_queue, ^{
            //FIXME: recalculate all ha1c instead
            [self computeHA1c:timeStamp];
            [self loadArrays];
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

- (void)computeHA1c:(NSDate*) timeStamp {
    NSArray *fetchedReadings = [TrendsAlgorithmModel
                                bgReadingsWithinHemoglobinLifeSpanBeforeEndDate: timeStamp];

    [self addHa1cReadingForBgReadings:fetchedReadings
                              date:timeStamp
                     decayLifeSeconds:TrendsAlgorithmModel.hemoglobinLifespanSeconds];

    [self loadHa1cArray];
}

/** calculates time weighted average ha1c, creates an Ha1cReading and adds it to Core Data
 After calling this method, typically caller will call loadHa1cArray
 = parameter bgReadings: readings may be in any chronological order
 - parameter date: date for the ha1cReading. bgReadings with timeStamp after date are ignored.
 */
- (void)addHa1cReadingForBgReadings:(NSArray *)bgReadings
                               date:(NSDate *)date
                   decayLifeSeconds:(NSTimeInterval)decayLifeSeconds {

    // call method defined in TrendsAlgorithmModel.swift from Objective C
    float ha1cTimeWeightedAverage = [TrendsAlgorithmModel ha1cValueForBgReadings:bgReadings
                                                                         endDate:date
                                                                decayLifeSeconds:TrendsAlgorithmModel.hemoglobinLifespanSeconds];

    NSLog(@"weighted average HA1c: %f", ha1cTimeWeightedAverage);

    // save to Core Data
    Ha1cReading* reading = [Ha1cReading MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    reading.quantity = @(ha1cTimeWeightedAverage);
    reading.timeStamp = date;
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

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

    NSDate *startDate = [(BGReading *)bgReadingsChronologicallyIncreasing[0] timeStamp];
    NSDate *bgLastDate = [(BGReading *)[bgReadingsChronologicallyIncreasing lastObject] timeStamp];
    NSDate *endDate = [bgLastDate dateByAddingTimeInterval:timeIntervalSeconds];

    // divide date range into time intervals and add an ha1cReading at every interval
    NSDate *date = startDate;
    while ([date compare:endDate] == NSOrderedAscending) {
        // date is on or before endDate

        [self addHa1cReadingForBgReadings:bgReadingsChronologicallyIncreasing
                                     date:date
                         decayLifeSeconds:TrendsAlgorithmModel.hemoglobinLifespanSeconds];

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
