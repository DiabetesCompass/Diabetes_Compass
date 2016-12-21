//
//  AG15Reading.h
//  CompassRose
//
//  Created by Christopher Balcells on 11/26/13.
//  Copyright (c) 2014 Clif Alferness. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Reading.h"

@interface AG15Reading : Reading

@property (nonatomic, retain) NSNumber * quantity;
@property (nonatomic, retain) NSNumber * insufficientDataWarning;
@property (nonatomic, retain) NSNumber * insufficientDataError;

@end
