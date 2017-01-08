//
//  BGPredictAlgorithm.h
//  CompassRose
//
//  Created by Christopher Balcells on 11/18/13.
//  Copyright (c) 2014 Clif Alferness. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BGAlgorithmModel : NSObject

+ (id)sharedInstance;

- (void) calculateGraphArray;
- (void) shiftGraphArray;
- (void) calculatePredictArray;

- (NSNumber*) graphArrayCount;
- (NSNumber*) predictArrayCount;
- (NSNumber*) getFromGraphArray:(NSUInteger)index;
- (NSNumber*) getFromPredictArray:(NSUInteger)index;

// FIXME: Either use mmol/L or use isInMoles to set units
/// - returns: current estimated BG in mg/dL
- (NSNumber*) getCurrentBG;

- (NSNumber*) getDeficit;
- (NSNumber*) getSettlingBG;

// FIXME: Either use mmol/L or use isInMoles to set units
/// - returns: settling BG in mg/dL
- (NSNumber *) getPredictSettlingBG;

- (NSNumber*) getPredictDeficit;

@end
