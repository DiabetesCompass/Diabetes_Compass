//
//  AddBGOverlayViewController.h
//  Compass
//
//  Created by Jose Carrillo and Christopher Balcells on 2/26/14.
//  Copyright (c) 2014 Clif Alferness. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANBlurredImageView.h"

@interface AddBGOverlayViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *trendsButton;
@property (weak, nonatomic) IBOutlet UIButton *historyButton;
@property (weak, nonatomic) IBOutlet UILabel *needBGTitle;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property(strong, nonatomic) ANBlurredImageView* blur;

- (IBAction)showTrends:(id)sender;
- (IBAction)showHistory:(id)sender;
- (IBAction)saveBG:(id)sender;

@end
