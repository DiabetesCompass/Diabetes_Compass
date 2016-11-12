//
//  EditItemViewController.m
//  BG Compass
//
//  Created by Jose Carrillo and Christopher Balcells on 3/1/14.
//  Copyright (c) 2014 Clif Alferness. All rights reserved.
//

#import "EditItemViewController.h"
#import <EFCircularSlider.h>
#import "Constants.h"
#import "FoodReading.h"
#import "BGReading.h"
#import "InsulinReading.h"
#import "BGAlgorithmModel.h"

@interface EditItemViewController ()

@property (nonatomic, assign) BOOL doneButtonClicked;
@property (strong, nonatomic) EFCircularSlider* valueSlider;

@property (strong, nonatomic) EFCircularSlider* carbsSlider;
@property (strong, nonatomic) NSDate *date;


@end

@implementation EditItemViewController

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
    [self.view setBackgroundColor:[UIColor clearColor]];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    
    if (self.editingMode) {
        self.title = @"Edit";
        self.date = ((Reading*)self.item).timeStamp;
    } else {
        self.title = @"New";
        self.date = [NSDate new];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM d, yyyy     h:mm a"];
    [self.dateButton setTitle:[dateFormatter stringFromDate:self.date] forState:UIControlStateNormal];
    
    self.titleLabel.text = ((Reading*)self.item).name;
    self.titleLabel.delegate = self;
    self.titleLabel.returnKeyType = UIReturnKeyDone;
    UIColor *color = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
    self.titleLabel.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Click to edit name..." attributes:@{NSForegroundColorAttributeName: color}];
    //UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    //[self.view addGestureRecognizer:singleTap];
    
    
//    CGRect bigSlider;
//    CGRect smallSlider;
//    
//    if([[NSUserDefaults standardUserDefaults] floatForKey:SETTING_SCREEN_CONSTANT] == 1) {
//        smallSlider = CGRectMake((320-170)/2, 160, 170, 170);
//        bigSlider = CGRectMake((320-270)/2, 110, 270, 270);
//    } else {
//        smallSlider = CGRectMake((320-130)/2, 140, 130, 130);
//        bigSlider = CGRectMake((320-220)/2, 95, 220, 220);
//    }
    
    
    if ([self.item isKindOfClass:[BGReading class]]) {
        //self.valueSlider = [[EFCircularSlider alloc] initWithFrame:bigSlider];
        [self generateBGForm];
    } else if ([self.item isKindOfClass:[InsulinReading class]]) {
        //self.valueSlider = [[EFCircularSlider alloc] initWithFrame:bigSlider];
        [self generateInsulinForm];
    } else if ([self.item isKindOfClass:[FoodReading class]]) {
        //self.valueSlider = [[EFCircularSlider alloc] initWithFrame:smallSlider];
        //self.carbsSlider = [[EFCircularSlider alloc] initWithFrame:bigSlider];
        [self generateFoodForm];
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.blur blurInAnimationWithDuration:0.25];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.doneButtonClicked = NO;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.doneButtonClicked == NO && self.editingMode == NO) {
        [self.item MR_deleteEntity];
    }
}

- (void)generateBGForm {
    
    /*self.valueSlider.minimumValue = 0.0;
    self.valueSlider.lineWidth = 6;
    self.valueSlider.handleColor = [UIColor colorWithRed:1.0 green:64.0/255.0 blue:67.0/255.0 alpha:0.9];
    self.valueSlider.handleType = EFDoubleCircleWithOpenCenter;
    self.valueSlider.unfilledColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
    self.valueSlider.filledColor = [UIColor colorWithRed:1.0 green:64.0/255.0 blue:67.0/255.0 alpha:0.9];
    self.valueSlider.labelFont = [UIFont fontWithName:@"HelveticaNeue" size:13];
    self.valueSlider.labelColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    [self.valueSlider addTarget:self action:@selector(newValue:) forControlEvents:UIControlEventValueChanged];
    
    NSMutableArray *labelsArray = [NSMutableArray new];
    if([[NSUserDefaults standardUserDefaults] boolForKey:SETTING_UNITS_IN_MOLES]) {
        self.valueSlider.maximumValue = 300.0/CONVERSIONFACTOR;
        [self.valueSlider setCurrentValue:[((BGReading*)self.item).quantity floatValue]];
        self.valueUnitsLabel.text = @"mmol/L";
        for(int i=1; i<11; i++) {
            [labelsArray addObject:[NSString stringWithFormat:@"%.0f", i*30.0/CONVERSIONFACTOR]];
        }
    } else {
        self.valueSlider.maximumValue = 300;
        [self.valueSlider setCurrentValue:[((BGReading*)self.item).quantity floatValue]*CONVERSIONFACTOR];
        self.valueUnitsLabel.text = @"mg/dL";
        for(int i=1; i<11; i++) {
            [labelsArray addObject:[NSString stringWithFormat:@"%.0f", i*30.0]];
        }
    }*/
    if([[NSUserDefaults standardUserDefaults] boolForKey:SETTING_UNITS_IN_MOLES]) {
        self.valueUnitsLabel.text = @"mmol/L";
    } else {
        self.valueUnitsLabel.text = @"mg/dL";
    }
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:SETTING_UNITS_IN_MOLES]) {
        self.valueField.text = [NSString stringWithFormat:@"%.1f", [((BGReading*)self.item).quantity floatValue]];
    } else {
        self.valueField.text = [NSString stringWithFormat:@"%.0f", [((BGReading*)self.item).quantity floatValue]*CONVERSIONFACTOR];
    }
    
    self.valueTitleLabel.text = @"Glucose";
    self.carbsTitleLabel.hidden = YES;
    self.carbsUnitsLabel.hidden = YES;
    self.carbsField.hidden = YES;
    [self.valueField becomeFirstResponder];
    
    //[self.valueSlider setInnerMarkingLabels:labelsArray];
    //[self.view addSubview:self.valueSlider];
}

- (void)generateFoodForm {
    
    
    /*self.valueSlider.minimumValue = 0.0;
    self.valueSlider.maximumValue = 5;
    self.valueSlider.lineWidth = 6;
    self.valueSlider.handleColor = [UIColor colorWithRed:1.0 green:64.0/255.0 blue:67.0/255.0 alpha:0.9];
    self.valueSlider.handleType = EFDoubleCircleWithOpenCenter;
    self.valueSlider.unfilledColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
    self.valueSlider.filledColor = [UIColor colorWithRed:1.0 green:64.0/255.0 blue:67.0/255.0 alpha:0.9];
    self.valueSlider.labelFont = [UIFont fontWithName:@"HelveticaNeue" size:13];
    self.valueSlider.labelColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    [self.valueSlider addTarget:self action:@selector(newValue:) forControlEvents:UIControlEventValueChanged];

    NSArray* labelsArray = @[@"1", @"2", @"3", @"4", @"5"];
    
    [self.valueSlider setInnerMarkingLabels:labelsArray];
    
    
    self.carbsSlider.minimumValue = 0.0;
    self.carbsSlider.maximumValue = 300;
    self.carbsSlider.snapToLabels = NO;
    self.carbsSlider.lineWidth = 8;
    
    self.carbsSlider.handleColor = [UIColor colorWithRed:29.0/255.0 green:207.0/255.0 blue:0.0 alpha:1.0];
    self.carbsSlider.handleType = EFDoubleCircleWithOpenCenter;
    self.carbsSlider.unfilledColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
    self.carbsSlider.filledColor = [UIColor colorWithRed:29.0/255.0 green:207.0/255.0 blue:0.0 alpha:1.0];
    self.carbsSlider.labelFont = [UIFont fontWithName:@"HelveticaNeue" size:13];
    self.carbsSlider.labelColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    [self.carbsSlider addTarget:self action:@selector(newCarbsValue:) forControlEvents:UIControlEventValueChanged];

    
    NSMutableArray *labelsArray2 = [NSMutableArray new];
    for(int i=1; i<11; i++) {
        [labelsArray2 addObject:[NSString stringWithFormat:@"%i", i*30]];
    }
    
    [self.carbsSlider setInnerMarkingLabels:labelsArray2];
    [self.view addSubview:self.carbsSlider];
    [self.view addSubview:self.valueSlider];
    
    [self.valueSlider setCurrentValue:[((FoodReading*)self.item).numberOfServings floatValue]];
    [self.carbsSlider setCurrentValue:[((FoodReading*)self.item).carbs floatValue]];
    */
    
    self.valueField.text = [((FoodReading*)self.item).numberOfServings stringValue];
    self.valueField.text = [NSString stringWithFormat:@"%.1f", [((FoodReading*)self.item).numberOfServings floatValue]];
    self.valueTitleLabel.text = @"Servings";
    NSString *units = ((FoodReading*)self.item).servingUnitAndQuantity;
    if (units.length == 0) {
        self.valueUnitsLabel.text = @"Manual Entry";
    } else {
        self.valueUnitsLabel.text = ((FoodReading*)self.item).servingUnitAndQuantity;
    }
    
    self.carbsTitleLabel.hidden = NO;
    self.carbsUnitsLabel.hidden = NO;
    self.carbsField.hidden = NO;
    
    self.carbsField.text = [NSString stringWithFormat:@"%.0f", [((FoodReading*)self.item).carbs floatValue]];
    [self.carbsField becomeFirstResponder];
    
}

- (void)generateInsulinForm {
    
    /*self.valueSlider.minimumValue = 0.0;
    self.valueSlider.lineWidth = 6;
    self.valueSlider.handleColor = [UIColor colorWithRed:67.0/255.0 green:64.0/255.0 blue:1 alpha:0.9];
    self.valueSlider.handleType = EFDoubleCircleWithOpenCenter;
    self.valueSlider.unfilledColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
    self.valueSlider.filledColor = [UIColor colorWithRed:67.0/255.0 green:64.0/255.0 blue:1 alpha:0.9];
    self.valueSlider.labelFont = [UIFont fontWithName:@"HelveticaNeue" size:13];
    self.valueSlider.labelColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    [self.valueSlider addTarget:self action:@selector(newValue:) forControlEvents:UIControlEventValueChanged];
    
    NSMutableArray *labelsArray = [NSMutableArray new];
    
    self.valueSlider.maximumValue = 300.0/18.0;
    [self.valueSlider setCurrentValue:[((InsulinReading*)self.item).quantity floatValue]];
    for(int i=1; i<11; i++) {
        [labelsArray addObject:[NSString stringWithFormat:@"%i", i*1]];
    }
    */

    NSArray* InsulinMappingArray = @[INSULINTYPE_STRING_REGULAR, INSULINTYPE_STRING_GLULISINE, INSULINTYPE_STRING_LISPRO, INSULINTYPE_STRING_ASPART];
// TODO: fix me this array should be placed somewhere else. Some sort of constants place. Also located in SettingsController.m
    if (self.editingMode) {
        self.valueField.text = [NSString stringWithFormat:@"%.2f", [((InsulinReading*)self.item).quantity floatValue]];
        self.valueTitleLabel.text = [@"Insulin - " stringByAppendingString:[InsulinMappingArray objectAtIndex:((InsulinReading*)self.item).insulinType.intValue]];
    } else {
        /* 
        float deficit = [[[BGAlgorithmModel sharedInstance] getDeficit] floatValue];
        // Use this code to default the insulin dose to the deficit.
        if (deficit < 0) {
            self.valueField.text = [NSString stringWithFormat:@"%.2f", -1*deficit];
        } else {
            self.valueField.text = @"0";
        }*/
        self.valueField.text = @"0";
        self.valueTitleLabel.text = [@"Insulin - " stringByAppendingString:[InsulinMappingArray objectAtIndex:[[NSUserDefaults standardUserDefaults] integerForKey:SETTING_INSULIN_TYPE]]];
    }
    
    self.valueUnitsLabel.text = @"Insulin Units";
    self.carbsTitleLabel.hidden = YES;
    self.carbsUnitsLabel.hidden = YES;
    self.carbsField.hidden = YES;
    [self.valueField becomeFirstResponder];
    //[self.valueSlider setInnerMarkingLabels:labelsArray];
    //[self.view addSubview:self.valueSlider];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) newValue:(EFCircularSlider*)sender {
    if([[NSUserDefaults standardUserDefaults] boolForKey:SETTING_UNITS_IN_MOLES]) {
        self.valueField.text = [NSString stringWithFormat:@"%.1f", sender.currentValue];
    } else {
        self.valueField.text = [NSString stringWithFormat:@"%.0f", sender.currentValue];
    }
}

- (void) newCarbsValue:(EFCircularSlider*)sender {
    self.carbsField.text = [NSString stringWithFormat:@"%.0f", sender.currentValue];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField endEditing:YES];
    [self.valueField becomeFirstResponder];
    return NO;
}


- (void) saveFood:(FoodReading*)food asNew:(BOOL)isNew {
    food.name = self.titleLabel.text;
    food.carbs = [NSNumber numberWithFloat:[self.carbsField.text floatValue]];
    food.timeStamp = self.date;
    food.numberOfServings = [NSNumber numberWithFloat:[self.valueField.text floatValue]];
    //food.servingUnitAndQuantity = self.servingSizeItem.value;
    if (isNew) {
        food.isPending = [NSNumber numberWithBool:YES];
    }
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

- (void) saveBG:(BGReading*)bg asNew:(BOOL)isNew {
    bg.name = @"Blood Glucose";
    if ([BGReading isInMoles]) {
        [bg setQuantity:[NSNumber numberWithFloat:[self.valueField.text floatValue]] withConversion:NO];
    } else {
        [bg setQuantity:[NSNumber numberWithFloat:[self.valueField.text floatValue]] withConversion:YES];
    }

    bg.timeStamp = self.date;
    bg.isPending = [NSNumber numberWithBool:NO];
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

- (void) saveInsulin:(InsulinReading*)insulin asNew:(BOOL)isNew {
    insulin.name = self.titleLabel.text;
    insulin.quantity = [NSNumber numberWithFloat:[self.valueField.text floatValue]];
    insulin.timeStamp = self.date;
    
    NSLog(@"%f", self.valueSlider.currentValue);
    if (isNew) {
        insulin.isPending = [NSNumber numberWithBool:YES];
        insulin.insulinType = @([[NSUserDefaults standardUserDefaults] integerForKey:SETTING_INSULIN_TYPE]);
    }
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}



- (IBAction)doneClicked:(id)sender {
    NSLocale *locale = [NSLocale currentLocale];
    NSDateFormatter *theDate = [NSDateFormatter new];
    [theDate setLocale:locale];
    [theDate setDateFormat:@"h:mm a MMMM d, yyyy"];
    
    
    self.doneButtonClicked = YES;
    if (self.editingMode) {
        
        if ([[self.item class] isSubclassOfClass:[BGReading class]]) {
            [self saveBG:self.item asNew:NO];
            NSDictionary *d = @{ @"timeStamp":((BGReading*)self.item).timeStamp };
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_BGREADING_EDITED object:nil userInfo:d];
        } else if ([[self.item class] isSubclassOfClass:[InsulinReading class]]) {
            [self saveInsulin:self.item asNew:NO];
            NSDictionary *d = @{ @"timeStamp":((InsulinReading*)self.item).timeStamp };
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_INSULINREADING_EDITED object:nil userInfo:d];
        } else if ([[self.item class] isSubclassOfClass:[FoodReading class]]) {
            [self saveFood:self.item asNew:NO];
            NSDictionary *d = @{ @"timeStamp":((FoodReading*)self.item).timeStamp };
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_FOODREADING_EDITED object:nil userInfo:d];
        }

        [self.navigationController popViewControllerAnimated:YES];
        
    } else {
        
        if ([[self.item class] isSubclassOfClass:[BGReading class]]) {
            [self saveBG:self.item asNew:YES];
            NSDictionary *d = @{ @"timeStamp":((BGReading*)self.item).timeStamp };
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_BGREADING_ADDED object:nil userInfo:d];
        } else if ([[self.item class] isSubclassOfClass:[InsulinReading class]]) {
            [self saveInsulin:self.item asNew:YES];
            NSDictionary *d = @{ @"timeStamp":((InsulinReading*)self.item).timeStamp };
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_INSULINREADING_ADDED object:nil userInfo:d];
        } else if ([[self.item class] isSubclassOfClass:[FoodReading class]]) {
            [self saveFood:self.item asNew:YES];
            NSDictionary *d = @{ @"timeStamp":((FoodReading*)self.item).timeStamp };
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_FOODREADING_ADDED object:nil userInfo:d];
        }
        
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)dateClicked:(id)sender {

//    RMDateSelectionViewController *dateSelectionVC = [RMDateSelectionViewController dateSelectionController];
//    dateSelectionVC.delegate = self;
//    [self.valueField resignFirstResponder];
//    [self.carbsField resignFirstResponder];
//    [dateSelectionVC show];
//    dateSelectionVC.datePicker.date = self.date;

    // https://github.com/CooperRS/RMDateSelectionViewController/wiki/Usage
    RMAction<UIDatePicker *> *selectAction =
        [RMAction<UIDatePicker *> actionWithTitle:@"Select"
                                            style:RMActionStyleDone
                                       andHandler:^(RMActionController<UIDatePicker *> *controller) {
               NSLog(@"Successfully selected date: %@", controller.contentView.date);
                                       }];

    RMAction<UIDatePicker *> *cancelAction =
        [RMAction<UIDatePicker *> actionWithTitle:@"Cancel"
                                            style:RMActionStyleCancel
                                       andHandler:^(RMActionController<UIDatePicker *> *controller) {
                                           NSLog(@"Date selection was canceled");
                                       }];

    RMDateSelectionViewController *dateSelectionController =
    [RMDateSelectionViewController actionControllerWithStyle:RMActionControllerStyleWhite
                                                       title:@"Test"
                                                     message:@"This is a test message.\nPlease choose a date and press 'Select' or 'Cancel'."
                                                selectAction:selectAction
                                             andCancelAction:cancelAction];

    //Now just present the date selection controller using the standard iOS presentation method
    [self presentViewController:dateSelectionController animated:YES completion:nil];
}

@end
