//
//  Utilities.h
//  Compass
//
//  Created by Jose Carrillo on 12/1/13.
//  Copyright (c) 2014 Clif Alferness. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reading.h"


@interface Utilities : NSObject

+ (NSString*) createFormattedStringFromNumber:(NSNumber*)number withNumberOfDecimalPlaces:(NSUInteger)decimal;

+ (NSString*) createFormattedStringFromNumber:(NSNumber *)number forReadingType:(Class)type;

+ (NSString*) getUnitsForBG;

+ (NSNumber*) roundNumber:(NSNumber*) number withNumberOfDecimalPlaces:(NSUInteger) places;
+ (float) roundFloat:(float) number withNumberOfDecimalPlaces:(NSUInteger) places;


@end
