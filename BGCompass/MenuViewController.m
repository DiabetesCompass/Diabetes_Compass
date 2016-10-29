//
//  MenuViewController.m
//  Compass
//
//  Created by Jose Carrillo and Christopher Balcells on 2/26/14.
//  Copyright (c) 2014 Clif Alferness. All rights reserved.
//

#import "MenuViewController.h"
#import <PPiFlatSegmentedControl.h>
#import "ItemSelectionTableViewController.h"
#import <BlurryModalSegue.h>
#import "ItemsNavigationViewController.h"
#import "BlurTransitionDelegate.h"

@interface MenuViewController ()

@property (nonatomic) int selectedSegmentIndex;
@property (strong, nonatomic) BlurTransitionDelegate* blurTransitionDelegate;

@end

@implementation MenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.blurTransitionDelegate = [BlurTransitionDelegate new];
    
    self.settingsButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:24];
    [self.settingsButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"icon-cog"] forState:UIControlStateNormal];
    
    self.exitButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:24];
    [self.exitButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"icon-remove"] forState:UIControlStateNormal];
    
    PPiFlatSegmentedControl *segmented=[[PPiFlatSegmentedControl alloc] initWithFrame:CGRectMake(-2, 70, 323, 39.5) items:@[@{@"text":@"Food"},@{@"text":@"Glucose"}, @{@"text":@"Insulin"}, @{@"text":@"All"}]iconPosition:IconPositionRight andSelectionBlock:^(NSUInteger segmentIndex) {
     
        self.selectedSegmentIndex = (int)segmentIndex;
        [self performSegueWithIdentifier:@"ItemListViewSegue" sender:self];
     } iconSeparation:0];
     
     segmented.color=[UIColor clearColor];
     segmented.borderWidth=1;
     segmented.borderColor=[UIColor colorWithRed:1 green:1 blue:1 alpha:0.4];
     segmented.selectedColor=[UIColor clearColor];
    // set the color for the food, glucose, insulin, all text & boxes
     segmented.textAttributes=@{NSFontAttributeName:[UIFont systemFontOfSize:15],
     NSForegroundColorAttributeName:[UIColor whiteColor]};
     segmented.selectedTextAttributes=@{NSFontAttributeName:[UIFont systemFontOfSize:15],
     NSForegroundColorAttributeName:[UIColor whiteColor]};
     [self.view addSubview:segmented];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [((ItemsNavigationViewController*)self.navigationController).blur blurInAnimationWithDuration:0.25];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ItemListViewSegue"]) {
        ItemSelectionTableViewController *controller = [segue destinationViewController];
        
        switch (self.selectedSegmentIndex) {
            case 0:
                controller.title = @"Food";
                controller.coreDataEntityString = @"FoodReading";
                break;
            case 1:
                controller.title = @"Blood Glucose";
                controller.coreDataEntityString = @"BGReading";
                break;
            case 2:
                controller.title = @"Insulin";
                controller.coreDataEntityString = @"InsulinReading";
                break;
            case 3:
                controller.title = @"All";
                //controller.coreDataEntityString = @"AllReading";
                break;
        }
        
        //BlurryModalSegue* bms = (BlurryModalSegue*)segue;
        
        //bms.backingImageBlurRadius = @(10);
        //bms.backingImageSaturationDeltaFactor = @(1);
        //bms.backingImageTintColor = [[UIColor whiteColor] colorWithAlphaComponent:.1];
        UIViewController *modalViewController = segue.destinationViewController;
        modalViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    } else if ([[segue identifier] isEqualToString:@"SettingsFromMenuSegue"]) {
        UIViewController *modalViewController = segue.destinationViewController;
        modalViewController.transitioningDelegate = self.blurTransitionDelegate;
    }
}

- (IBAction)exitMenu:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)showSettings:(id)sender {
    [self performSegueWithIdentifier:@"SettingsFromMenuSegue" sender:self];
}
@end
