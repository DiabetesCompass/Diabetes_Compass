//
//  SettingsController.m
//  BG Compass
//
//  Created by Jose Carrillo and Christopher Balcells on 11/29/13.
//  Copyright (c) 2013 Clif Alferness. All rights reserved.
//

#import "SettingsController.h"
#import <FontAwesome+iOS/NSString+FontAwesome.h>
#import "Constants.h"
#import "Utilities.h"
#import "BGReading.h"
#import "TutorialTitleItem.h"
#import "TutorialTextItem.h"
#import "TutorialBoolItem.h"
#import "TutorialPickerItem.h"
#import "ItemsNavigationViewController.h"

#define MINIMUM_PRECISION 0.01
#define BG_MINIMUM_PRECISION 0.1

@interface SettingsController ()

@property (strong, readwrite, nonatomic) TutorialTextItem *insulinSensitivityItem;
@property (strong, readwrite, nonatomic) TutorialPickerItem *insulinTypeItem;
//@property (strong, readwrite, nonatomic) TutorialTextItem *insulinDurationItem;
@property (strong, readwrite, nonatomic) TutorialTextItem *carbohydrateSensitivityItem;
@property (strong, readwrite, nonatomic) TutorialTextItem *idealBGMaxItem;
@property (strong, readwrite, nonatomic) TutorialTextItem *idealBGMinItem;
@property (strong, readwrite, nonatomic) TutorialTextItem *ha1cConstantItem;
//@property (strong, readwrite, nonatomic) TutorialTextItem *ag15ConstantItem;
@property (strong, readwrite, nonatomic) TutorialBoolItem *useMoleUnitsItem;
@property (strong, readwrite, nonatomic) TutorialBoolItem *militaryTimeItem;

@property (nonatomic) BOOL insulinSensitivityDidChange;
@property (nonatomic) BOOL carbSensitivityDidChange;
@property (nonatomic) BOOL idealBGMaxDidChange;
@property (nonatomic) BOOL idealBGMinDidChange;

@end

@implementation SettingsController

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

    self.manager = [[RETableViewManager alloc] initWithTableView:self.tableView];
    [self setupSettingsPage];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.doneButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"icon-ok"]];
    [self.doneButton setTitleTextAttributes:@{
                                              NSFontAttributeName: [UIFont fontWithName:kFontAwesomeFamilyName size:26.0],
                                              NSForegroundColorAttributeName: [UIColor whiteColor]
                                              } forState:UIControlStateNormal];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController navigationBar].barTintColor = [UIColor colorWithRed:55.0/255.0 green:93.0/255.0 blue:140.0/255.0 alpha:1];
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [((ItemsNavigationViewController*)self.navigationController).blur blurInAnimationWithDuration:0.25];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setupSettingsPage {
    
    self.manager[@"TutorialTextItem"] = @"TutorialTextCell";
    self.manager[@"TutorialTitleItem"] = @"TutorialTitleCell";
    self.manager[@"TutorialPickerItem"] = @"TutorialPickerCell";
    self.manager[@"TutorialInlinePickerItem"] = @"TutorialInlinePickerCell";
    self.manager[@"TutorialBoolItem"] = @"TutorialBoolCell";
    
    RETableViewSection *insulinSection = [RETableViewSection sectionWithHeaderTitle:@""];
    RETableViewSection *carbsSection = [RETableViewSection sectionWithHeaderTitle:@""];
    RETableViewSection *bgSection = [RETableViewSection sectionWithHeaderTitle:@""];
    //RETableViewSection *trendsSection = [RETableViewSection sectionWithHeaderTitle:@""];
    RETableViewSection *miscellaneousSection = [RETableViewSection sectionWithHeaderTitle:@""];
    
    [self.manager addSection:insulinSection];
    [self.manager addSection:carbsSection];
    [self.manager addSection:bgSection];
    //[self.manager addSection:trendsSection];
    [self.manager addSection:miscellaneousSection];
    
    
    NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
    
    TutorialTitleItem  *insulinTitle = [TutorialTitleItem itemWithTitle:@"INSULIN"];
    TutorialTitleItem  *carbsTitle = [TutorialTitleItem  itemWithTitle:@"CARBOHYDRATES"];
    TutorialTitleItem  *bgTitle = [TutorialTitleItem  itemWithTitle:@"BLOOD GLUCOSE"];
    //TutorialTitleItem  *trendsTitle = [TutorialTitleItem  itemWithTitle:@"TRENDS"];
    TutorialTitleItem  *miscTitle = [TutorialTitleItem  itemWithTitle:@"MISCELLANEOUS SETTINGS"];
    
    self.insulinSensitivityItem = [TutorialTextItem itemWithTitle:@"Sensitivity" value:[Utilities createFormattedStringFromNumber:((NSNumber*)[settings valueForKey:SETTING_INSULIN_SENSITIVITY]) withNumberOfDecimalPlaces:2]];
    
    //self.insulinDurationItem = [TutorialTextItem itemWithTitle:@"Duration" value:[((NSNumber*)[settings valueForKey:SETTING_INSULIN_DURATION]) stringValue]];
    
    self.carbohydrateSensitivityItem = [TutorialTextItem itemWithTitle:@"Sensitivity" value:[Utilities createFormattedStringFromNumber:((NSNumber*)[settings valueForKey:SETTING_CARB_SENSITIVITY]) withNumberOfDecimalPlaces:2]];
    
    self.idealBGMaxItem = [TutorialTextItem itemWithTitle:@"Ideal Max" value:[Utilities createFormattedStringFromNumber:((NSNumber*)[settings valueForKey:SETTING_IDEALBG_MAX]) forReadingType:[BGReading class]]];
    self.idealBGMinItem = [TutorialTextItem itemWithTitle:@"Ideal Min" value:[Utilities createFormattedStringFromNumber:((NSNumber*)[settings valueForKey:SETTING_IDEALBG_MIN]) forReadingType:[BGReading class]]];
    
    //self.ha1cConstantItem = [TutorialTextItem itemWithTitle:@"HA1c Constant" value:[Utilities createFormattedStringFromNumber:((NSNumber*)[settings valueForKey:SETTING_HA1C_CONSTANT]) withNumberOfDecimalPlaces:1]];
    //self.ag15ConstantItem = [TutorialTextItem itemWithTitle:@"1,5AG Constant" value:[Utilities createFormattedStringFromNumber:((NSNumber*)[settings valueForKey:SETTING_15AG_CONSTANT]) withNumberOfDecimalPlaces:1]];
    
    self.useMoleUnitsItem = [TutorialBoolItem itemWithTitle:@"Use mmol/L" value:[settings boolForKey:SETTING_UNITS_IN_MOLES]];
    self.militaryTimeItem = [TutorialBoolItem itemWithTitle:@"Use 24 Hr clock" value:[settings boolForKey:SETTING_MILITARY_TIME]];
    
    NSArray* InsulinMappingArray = @[INSULINTYPE_STRING_REGULAR, INSULINTYPE_STRING_GLULISINE, INSULINTYPE_STRING_LISPRO, INSULINTYPE_STRING_ASPART];
// TODO: fix me this array should be placed somewhere else. Some sort of constants place. Also in EditItemViewController.m
    self.insulinTypeItem = [TutorialPickerItem itemWithTitle:@"Type" value:@[[InsulinMappingArray objectAtIndex:[settings integerForKey:SETTING_INSULIN_TYPE]]] placeholder:nil options:@[InsulinMappingArray]];
    
    self.insulinSensitivityItem.keyboardType = UIKeyboardTypeDecimalPad;
    self.insulinSensitivityItem.keyboardAppearance = UIKeyboardAppearanceDark;
    //self.insulinDurationItem.keyboardType = UIKeyboardTypeDecimalPad;
    //self.insulinDurationItem.keyboardAppearance = UIKeyboardAppearanceDark;
    self.carbohydrateSensitivityItem.keyboardType = UIKeyboardTypeDecimalPad;
    self.carbohydrateSensitivityItem.keyboardAppearance = UIKeyboardAppearanceDark;
    self.idealBGMinItem.keyboardType = UIKeyboardTypeDecimalPad;
    self.idealBGMinItem.keyboardAppearance = UIKeyboardAppearanceDark;
    self.idealBGMaxItem.keyboardType = UIKeyboardTypeDecimalPad;
    self.idealBGMaxItem.keyboardAppearance = UIKeyboardAppearanceDark;
    //self.ha1cConstantItem.keyboardType = UIKeyboardTypeDecimalPad;
    //self.ha1cConstantItem.keyboardAppearance = UIKeyboardAppearanceDark;
    //self.ag15ConstantItem.keyboardType = UIKeyboardTypeDecimalPad;
    //self.ag15ConstantItem.keyboardAppearance = UIKeyboardAppearanceDark;
    
    self.insulinTypeItem.inlinePicker = YES;
    __unsafe_unretained typeof(self) weakSelf = self;
    self.insulinSensitivityItem.onChange = ^(RETextItem* item) {
        weakSelf.insulinSensitivityDidChange = YES;
    };
    
    self.carbohydrateSensitivityItem.onChange = ^(RETextItem* item) {
        weakSelf.carbSensitivityDidChange = YES;
    };
    
    self.idealBGMaxItem.onChange = ^(RETextItem* item) {
        weakSelf.idealBGMaxDidChange = YES;
        NSLog(@"Change");
    };
    
    self.idealBGMinItem.onChange = ^(RETextItem* item) {
        weakSelf.idealBGMinDidChange = YES;
    };
    
    self.useMoleUnitsItem.switchValueChangeHandler = ^(REBoolItem *item) {
        if (item.value) {
            if (!weakSelf.insulinSensitivityDidChange) {
                weakSelf.insulinSensitivityItem.value = [NSString stringWithFormat:@"%.2f",[weakSelf.insulinSensitivityItem.value floatValue] / MG_PER_DL_PER_MMOL_PER_L];
            }
            
            if (!weakSelf.carbSensitivityDidChange) {
                weakSelf.carbohydrateSensitivityItem.value = [NSString stringWithFormat:@"%.2f",[weakSelf.carbohydrateSensitivityItem.value floatValue] / MG_PER_DL_PER_MMOL_PER_L];
            }
            
            if (!weakSelf.idealBGMaxDidChange) {
                weakSelf.idealBGMaxItem.value = [NSString stringWithFormat:@"%.2f",[weakSelf.idealBGMaxItem.value floatValue] / MG_PER_DL_PER_MMOL_PER_L];
            }
            
            if (!weakSelf.idealBGMinDidChange) {
                weakSelf.idealBGMinItem.value = [NSString stringWithFormat:@"%.2f",[weakSelf.idealBGMinItem.value floatValue] / MG_PER_DL_PER_MMOL_PER_L];
            }
            
        } else {
            
            if (!weakSelf.insulinSensitivityDidChange) {
                weakSelf.insulinSensitivityItem.value = [NSString stringWithFormat:@"%.0f",[weakSelf.insulinSensitivityItem.value floatValue] * MG_PER_DL_PER_MMOL_PER_L];
            }
            
            if (!weakSelf.carbSensitivityDidChange) {
                weakSelf.carbohydrateSensitivityItem.value = [NSString stringWithFormat:@"%.0f",[weakSelf.carbohydrateSensitivityItem.value floatValue] * MG_PER_DL_PER_MMOL_PER_L];
            }
            
            if (!weakSelf.idealBGMaxDidChange) {
                weakSelf.idealBGMaxItem.value = [NSString stringWithFormat:@"%.0f",[weakSelf.idealBGMaxItem.value floatValue] * MG_PER_DL_PER_MMOL_PER_L];
            }
            
            if (!weakSelf.idealBGMinDidChange) {
                weakSelf.idealBGMinItem.value = [NSString stringWithFormat:@"%.0f",[weakSelf.idealBGMinItem.value floatValue] * MG_PER_DL_PER_MMOL_PER_L];
                
            }
            
        }
        [weakSelf.manager.tableView reloadData];
        weakSelf.insulinSensitivityDidChange = NO;
        weakSelf.carbSensitivityDidChange = NO;
        weakSelf.idealBGMaxDidChange = NO;
        weakSelf.idealBGMinDidChange = NO;
    };
    
    
    [insulinSection addItem:insulinTitle];
    [insulinSection addItem:self.insulinTypeItem];
    [insulinSection addItem:self.insulinSensitivityItem];
    //[insulinSection addItem:self.insulinDurationItem];
    
    [carbsSection addItem:carbsTitle];
    [carbsSection addItem:self.carbohydrateSensitivityItem];
    
    [bgSection addItem:bgTitle];
    [bgSection addItem:self.idealBGMaxItem];
    [bgSection addItem:self.idealBGMinItem];
    
    //[trendsSection addItem:trendsTitle];
    //[trendsSection addItem:self.ha1cConstantItem];
    //[trendsSection addItem:self.ag15ConstantItem];
    
    [miscellaneousSection addItem:miscTitle];
    [miscellaneousSection addItem:self.useMoleUnitsItem];
    [miscellaneousSection addItem:self.militaryTimeItem];
    
}


- (IBAction)clickedDone:(id)sender {
    [self saveSettings];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void) saveSettings {
    NSNumberFormatter * f = [NSNumberFormatter new];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
    
    NSNumber* new_UseMoleUnits = [NSNumber numberWithBool:self.useMoleUnitsItem.value];
    NSNumber* new_insulinSensitivity = [Utilities roundNumber:[f numberFromString:self.insulinSensitivityItem.value] withNumberOfDecimalPlaces:2];
    NSNumber* new_carbSensitivity = [Utilities roundNumber:[f numberFromString:self.carbohydrateSensitivityItem.value] withNumberOfDecimalPlaces:2];
    NSNumber* new_idealBGMax = [Utilities roundNumber:[f numberFromString:self.idealBGMaxItem.value] withNumberOfDecimalPlaces:2];
    NSNumber* new_idealBGMin = [Utilities roundNumber:[f numberFromString:self.idealBGMinItem.value] withNumberOfDecimalPlaces:2];
    
//    NSNumber* new_ha1cConstant = [Utilities roundNumber:[f numberFromString:self.ha1cConstantItem.value] withNumberOfDecimalPlaces:2];
    //NSNumber* new_ag15Constant = [Utilities roundNumber:[f numberFromString:self.ag15ConstantItem.value] withNumberOfDecimalPlaces:2];
    
    [settings setValue:new_UseMoleUnits forKey:SETTING_UNITS_IN_MOLES];
    [settings setValue:new_insulinSensitivity forKey:SETTING_INSULIN_SENSITIVITY];
    [settings setValue:new_carbSensitivity forKey:SETTING_CARB_SENSITIVITY];
    [settings setValue:new_idealBGMax forKey:SETTING_IDEALBG_MAX];
    [settings setValue:new_idealBGMin forKey:SETTING_IDEALBG_MIN];
//    [settings setValue:new_ha1cConstant forKey:SETTING_HA1C_CONSTANT];
    //[settings setValue:new_ag15Constant forKey:SETTING_15AG_CONSTANT];
    
    //[settings setValue:[f numberFromString:self.insulinDurationItem.value]  forKey:SETTING_INSULIN_DURATION];
    
    for (NSObject* object in self.insulinTypeItem.value) {
        NSLog(@"The objects %@", object);
    }
    
    //NSLog(@"The insulinTypeItem returns %l", [self.insulinTypeItem.inlinePickerItem);
    
    [settings setValue:@([self indexForInsulinTypeString:[self.insulinTypeItem.value firstObject]]) forKey:SETTING_INSULIN_TYPE];
    [settings setValue:[NSNumber numberWithBool:self.militaryTimeItem.value]  forKey:SETTING_MILITARY_TIME];
    [settings synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_SETTINGS_CHANGED object:self];
    
}

- (int) indexForInsulinTypeString:(NSString *) insulinType
{
    NSArray* InsulinMappingArray = @[INSULINTYPE_STRING_REGULAR, INSULINTYPE_STRING_GLULISINE, INSULINTYPE_STRING_LISPRO, INSULINTYPE_STRING_ASPART];
    
    for (int i = 0; i < [InsulinMappingArray count]; i++) {
        if ([insulinType isEqualToString:[InsulinMappingArray objectAtIndex:i]]) {
            return i;
        }
    }
    return -1;
    
}



@end
