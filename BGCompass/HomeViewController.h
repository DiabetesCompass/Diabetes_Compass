//
//  HomeViewController.h
//  CompassRose
//
//  Created by Jose Carrillo and Christopher Balcells on 11/9/13.
//  Copyright (c) 2013 Clif Alferness. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphViewController.h"
#import "AddedListViewController.h"
#import "CurrentBGViewController.h"
#import "SwapperViewController.h"
#import "BlurTransitionDelegate.h"
#import "ZoomModalTransitionDelegate.h"

@interface HomeViewController : UIViewController


@property (nonatomic, strong) ZoomModalTransitionDelegate *transitionController;

- (IBAction)rejectPendingItems:(id)sender;
- (IBAction)acceptPendingitems:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIButton *rejectButton;
@property (weak, nonatomic) IBOutlet UIButton *menuButton;

@property (weak, nonatomic) IBOutlet UIButton *trendsButton2;

@property (assign, nonatomic) int selectedSegmentIndex;

@property (strong, nonatomic) BlurTransitionDelegate *blurTransitionDelegate;

- (void) showPendingItemsList;

- (void) showCurrentBG;

- (IBAction)showMenu:(id)sender;
@end
