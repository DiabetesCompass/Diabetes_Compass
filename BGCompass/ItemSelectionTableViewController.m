//
//  ItemSelectionTableViewController.m
//  CompassRose
//
//  Created by Jose Carrillo and Christopher Balcells on 11/10/13.
//  Copyright (c) 2013 Clif Alferness. All rights reserved.
//

#import "ItemSelectionTableViewController.h"
#import "ItemTableViewCell.h"
#import "FoodReading.h"
#import "BGReading.h"
#import "InsulinReading.h"
#import "APIDelegate.h"
#import "NutritionixSearchFood.h"
#import "AppDelegate.h"
#import "PPiFlatSegmentedControl.h"
#import "EditTableViewController.h"
#import <FontAwesome+iOS/NSString+FontAwesome.h>
#import <FontAwesome+iOS/UIImage+FontAwesome.h>
#import "ItemsNavigationViewController.h"
#import "Reading.h"
#import "Constants.h"
#import "Utilities.h"
#import <Reachability.h>

#warning Register for notifications about the network. If the network changes status. And it changes to connected. And _connectionWasDown == YES, then re-search whatever phrase is in the search bar. This is meant to handle the case where while searching no internet was available, but then sometime after, and without typing into the search bar, internet did become available.

@implementation ItemSelectionTableViewController {
    BOOL _connectionWasDown;
    BOOL _searching;
    BOOL _haveSearched;
    NSTimer *_searchTimer;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    [self hideSearchBar];
 
    return self;
}

- (void)viewDidLoad
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.separatorColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
    
    [super viewDidLoad];
    [self hideSearchBar];
    _connectionWasDown = YES;
    _searching = NO;
    _haveSearched = NO;

    [self.navigationController.view setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    
    
    /*UILabel *back = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 64)];
    back.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
    [self.navigationController.view addSubview:back];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setTranslucent:YES];*/
    
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"EditItemSegue"]) {
        ((EditTableViewController*)segue.destinationViewController).item = self.selectedItem;
        ((EditTableViewController*)segue.destinationViewController).editingMode = self.editingMode;
    } else if ([[segue identifier] isEqualToString:@"upcScannerSegue"]) {
        NSArray* VCs = [((UINavigationController*)segue.destinationViewController) viewControllers];
        UPCScannerViewController* vc = [VCs firstObject];
        vc.delegate = self;
    }
}

-(void) fetchData {
    if ([self.coreDataEntityString isEqualToString:@"FoodReading"]) {
        self.historyItemsArray = [NSMutableArray arrayWithArray:[FoodReading MR_findByAttribute:@"isPending" withValue:[NSNumber numberWithBool:NO] andOrderBy:@"timeStamp" ascending:NO]];
        self.favoriteItemsArray = [NSMutableArray arrayWithArray:[FoodReading MR_findByAttribute:@"isFavorite" withValue:[NSNumber numberWithBool:YES] andOrderBy:@"timeStamp" ascending:NO]];
    } else if ([self.coreDataEntityString isEqualToString:@"InsulinReading"]) {
        self.historyItemsArray = [NSMutableArray arrayWithArray:[InsulinReading MR_findByAttribute:@"isPending" withValue:[NSNumber numberWithBool:NO] andOrderBy:@"timeStamp" ascending:NO]];
        self.favoriteItemsArray = [NSMutableArray arrayWithArray:[InsulinReading MR_findByAttribute:@"isFavorite" withValue:[NSNumber numberWithBool:YES] andOrderBy:@"timeStamp" ascending:NO]];
    } else if ([self.coreDataEntityString isEqualToString:@"BGReading"]){
        self.historyItemsArray = [NSMutableArray arrayWithArray:[BGReading MR_findByAttribute:@"isPending" withValue:[NSNumber numberWithBool:NO] andOrderBy:@"timeStamp" ascending:NO]];
        self.favoriteItemsArray = [NSMutableArray arrayWithArray:[BGReading MR_findByAttribute:@"isFavorite" withValue:[NSNumber numberWithBool:YES] andOrderBy:@"timeStamp" ascending:NO]];
    } else {
        NSArray *total = [BGReading MR_findByAttribute:@"isPending" withValue:[NSNumber numberWithBool:NO] andOrderBy:@"timeStamp" ascending:NO];
        
        total = [total arrayByAddingObjectsFromArray:[InsulinReading MR_findByAttribute:@"isPending" withValue:[NSNumber numberWithBool:NO] andOrderBy:@"timeStamp" ascending:NO]];
        total = [total arrayByAddingObjectsFromArray:[FoodReading MR_findByAttribute:@"isPending" withValue:[NSNumber numberWithBool:NO] andOrderBy:@"timeStamp" ascending:NO]];
        
        NSArray *total2 = [BGReading MR_findByAttribute:@"isFavorite" withValue:[NSNumber numberWithBool:YES] andOrderBy:@"timeStamp" ascending:NO];
        
        total2 = [total2 arrayByAddingObjectsFromArray:[InsulinReading MR_findByAttribute:@"isFavorite" withValue:[NSNumber numberWithBool:YES] andOrderBy:@"timeStamp" ascending:NO]];
        total2 = [total2 arrayByAddingObjectsFromArray:[FoodReading MR_findByAttribute:@"isFavorite" withValue:[NSNumber numberWithBool:YES] andOrderBy:@"timeStamp" ascending:NO]];
        
        total = [total sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            Reading *read1 = obj1;
            Reading *read2  =obj2;
            
            if (read1.timeStamp.timeIntervalSince1970 < read2.timeStamp.timeIntervalSince1970) {
                return 1;
            } else {
                return -1;
            }
        }];
        
        total2 = [total2 sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            Reading *read1 = obj1;
            Reading *read2  =obj2;
            
            if (read1.timeStamp.timeIntervalSince1970 < read2.timeStamp.timeIntervalSince1970) {
                return 1;
            } else {
                return -1;
            }
        }];
        self.historyItemsArray = [NSMutableArray arrayWithArray:total];
        self.favoriteItemsArray = [NSMutableArray arrayWithArray:total2];
        NSMutableArray *toolbarButtons = [self.navigationItem.rightBarButtonItems mutableCopy];
        
        // This is how you remove the button from the toolbar and animate it
        [toolbarButtons removeObject:self.addButton];
        [self.navigationItem setRightBarButtonItems:toolbarButtons animated:YES];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    NSLog(@"viewwillappear of itemselection");
    [self fetchData];
    [self.tableView reloadData];
    
    if (self.searchDisplayController.isActive) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UPCScannerInfoDelegate

- (void) fromViewController:(UPCScannerViewController *)controller withBarCode:(NSString *)barCode
{
    [[APIDelegate sharedInstance] searchNutritionixWithUpc:barCode withController:self];
    [self setSearching:YES];
    [self.searchDisplayController.searchResultsTableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 2;
    } else {
        return 2;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
        if (section == 0) {
            return 1;
        } else {
            if (_connectionWasDown || [self.searchResults count] == 0) {
                return 1;
            }
        }
        return [self.searchResults count];
    } else {
        if (section == 0) {
            return 1;
        } else {
            if (self.tableViewMode == 0) {
                if ([self.historyItemsArray count] == 0) {
                    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
                    //[pleaseAddStuffText setHidden:NO];
#warning add hidden empty table image
                } else {
                    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
                    //[pleaseAddStuffText setHidden:YES];
                }
                return [self.historyItemsArray count];
            } else if (self.tableViewMode == 1) {
                if ([self.favoriteItemsArray count] == 0) {
                    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
                    //[pleaseAddStuffText setHidden:NO];
                } else {
                    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
                    //[pleaseAddStuffText setHidden:YES];
                }
                return [self.favoriteItemsArray count];
            }
        }
    }
    
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (section == 1) {
            if (_searching) {
                return @"Searching...";
            } else if (!_haveSearched) {
                return @" ";
            }
            return @"Search Results";
        }
    }
    return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
        if (indexPath.section == 0) {
            return 44.0f;
        }
        
        if (_connectionWasDown || [self.searchResults count] == 0) {
            return 300.0f;
        }
        
        return 44.0f;
        
    } else {
        if (indexPath.section == 0) {
            return 40.0f;
        } else {
            return 65.0f;
        }
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    
    if (tableView == self.searchDisplayController.searchResultsTableView) {

        //Try and reuse a cell.
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        
        //Create a new cell if not.
        if (cell == nil) {
            cell = [[UITableViewCell new] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
        }
        
        if (indexPath.section == 0) {
            cell.textLabel.text = @"Manual Entry";
            cell.detailTextLabel.text = @"";
            
        } else {
            if (!_haveSearched) {
                // Leave cell empty.
            } else if (_connectionWasDown) {
                // If there was no internet when search was attempted display a warning in the tableview section. No Alerts!
#warning display a "No internet connected" view
                cell = [tableView dequeueReusableCellWithIdentifier:@"DeadCell"];
                if (!cell) {
                    cell = [[UITableViewCell new] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"DeadCell"];
                }
                cell.textLabel.text = @"Network connectivity is required to search food in database";
            } else if ([self.searchResults count] == 0) {
                // For some reason, search results are empty. Display a message in the view.
#warning put in a "No Results available view"
                cell = [tableView dequeueReusableCellWithIdentifier:@"DeadCell"];
                if (!cell) {
                    cell = [[UITableViewCell new] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"DeadCell"];
                }
                cell.textLabel.text = @"No results available";
                
            } else {
                NutritionixSearchFood * result = (NutritionixSearchFood *)[self.searchResults objectAtIndex:indexPath.row];
                cell.textLabel.text = [result name];
                cell.detailTextLabel.text = [result brand];
            }
        }
        cell.backgroundColor = [UIColor clearColor];
        return cell;
        
    } else {
        if (indexPath.section == 0){
            static NSString *CellIdentifier = @"SegmentCell";
            ItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            if ([cell.contentView.subviews count] == 0) {
                PPiFlatSegmentedControl *segmented = [[PPiFlatSegmentedControl alloc] initWithFrame:CGRectMake(-2, 0, 323, 40) items:@[@{@"text":@"History",@"icon":@"icon-time"},@{@"text":@"Favorites",@"icon":@"icon-star"}] iconPosition:IconPositionRight andSelectionBlock:^(NSUInteger segmentIndex) {
                    if (segmentIndex == 0) {
                        self.tableViewMode = 0;
                    } else {
                        self.tableViewMode = 1;
                    }
                    [self fetchData];
                    [self.tableView reloadData];
                } iconSeparation:0];
                
                segmented.color=[UIColor clearColor];
                segmented.borderWidth=0.5;
                segmented.borderColor=[UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
                segmented.selectedColor=[UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
                segmented.textAttributes=@{NSFontAttributeName:[UIFont systemFontOfSize:15],
                                           NSForegroundColorAttributeName:[UIColor whiteColor]};
                segmented.selectedTextAttributes=@{NSFontAttributeName:[UIFont systemFontOfSize:15],
                                                   NSForegroundColorAttributeName:[UIColor whiteColor]};
                
                
                
                [cell.contentView addSubview:segmented];
            }
            return cell;
        } else {
            static NSString *CellIdentifier = @"ItemCell";
            ItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                        
            NSLocale *locale = [NSLocale currentLocale];
            NSDateFormatter *theDate = [NSDateFormatter new];
            [theDate setLocale:locale];
            [theDate setDateFormat:@"MMM d"];
            NSDateFormatter *theTime = [NSDateFormatter new];
            [theTime setLocale:locale];
            [theTime setDateFormat:@"h:mm a"];
            cell.favoritesButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
            
            Reading* item;
            if (self.tableViewMode == 0) {
                item = ((Reading*)[self.historyItemsArray objectAtIndex: indexPath.row]);
            } else {
                item = ((Reading*)[self.favoriteItemsArray objectAtIndex: indexPath.row]);
            }
            
            cell.descriptionLabel.text = item.name;
            cell.infoNumberLabel.text = [item itemValue];
            cell.timeLabel.text = [theTime stringFromDate:item.timeStamp];
            cell.dateLabel.text = [theDate stringFromDate:item.timeStamp];
            if ([item.isFavorite boolValue]) {
                [cell.favoritesButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"icon-star"] forState:UIControlStateNormal];
            } else {
                [cell.favoritesButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"icon-star-empty"] forState:UIControlStateNormal];
            }
            
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
    self.editingMode = NO;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        if (indexPath.section == 1) {
            if (_searching || _connectionWasDown || [self.searchResults count] == 0) {
                //Do not respond.
                return;
            } else {
                NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
                self.selectedItem = [FoodReading MR_createInContext:context];
                ((Reading*)self.selectedItem).isPending = [NSNumber numberWithBool:YES];
                NutritionixSearchFood *food = [self.searchResults objectAtIndex:[indexPath row]];
                ((FoodReading*)self.selectedItem).name = food.name;
                ((FoodReading*)self.selectedItem).carbs = [NSNumber numberWithInt:([food.carbs floatValue] + 0.5)];
                ((FoodReading*)self.selectedItem).servingUnitAndQuantity = [[food.servingUnitQuantity stringByAppendingString:@" "] stringByAppendingString:food.servingUnit];
                ((FoodReading*)self.selectedItem).timeStamp = [NSDate date];
            }
        } else {
            self.selectedItem = [FoodReading MR_createInContext:context];
            ((Reading*)self.selectedItem).isPending = [NSNumber numberWithBool:YES];
            ((FoodReading*)self.selectedItem).name = self.searchDisplayController.searchBar.text;
        }
        ((FoodReading*)self.selectedItem).numberOfServings = [NSNumber numberWithInt:1];
        
        [self performSegueWithIdentifier:@"EditItemSegue" sender:self];
    } else {
        if (indexPath.section == 1) {
            if (self.tableViewMode == 0) {
                self.selectedItem = [self.historyItemsArray objectAtIndex:[indexPath row]];
            } else {
                self.selectedItem = [self.favoriteItemsArray objectAtIndex:[indexPath row]];
            }
            UIActionSheet *actionSheet = [[UIActionSheet new] initWithTitle:@"How do you wish to use this entry?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Edit Entry", @"Use As New Entry", nil];
            actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
            [actionSheet showInView:self.view];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView && indexPath.section == 1
        && (_searching || _connectionWasDown || [self.searchResults count] == 0)) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return NO;
    } else {
        if (indexPath.section == 1) {
            return YES;
        } else {
            return NO;
        }
    }
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Delete the row from the data source
        if (self.tableViewMode == 0) {
            [((Reading*)[self.historyItemsArray objectAtIndex:indexPath.row]) MR_deleteEntity];
            [self.historyItemsArray removeObjectAtIndex:indexPath.row];
        } else if (self.tableViewMode == 1) {
            [((Reading*)[self.favoriteItemsArray objectAtIndex:indexPath.row]) MR_deleteEntity];
            [self.favoriteItemsArray removeObjectAtIndex:indexPath.row];
        }
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        if ([self.coreDataEntityString isEqualToString:@"FoodReading"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_FOODREADING_EDITED object:nil userInfo:nil];
        } else if ([self.coreDataEntityString isEqualToString:@"InsulinReading"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_INSULINREADING_EDITED object:nil userInfo:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_BGREADING_EDITED object:nil userInfo:nil];
        }
        
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        
    }
}


#pragma mark - Search Display Delegate Methods

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // Tells the table data source to reload when text changes
    // Return YES to cause the search result table view to be reloaded.
    // Instead of reloading table when text changes. Will reload table when results are pushed.
#warning this idea hinges on whether reloadData method refreshes the table. It will be called on the success callback in APIDelegate
    
    if (searchString.length == 0) {
        return YES;
    }
    return NO;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    // Tells the table data source to reload when scope bar selection changes
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    // launch a timer for half a second. If another change happens in the meantime, cancel that timer and launch another one. Once the user has paused for half a second without changing text, send a search to Nutritionix.
#warning This is not working. Need to get internet to see how NSTimer works.
    
    if (_searchTimer) {
        [_searchTimer invalidate];
        _searchTimer = nil;
    }
    
    if (searchText.length != 0) {
        _searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(doStringSearch:) userInfo:searchText repeats:NO];
    } else {
        _haveSearched = NO;
    }
}

-(void) doStringSearch:(NSTimer*)theTimer
{
    NSLog(@"DoStringSearch fired successfully");
    [[APIDelegate sharedInstance] searchNutritionixWithString:(NSString *)theTimer.userInfo withController:self];
    [self setSearching:YES];
    //_haveSearched = YES;
    [self.searchDisplayController.searchResultsTableView reloadData];
}

-(void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

-(void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}


- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    if (searchBar.text.length == 0) {
        [self hideSearchBar];
    } else {
#warning if this is invoked when the "Search" button is pressed. Then here there should be a search invocation unless the currently displayed results are for the same searchText.
    }
}


- (void)hideSearchBar
{
    self.header = self.tableView.tableHeaderView;
    self.searchDisplayController.searchBar.hidden = YES;
    self.tableView.tableHeaderView = nil;
    [self.searchDisplayController setActive:NO animated:YES];

}

- (void) searchBarBookmarkButtonClicked:(UISearchBar *)searchBar {
    [self performSegueWithIdentifier:@"upcScannerSegue" sender:self];
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self hideSearchBar];
}

- (IBAction) exitList:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)newItem:(id)sender {
    // make the search bar visible
    if ([self.title  isEqual: @"Food"] ) {
        
        if (self.header == nil) {
            self.header = self.tableView.tableHeaderView;
        } else {
            self.tableView.tableHeaderView = self.header;
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        }
#warning here is where you can disable/activate UPC scanner button.
        [self.searchDisplayController.searchBar setShowsBookmarkButton:YES];
        [self.searchDisplayController.searchBar setShowsScopeBar:NO];
        [self.searchDisplayController.searchBar setShowsCancelButton:YES animated:YES];
        [self.searchDisplayController.searchBar setImage:[UIImage imageWithIcon:@"icon-barcode" backgroundColor:[UIColor whiteColor] iconColor:[UIColor blackColor] iconScale:1 andSize:CGSizeMake(20, 20)] forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateNormal];
        //[self.searchDisplayController.searchBar setPositionAdjustment:UIOffsetMake(0, 0) forSearchBarIcon:UISearchBarIconBookmark];
        [self.searchDisplayController setActive: YES animated: YES];
        self.searchDisplayController.searchBar.hidden = NO;
        [self.searchDisplayController.searchBar becomeFirstResponder];
        
    } else if ([self.title  isEqual: @"Blood Glucose"]) {
        NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
        self.selectedItem = [BGReading MR_createInContext:context];
        ((BGReading*)self.selectedItem).name = @"Blood Glucose";
        ((BGReading*)self.selectedItem).timeStamp = [NSDate date];
        [self performSegueWithIdentifier:@"EditItemSegue" sender:self];
        
    } else if ([self.title  isEqual: @"Insulin"]) {
        NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
        self.selectedItem = [InsulinReading MR_createInContext:context];
        ((InsulinReading*)self.selectedItem).name = @"Insulin";
        ((InsulinReading*)self.selectedItem).timeStamp = [NSDate date];
        [self performSegueWithIdentifier:@"EditItemSegue" sender:self];
        
    }
    

}

- (IBAction)favoriteClicked:(id)sender {
    
    UIButton* button = (UIButton*)sender;
    ItemTableViewCell* cell = (ItemTableViewCell*)button.superview.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    BGReading* reading = [self.historyItemsArray objectAtIndex:indexPath.row];
    
    if ([reading.isFavorite boolValue]) {
        reading.isFavorite = [NSNumber numberWithBool:NO];
        [cell.favoritesButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"icon-star-empty"] forState:UIControlStateNormal];
        
    } else {
        reading.isFavorite = [NSNumber numberWithBool:YES];
        [cell.favoritesButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"icon-star"] forState:UIControlStateNormal];
    }
    
}


#pragma mark - UIActionSheetDelegate Methods

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
    if (buttonIndex == 0) {
        self.editingMode = YES;
        [self performSegueWithIdentifier:@"EditItemSegue" sender:self];
    } else if (buttonIndex == 1) {
        if ([[self.selectedItem class] isSubclassOfClass:[FoodReading class]]) {
            FoodReading* food = [FoodReading MR_createInContext:context];
            food.isPending = [NSNumber numberWithBool:YES];
            food.name = ((FoodReading*)self.selectedItem).name;
            food.timeStamp = ((FoodReading*)self.selectedItem).timeStamp;
            food.carbs = ((FoodReading*)self.selectedItem).carbs;
            food.servingUnitAndQuantity = ((FoodReading*)self.selectedItem).servingUnitAndQuantity;
            food.numberOfServings = ((FoodReading*)self.selectedItem).numberOfServings;
            self.selectedItem = food;
        } else if ([[self.selectedItem class] isSubclassOfClass:[BGReading class]]) {
            BGReading* reading = [BGReading MR_createInContext:context];
            reading.isPending = [NSNumber numberWithBool:YES];
            reading.name = ((BGReading*)self.selectedItem).name;
            reading.quantity = ((BGReading*)self.selectedItem).quantity;
            reading.timeStamp = ((BGReading*)self.selectedItem).timeStamp;
            self.selectedItem = reading;
        } else if ([[self.selectedItem class] isSubclassOfClass:[InsulinReading class]]) {
            InsulinReading* reading = [InsulinReading MR_createInContext:context];
            reading.isPending = [NSNumber numberWithBool:YES];
            reading.name = ((InsulinReading*)self.selectedItem).name;
            reading.quantity = ((InsulinReading*)self.selectedItem).quantity;
            reading.timeStamp = ((InsulinReading*)self.selectedItem).timeStamp;
            self.selectedItem = reading;
        }
        
        [self performSegueWithIdentifier:@"EditItemSegue" sender:self];
    }
    
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    for (UIView *subview in actionSheet.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            if (![button.titleLabel.text  isEqual: @"Cancel"]) {
                [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            } else {
                [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            }
        }
    }
}

- (void) setConnectionWasDown:(BOOL) yesOrNo
{
    _connectionWasDown = yesOrNo;
}

- (void) setSearching:(BOOL) yesOrNo
{
    if (_searching && !yesOrNo) {
        _haveSearched = YES;
    }
    _searching = yesOrNo;
}


@end
