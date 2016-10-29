//
//  TrendsViewController.h
//  BG Compass
//
//  Created by Jose Carrillo and Christopher Balcells on 11/23/13.
//  Copyright (c) 2013 Clif Alferness. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CorePlot-CocoaTouch.h>
#import "APPaginalTableView.h"

@interface TrendsContainerViewController : UIViewController <CPTPlotDataSource, CPTPlotSpaceDelegate, APPaginalTableViewDataSource, APPaginalTableViewDelegate>



@end
