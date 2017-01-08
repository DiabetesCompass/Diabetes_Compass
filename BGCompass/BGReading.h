//
//  BGReading.h
//  Compass
//
//  Created by macbookpro on 4/14/13.
//  Copyright (c) 2013 Clif Alferness. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Reading.h"


@interface BGReading : Reading

extern NSString *const stringForUnitsInMoles;
extern NSString *const stringForUnitsInMilligrams;

/** BGReading.quantity units are millimoles/liter, never milligram/deciliter.
 This keeps database and methods consistent.
 UI input and display can use either unit via Settings
 */
@property (nonatomic, retain) NSNumber * quantity;

+(NSString *) displayString:(NSNumber*) value withConversion:(BOOL)convert;
-(NSString *) displayString;

// TODO: Consider rename isInMoles to displayBGQuantityInMoles and move to Settings
/** Can be used to display BGReading.quantity in mmole/L or mg/dL.
 mmole/L is popular in EU.
 mg/dL is popular in US.
 */
+(BOOL) isInMoles;

//-(NSString *) itemValue;
-(void) setQuantity:(NSNumber *)quantity withConversion:(BOOL)action;
+ (float) getValue:(float)value withConversion: (BOOL) convert;

@end
