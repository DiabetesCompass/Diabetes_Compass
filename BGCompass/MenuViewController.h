//
//  MenuViewController.h
//  Compass
//
//  Created by Jose Carrillo and Christopher Balcells on 2/26/14.
//  Copyright (c) 2014 Clif Alferness. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *exitButton;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;


- (IBAction)exitMenu:(id)sender;
- (IBAction)showSettings:(id)sender;

@end
