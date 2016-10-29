//
//  NutritionixUPCFood.h
//  BGCompass
//
//  Created by Christopher Balcells on 4/1/14.
//  Copyright (c) 2014 Clif Alferness. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NutritionixSearchFood.h"

@interface NutritionixUPCFood : NutritionixSearchFood

// The request parameters
@property (strong, nonatomic) NSString *upc;

@end
