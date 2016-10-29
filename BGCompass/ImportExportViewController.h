//
//  ImportExportViewController.h
//  Compass
//
//  Created by Jose Carrillo on 3/3/14.
//  Copyright (c) 2014 Clif Alferness. All rights reserved.
//
//This file is for import and export of csv files with historical data

#import <UIKit/UIKit.h>
#import "CHCSVParser.h"

@interface ImportExportViewController : UIViewController <CHCSVParserDelegate>

@property (strong, nonatomic) NSURL* url;

- (void)parseFile:(NSURL*)url;

@end
