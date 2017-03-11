//
//  AddedListViewController.h
//  CompassRose
//
//  Created by Jose Carrillo and Christopher Balcells on 11/9/13.
//  Copyright (c) 2013 Clif Alferness. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwapperViewController.h"

@interface AddedListViewController : UITableViewController
@property (strong, nonatomic) NSMutableArray* readingsArray;
@property (strong, nonatomic) NSObject *selectedItem;

@property (weak, nonatomic) IBOutlet UITextView *actionTextView;

@end
