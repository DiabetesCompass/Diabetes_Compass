//
//  BGReadingTestHelper.h
//  BGCompass
//
//  Created by Steve Baker on 1/6/17.
//  Copyright © 2017 Clif Alferness. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "BGReading.h"

/** This class returns BGReading for use by Swift unit tests.
 Using it because currently don't know how to use MagicalRecord from Swift
 */
@interface BGReadingTestHelper : NSObject

/// - returns: an array of BGReading, all with quantity 135
+ (NSArray *)bgReadings135:(NSDate *)endDate;

+ (NSArray *)bgReadingsAlternating135and170:(NSDate *)endDate;

+ (NSArray *)bgReadings150then50:(NSDate *)endDate;

@end
