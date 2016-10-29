//
//  currentBGViewController.h
//  CompassRose
//
//  Created by Jose Carrillo and Christopher Balcells on 11/9/13.
//  Copyright (c) 2013 Clif Alferness. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwapperViewController.h"

@interface CurrentBGViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *bgTextView;
@property (weak, nonatomic) IBOutlet UITextView *actionTextView;
-(void) updateData;

@end
