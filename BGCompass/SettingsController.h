//
//  SettingsController.h
//  Compass
//
//  Created by Jose Carrillo and Christopher Balcells on 11/29/13.
//  Copyright (c) 2013 Clif Alferness. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RETableViewManager.h>
#import "ANBlurredImageView.h"

@interface SettingsController : UITableViewController

@property (nonatomic, strong) RETableViewManager* manager;
@property(strong, nonatomic) ANBlurredImageView* blur;


@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

- (IBAction)clickedDone:(id)sender;

@end
