//
//  TrendsAlgorithmModel.h
//  CompassRose
//
//  Created by Christopher Balcells on 11/22/13.
//  Copyright (c) 2014 Clif Alferness. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "BGReading.h"
//#import "AG15Reading.h"
#import "Ha1cReading.h"

@interface TrendsAlgorithmModel : NSObject

@property (strong, nonatomic) NSArray* ha1cArray;
//@property (strong, nonatomic) NSArray* ag15Array;
@property (strong, nonatomic) NSArray* bgArray;
@property (strong, nonatomic) dispatch_queue_t trend_queue;

+ (id) sharedInstance;

- (void) computeHA1c:(NSDate*) timeStamp;

- (NSNumber*) ha1cArrayCount;
- (NSNumber*) bgArrayCount;

- (Ha1cReading*) getFromHa1cArray:(NSUInteger)index;
- (BGReading*) getFromBGArray:(NSUInteger)index;

//Just for demo purpose. Should not be public usually. Delete after.
//- (void) correctTrendReadingsAfterDate:(NSDate*) lowerBound;

@end
