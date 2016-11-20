//
//  AddedListViewController.m
//  CompassRose
//
//  Created by Jose Carrillo and Christopher Balcells on 11/9/13.
//  Copyright (c) 2013 Clif Alferness. All rights reserved.
//

#import "AddedListViewController.h"
#import "BGReading.h"
#import "PendingItemCell.h"
#import "HomeViewController.h"
#import "BGAlgorithmModel.h"
#import "EditTableViewController.h"
#import "ItemsNavigationViewController.h"
#import "UIImage+ImageEffects.h"
#import "Constants.h"
#import "Utilities.h"

@interface AddedListViewController ()

@property (strong, nonatomic) NSMutableArray *itemsArray;

@end

@implementation AddedListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotifications:) name:NOTE_PREDICT_RECALCULATED object:nil];
}

- (void)handleNotifications:(NSNotification*) note
{
    NSLog(@"AddedListViewer received notification name: %@", [note name]);
    [self performSelectorOnMainThread:@selector(updateData) withObject:self waitUntilDone:NO];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSArray *food = [NSMutableArray arrayWithArray:[FoodReading MR_findByAttribute:@"isPending" withValue:[NSNumber numberWithBool:YES] andOrderBy:@"timeStamp" ascending:NO]];
    
    NSArray *insulin = [NSMutableArray arrayWithArray:[InsulinReading MR_findByAttribute:@"isPending" withValue:[NSNumber numberWithBool:YES] andOrderBy:@"timeStamp" ascending:NO]];
    self.itemsArray = [NSMutableArray arrayWithArray:food];
    [self.itemsArray addObjectsFromArray:insulin];
    
    [self.tableView reloadData];
    [self updateData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.itemsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"PendingItemCell";
    
    PendingItemCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.itemName.text = ((Reading*)[self.itemsArray objectAtIndex:indexPath.row]).name;
    cell.itemValue.text = [((Reading*)[self.itemsArray objectAtIndex:indexPath.row]) itemValue];
    
    
    //cell.selectedBackgroundView = [ [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"cell_pressed.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ]autorelease];
    //cell.backgroundView = [[UIImageView new] initWithImage:[UIImage imageNamed:@"tableviewBackground.png"]];
    cell.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [[self.itemsArray objectAtIndex:indexPath.row] MR_deleteEntity];
        [self.itemsArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        if ([self.itemsArray count] == 0) {
            [((HomeViewController*)self.parentViewController.parentViewController) showCurrentBG];
        }
        // Save context. This should eliminate the issue of reloading the items after closing down the app.
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {}];
        
        // Send notification.
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_PENDINGREADING_DELETED object:nil userInfo:nil];

    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        
    }
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedItem = [self.itemsArray objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"EditItemSegue2" sender:self];
    
}



#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"EditItemSegue2"]) {
        EditTableViewController *viewController = segue.destinationViewController;
        viewController.item = self.selectedItem;
        viewController.editingMode = YES;
        viewController.blurBackground = YES;
        
        CGRect frame = [UIScreen mainScreen].bounds;
        UIGraphicsBeginImageContext(frame.size);
        [self.parentViewController.parentViewController.view.window drawViewHierarchyInRect:frame afterScreenUpdates:NO];
        UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    
        ANBlurredImageView *blurView = [[ANBlurredImageView alloc] initWithImage:snapshot];
        blurView.framesCount = 10;
        blurView.blurAmount = 0.5;
        blurView.blurTintColor = [UIColor clearColor];
        [((ItemsNavigationViewController*)self.navigationController).blur removeFromSuperview];
        ((ItemsNavigationViewController*)self.navigationController).blur = blurView;
        [self.navigationController.view addSubview:blurView];
        [self.navigationController.view sendSubviewToBack:blurView];
        
    }
}

#pragma ActionText from CurrentBGViewController

-(void) updateData
{
    //NSLog(@"update data on current BG");
    NSNumber *bgSettling = [[BGAlgorithmModel sharedInstance] getPredictSettlingBG];
    NSString *bgSettlingString = [Utilities createFormattedStringFromNumber:bgSettling forReadingType:[BGReading class]];
    
    NSDictionary *thin = @{NSForegroundColorAttributeName:[UIColor greenColor],
                           NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Thin" size:17]};
    NSDictionary *bold = @{NSForegroundColorAttributeName:[UIColor greenColor],
                           NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Bold" size:17]};
    
    NSNumber *deficit = [[BGAlgorithmModel sharedInstance] getPredictDeficit];
    //NSLog(@"Deficit value is:%f", [deficit floatValue]);
    NSString *deficitType;
    NSString *units = [Utilities getUnitsForBG];
    
    
    NSMutableAttributedString *aString1 = [[NSMutableAttributedString new] initWithString:ACTION_STRING1 attributes:thin];
    NSAttributedString *aString2 = [[NSAttributedString new] initWithString:bgSettlingString attributes:bold];
    NSAttributedString *aString3 = [[NSAttributedString new] initWithString:[@" " stringByAppendingString:units] attributes:thin];
    
    NSString *deficitString;
    
    if (deficit.floatValue < 0) {
        deficit = [NSNumber numberWithFloat:fabs(deficit.floatValue)];
        deficitString = [Utilities createFormattedStringFromNumber:deficit forReadingType:[InsulinReading class]];
        deficitType = INSULIN_STRING;
    } else {
        deficitString = [Utilities createFormattedStringFromNumber:deficit forReadingType:[FoodReading class]];
        deficitType = CARBS_STRING;
    }
    
    if ([deficit isEqualToNumber:[NSNumber numberWithInt:0]]) {
        NSAttributedString *aString7 = [[NSMutableAttributedString new] initWithString:NO_ACTION_STRING attributes:thin];
        
        [aString1 appendAttributedString:aString2];
        [aString1 appendAttributedString:aString3];
        [aString1 appendAttributedString:aString7];
        
    } else {
        NSAttributedString *aString4 = [[NSAttributedString new] initWithString:ACTION_STRING2 attributes:thin];
        NSAttributedString *aString5 = [[NSAttributedString new] initWithString:deficitString attributes:bold];
        NSAttributedString *aString6 = [[NSAttributedString new] initWithString:deficitType attributes:thin];
        
        [aString1 appendAttributedString:aString2];
        [aString1 appendAttributedString:aString3];
        [aString1 appendAttributedString:aString4];
        [aString1 appendAttributedString:aString5];
        [aString1 appendAttributedString:aString6];
    }
    
    self.actionTextView.attributedText = aString1;
    self.actionTextView.textAlignment = NSTextAlignmentCenter;
    
    //self.bgTextView.frame = CGRectMake(26, 0, 320, 107);
}


@end
