//
//  currentBGViewController.m
//  CompassRose
//
//  Created by Jose Carrillo and Christopher Balcells on 11/9/13.
//  Copyright (c) 2013 Clif Alferness. All rights reserved.
//

#import "CurrentBGViewController.h"
#import "BGAlgorithmModel.h"
#import "Constants.h"
#import "BGReading.h"
#import "FoodReading.h"
#import "InsulinReading.h"
#import "Utilities.h"
#import "TrendsAlgorithmModel.h"

@interface CurrentBGViewController ()

@end

@implementation CurrentBGViewController

#pragma mark - lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self addObservers];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - observer

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotifications:) name:NOTE_GRAPH_RECALCULATED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotifications:) name:NOTE_GRAPH_SHIFTED object:nil];
}

- (void)handleNotifications:(NSNotification *) note {
    NSLog(@"CurrentBGViewController received notification name: %@", [note name]);
    if ([[note name] isEqualToString:NOTE_GRAPH_RECALCULATED]) {
        [self performSelectorOnMainThread:@selector(updateData) withObject:self waitUntilDone:NO];
    } else if ([[note name] isEqualToString:NOTE_GRAPH_SHIFTED]) {
        [self performSelectorOnMainThread:@selector(updateData) withObject:self waitUntilDone:NO];
    }
}

-(void) updateData {
    NSLog(@"update data on current BG");
    NSNumber *bgCurrent = [[BGAlgorithmModel sharedInstance] getCurrentBG];
    NSLog(@"Current BG is: %@", bgCurrent);
    NSLog(@"update latest HA1c data");
    Ha1cReading* lastHA1c = [Ha1cReading MR_findFirstOrderedByAttribute:@"timeStamp" ascending:NO inContext:[NSManagedObjectContext MR_defaultContext]];
    NSNumber *latestHA1c = lastHA1c.quantity;
    NSLog(@"latest HA1c: %@", latestHA1c);
    NSString *latestEstimatedHA1c = [NSString stringWithFormat: @ "%.2f", [latestHA1c floatValue]];
    NSNumber *bgCurrentForTest = [[BGAlgorithmModel sharedInstance] getCurrentMmolPerLBG];
    NSLog(@"Current BG is: %@", bgCurrent);
    
    NSString *bgCurrentString = [Utilities createFormattedStringFromNumber:bgCurrent forReadingType:[BGReading class]];

    // These are the colors & styles for the present est BG & deficit texts
    //general texts
    NSDictionary *thin = @{NSForegroundColorAttributeName:[UIColor whiteColor],
                           NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Thin" size:17]};
    //next is the est BG
    NSDictionary *thinBig = @{NSForegroundColorAttributeName:[UIColor yellowColor],
                           NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Thin" size:100]};
    //deficit & settling texts
    NSDictionary *bold = @{NSForegroundColorAttributeName:[UIColor yellowColor],
                           NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Bold" size:17]};
    
    NSNumber *deficit = [[BGAlgorithmModel sharedInstance] getDeficit];
    //NSLog(@"Deficit value is:%f", [deficit floatValue]);
    NSString *deficitType;
    NSString *units = [Utilities getUnitsForBG];
    NSString *hA1cUnits = @"%";
    NSString *unknownBG = @"???";
    
    NSMutableAttributedString *aString1 = [[NSMutableAttributedString new] initWithString:ACTION_STRING1 attributes:thin];
    NSAttributedString *aString2 = [[NSAttributedString new] initWithString:latestEstimatedHA1c attributes:bold];
    NSAttributedString *aString8 = [[NSAttributedString new] initWithString:[@" " stringByAppendingString:hA1cUnits] attributes:thin];
    
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
        [aString1 appendAttributedString:aString2];
        [aString1 appendAttributedString:aString8];

    } else {
        NSAttributedString *aString4 = [[NSAttributedString new] initWithString:ACTION_STRING2 attributes:thin];
        NSAttributedString *aString5 = [[NSAttributedString new] initWithString:deficitString attributes:bold];
        NSAttributedString *aString6 = [[NSAttributedString new] initWithString:deficitType attributes:thin];
        
        [aString1 appendAttributedString:aString2];
        [aString1 appendAttributedString:aString8];
        [aString1 appendAttributedString:aString4];
        [aString1 appendAttributedString:aString5];
        [aString1 appendAttributedString:aString6];
    }

    self.actionTextView.attributedText = aString1;
    self.actionTextView.textAlignment = NSTextAlignmentCenter;
    if ([bgCurrentForTest doubleValue] < 1.7) {
        NSLog(@"mmol/L");
        NSMutableAttributedString *aString9 = [[NSMutableAttributedString new] initWithString:unknownBG attributes:thinBig];
        NSAttributedString *aString3 = [[NSAttributedString new] initWithString:[@" " stringByAppendingString:units] attributes:thin];
        [aString9 appendAttributedString:aString3];
        self.bgTextView.attributedText = aString9;
        self.bgTextView.textAlignment = NSTextAlignmentCenter;

    } else {
        NSLog(@"mg/dL");
        NSMutableAttributedString *bString = [[NSMutableAttributedString new] initWithString:bgCurrentString attributes:thinBig];
        NSAttributedString *aString3 = [[NSAttributedString new] initWithString:[@" " stringByAppendingString:units] attributes:thin];
        [bString appendAttributedString:aString3];
        self.bgTextView.attributedText = bString;
        self.bgTextView.textAlignment = NSTextAlignmentCenter;
    }
    
}

@end
