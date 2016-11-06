//
//  GraphViewController.h
//  CompassRose
//
//  Created by Jose Carrillo and Christopher Balcells on 11/9/13.
//  Copyright (c) 2013 Clif Alferness. All rights reserved.
//

#import <UIKit/UIKit.h>

// https://github.com/core-plot/core-plot/issues/204
#import <CorePlot/ios/CorePlot.h>

#import "InsulinReading.h"
#import "FoodReading.h"

@interface GraphViewController : UIViewController <CPTPlotDataSource, CPTPlotSpaceDelegate, CPTScatterPlotDelegate>
- (void)updateData;
@end
