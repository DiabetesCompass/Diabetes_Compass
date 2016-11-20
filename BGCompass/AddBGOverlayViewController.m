//
//  AddBGOverlayViewController.m
//  Compass
//
//  Created by Jose Carrillo and Christopher Balcells on 2/26/14.
//  Copyright (c) 2014 Clif Alferness. All rights reserved.
//

#import "AddBGOverlayViewController.h"
#import <EFCircularSlider.h>
#import "Constants.h"
#import "BGReading.h"

@interface AddBGOverlayViewController ()

@property (weak, nonatomic) EFCircularSlider *circularSlider;
@property (weak, nonatomic) UILabel *bgValue;

@end

@implementation AddBGOverlayViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.needBGTitle.textColor = [UIColor whiteColor];
    
    
    UILabel *bgUnits;
    UILabel *bgValue;
    float screenConstant = [[NSUserDefaults standardUserDefaults] floatForKey:SETTING_SCREEN_CONSTANT];
    
    EFCircularSlider* circularSlider;
    if (screenConstant == 1) {
        bgValue = [[UILabel alloc] initWithFrame:CGRectMake((320-200)/2, 270, 200, 60)];
        bgUnits = [[UILabel alloc] initWithFrame:CGRectMake((320-200)/2, 270, 200, 200)];
        circularSlider = [[EFCircularSlider alloc] initWithFrame:CGRectMake((320-270)/2, 170, 270, 270)];
    } else {
        bgValue = [[UILabel alloc] initWithFrame:CGRectMake((320-200)/2, 215, 200, 60)];
        bgUnits = [[UILabel alloc] initWithFrame:CGRectMake((320-200)/2, 210, 200, 200)];
        circularSlider = [[EFCircularSlider alloc] initWithFrame:CGRectMake((320-230)/2, 140, 230, 230)];
    }
    
    [circularSlider addTarget:self action:@selector(newValue:) forControlEvents:UIControlEventValueChanged];
    circularSlider.minimumValue = 0.0f;
    circularSlider.lineWidth = 6;
    circularSlider.unfilledColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
    circularSlider.handleColor = [UIColor colorWithRed:1.0 green:64.0/255.0 blue:67.0/255.0 alpha:0.9];
    //circularSlider.handleType = EFDoubleCircleWithOpenCenter;
    circularSlider.filledColor = [UIColor colorWithRed:1.0 green:64.0/255.0 blue:67.0/255.0 alpha:0.9];
    circularSlider.labelFont = [UIFont fontWithName:@"HelveticaNeue" size:13];
    circularSlider.labelColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    self.circularSlider = circularSlider;
    
    
    bgValue.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:60];
    bgValue.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
    bgValue.textAlignment = NSTextAlignmentCenter;
    self.bgValue = bgValue;
    
    
    bgUnits.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20];
    bgUnits.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    bgUnits.backgroundColor = [UIColor clearColor];
    bgUnits.numberOfLines = 1;
    bgUnits.textAlignment = NSTextAlignmentCenter;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:SETTING_UNITS_IN_MOLES]) {
        bgUnits.text = @"mmol/L";
        bgValue.text = [NSString stringWithFormat:@"%.2f", circularSlider.currentValue];
        circularSlider.maximumValue = 300.0/18.0;
        
        NSMutableArray *labelsArray = [NSMutableArray new];
        for(int i=1; i<11; i++) {
            [labelsArray addObject:[NSString stringWithFormat:@"%.0f", i*30.0/18.0]];
        }
        [circularSlider setInnerMarkingLabels:labelsArray];
        
    } else {
        bgUnits.text = @"mg/dL";
        bgValue.text = [NSString stringWithFormat:@"%.0f", circularSlider.currentValue];
        circularSlider.maximumValue = 300.0;
        
        NSMutableArray *labelsArray = [NSMutableArray new];
        for(int i=1; i<11; i++) {
            [labelsArray addObject:[NSString stringWithFormat:@"%.0f", i*30.0]];
        }
        [circularSlider setInnerMarkingLabels:labelsArray];
    }
    
    
    [self.view addSubview:circularSlider];
    [self.view addSubview:bgUnits];
    [self.view addSubview:bgValue];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.blur blurInAnimationWithDuration:0.5];
}

- (void) newValue:(EFCircularSlider*) slider {
    if([[NSUserDefaults standardUserDefaults] boolForKey:SETTING_UNITS_IN_MOLES]) {
        self.bgValue.text = [NSString stringWithFormat:@"%.1f", slider.currentValue];
    } else {
        self.bgValue.text = [NSString stringWithFormat:@"%.0f", slider.currentValue];
    }
}

- (IBAction)showTrends:(id)sender {
}

- (IBAction)showHistory:(id)sender {
}

- (IBAction)saveBG:(id)sender {
    NSNumberFormatter * f = [NSNumberFormatter new];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    
    BGReading *bg = [BGReading MR_createEntity];
    bg.name = @"Blood Glucose";
    [bg setQuantity:[NSNumber numberWithFloat:self.circularSlider.currentValue] withConversion:![[NSUserDefaults standardUserDefaults]boolForKey:SETTING_UNITS_IN_MOLES]];
    bg.timeStamp = [NSDate date];
    bg.isPending = [NSNumber numberWithBool:NO];
    
    
    NSDictionary *d = @{ @"timeStamp":bg.timeStamp };
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_BGREADING_ADDED object:nil userInfo:d];
    
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError* error) {
        success ?: NSLog(@"%@", error);
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
@end
