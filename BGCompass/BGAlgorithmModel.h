//
//  BGPredictAlgorithm.h
//  CompassRose
//
//  Created by Christopher Balcells on 11/18/13.
//  Copywrite (c) 2014 Clif Alferness. All rights reserved.
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

- (NSNumber*) getCurrentBG;
- (NSNumber*) getDeficit;
- (NSNumber*) getSettlingBG;

- (NSNumber *) getPredictSettlingBG;
- (NSNumber*) getPredictDeficit;

@end
