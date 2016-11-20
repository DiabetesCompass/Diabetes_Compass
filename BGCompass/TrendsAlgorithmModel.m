//
//  TrendsAlgorithmModel.m
//  CompassRose
//
//  Created by Christopher Balcells on 11/22/13.
//  Copyright (c) 2014 Clif Alferness. All rights reserved.
//

#import "TrendsAlgorithmModel.h"
#import "Constants.h"

@interface TrendsAlgorithmModel()

@end

@implementation TrendsAlgorithmModel

+ (id)sharedInstance
{
    static TrendsAlgorithmModel *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.trend_queue = dispatch_queue_create("trend_queue", DISPATCH_QUEUE_SERIAL);
        [self addObservers];
        [self loadArrays];
    }
    return self;
}

- (void)dealloc {
    [self removeObservers];
}

#pragma mark - observer

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotifications:) name:NOTE_REJECTED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotifications:) name:NOTE_SETTINGS_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotifications:) name:NOTE_BGREADING_ADDED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotifications:) name:NOTE_BGREADING_EDITED object:nil];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTE_REJECTED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTE_SETTINGS_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTE_BGREADING_ADDED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTE_BGREADING_EDITED object:nil];
}

- (void) handleNotifications:(NSNotification*) note {
    NSLog(@"Received a notification whose name was: %@", [note name]);
    if ([[note name] isEqualToString:NOTE_BGREADING_ADDED]) {
        NSDate* new_timeStamp = [note.userInfo valueForKey:@"timeStamp"];
        /*NSLog(@"The new timeStamp value is:%@", new_timeStamp);
        BGReading* lastReading = [BGReading MR_findFirstOrderedByAttribute:@"timeStamp" ascending:NO inContext:[NSManagedObjectContext MR_defaultContext]];
        NSDate* last_timeStamp = lastReading.timeStamp;
        
        if ([last_timeStamp compare:new_timeStamp] == NSOrderedAscending) {
            dispatch_async(self.trend_queue, ^{
                NSError* error;
                [self calculateHa1c:nil error:&error];
                [self calculateAg15:nil error:&error];
                [self loadArrays];
            });
        } else {*/
        
        
        dispatch_async(self.trend_queue, ^{
            [self correctTrendReadingsAfterDate:new_timeStamp];
        });

        //}
    } else if ([[note name] isEqualToString:NOTE_BGREADING_EDITED]) {
        NSDate* timeStamp = [note.userInfo valueForKey:@"timeStamp"];
        dispatch_async(self.trend_queue, ^{
            [self correctTrendReadingsAfterDate:timeStamp];
                  // print("BG reading added");
        });
    }
}

- (void) loadArrays
{
    self.ha1cArray = [Ha1cReading MR_findAllSortedBy:@"timeStamp" ascending:YES inContext:[NSManagedObjectContext MR_defaultContext]];
    self.bgArray = [BGReading MR_findAllSortedBy:@"timeStamp" ascending:YES inContext:[NSManagedObjectContext MR_defaultContext]];
    self.ag15Array = [AG15Reading MR_findAllSortedBy:@"timeStamp" ascending:YES inContext:[NSManagedObjectContext MR_defaultContext]];
}
//count HA1c readings?
- (NSNumber*) ha1cArrayCount
{
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
- (NSNumber*) bgArrayCount
{
    NSNumber* result;
    if (self.bgArray) {
        result = @([self.bgArray count]);
    } else {
        result = @(0);
    }
    return result;
}
//count Ag15 readings?
- (NSNumber*) ag15ArrayCount
{
    NSNumber* result;
    if (self.ag15Array) {
        result = @([self.ag15Array count]);
    } else {
        result = @(0);
    }
    return result;
}
 //fetch previous HA1c readings?
- (Ha1cReading*) getFromHa1cArray:(NSUInteger)index
{
    Ha1cReading* result;
    if (self.ha1cArray) {
        result = [self.ha1cArray objectAtIndex:index];
    } else {
        result = nil;
    }
    return result;
}
//fetch previous BG readings?
- (BGReading*) getFromBGArray:(NSUInteger)index
{
    BGReading* result;
    if (self.bgArray && self.bgArray.count != 0) {
        result = [self.bgArray objectAtIndex:index];
    } else {
        result = nil;
    }
    return result;
}
//fetch previous 15AG readings?
- (AG15Reading*) getFromAg15Array:(NSUInteger)index
{
    AG15Reading* result;
    if (self.ag15Array) {
        result = [self.ag15Array objectAtIndex:index];
    } else {
        result = nil;
    }
    return result;
}

- (void) correctTrendReadingsAfterDate:(NSDate*) lowerBound
{
    /*  This method is intended to be called whenever a reading value is edited which necessitates the recalculation of trend calculations. However, since they may extend back very far back in the past, it is best to only recalculate what is necessary. */
    
    // TODO: Only really want to correct trend readings for 90 days after the lowerBound date.
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"timeStamp >= %@", lowerBound];
    NSArray *fetchedReadings = [BGReading MR_findAllSortedBy:@"timeStamp" ascending:YES withPredicate:predicate inContext:[NSManagedObjectContext MR_defaultContext]];
   
/*
 1 - Delete old readings.
 */
    NSArray *fetchedHa1c = [Ha1cReading MR_findAllWithPredicate:predicate inContext:[NSManagedObjectContext MR_defaultContext]];
    NSArray *fetched15ag = [AG15Reading MR_findAllWithPredicate:predicate inContext:[NSManagedObjectContext MR_defaultContext]];
    for (Ha1cReading* reading in fetchedHa1c) {
        [reading MR_deleteEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    }
    for (AG15Reading* reading in fetched15ag) {
        [reading MR_deleteEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    }
/*
 2 - Add new readings.
 */
    for (BGReading* reading in fetchedReadings) {
        NSLog(@"Correcting reading...timestamp=%@", reading.timeStamp);
  //      [self calculateHa1c:reading];
  //      [self calculateAg15:reading];
    }
}

- (void) calculateHa1c:(BGReading*) bgReading
{
/*
 1 -- Retreive all blood glucose readings from the past 90 days. Backwards from the BGReading of interest.
 */
    NSPredicate *predicate;
    BGReading* lastReading = bgReading;
    if (!lastReading) {
        lastReading = [BGReading MR_findFirstOrderedByAttribute:@"timeStamp" ascending:NO inContext:[NSManagedObjectContext MR_defaultContext]];
    }
   // NSLog(@"Is the last reading null? %d", lastReading == nil);
    NSDate* ninety_days_ago = [lastReading.timeStamp dateByAddingTimeInterval:-90*HOURS_IN_ONE_DAY*SECONDS_IN_ONE_HOUR];
    predicate = [NSPredicate predicateWithFormat:@"timeStamp >= %@", ninety_days_ago];
    NSArray *fetchedReadings = [BGReading MR_findAllSortedBy:@"timeStamp" ascending:YES withPredicate:predicate inContext:[NSManagedObjectContext MR_defaultContext]];
    
/*
 2 -- Interpolate all of these readings. Unless they are larger than a day apart. Then ignore.
 */
    int interval = 1; // interpolated array will be 1 minute intervals.
    
    int arraysize = (int) 90*HOURS_IN_ONE_DAY*MINUTES_IN_ONE_HOUR/interval + 1; // The array will contain 90 days of readings.
    float interpolated[arraysize];
    memset(interpolated, 0.0, sizeof(interpolated[0]) * arraysize);
    BOOL zeroed[arraysize];
    memset(zeroed, 1, sizeof(zeroed[0]) * arraysize);
    BGReading* previousReading = nil;
    
    int bigIndex = 0;
    
    for (BGReading* reading in fetchedReadings) {
        //NSLog(@"The current reading's timestamp:%@, quantity:%@", reading.timeStamp, reading.quantity);
        //NSLog(@"The previous reading's timestamp:%@, quantity:%@", previousReading.timeStamp, previousReading.quantity);
         if (previousReading) {
            int minutesBetweenReadings = (int)[reading.timeStamp timeIntervalSinceDate:previousReading.timeStamp]/(SECONDS_IN_ONE_MINUTE) + 0.5;
            minutesBetweenReadings = abs(minutesBetweenReadings);
            BOOL zero_out = 0;
            
            if (minutesBetweenReadings < interval) {
                continue; // If two readings are within an interval of each other ignore this one. Move to the next.
            }
            //if (minutesBetweenReadings > HOURS_IN_ONE_DAY*MINUTES_IN_ONE_HOUR) {
                //zero_out = YES;
            //}
            for (int index = 0; index < minutesBetweenReadings/interval; index++, bigIndex++) {
                if (!zero_out) {
                    zeroed[bigIndex] = 0;
                    // Final equation: y = y1 + (y2-y1)/(x2-x1)
                    interpolated[bigIndex] = previousReading.quantity.floatValue + (reading.quantity.floatValue - previousReading.quantity.floatValue)/(minutesBetweenReadings/interval)*index;
                    //NSLog(@"the value of the interpolation is: %f", interpolated[bigIndex]);
               }
            }
        }
        previousReading = reading;
    }

    /*
    for ( int i=0; i<arraysize; ++i ) {
        NSLog(@"The interpolated array looks like: %f", interpolated[i]);
        NSLog(@"The zeroed out array looks like:%d", zeroed[i]);
    }*/
    
/*
 3 -- Calculate the decay array.
 */
    double decay;
    double sum_product = 0.0;
    double sum_decay = 0.0;
    for (int index = 0; index < arraysize; index++) {
        if (!zeroed[index]) {
            //decay = powf(2.71828182845904523536, (index - arraysize)/2994);
            //decay = expf((index - arraysize)/62324.4258);
            decay = exp((index - arraysize)/62324.4258);
            sum_decay += decay;
            sum_product += decay*interpolated[index];
        }
    }

/*
 4 -- Add final result to CoreData.
 */
    
    double weightedBGave = ((sum_product/sum_decay));
    //print(@"Ha1c value is:");
    double result = ((weightedBGave)*5)/100;
    //double result = ((sum_product/sum_decay)*5)/100;
//log the result
    NSLog(@"the time weighted average BG is: %f", weightedBGave);
    NSLog(@"The final ha1c is: %f", result);
    Ha1cReading* reading = [Ha1cReading MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    reading.quantity = @(result);
    //set the timestamp of this HA1c to the timestamp of the last BG reading?
    reading.timeStamp = lastReading.timeStamp;
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    [self loadArrays];
}

- (void) calculateAg15:(BGReading*) bgReading
{
/*
 1 -- Retreive all blood glucose readings from the past 90 days. Backwards from lastReading.
 */
    BGReading* lastReading = [BGReading MR_findFirstOrderedByAttribute:@"timeStamp" ascending:NO inContext:[NSManagedObjectContext MR_defaultContext]];
    
    NSDate* thirty_days_ago = [lastReading.timeStamp dateByAddingTimeInterval:-30*HOURS_IN_ONE_DAY*SECONDS_IN_ONE_HOUR];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"timeStamp >= %@", thirty_days_ago];
    NSArray *fetchedReadings = [BGReading MR_findAllSortedBy:@"timeStamp" ascending:YES withPredicate:predicate inContext:[NSManagedObjectContext MR_defaultContext]];

/*
 2 -- Interpolate all of these readings. Unless they are larger than a day apart. Then ignore.
 */
    int arraysize = (int) 90*HOURS_IN_ONE_DAY*MINUTES_IN_ONE_HOUR/1 + 1;
    float interpolated[arraysize];
    BOOL zeroed[arraysize];
    lastReading = nil;
    for (BGReading* reading in fetchedReadings) {
        if (lastReading) {
            int minutesBetweenReadings = (int)[reading.timeStamp timeIntervalSinceDate:lastReading.timeStamp]/SECONDS_IN_ONE_MINUTE + 0.5;
            BOOL zero_out = NO;
            //if (minutesBetweenReadings > HOURS_IN_ONE_DAY*MINUTES_IN_ONE_HOUR) {
            //    zero_out = YES;
            //}
            for (int index = 0; index < minutesBetweenReadings/1; index ++) {
                if (zero_out) {
                    interpolated[index] = 0.0;
                    zeroed[index] = YES;
                } else {
                    // Final equation: y = y1 + (y2-y1)/(x2-x1)*index
                    interpolated[index] = lastReading.quantity.floatValue + (reading.quantity.floatValue - lastReading.quantity.floatValue)/ (reading.quantity.floatValue - lastReading.quantity.floatValue)*index;
                }
            }
        }
        lastReading = reading;
    }
/*
 3 - Calculate 1,5AG based on whether InterpolatedBGReadings crosses over the renal threshold.
 */
    float result = 21.0f; //Initial value for 1,5AG
    float renal_threshold;
    if ([BGReading isInMoles]) {
        renal_threshold = 180/CONVERSIONFACTOR;
    } else {
        renal_threshold = 180;
    }
    float k15ag = [[NSUserDefaults standardUserDefaults] floatForKey:@"15AGConstant"];
    
    for (int index = 0; index < arraysize; index++) {
        if (!zeroed[index]) {
            if (interpolated[index] <= renal_threshold) {
                result += 0.3/HOURS_IN_ONE_DAY*MINUTES_IN_ONE_HOUR;
            } else {
                result -= (interpolated[index] - renal_threshold) * k15ag/HOURS_IN_ONE_DAY*MINUTES_IN_ONE_HOUR;
            }
        }
    }
    
/*
 4 - Clip the calculated result to the range of: [0, 21]
 */
    if (result > 21) {
        result = 21;
    }
    if (result < 0) {
        result = 0;
    }

/*
 5 - Save the result to CoreData.
 */
    //NSLog(@"The final ag15 is: %f", result);
    AG15Reading* reading = [AG15Reading MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    reading.quantity = @(result);
    reading.timeStamp = lastReading.timeStamp;
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

@end
