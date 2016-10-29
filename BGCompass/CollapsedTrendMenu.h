//
//  CollapsedTrendMenu.h
//  Compass
//
//  Created by Jose Carrillo and Christopher Balcells on 11/6/13.
//  Copyright (c) 2013 Clif Alferness. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollapsedTrendView.h"

@interface CollapsedTrendMenu : CollapsedTrendView
@property (weak, nonatomic) IBOutlet UIButton *backButton;


- (IBAction)backClicked:(id)sender;

@end
