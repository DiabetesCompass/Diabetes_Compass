//
//  ItemSelectionTableViewController.h
//  CompassRose
//
//  Created by Jose Carrillo and Christopher Balcells on 11/10/13.
//  Copyright (c) 2013 Clif Alferness. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NutritionixSearchFood.h"
#import "ItemTableViewCell.h"
#import "UPCScannerViewController.h"

@interface ItemSelectionTableViewController : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate, UIActionSheetDelegate, UPCScannerInfoDelegate>

@property (strong, nonatomic) NSMutableArray *historyItemsArray;
@property (strong, nonatomic) NSMutableArray *favoriteItemsArray;
@property (strong, nonatomic) NSString *coreDataEntityString;
@property (strong, nonatomic) NSMutableArray *searchResults;
@property (strong, nonatomic) UIView *header;
@property (strong, nonatomic) NSObject *selectedItem;
@property (assign, nonatomic) NSInteger tableViewMode;
@property (assign, nonatomic) BOOL editingMode;
@property (nonatomic) BOOL internetIsReachable;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *addButton;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *exitButton;

- (IBAction)exitList:(id)sender;

- (IBAction)newItem:(id)sender;

- (IBAction)favoriteClicked:(id)sender;

- (void) setConnectionWasDown:(BOOL) yesOrNo;
- (void) setSearching:(BOOL) yesOrNo;

@end
