//
//  EditTableViewController.m
//  BG Compass
//
//  Created by Jose Carrillo and Christopher Balcells on 11/29/13.
//  Copyright (c) 2013 Clif Alferness. All rights reserved.
//

#import "EditTableViewController.h"
#import "FoodReading.h"
#import "BGReading.h"
#import "InsulinReading.h"
#import "Constants.h"
#import "ItemsNavigationViewController.h"
#import <FontAwesome+iOS/NSString+FontAwesome.h>

@interface EditTableViewController ()


@property (strong, readwrite, nonatomic) RETableViewItem *typeItem;
@property (strong, readwrite, nonatomic) RETextItem *nameItem;
@property (strong, readwrite, nonatomic) REDateTimeItem *dateTimeItem;
@property (strong, readwrite, nonatomic) RETextItem *numberOfServingsItem;
@property (strong, readwrite, nonatomic) RETextItem *valueItem;
@property (strong, readwrite, nonatomic) RETextItem *servingSizeItem;
@property (strong, readwrite, nonatomic) RETextItem *carbsItem;

@end

@implementation EditTableViewController

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
    [self.navigationController setNavigationBarHidden:NO animated:NO];

    self.manager = [[RETableViewManager alloc] initWithTableView:self.tableView];
    
    if ([self.item isKindOfClass:[FoodReading class]]) {
        [self generateFoodReadingForm];
    } else if ([self.item isKindOfClass:[BGReading class]]) {
        [self generateBGReadingForm];
    } else {
        [self generateInsulinReadingForm];
    }
    
    if (self.editingMode) {
        self.title = @"Edit";
    } else {
        self.title = @"New";
    }
    
    [self.doneButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"icon-ok"]];
    [self.doneButton setTitleTextAttributes:@{
                                              NSFontAttributeName: [UIFont fontWithName:kFontAwesomeFamilyName size:26.0],
                                              NSForegroundColorAttributeName: [UIColor whiteColor]
                                              } forState:UIControlStateNormal];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [((ItemsNavigationViewController*)self.navigationController).blur blurInAnimationWithDuration:0.25];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.doneButtonClicked == NO && self.editingMode == NO) {
        [self.item MR_deleteEntity];
    }
    
    if ([self.item isKindOfClass:[FoodReading class]]) {
        // [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) generateFoodReadingForm {
    
    FoodReading *food = self.item;
    NSDate *date;
    RETableViewSection *section;
    
    if (self.editingMode) {
        date = food.timeStamp;
        section = [RETableViewSection sectionWithHeaderTitle:@"Edit Reading"];
    } else {
        date = [NSDate date];
        section = [RETableViewSection sectionWithHeaderTitle:@"New Reading"];
    }
    [self.manager addSection:section];
    
    
    RETableViewSection *section2 = [RETableViewSection sectionWithHeaderTitle:@""];
    [self.manager addSection:section2];
    
    RETableViewSection *section3 = [RETableViewSection sectionWithHeaderTitle:@""];
    [self.manager addSection:section3];
    
    self.nameItem = [RETextItem itemWithTitle:@"Name" value:food.name placeholder:nil];
    self.typeItem = [RETableViewItem itemWithTitle:@"Type"];
    self.typeItem.detailLabelText = @"Food";
    self.typeItem.style = UITableViewCellStyleValue1;
    self.typeItem.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    
    /*self.typeItem.onChange = ^(REPickerItem *item){
     NSLog(@"Value: %@", item.value);
     };*/
    
    self.dateTimeItem = [REDateTimeItem itemWithTitle:@"Date" value:date placeholder:nil format:@"MMMM d, yyyy h:mm a" datePickerMode:UIDatePickerModeDateAndTime];
    
    self.numberOfServingsItem = [RETextItem itemWithTitle:@"Number of Servings" value:[food.numberOfServings stringValue] placeholder:nil];
    self.servingSizeItem = [RETextItem itemWithTitle:@"Serving Size" value:food.servingUnitAndQuantity placeholder:nil];
    self.carbsItem = [RETextItem itemWithTitle:@"Carbs per Serving" value:[food.carbs stringValue] placeholder:nil];
    self.numberOfServingsItem.keyboardType = UIKeyboardTypeDecimalPad;
    self.servingSizeItem.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    self.carbsItem.keyboardType = UIKeyboardTypeDecimalPad;
    
    if (REUIKitIsFlatMode()) {
        self.dateTimeItem.inlineDatePicker = YES;
    }
    
    
    [section addItem:self.typeItem];
    [section2 addItem:self.nameItem];
    [section2 addItem:self.dateTimeItem];
    [section3 addItem:self.numberOfServingsItem];
    [section3 addItem:self.carbsItem];
    [section3 addItem:self.servingSizeItem];
    
}

- (void) generateBGReadingForm {
    
    BGReading *bg = self.item;
    NSDate *date;
    RETableViewSection *section;
    
    if (self.editingMode) {
        date = bg.timeStamp;
        section = [RETableViewSection sectionWithHeaderTitle:@"Edit Reading"];
    } else {
        date = [NSDate date];
        section = [RETableViewSection sectionWithHeaderTitle:@"New Reading"];
    }
    
    [self.manager addSection:section];
    
    RETableViewSection *section2 = [RETableViewSection sectionWithHeaderTitle:@""];
    [self.manager addSection:section2];
    
    RETableViewSection *section3 = [RETableViewSection sectionWithHeaderTitle:@""];
    [self.manager addSection:section3];
    
    self.nameItem = [RETextItem itemWithTitle:@"Name" value:bg.name placeholder:nil];
    self.typeItem = [RETableViewItem itemWithTitle:@"Type"];
    self.typeItem.detailLabelText = @"Blood Glucose";
    self.typeItem.style = UITableViewCellStyleValue1;
    self.typeItem.selectionStyle = UITableViewCellSelectionStyleNone;
    
    /*self.typeItem.onChange = ^(REPickerItem *item){
     NSLog(@"Value: %@", item.value);
     };*/
    
    self.dateTimeItem = [REDateTimeItem itemWithTitle:@"Date" value:date placeholder:nil format:@"MMMM d, yyyy h:mm a" datePickerMode:UIDatePickerModeDateAndTime];
    
    self.valueItem = [RETextItem itemWithTitle:@"Value" value:bg.itemValue placeholder:nil];
    self.valueItem.keyboardType = UIKeyboardTypeDecimalPad;
    
    if (REUIKitIsFlatMode()) {
        self.dateTimeItem.inlineDatePicker = YES;
    }
    
    
    [section addItem:self.typeItem];
    [section2 addItem:self.nameItem];
    [section2 addItem:self.dateTimeItem];
    [section3 addItem:self.valueItem];
}

- (void) generateInsulinReadingForm {
    BGReading *insulin = self.item;
    NSDate *date;
    RETableViewSection *section;
    
    if (self.editingMode) {
        date = insulin.timeStamp;
        section = [RETableViewSection sectionWithHeaderTitle:@"Edit Reading"];
    } else {
        date = [NSDate date];
        section = [RETableViewSection sectionWithHeaderTitle:@"New Reading"];
    }
    
    [self.manager addSection:section];
    
    RETableViewSection *section2 = [RETableViewSection sectionWithHeaderTitle:@""];
    [self.manager addSection:section2];
    
    RETableViewSection *section3 = [RETableViewSection sectionWithHeaderTitle:@""];
    [self.manager addSection:section3];
    
    self.nameItem = [RETextItem itemWithTitle:@"Name" value:insulin.name placeholder:nil];
    self.typeItem = [RETableViewItem itemWithTitle:@"Type"];
    self.typeItem.detailLabelText = @"Insulin";
    self.typeItem.style = UITableViewCellStyleValue1;
    self.typeItem.selectionStyle = UITableViewCellSelectionStyleNone;
    
    /*self.typeItem.onChange = ^(REPickerItem *item){
     NSLog(@"Value: %@", item.value);
     };*/
    
    self.dateTimeItem = [REDateTimeItem itemWithTitle:@"Date" value:date placeholder:nil format:@"MMMM d, yyyy h:mm a" datePickerMode:UIDatePickerModeDateAndTime];
    
    self.valueItem = [RETextItem itemWithTitle:@"Value" value:insulin.itemValue placeholder:nil];
    self.valueItem.keyboardType = UIKeyboardTypeDecimalPad;
    
    if (REUIKitIsFlatMode()) {
        self.dateTimeItem.inlineDatePicker = YES;
    }
    
    
    [section addItem:self.typeItem];
    [section2 addItem:self.nameItem];
    [section2 addItem:self.dateTimeItem];
    [section3 addItem:self.valueItem];
}

- (IBAction)finishedEditing:(id)sender {
    NSLocale *locale = [NSLocale currentLocale];
    NSDateFormatter *theDate = [NSDateFormatter new];
    [theDate setLocale:locale];
    [theDate setDateFormat:@"h:mm a MMMM d, yyyy"];
    
    
    self.doneButtonClicked = YES;
    if (self.editingMode) {
        
        if ([[self.item class] isSubclassOfClass:[BGReading class]]) {
            [self saveBG:self.item asNew:NO];
        } else if ([[self.item class] isSubclassOfClass:[InsulinReading class]]) {
            [self saveInsulin:self.item asNew:NO];
        } else if ([[self.item class] isSubclassOfClass:[FoodReading class]]) {
            [self saveFood:self.item asNew:NO];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
        
    } else {
        
        if ([[self.item class] isSubclassOfClass:[BGReading class]]) {
            [self saveBG:self.item asNew:YES];
        } else if ([[self.item class] isSubclassOfClass:[InsulinReading class]]) {
            [self saveInsulin:self.item asNew:YES];
        } else if ([[self.item class] isSubclassOfClass:[FoodReading class]]) {
            [self saveFood:self.item asNew:YES];
        }
        
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    
}

- (void) saveFood:(FoodReading*)food asNew:(BOOL)isNew {
    food.name = self.nameItem.value;
    food.carbs = [NSNumber numberWithInt:[self.carbsItem.value intValue]];
    food.timeStamp = self.dateTimeItem.value;
    food.numberOfServings = [NSNumber numberWithFloat:[self.numberOfServingsItem.value floatValue]];
    food.servingUnitAndQuantity = self.servingSizeItem.value;
    
    if (isNew) {
        food.isPending = [NSNumber numberWithBool:YES];
        NSDictionary *d = @{ @"timeStamp":food.timeStamp };
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_FOODREADING_ADDED object:nil userInfo:d];
    } else {
        NSDictionary *d = @{ @"timeStamp":food.timeStamp };
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_FOODREADING_EDITED object:nil userInfo:d];
    }
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError* error) {
        success ?: NSLog(@"%@", error);
    }];
}

- (void) saveBG:(BGReading*)bg asNew:(BOOL)isNew {
    bg.name = @"Blood Glucose";
    [bg setQuantity:[NSNumber numberWithFloat:[self.valueItem.value floatValue]] withConversion:YES];
    bg.timeStamp = self.dateTimeItem.value;
    bg.isPending = [NSNumber numberWithBool:NO];
    
    if (isNew) {
        NSDictionary *d = @{ @"timeStamp":bg.timeStamp };
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_BGREADING_ADDED object:nil userInfo:d];
    } else {
        NSDictionary *d = @{ @"timeStamp":bg.timeStamp };
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_BGREADING_EDITED object:nil userInfo:d];
    }
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError* error) {
        success ?: NSLog(@"%@", error);
    }];
}

- (void) saveInsulin:(InsulinReading*)insulin asNew:(BOOL)isNew {
    insulin.name = @"Insulin";
    insulin.quantity = [NSNumber numberWithFloat:[self.valueItem.value floatValue]];
    insulin.timeStamp = self.dateTimeItem.value;
    
    if (isNew) {
        insulin.isPending = [NSNumber numberWithBool:YES];
        NSDictionary *d = @{ @"timeStamp":insulin.timeStamp };
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_INSULINREADING_ADDED object:nil userInfo:d];
    } else {
        NSDictionary *d = @{ @"timeStamp":insulin.timeStamp };
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_INSULINREADING_EDITED object:nil userInfo:d];
    }
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError* error) {
        success ?: NSLog(@"%@", error);
    }];
}

@end
