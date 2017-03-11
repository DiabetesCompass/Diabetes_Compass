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

/** This is a convenience method for use by Swift.
    Currently don't know how to use MagicalRecord from Swift.
 - returns: a BGReading, not saved in CoreData
 */
+ (BGReading *)bgReadingWithName:(NSString *)name
                       timeStamp:(NSDate *)timeStamp
                        quantity:(NSNumber *)quantity
                       isPending:(Boolean)isPending;

/** This is a convenience method for use by Swift unit tests.
 Currently don't know how to use MagicalRecord from Swift.
 - returns: an array of BGReading, not saved in CoreData
 Method name describes mg/dL, method converts units to mmol/L for BGReading.quantity
 */
+ (NSArray *)bgReadings135:(NSDate *)endDate;

@end
