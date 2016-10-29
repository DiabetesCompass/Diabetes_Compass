//
//  InsulinReading.h
//  Compass
//
//  Created by macbookpro on 4/15/13.
//  Copyright (c) 2013 Clif Alferness. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Reading.h"

@interface InsulinReading : Reading

//@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * insulinType;
@property (nonatomic, retain) NSNumber * quantity;
//@property (nonatomic, retain) NSDate * timeStamp;
//@property (nonatomic, retain) NSNumber * isFavorite;

-(NSString *) quantityWeightedString;
//-(NSString *) itemValue;

@end
