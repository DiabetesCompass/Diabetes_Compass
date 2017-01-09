//
//  Ha1cReading.h
//  CompassRose
//
//  Created by Christopher Balcells on 11/26/13.
//  Copyright (c) 2014 Clif Alferness. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Reading.h"

@interface Ha1cReading : Reading

/**
 Ha1cReading.quantity units are percent of hemoglobin that is glycated.
 Generally physiologic HA1c is >= 5.
 5 represents 5%, or 0.05
 https://en.wikipedia.org/wiki/Glycated_hemoglobin
 */
@property (nonatomic, retain) NSNumber * quantity;

@property (nonatomic, retain) NSNumber * insufficientDataWarning;
@property (nonatomic, retain) NSNumber * insufficientDataError;

@end
