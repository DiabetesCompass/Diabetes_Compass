//
//  BGPredictAlgorithm.m
//  CompassRose
//
//  Created by Christopher Balcells on 11/18/13.
//  Copywrite (c) 2014 Clif Alferness. All rights reserved.
//

#import "BGAlgorithmModel.h"
#import "BGReading.h"
#import "FoodReading.h"
#import "InsulinReading.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "CurveModel.h"
#import "BackgroundTaskDelegate.h"

@interface BGAlgorithmModel()
@property (strong, nonatomic) NSManagedObjectContext* dataContext;
@property (strong, nonatomic) NSArray* graphArray;
@property (strong, nonatomic) NSArray* predictArray;
@property (strong, nonatomic) NSDate* lastCalculated;

@end

@implementation BGAlgorithmModel

+ (id)sharedInstance
{
    static BGAlgorithmModel *sharedInstance = nil;
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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotifications:) name:NOTE_ACCEPTED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotifications:) name:NOTE_REJECTED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotifications:) name:NOTE_SETTINGS_CHANGED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotifications:) name:NOTE_FOODREADING_ADDED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotifications:) name:NOTE_FOODREADING_EDITED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotifications:) name:NOTE_BGREADING_ADDED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotifications:) name:NOTE_BGREADING_EDITED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotifications:) name:NOTE_INSULINREADING_ADDED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotifications:) name:NOTE_INSULINREADING_EDITED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotifications:) name:NOTE_PENDINGREADING_DELETED object:nil];
    }
    return self;
}

- (void) handleNotifications:(NSNotification*) note
{
    NSLog(@"BGAlgorithmModel received a notification whose name was: %@", [note name]);
    if ([[note name] isEqualToString:NOTE_REJECTED]) {
        dispatch_async([[BackgroundTaskDelegate sharedInstance] getPredictQueue], ^{
            [self calculatePredictArray];
        });
    } else if ([[note name] isEqualToString:NOTE_ACCEPTED]) {
        dispatch_async([[BackgroundTaskDelegate sharedInstance] getPredictQueue], ^{
            
            [self calculateGraphArray];
            [self calculatePredictArray];
        });
    } else if ([[note name] isEqualToString:NOTE_SETTINGS_CHANGED]) {
        dispatch_async([[BackgroundTaskDelegate sharedInstance] getPredictQueue], ^{
            [self calculateGraphArray];
            [self calculatePredictArray];
        });
    } else if ([[note name] isEqualToString:NOTE_FOODREADING_ADDED]) {
        dispatch_async([[BackgroundTaskDelegate sharedInstance] getPredictQueue], ^{
            [self calculatePredictArray];
        });
    } else if ([[note name] isEqualToString:NOTE_FOODREADING_EDITED]) {
        dispatch_async([[BackgroundTaskDelegate sharedInstance] getPredictQueue], ^{
            [self calculateGraphArray];
            [self calculatePredictArray];
        });
    } else if ([[note name] isEqualToString:NOTE_BGREADING_ADDED]) {
        dispatch_async([[BackgroundTaskDelegate sharedInstance] getPredictQueue], ^{
            [self calculateGraphArray];
            [self calculatePredictArray];
        });
    } else if ([[note name] isEqualToString:NOTE_BGREADING_EDITED]) {
        dispatch_async([[BackgroundTaskDelegate sharedInstance] getPredictQueue], ^{
            [self calculateGraphArray];
            [self calculatePredictArray];
        });
    } else if ([[note name] isEqualToString:NOTE_INSULINREADING_ADDED]) {
        dispatch_async([[BackgroundTaskDelegate sharedInstance] getPredictQueue], ^{
            [self calculatePredictArray];
        });
    } else if ([[note name] isEqualToString:NOTE_INSULINREADING_EDITED]) {
        dispatch_async([[BackgroundTaskDelegate sharedInstance] getPredictQueue], ^{
            [self calculateGraphArray];
            [self calculatePredictArray];
        });
    } else if ([[note name] isEqualToString:NOTE_PENDINGREADING_DELETED]) {
        dispatch_async([[BackgroundTaskDelegate sharedInstance] getPredictQueue], ^{
            [self calculatePredictArray];
        });
    }
}

+ (NSManagedObjectContext *)dataContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (NSNumber*) graphArrayCount
{
    NSNumber* result;
    if (self.graphArray) {
        result = @([self.graphArray count]);
    } else {
        result = @(0);
    }
    return result;
}

- (NSNumber*) predictArrayCount
{
    NSNumber* result;
    if (self.predictArray) {
        result = @([self.predictArray count]);
    } else {
        result = @(0);
    }
    
    return result;
}

- (NSNumber*) getFromGraphArray:(NSUInteger)index
{
    NSNumber* result;
    if (self.graphArray) {
        result = [self.graphArray objectAtIndex:index];
    } else {
        result = @(0);
    }
    return result;
}

- (NSNumber*) getFromPredictArray:(NSUInteger)index
{
    NSNumber* result;
    if (self.predictArray) {
        result = [self.predictArray objectAtIndex:index];
    } else {
        result = @(0);
    }
    return result;
}

- (void) calculatePredictArray
{
    NSArray *foodReadings = [FoodReading MR_findByAttribute:@"isPending" withValue:[NSNumber numberWithBool:YES] andOrderBy:@"timeStamp" ascending:NO inContext:[NSManagedObjectContext MR_defaultContext]];
    NSArray *insulinReadings = [InsulinReading MR_findByAttribute:@"isPending" withValue:[NSNumber numberWithBool:YES] andOrderBy:@"timeStamp" ascending:NO inContext:[NSManagedObjectContext MR_defaultContext]];
    
    if ([foodReadings count] == 0 && [insulinReadings count] == 0) {
        //NSLog(@"No readings are predicting.");
        self.predictArray = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_PREDICT_RECALCULATED object:self];
        return;
    }
    
    int arraysize = [[CurveModel sharedInstance] getInsulinDuration] + PREDICT_MINUTES + [[CurveModel sharedInstance] getInsulinDuration];
    float temp_predictArray[arraysize];
    memset(temp_predictArray, 0, sizeof(temp_predictArray[0]) * arraysize);
    
    NSDate *zeroPoint = [NSDate dateWithTimeIntervalSinceNow:-1*[[CurveModel sharedInstance] getInsulinDuration]*SECONDS_IN_ONE_MINUTE];
    
    float carbEffect[FOOD_CURVE_LENGTH_MINUTES];
    float insulinEffect[[[CurveModel sharedInstance] getInsulinDuration]];
    
    for (FoodReading *foodReading in foodReadings) {
        memset(carbEffect, 0, sizeof(carbEffect[0]) * FOOD_CURVE_LENGTH_MINUTES);
        [[CurveModel sharedInstance] effectFromFoodReading:foodReading toArray:carbEffect];
        int zero = ([foodReading.timeStamp timeIntervalSinceDate:zeroPoint] / SECONDS_IN_ONE_MINUTE);
        int index;
        for (index = 1; index < FOOD_CURVE_LENGTH_MINUTES && (zero+index) < arraysize; index++) {
            temp_predictArray[zero + index] += carbEffect[index];
        }
        for (int j = 0; zero+index+j < arraysize; j++) {
            temp_predictArray[zero + index + j] += carbEffect[index - 1];
        }
    }
    
    for (InsulinReading* insulinReading in insulinReadings) {        
        memset(insulinEffect, 0, sizeof(insulinEffect[0]) * [[CurveModel sharedInstance] getInsulinDuration]);
        [[CurveModel sharedInstance] effectFromInsulinReading:insulinReading toArray:insulinEffect];
        int zero = ([insulinReading.timeStamp timeIntervalSinceDate:zeroPoint] / SECONDS_IN_ONE_MINUTE);
        int index;
        for (index = 1; index < [[CurveModel sharedInstance] getInsulinDuration] && (zero+index) < arraysize; index++) {
            temp_predictArray[zero + index] -= insulinEffect[index];
        }
        for (int j = 0; zero+index+j < arraysize; j++) {
            temp_predictArray[zero + index + j] -= insulinEffect[index - 1];
        }
    }

    int nowIndex = [[CurveModel sharedInstance] getInsulinDuration];
    
    NSMutableArray* finalArray = [NSMutableArray new];
    NSNumber* newNumber;
    for (int index = 0; index < arraysize-nowIndex; index++) {
        NSNumber* current = (NSNumber*)self.graphArray[index];
        if (nowIndex+index < arraysize) {
            newNumber = [NSNumber numberWithFloat:temp_predictArray[nowIndex+index] + current.floatValue];
        } else {
            [finalArray addObject:[NSNumber numberWithFloat:temp_predictArray[arraysize-1] + current.floatValue]];
        }
        [finalArray addObject:newNumber];
    }
    self.predictArray = [NSArray arrayWithArray:finalArray];
    //NSLog(@"The predictArray is: %@", self.predictArray);
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_PREDICT_RECALCULATED object:self];
}

- (void) shiftGraphArray
{
    /*
     1 - Check the last BGReading from CoreData. Ensure that it exists, and is still current.
     2 - Copy over shifted array and set CoreData fetch bounds
     3 - Add effects from new food
     4 - Add effects from new insulin
     */
/*
 1 -- Retrieve the final estimatedBGReading from CoreData.
 */
    BGReading* lastReading = [BGReading MR_findFirstOrderedByAttribute:@"timeStamp" ascending:NO inContext:[NSManagedObjectContext MR_defaultContext]];
    
    NSNumber *minutesSinceLastReading;
    if (lastReading == nil) {
        //NSLog(@"No previous reading exists. Ending calc.");
        self.graphArray = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_GRAPH_SHIFTED object:self];
        return;
    } else {
        NSTimeInterval secondsSinceLastReading = [[NSDate date] timeIntervalSinceDate:lastReading.timeStamp];
        minutesSinceLastReading = [NSNumber numberWithFloat:secondsSinceLastReading / SECONDS_IN_ONE_MINUTE];
        if (minutesSinceLastReading.intValue > BG_EXPIRATION_MINUTES) {
            //NSLog(@"BG Reading is too old.");
            self.graphArray = nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_GRAPH_SHIFTED object:self];
            return;
        }
    }
    //NSLog(@"Minutes Since Last Reading = %d", minutesSinceLastReading.intValue);
    
/*
 2 -- Copy over shifted array and set CoreData fetch bounds.
 */
    int arraysize = PREDICT_MINUTES + [[CurveModel sharedInstance] getInsulinDuration];
    float estimatedBGArray[arraysize];
    
    //Calculate minutes since last calculated
    NSTimeInterval secondsSinceLastCalculation = [[NSDate date] timeIntervalSinceDate:self.lastCalculated];
    NSNumber* minutesSinceLastCalculation = [NSNumber numberWithInt:(int) (secondsSinceLastCalculation / SECONDS_IN_ONE_MINUTE + 0.5)];
    
    NSLog(@"Minutes Since Last Calculation = %f", minutesSinceLastCalculation.floatValue);

    // Copy over shifted old array, extend by final value
    for (int i = 0; i < arraysize; ++i) {
        if ([minutesSinceLastCalculation intValue] + i < [self.graphArray count]) {
            estimatedBGArray[i] = [[self.graphArray objectAtIndex:([minutesSinceLastCalculation intValue] + i)] floatValue];
        } else {
            estimatedBGArray[i] = [[self.graphArray lastObject] floatValue];
        }
    }
    
    // Only use readings since lastCalculated and until PREDICT_MINUTES into the future
    NSDate* upperBound = [NSDate dateWithTimeIntervalSinceNow:PREDICT_MINUTES*SECONDS_IN_ONE_MINUTE];
    NSDate* lowerBoundFood = [NSDate dateWithTimeIntervalSinceNow:(FOOD_CURVE_LENGTH_MINUTES - minutesSinceLastCalculation.intValue)*SECONDS_IN_ONE_MINUTE];
    NSDate* lowerBoundInsulin = [NSDate dateWithTimeIntervalSinceNow:([[CurveModel sharedInstance] getInsulinDuration] - minutesSinceLastCalculation.intValue)*SECONDS_IN_ONE_MINUTE];

/*
 3 -- Fetch food readings and calculate effects from carbs.
 */
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(timeStamp <= %@) AND (timeStamp >= %@)", upperBound, lowerBoundFood];
    
    NSArray *fetchedReadings = [FoodReading MR_findAllSortedBy:@"timeStamp" ascending:NO withPredicate:predicate inContext:[NSManagedObjectContext MR_defaultContext]];
    
    /* Factor their impact into the estimatedBGArray. */
    NSDate *zeroPoint = [NSDate dateWithTimeInterval:-1*[[CurveModel sharedInstance] getInsulinDuration]*SECONDS_IN_ONE_MINUTE sinceDate:lastReading.timeStamp];
    
    float carbEffect[FOOD_CURVE_LENGTH_MINUTES];
    
    for (FoodReading *foodReading in fetchedReadings) {
        
        memset(carbEffect, 0, sizeof(carbEffect[0]) * FOOD_CURVE_LENGTH_MINUTES); // zero out array between loops.
        //NSLog(@"%@", foodReading.carbs);
        [[CurveModel sharedInstance] effectFromFoodReading:foodReading toArray:carbEffect];
        int zero = ([foodReading.timeStamp timeIntervalSinceDate:zeroPoint] / SECONDS_IN_ONE_MINUTE);
        int index;
        for (index = 1; index < FOOD_CURVE_LENGTH_MINUTES && (zero+index) < arraysize; index++) {
            estimatedBGArray[zero + index] += carbEffect[index];
        }
        for (int j = 0; zero+index+j < arraysize; j++) {
            estimatedBGArray[zero + index + j] += carbEffect[index - 1];
        }
    }
    
/*
 4 -- Fetch Insulin Readings and calculate effects from insulin.
 */
    predicate = [NSPredicate predicateWithFormat:@"(timeStamp <= %@) AND (timeStamp >= %@)", upperBound, lowerBoundInsulin];
    
    fetchedReadings = [InsulinReading MR_findAllSortedBy:@"timeStamp" ascending:NO withPredicate:predicate inContext:[NSManagedObjectContext MR_defaultContext]];
    
    float insulinEffect[[[CurveModel sharedInstance] getInsulinDuration]];
    for (InsulinReading *insulinReading in fetchedReadings) {
        memset(insulinEffect, 0, sizeof(insulinEffect[0]) * [[CurveModel sharedInstance] getInsulinDuration]); // zero out array between loops.
        [[CurveModel sharedInstance] effectFromInsulinReading:insulinReading toArray:insulinEffect];
        int zero = ([insulinReading.timeStamp timeIntervalSinceDate:zeroPoint] / SECONDS_IN_ONE_MINUTE);
        //NSLog(@"Zero=%d",zero);
        int index;
        for (index = 1; index < [[CurveModel sharedInstance] getInsulinDuration] && (zero+index) < arraysize; index++) {
            estimatedBGArray[zero + index] -= insulinEffect[index];
        }
        for (int j = 0; zero+index+j < arraysize; j++) {
            estimatedBGArray[zero + index + j] -= insulinEffect[index - 1];
        }
    }

    // Record the current timestamp for future calculations.
    self.lastCalculated = [NSDate date];

    NSMutableArray *final_array = [[NSMutableArray alloc] initWithCapacity:arraysize];
    float value;
    for (int n = 0; n < arraysize; n++) {
        value = estimatedBGArray[n];
        [final_array addObject:@(value)];
    }
    self.graphArray = [NSArray arrayWithArray:final_array];
    //NSLog(@"graphArray is %@", self.graphArray);
    //NSLog(@"graphArray count is %lu", [[self graphArray] count]);
    //NSLog(@"Finished Shift");
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_GRAPH_SHIFTED object:self];
}


- (void) calculateGraphArray
{
    /*
     1 -- Retrieve the last BGReading from CoreData.
          If there is no BG reading in the last BG_EXPIRATION_TIME minutes, then do not estimate the array.
     2 -- Initialize array and bounds for CoreData fetches.
     3 -- Calculate effects from food
     4 -- Calculate effects from insulin
     5 -- Scale the array so it aligns with the lastBGReading
          Predict values for PREDICT_MINUTES + INSULIN_CURVE_LENGTH_MINUTES into the future.
          This implementation assumes that future additions to the array can only take place PREDICT_MINUTES into the future. */
    //NSLog(@"Calculation begins.");
    
/*
 1 -- Retrieve the last BGReading from CoreData.
 */
    BGReading* lastReading = [BGReading MR_findFirstOrderedByAttribute:@"timeStamp" ascending:NO inContext:[NSManagedObjectContext MR_defaultContext]];
    
    NSNumber *minutesSinceLastReading;
    if (lastReading == nil) {
        NSLog(@"No previous reading exists. Ending calc.");
        self.graphArray = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_GRAPH_RECALCULATED object:self];
        return;
    } else {
        NSTimeInterval secondsSinceLastReading = [[NSDate date] timeIntervalSinceDate:lastReading.timeStamp];
        minutesSinceLastReading = [NSNumber numberWithFloat:secondsSinceLastReading / SECONDS_IN_ONE_MINUTE];
        if (minutesSinceLastReading.intValue > BG_EXPIRATION_MINUTES) {
            NSLog(@"BG Reading is too old.");
            self.graphArray = nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_GRAPH_RECALCULATED object:self];
            return;
        }
    }
    //NSLog(@"Minutes Since Last Reading = %d", minutesSinceLastReading.intValue);

/*
 2 -- Initialize array and bounds for CoreData fetches
 */
    NSDate* upperBound = [NSDate dateWithTimeIntervalSinceNow:PREDICT_MINUTES*SECONDS_IN_ONE_MINUTE];
    NSDate* lowerBoundFood = [NSDate dateWithTimeIntervalSinceNow:-1*(FOOD_CURVE_LENGTH_MINUTES + minutesSinceLastReading.intValue)*SECONDS_IN_ONE_MINUTE];
    NSDate* lowerBoundInsulin = [NSDate dateWithTimeIntervalSinceNow:-1*([[CurveModel sharedInstance] getInsulinDuration] + minutesSinceLastReading.intValue)*SECONDS_IN_ONE_MINUTE];;

    // Calculating the arraysize here assumes that insulin effect is always longer than food.
    int arraysize = [[CurveModel sharedInstance] getInsulinDuration] + minutesSinceLastReading.intValue + (PREDICT_MINUTES + [[CurveModel sharedInstance] getInsulinDuration]);
    float estimatedBGArray[arraysize];
    memset(estimatedBGArray, 0, sizeof(estimatedBGArray[0]) * arraysize);

/*
 3 -- Fetch food readings and calculate effects from carbs.
 */
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(timeStamp <= %@) AND (timeStamp >= %@) AND (isPending == %@)", upperBound, lowerBoundFood, [NSNumber numberWithBool:NO]];

    NSArray *fetchedReadings = [FoodReading MR_findAllSortedBy:@"timeStamp" ascending:NO withPredicate:predicate inContext:[NSManagedObjectContext MR_defaultContext]];

    /* Factor their impact into the estimatedBGArray. */
    NSDate *zeroPoint = [NSDate dateWithTimeInterval:-1*[[CurveModel sharedInstance] getInsulinDuration]*SECONDS_IN_ONE_MINUTE sinceDate:lastReading.timeStamp];
    
    float carbEffect[FOOD_CURVE_LENGTH_MINUTES];
    
    for (FoodReading *foodReading in fetchedReadings) {
        memset(carbEffect, 0, sizeof(carbEffect[0]) * FOOD_CURVE_LENGTH_MINUTES); // zero out array between loops.
        //NSLog(@"%@", foodReading.carbs);
        [[CurveModel sharedInstance] effectFromFoodReading:foodReading toArray:carbEffect];
        int zero = ([foodReading.timeStamp timeIntervalSinceDate:zeroPoint] / SECONDS_IN_ONE_MINUTE);
        int index;
        for (index = 1; index < FOOD_CURVE_LENGTH_MINUTES && (zero+index) < arraysize; index++) {
            estimatedBGArray[zero + index] += carbEffect[index];
        }
        for (int j = 0; zero+index+j < arraysize; j++) {
            estimatedBGArray[zero + index + j] += carbEffect[index - 1];
        }
    }

/* 
 4 -- Fetch Insulin Readings and calculate effects from insulin.
 */
    predicate = [NSPredicate predicateWithFormat:@"(timeStamp <= %@) AND (timeStamp >= %@) AND (isPending == %@)", upperBound, lowerBoundInsulin, [NSNumber numberWithBool:NO]];
    
    fetchedReadings = [InsulinReading MR_findAllSortedBy:@"timeStamp" ascending:NO withPredicate:predicate inContext:[NSManagedObjectContext MR_defaultContext]];

    float insulinEffect[[[CurveModel sharedInstance] getInsulinDuration]];
    for (InsulinReading *insulinReading in fetchedReadings) {
        memset(insulinEffect, 0, sizeof(insulinEffect[0]) * [[CurveModel sharedInstance] getInsulinDuration]); // zero out array between loops.
        [[CurveModel sharedInstance] effectFromInsulinReading:insulinReading toArray:insulinEffect];
        int zero = ([insulinReading.timeStamp timeIntervalSinceDate:zeroPoint] / SECONDS_IN_ONE_MINUTE);
        int index;
        for (index = 1; index < [[CurveModel sharedInstance] getInsulinDuration] && (zero+index) < arraysize; index++) {
            estimatedBGArray[zero + index] -= insulinEffect[index];
        }
        for (int j = 0; zero+index+j < arraysize; j++) {
            estimatedBGArray[zero + index + j] -= insulinEffect[index - 1];
        }
    }

/*
 5 - Scale the array so that it aligns with the lastBGreading (only necessary if completely recalculating).
 */
    float scalefactor = lastReading.quantity.floatValue - estimatedBGArray[[[CurveModel sharedInstance] getInsulinDuration]];
    //NSLog(@"lastreading=%f", lastReading.quantity.floatValue);
    //NSLog(@"scalefactor=%f", scalefactor);
    // Only use from the current time forward.
    int nowIndex = (-1*[lastReading.timeStamp timeIntervalSinceNow]/SECONDS_IN_ONE_MINUTE) + [[CurveModel sharedInstance] getInsulinDuration];

   // NSLog(@"nowIndex = %d; arraysize = %d", nowIndex, arraysize);
    NSMutableArray *final_array = [[NSMutableArray alloc] initWithCapacity:arraysize-nowIndex];
    float value;
    float minimum = 30; //set the minimum graph value at 30 mg/dL
    float maximum = FLT_MIN;
    //clip the graph at the minimum value if less
    for (int n = nowIndex; n < arraysize; n++) {
        value = estimatedBGArray[n] + scalefactor;
        if (value < minimum) {
            minimum = value;
        }
        if (value > maximum) {
            maximum = value;
        }
        [final_array addObject:@(value)];
    }
    //self.maximum = @(maximum);
    //self.minimum = @(minimum);
    //NSLog(@"Maximum is %f, Minimum is %f", maximum, minimum);
    self.graphArray = [NSArray arrayWithArray:final_array];
   
    // Record the current timestamp for future calculations.
    self.lastCalculated = [NSDate date];
    
    //NSLog(@"graphArray is %@", self.graphArray);
    //NSLog(@"graphArray count is %lu", [[self graphArray] count]);
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_GRAPH_RECALCULATED object:self];
    //NSLog(@"Finished Calculation");
}
//find the current estimated BG.
- (NSNumber*) getCurrentBG
{
    float current_value = [[self.graphArray firstObject] floatValue];
    current_value = [BGReading getValue:current_value withConversion:YES];
    return @(current_value);
}

- (NSNumber*) getDeficit
{
    float ideal_max = [[NSUserDefaults standardUserDefaults] floatForKey:SETTING_IDEALBG_MAX];
    float ideal_min = [[NSUserDefaults standardUserDefaults] floatForKey:SETTING_IDEALBG_MIN];
    float ideal_midpoint = (ideal_max - ideal_min)/2 + ideal_min;
    
    float asymptote_value = [[self getSettlingBG] floatValue];

    float insulinSensitivity = [[NSUserDefaults standardUserDefaults] floatForKey:SETTING_INSULIN_SENSITIVITY];
    float carbSensitivity = [[NSUserDefaults standardUserDefaults] floatForKey:SETTING_CARB_SENSITIVITY];
    
// TODO: fix me This doesn't report correctly for very small deficits (less than whole numbers for carbs).
    if (asymptote_value < ideal_min) {
        return @((ideal_midpoint - asymptote_value)/carbSensitivity);
    } else if (asymptote_value > ideal_max) {
        return @((ideal_midpoint - asymptote_value)/insulinSensitivity);
    }
    return @(0);
}


- (NSNumber*) getPredictDeficit
{
    float ideal_max = [[NSUserDefaults standardUserDefaults] floatForKey:SETTING_IDEALBG_MAX];
    float ideal_min = [[NSUserDefaults standardUserDefaults] floatForKey:SETTING_IDEALBG_MIN];
    float ideal_midpoint = (ideal_max - ideal_min)/2 + ideal_min;
    
    float asymptote_value = [[self getPredictSettlingBG] floatValue];
    
    float insulinSensitivity = [[NSUserDefaults standardUserDefaults] floatForKey:SETTING_INSULIN_SENSITIVITY];
    float carbSensitivity = [[NSUserDefaults standardUserDefaults] floatForKey:SETTING_CARB_SENSITIVITY];
    
    if (asymptote_value < ideal_min) {
        return @((ideal_midpoint - asymptote_value)/carbSensitivity);
    } else if (asymptote_value > ideal_max) {
        return @((ideal_midpoint - asymptote_value)/insulinSensitivity);
    }
    return @(0);
}
//Find the settling BG.
- (NSNumber *) getSettlingBG
{
    float asymptote_value = [[self.graphArray lastObject] floatValue];
    asymptote_value = [BGReading getValue:asymptote_value withConversion:YES];
    if (asymptote_value < 30){
        asymptote_value = 30;
    }
    return @(asymptote_value);
}

- (NSNumber *) getPredictSettlingBG
{
    float asymptote_value = [[self.predictArray lastObject] floatValue];
    asymptote_value = [BGReading getValue:asymptote_value withConversion:YES];
    return @(asymptote_value);
}

@end
