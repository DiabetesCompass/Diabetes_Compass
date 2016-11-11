//
//  HomeViewController.m
//  CompassRose
//
//  Created by Jose Carrillo and Christopher Balcells on 11/9/13.
//  Copyright (c) 2013 Clif Alferness. All rights reserved.
//

#import "HomeViewController.h"
#import "ItemSelectionTableViewController.h"
#import <FontAwesome+iOS/NSString+FontAwesome.h>
#import "GraphViewController.h"
#import "BGAlgorithmModel.h"
#import "BGReading.h"
#import "FoodReading.h"
#import "ZoomModalAnimator.h"
#import "ItemsNavigationViewController.h"
#import "UIImage+ImageEffects.h"
#import <PPiFlatSegmentedControl.h>
#import "Constants.h"
#import "TrendsAlgorithmModel.h"
#import "AddBGOverlayViewController.h"
#import <BlurryModalSegue.h>
#import "ANBlurredImageView.h"

// TODO: fix me add template for when database or graph is empty
@interface HomeViewController ()

@property (assign, nonatomic) BOOL presentingModal;
@property (strong, nonatomic) ANBlurredImageView *blur;
//@property (strong, nonatomic) UIView* backgroundAnimationView;

@end

@implementation HomeViewController

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
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    UIImageView *backgroundView = [[UIImageView new] initWithImage:[UIImage imageNamed:@"red"]];
    backgroundView.frame = self.view.frame;
    [[self view] addSubview:backgroundView];
    [[self view] sendSubviewToBack:backgroundView];
    
    
    
    
    /*[UIView animateKeyframesWithDuration:10 delay:0 options:UIViewKeyframeAnimationOptionAutoreverse | UIViewKeyframeAnimationOptionRepeat animations:^{
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.15 animations:^{
            //90 degrees (clockwise)
            backgroundView.transform = CGAffineTransformMakeRotation(M_PI * -1.5);
            //backgroundView.transform = CGAffineTransformMakeTranslation(-200, 0);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.15 relativeDuration:0.10 animations:^{
            //180 degrees
            backgroundView.transform = CGAffineTransformMakeRotation(M_PI * 1.0);
            //backgroundView.transform = CGAffineTransformMakeTranslation(0, -200);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.25 relativeDuration:0.20 animations:^{
            //Swing past, ~225 degrees
            backgroundView.transform = CGAffineTransformMakeRotation(M_PI * 1.3);
            //backgroundView.transform = CGAffineTransformMakeTranslation(-200, 0);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.45 relativeDuration:0.20 animations:^{
            //Swing back, ~140 degrees
            //backgroundView.transform = CGAffineTransformMakeRotation(M_PI * 0.8);
            backgroundView.transform = CGAffineTransformMakeTranslation(0, -200);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.65 relativeDuration:0.35 animations:^{
            //Spin and fall off the corner
            //Fade out the cover view since it is the last step
            CGAffineTransform shift = CGAffineTransformMakeTranslation(180.0, 0.0);
            CGAffineTransform rotate = CGAffineTransformMakeRotation(M_PI * 0.3);
            backgroundView.transform = CGAffineTransformConcat(shift, rotate);
            //_coverView.alpha = 0.0;
        }];
    } completion:^(BOOL finished) {
        //Completion Block
    }];*/
    
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];

    // button font may be set to custom FontAwesome in storyboard
    [self.trendsButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"icon-bar-chart"]
                       forState:UIControlStateNormal];
    [self.acceptButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"icon-ok"]
                       forState:UIControlStateNormal];
    [self.rejectButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"icon-remove"]
                       forState:UIControlStateNormal];
    [self.menuButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"icon-align-justify"]
                     forState:UIControlStateNormal];

    self.transitionController = [ZoomModalTransitionDelegate new];
    self.blurTransitionDelegate = [BlurTransitionDelegate new];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
   // Dispose of any resources that can be recreated.
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.presentingModal == NO) {
        [self.navigationController setNavigationBarHidden:NO animated:animated];
    }
}

-(void) viewDidAppear:(BOOL)animated {
    //UIView *image = [self.navigationController.view snapshotViewAfterScreenUpdates:NO];
    
    NSDate *firstDate = ((BGReading*)[BGReading MR_findFirstOrderedByAttribute:@"timeStamp" ascending:NO]).timeStamp;
    NSDate* now = [NSDate date];
    if ([now timeIntervalSince1970] - [firstDate timeIntervalSince1970] > BG_EXPIRATION_MINUTES*SECONDS_IN_ONE_MINUTE) {
        [self performSegueWithIdentifier:@"NeedBGSegue" sender:self];
    }
    
    if ([FoodReading MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"isPending == %@", [NSNumber numberWithBool:YES]]] != 0 || [InsulinReading MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"isPending == %@", [NSNumber numberWithBool:YES]]] != 0) {
        [self showPendingItemsList];
        
    } else {
        [self showCurrentBG];
    }
    
}

/*- (void)updateData
{
    NSLog(@"updateData of homeViewController is called");
    NSArray* viewControllers = self.childViewControllers;
    
    for (UIViewController* vc in viewControllers) {
        if ([vc isKindOfClass:[GraphViewController class]]) {
            NSLog(@"updateData of graph about to be called");
            GraphViewController* graphvc = (GraphViewController*) vc;
            [graphvc updateData];
        } else if ([vc isKindOfClass:[SwapperViewController class] ]) {
            for (UIViewController* vc2 in vc.childViewControllers) {
                if ([vc2 isKindOfClass:[CurrentBGViewController class]]) {
                    NSLog(@"updateData of current BG about to be called");
                    CurrentBGViewController* BGvc = (CurrentBGViewController*) vc2;
                    [BGvc updateData];
                }
            }
        }
    }
}*/

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.presentingModal = NO;
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
                controller.coreDataEntityString = @"All";
                break;
        }
    } else if ([[segue identifier] isEqualToString:@"SettingsSegue"]) {
        self.presentingModal = YES;
        UIViewController *modalViewController = segue.destinationViewController;
        modalViewController.transitioningDelegate = self.blurTransitionDelegate;
    } else if ([[segue identifier] isEqualToString:@"TrendsSegue"]) {
        UIViewController *modalViewController = segue.destinationViewController;
        modalViewController.transitioningDelegate = self.transitionController;
        modalViewController.modalPresentationStyle = UIModalPresentationCustom;
    } else if ([[segue identifier] isEqualToString:@"NeedBGSegue"]) {
        self.presentingModal = YES;
        //BlurryModalSegue* bms = (BlurryModalSegue*)segue;
        
        //bms.backingImageBlurRadius = @(10);
        //bms.backingImageSaturationDeltaFactor = @(1);
        //bms.backingImageTintColor = [[UIColor whiteColor] colorWithAlphaComponent:.1];
        UIViewController *modalViewController = segue.destinationViewController;
        modalViewController.transitioningDelegate = self.blurTransitionDelegate;
        
    } else if([[segue identifier] isEqualToString:@"MenuSegue"]) {
        self.presentingModal = YES;
        UIViewController *modalViewController = segue.destinationViewController;
        modalViewController.transitioningDelegate = self.blurTransitionDelegate;
        
        
    }
    
}

- (IBAction)clickTrends:(id)sender {
}


-(void)showPendingItemsList {
    for (UIViewController* controller in [self childViewControllers]) {
        if ([controller isKindOfClass:[SwapperViewController class]]) {
            SwapperViewController* swapper = (SwapperViewController*) controller;
            [swapper showPendingItemsList];
        }
    }
    [self.trendsButton setHidden:YES];
    [self.acceptButton setHidden:NO];
    [self.rejectButton setHidden:NO];
    //[self.menuButton setHidden:YES];
}

-(void)showCurrentBG {
    for (UIViewController* controller in [self childViewControllers]) {
        if ([controller isKindOfClass:[SwapperViewController class]]) {
            SwapperViewController* swapper = (SwapperViewController*) controller;
            [swapper showCurrentBG];
        }
    }
    [self.acceptButton setHidden:YES];
    [self.rejectButton setHidden:YES];
    [self.trendsButton setHidden:NO];
    //[self.menuButton setHidden:NO];
}

- (IBAction)showMenu:(UIButton*)sender {
}

- (IBAction)rejectPendingItems:(id)sender {
    NSArray *food = [FoodReading MR_findByAttribute:@"isPending" withValue:[NSNumber numberWithBool:YES]];
    NSArray *insulin = [InsulinReading MR_findByAttribute:@"isPending" withValue:[NSNumber numberWithBool:YES]];
    NSArray *items = [food arrayByAddingObjectsFromArray:insulin];
    for (NSManagedObject* item in items) {
        [item MR_deleteEntity];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_REJECTED object:self];
    [self showCurrentBG];
}

- (IBAction)acceptPendingitems:(id)sender {

    NSArray *food = [FoodReading MR_findByAttribute:@"isPending" withValue:[NSNumber numberWithBool:YES]];
    NSArray *insulin = [InsulinReading MR_findByAttribute:@"isPending" withValue:[NSNumber numberWithBool:YES]];
    NSArray *items = [food arrayByAddingObjectsFromArray:insulin];
    for (Reading* item in items) {
        item.isPending = [NSNumber numberWithBool:NO];
    }
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError* error) {
        success ?: NSLog(@"%@", error);
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_ACCEPTED object:self];
    [self showCurrentBG];
}


-(void)pauseLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

-(void)resumeLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
}



@end
