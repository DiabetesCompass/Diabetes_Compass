//
//  FoodReading.h
//  Compass
//
//  Created by macbookpro on 4/17/13.
//  Copyright (c) 2013 Clif Alferness. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Reading.h"

@interface FoodReading : Reading

@property (nonatomic, retain) NSNumber * carbs;
//@property (nonatomic, retain) NSString * name;
//@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSNumber * numberOfServings;
@property (nonatomic, retain) NSString * servingUnitAndQuantity;
//@property (nonatomic, retain) NSNumber * isFavorite;

//-(NSString *) itemValue;
@end
