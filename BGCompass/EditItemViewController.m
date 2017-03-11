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

#pragma mark - view

- (void)viewDidLoad {
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
    
    [self configureDateButton:self.date];
    
    self.titleLabel.text = ((Reading*)self.item).name;
    self.titleLabel.delegate = self;
    self.titleLabel.returnKeyType = UIReturnKeyDone;
    UIColor *color = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
    self.titleLabel.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Click to edit name..." attributes:@{NSForegroundColorAttributeName: color}];
    
    if ([self.item isKindOfClass:[BGReading class]]) {
        [self generateBGForm];
    } else if ([self.item isKindOfClass:[InsulinReading class]]) {
        [self generateInsulinForm];
    } else if ([self.item isKindOfClass:[FoodReading class]]) {
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

#pragma mark - date

- (void)configureDateButton:(NSDate *)date {
    [self.dateButton setTitle:[EditItemViewController dateStringFromDate:date]
                     forState:UIControlStateNormal];
}

+ (NSString *)dateStringFromDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM d, yyyy     h:mm a"];
    return [dateFormatter stringFromDate:date];
}

#pragma mark - forms

- (void)generateBGForm {
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:SETTING_SHOULD_DISPLAY_BG_IN_MMOL_PER_L]) {
        self.valueUnitsLabel.text = @"mmol/L";
    } else {
        self.valueUnitsLabel.text = @"mg/dL";
    }
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:SETTING_SHOULD_DISPLAY_BG_IN_MMOL_PER_L]) {
        self.valueField.text = [NSString stringWithFormat:@"%.1f", [((BGReading*)self.item).quantity floatValue]];
    } else {
        self.valueField.text = [NSString stringWithFormat:@"%.0f", [((BGReading*)self.item).quantity floatValue] * MG_PER_DL_PER_MMOL_PER_L];
    }
    
    self.valueTitleLabel.text = @"Glucose";
    self.carbsTitleLabel.hidden = YES;
    self.carbsUnitsLabel.hidden = YES;
    self.carbsField.hidden = YES;
    [self.valueField becomeFirstResponder];
}

- (void)generateFoodForm {
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

    NSArray* InsulinMappingArray = @[INSULINTYPE_STRING_REGULAR, INSULINTYPE_STRING_GLULISINE, INSULINTYPE_STRING_LISPRO, INSULINTYPE_STRING_ASPART];
// TODO: fix me this array should be placed somewhere else. Some sort of constants place. Also located in SettingsController.m
    if (self.editingMode) {
        self.valueField.text = [NSString stringWithFormat:@"%.2f", [((InsulinReading*)self.item).quantity floatValue]];
        self.valueTitleLabel.text = [@"Insulin - " stringByAppendingString:[InsulinMappingArray objectAtIndex:((InsulinReading*)self.item).insulinType.intValue]];
    } else {
        self.valueField.text = @"0";
        self.valueTitleLabel.text = [@"Insulin - " stringByAppendingString:[InsulinMappingArray objectAtIndex:[[NSUserDefaults standardUserDefaults] integerForKey:SETTING_INSULIN_TYPE]]];
    }
    
    self.valueUnitsLabel.text = @"Insulin Units";
    self.carbsTitleLabel.hidden = YES;
    self.carbsUnitsLabel.hidden = YES;
    self.carbsField.hidden = YES;
    [self.valueField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) newValue:(EFCircularSlider*)sender {
    if([[NSUserDefaults standardUserDefaults] boolForKey:SETTING_SHOULD_DISPLAY_BG_IN_MMOL_PER_L]) {
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
    if (isNew) {
        food.isPending = [NSNumber numberWithBool:YES];
    }
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

- (void) saveBG:(BGReading*)bg asNew:(BOOL)isNew {
    bg.name = @"Blood Glucose";
    if ([BGReading shouldDisplayBgInMmolPerL]) {
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
            //This would be a good place to test the BG value to see if it is in a reasonable range and offer a way to abort or go back.
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

    [self.valueField resignFirstResponder];
    [self.carbsField resignFirstResponder];

    // https://github.com/CooperRS/RMDateSelectionViewController/wiki/Usage
    RMAction<UIDatePicker *> *selectAction = [RMAction<UIDatePicker *>
                                              actionWithTitle:@"Select"
                                              style:RMActionStyleDone
                                              andHandler:^(RMActionController<UIDatePicker *> *controller) {
                                                  self.date = controller.contentView.date;
                                                  [self configureDateButton:self.date];
                                              }];

    RMAction<UIDatePicker *> *cancelAction = [RMAction<UIDatePicker *>
                                              actionWithTitle:@"Cancel"
                                              style:RMActionStyleCancel
                                              andHandler:^(RMActionController<UIDatePicker *> *controller) {
                                                  //NSLog(@"Date selection was canceled");
                                              }];

    RMDateSelectionViewController *dateSelectionController =
    [RMDateSelectionViewController actionControllerWithStyle:RMActionControllerStyleWhite
                                                       title:nil
                                                     message:nil
                                                selectAction:selectAction
                                             andCancelAction:cancelAction];

    dateSelectionController.datePicker.date = self.date;

    //Now just present the date selection controller using the standard iOS presentation method
    [self presentViewController:dateSelectionController animated:YES completion:nil];
}

@end
