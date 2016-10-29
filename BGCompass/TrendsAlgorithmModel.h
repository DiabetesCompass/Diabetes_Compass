//
//  Ha1cAlgorithmModel.h
//  CompassRose
//
//  Created by Christopher Balcells on 11/22/13.
//  Copywrite (c) 2014 Clif Alferness. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "BGReading.h"
#import "AG15Reading.h"
#import "Ha1cReading.h"

@interface TrendsAlgorithmModel : NSObject

@property (strong, nonatomic) NSArray* ha1cArray;
@property (strong, nonatomic) NSArray* ag15Array;
@property (strong, nonatomic) NSArray* bgArray;
@property (strong, nonatomic) dispatch_queue_t trend_queue;

+ (id) sharedInstance;

- (void) calculateHa1c:(BGReading*) reading;
- (void) calculateAg15:(BGReading*) reading;

- (NSNumber*) ha1cArrayCount;
- (NSNumber*) bgArrayCount;
- (NSNumber*) ag15ArrayCount;
- (Ha1cReading*) getFromHa1cArray:(NSUInteger)index;
- (BGReading*) getFromBGArray:(NSUInteger)index;
- (AG15Reading*) getFromAg15Array:(NSUInteger)index;

//Just for demo purpose. Should not be public usually. Delete after.
- (void) correctTrendReadingsAfterDate:(NSDate*) lowerBound;

@end
