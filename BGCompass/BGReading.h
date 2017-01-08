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

// FIXME: Explicitly state quantity units and use them consistently
@property (nonatomic, retain) NSNumber * quantity;

+(NSString *) displayString:(NSNumber*) value withConversion:(BOOL)convert;
-(NSString *) displayString;
+(BOOL) isInMoles;

//-(NSString *) itemValue;
-(void) setQuantity:(NSNumber *)quantity withConversion:(BOOL)action;
+ (float) getValue:(float)value withConversion: (BOOL) convert;

@end
