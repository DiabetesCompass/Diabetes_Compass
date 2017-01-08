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

/** BGReading.quantity units are millimole/liter, never milligram/deciliter.
 This keeps database and methods consistent.
 UI input and display can use either unit via Settings
 */
@property (nonatomic, retain) NSNumber * quantity;

+(NSString *) displayString:(NSNumber*) value withConversion:(BOOL)convert;
-(NSString *) displayString;

// TODO: Consider move to Settings
/** Can be used to display BGReading.quantity in mmol/L or mg/dL.
 millimole/liter is popular in EU.
 milligram/deciliter is popular in US.
 */
+(BOOL) shouldDisplayBgInMmolPerL;

-(void) setQuantity:(NSNumber *)quantity withConversion:(BOOL)action;
+ (float) getValue:(float)value withConversion: (BOOL) convert;

@end
