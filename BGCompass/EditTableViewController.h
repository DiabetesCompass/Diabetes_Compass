//
//  EditTableViewController.h
//  BG Compass
//
//  Created by Jose Carrillo and Christopher Balcells on 11/29/13.
//  Copyright (c) 2013 Clif Alferness. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RETableViewManager.h>

@interface EditTableViewController : UITableViewController

@property (nonatomic, strong) id item;
@property (nonatomic, assign) BOOL editingMode;
@property (nonatomic, assign) BOOL doneButtonClicked;
@property (nonatomic, assign) BOOL blurBackground;
@property (nonatomic, strong) RETableViewManager* manager;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

- (IBAction)finishedEditing:(id)sender;
@end
