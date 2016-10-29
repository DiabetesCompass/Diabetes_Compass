//
//  CurveModel.h
//  CompassRose
//
//  Created by Christopher Balcells on 11/15/13.
//  Copywrite (c) 2014 Clif Alferness. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InsulinReading.h"
#import "FoodReading.h"

@interface CurveModel : NSObject
- (void) effectFromInsulinReading:(InsulinReading*) insulinReading toArray:(float *)insulinEffect;
- (void) effectFromFoodReading:(FoodReading*) foodReading toArray:(float *)carbEffect;
- (int) getInsulinDuration;
+ (id) sharedInstance;
@end
