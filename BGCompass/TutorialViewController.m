//
//  TutorialViewController.m
//  Compass
//
//  Created by Jose Carrillo and Christopher Balcells on 2/24/14.
//  Copyright (c) 2014 Clif Alferness. All rights reserved.
//

#import "TutorialViewController.h"
#import <EAIntroView.h>
#import "Constants.h"
#import <RETableViewManager.h>
#import "Utilities.h"
#import "BGReading.h"
#import "TutorialTextItem.h"
#import "TutorialTitleItem.h"
#import "TutorialPickerItem.h"
#import "TutorialBoolItem.h"
#import "BGReading.h"
#import <EFCircularSlider.h>

@interface TutorialViewController ()

@property(strong, nonatomic) RETableViewManager *manager;
@property(strong, nonatomic) UITableView *settingsTableView;


@property (strong, readwrite, nonatomic) TutorialTextItem *insulinSensitivityItem;
@property (strong, readwrite, nonatomic) TutorialPickerItem *insulinTypeItem;
@property (strong, readwrite, nonatomic) TutorialTextItem *carbohydrateSensitivityItem;
@property (strong, readwrite, nonatomic) TutorialTextItem *idealBGMaxItem;
@property (strong, readwrite, nonatomic) TutorialTextItem *idealBGMinItem;
@property (strong, readwrite, nonatomic) TutorialBoolItem *useMoleUnitsItem;
@property (strong, readwrite, nonatomic) TutorialBoolItem *militaryTimeItem;

@property (nonatomic) BOOL insulinSensitivityDidChange;
@property (nonatomic) BOOL carbSensitivityDidChange;
@property (nonatomic) BOOL idealBGMaxDidChange;
@property (nonatomic) BOOL idealBGMinDidChange;


@property (weak, nonatomic) UILabel *bgUnits;
@property (weak, nonatomic) UILabel *bgValue;
@property (weak, nonatomic) EFCircularSlider *circularSlider;

@end

@implementation TutorialViewController

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
    self.idealBGMaxDidChange = NO;
    self.idealBGMinDidChange = NO;
    self.insulinSensitivityDidChange = NO;
    self.carbSensitivityDidChange = NO;
    
    [self setupTutorial];
    
    self.manager = [[RETableViewManager alloc] initWithTableView:self.settingsTableView];
    
    [self setupSettingsPage];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setupTutorial {
    float screenConstant = [[NSUserDefaults standardUserDefaults] floatForKey:SETTING_SCREEN_CONSTANT];
    
    EAIntroPage *page1 = [EAIntroPage page];
    page1.title = @"Welcome";
    page1.titlePositionY = 500 * screenConstant;
    page1.desc = @"The future of blood glucose estimation";
    page1.titleFont = [UIFont fontWithName:@"HelveticaNeue-Ultralight" size:60];
    page1.bgImage = [UIImage imageNamed:@"cool"];
    page1.titleImage = [UIImage imageNamed:@"appIcon"];
    
    
    
    
    
    UIView *settingsView = [[UIView alloc] initWithFrame:self.view.bounds];
    if(screenConstant == 1) {
        self.settingsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 125, 320, 370)];
        page1.imgPositionY = 200;
    } else {
        self.settingsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 125, 320, 280)];
        page1.imgPositionY = 150;
    }
    
    self.settingsTableView.backgroundColor = [UIColor clearColor];
    [self.settingsTableView setSeparatorInset:UIEdgeInsetsZero];
    
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(30, 57, 260, 60)];
    title.text = @"First, some information about you";
    title.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:25];
    title.textColor = [UIColor whiteColor];
    title.backgroundColor = [UIColor clearColor];
    title.numberOfLines = 2;
    title.textAlignment = NSTextAlignmentCenter;
    
    [settingsView addSubview:self.settingsTableView];
    [settingsView addSubview:title];
    
    EAIntroPage *page2 = [EAIntroPage pageWithCustomView:settingsView];
    page2.bgImage = [UIImage imageNamed:@"cool2"];
    
    
    UIView *firstBGView = [[UIView alloc] initWithFrame:self.view.bounds];
    UILabel *title2 = [[UILabel alloc] initWithFrame:CGRectMake(30, 42, 260, 60)];
    title2.text = @"One more thing...";
    title2.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:25];
    title2.textColor = [UIColor whiteColor];
    title2.backgroundColor = [UIColor clearColor];
    title2.numberOfLines = 1;
    title2.textAlignment = NSTextAlignmentCenter;
    
    UILabel *bgUnits;
    UIButton *finishButton = finishButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UILabel *bgTitle;
    UILabel *bgValue;
    EFCircularSlider* circularSlider;
    if (screenConstant == 1) {
        bgValue = [[UILabel alloc] initWithFrame:CGRectMake((320-200)/2, 230, 200, 60)];
        bgUnits = [[UILabel alloc] initWithFrame:CGRectMake((320-200)/2, 233, 200, 200)];
        [finishButton setFrame:CGRectMake((320-200)/2, 418, 200, 50)];
        bgTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, 320, 60)];
        
        circularSlider = [[EFCircularSlider alloc] initWithFrame:CGRectMake((320-270)/2, 133, 270, 270)];
    } else {
        bgValue = [[UILabel alloc] initWithFrame:CGRectMake((320-200)/2, 200, 200, 60)];
        bgUnits = [[UILabel alloc] initWithFrame:CGRectMake((320-200)/2, 190, 200, 200)];
        [finishButton setFrame:CGRectMake((320-200)/2, [UIScreen mainScreen].bounds.size.height - 125, 200, 50)];
        bgTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, 320, 60)];
        circularSlider = [[EFCircularSlider alloc] initWithFrame:CGRectMake((320-230)/2, 120, 230, 230)];
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
    
    bgValue.text = [NSString stringWithFormat:@"%.2f", circularSlider.currentValue];
    bgValue.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:50];
    bgValue.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
    bgValue.textAlignment = NSTextAlignmentCenter;
    self.bgValue = bgValue;
    
    bgTitle.text = @"What is your current blood glucose level?";
    bgTitle.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:17];
    bgTitle.textColor = [UIColor whiteColor];
    bgTitle.backgroundColor = [UIColor clearColor];
    bgTitle.numberOfLines = 1;
    bgTitle.textAlignment = NSTextAlignmentCenter;
    
    
    
    
    bgUnits.text = @"mg/dL";
    circularSlider.maximumValue = 300.0;
    
    NSMutableArray *labelsArray = [NSMutableArray new];
    for(int i=1; i<11; i++) {
        [labelsArray addObject:[NSString stringWithFormat:@"%.0f", i*30.0]];
    }
    [circularSlider setInnerMarkingLabels:labelsArray];
    self.circularSlider = circularSlider;
    
    
    bgUnits.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20];
    bgUnits.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    bgUnits.backgroundColor = [UIColor clearColor];
    bgUnits.numberOfLines = 1;
    bgUnits.textAlignment = NSTextAlignmentCenter;
    self.bgUnits = bgUnits;
    
    finishButton.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
    [finishButton setTitle:@"Finish" forState:UIControlStateNormal];
    [finishButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [finishButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:25]];
    finishButton.layer.borderWidth = 1.0f;
    finishButton.layer.cornerRadius = 5;
    finishButton.layer.borderColor = [[UIColor colorWithRed:1 green:1 blue:1 alpha:0.2] CGColor];
    [finishButton addTarget:self action:@selector(completedTutorial) forControlEvents:UIControlEventTouchUpInside];
    
    
    [firstBGView addSubview:title2];
    [firstBGView addSubview:finishButton];
    [firstBGView addSubview:bgTitle];
    [firstBGView addSubview:bgUnits];
    [firstBGView addSubview:circularSlider];
    [firstBGView addSubview:bgValue];
    
    

    EAIntroPage *page3 = [EAIntroPage pageWithCustomView:firstBGView];
    page3.bgImage = [UIImage imageNamed:@"red"];

    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1,page2,page3]];

    // Deleted incorrect
    // intro.skipButton = NO;
    // TODO: set showSkipButtonOnlyOnLastPage ? e.g.
    // intro.skipButton.showSkipButtonOnlyOnLastPage = NO;

    intro.swipeToExit = NO;
    
    [intro showInView:self.view animateDuration:0.0];
    [intro setDelegate:self];
}



-(void) newValue:(EFCircularSlider*)slider {
    if(self.useMoleUnitsItem.value) {
        self.bgValue.text = [NSString stringWithFormat:@"%.1f", slider.currentValue];
    } else {
        self.bgValue.text = [NSString stringWithFormat:@"%.0f", slider.currentValue];
    }
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
    RETableViewSection *miscellaneousSection = [RETableViewSection sectionWithHeaderTitle:@""];
    
    
    [self.manager addSection:insulinSection];
    [self.manager addSection:carbsSection];
    [self.manager addSection:bgSection];
    [self.manager addSection:miscellaneousSection];
    
    
    NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
    
    TutorialTitleItem  *insulinTitle = [TutorialTitleItem itemWithTitle:@"INSULIN"];
    TutorialTitleItem  *carbsTitle = [TutorialTitleItem  itemWithTitle:@"CARBOHYDRATES"];
    TutorialTitleItem  *bgTitle = [TutorialTitleItem  itemWithTitle:@"BLOOD GLUCOSE"];
    TutorialTitleItem  *miscTitle = [TutorialTitleItem  itemWithTitle:@"MISCELLANEOUS SETTINGS"];
    
    self.insulinSensitivityItem = [TutorialTextItem itemWithTitle:@"Sensitivity" value:[Utilities createFormattedStringFromNumber:((NSNumber*)[settings valueForKey:SETTING_INSULIN_SENSITIVITY]) withNumberOfDecimalPlaces:2]];
    
    self.carbohydrateSensitivityItem = [TutorialTextItem itemWithTitle:@"Sensitivity" value:[Utilities createFormattedStringFromNumber:((NSNumber*)[settings valueForKey:SETTING_CARB_SENSITIVITY]) withNumberOfDecimalPlaces:2]];
    
    self.idealBGMaxItem = [TutorialTextItem itemWithTitle:@"Ideal Max" value:[Utilities createFormattedStringFromNumber:((NSNumber*)[settings valueForKey:SETTING_IDEALBG_MAX]) forReadingType:[BGReading class]]];
    self.idealBGMinItem = [TutorialTextItem itemWithTitle:@"Ideal Min" value:[Utilities createFormattedStringFromNumber:((NSNumber*)[settings valueForKey:SETTING_IDEALBG_MIN]) forReadingType:[BGReading class]]];
    
    self.useMoleUnitsItem = [TutorialBoolItem itemWithTitle:@"Use mmol/L" value:[settings boolForKey:SETTING_UNITS_IN_MOLES]];
    self.militaryTimeItem = [TutorialBoolItem itemWithTitle:@"Use 24 Hr clock" value:[settings boolForKey:SETTING_MILITARY_TIME]];
    
    NSArray* InsulinMappingArray = @[INSULINTYPE_STRING_REGULAR, INSULINTYPE_STRING_GLULISINE, INSULINTYPE_STRING_LISPRO, INSULINTYPE_STRING_ASPART];
#warning this array should be placed somewhere else. Some sort of constants place. Also in EditItemViewController.m
    self.insulinTypeItem = [TutorialPickerItem itemWithTitle:@"Type" value:@[[InsulinMappingArray objectAtIndex:[settings integerForKey:SETTING_INSULIN_TYPE]]] placeholder:nil options:@[InsulinMappingArray]];
    
    self.insulinSensitivityItem.keyboardType = UIKeyboardTypeDecimalPad;
    self.insulinSensitivityItem.keyboardAppearance = UIKeyboardAppearanceDark;
    self.carbohydrateSensitivityItem.keyboardType = UIKeyboardTypeDecimalPad;
    self.carbohydrateSensitivityItem.keyboardAppearance = UIKeyboardAppearanceDark;
    self.idealBGMinItem.keyboardType = UIKeyboardTypeDecimalPad;
    self.idealBGMinItem.keyboardAppearance = UIKeyboardAppearanceDark;
    self.idealBGMaxItem.keyboardType = UIKeyboardTypeDecimalPad;
    self.idealBGMaxItem.keyboardAppearance = UIKeyboardAppearanceDark;
    
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
                weakSelf.insulinSensitivityItem.value = [NSString stringWithFormat:@"%.2f",[weakSelf.insulinSensitivityItem.value floatValue] / 18.0];
            }
            
            if (!weakSelf.carbSensitivityDidChange) {
                weakSelf.carbohydrateSensitivityItem.value = [NSString stringWithFormat:@"%.2f",[weakSelf.carbohydrateSensitivityItem.value floatValue] / 18.0];
            }
            
            if (!weakSelf.idealBGMaxDidChange) {
                weakSelf.idealBGMaxItem.value = [NSString stringWithFormat:@"%.2f",[weakSelf.idealBGMaxItem.value floatValue] / 18.0];
            }
            
            if (!weakSelf.idealBGMinDidChange) {
                weakSelf.idealBGMinItem.value = [NSString stringWithFormat:@"%.2f",[weakSelf.idealBGMinItem.value floatValue] / 18.0];
            }
            
            weakSelf.bgUnits.text = @"mmol/L";
            weakSelf.circularSlider.maximumValue = 300.0/18.0;
            weakSelf.circularSlider.currentValue = weakSelf.circularSlider.currentValue / 18.0;
            
            weakSelf.bgValue.text = [NSString stringWithFormat:@"%.1f", weakSelf.circularSlider.currentValue];
            
            
            NSMutableArray *labelsArray = [NSMutableArray new];
            for(int i=1; i<11; i++) {
                [labelsArray addObject:[NSString stringWithFormat:@"%.0f", i*30.0/18.0]];
            }
            [weakSelf.circularSlider setInnerMarkingLabels:labelsArray];
            
        } else {
            
            if (!weakSelf.insulinSensitivityDidChange) {
                weakSelf.insulinSensitivityItem.value = [NSString stringWithFormat:@"%.2f",[weakSelf.insulinSensitivityItem.value floatValue] * 18.0];
            }
            
            if (!weakSelf.carbSensitivityDidChange) {
                weakSelf.carbohydrateSensitivityItem.value = [NSString stringWithFormat:@"%.2f",[weakSelf.carbohydrateSensitivityItem.value floatValue] * 18.0];
            }
            
            if (!weakSelf.idealBGMaxDidChange) {
                weakSelf.idealBGMaxItem.value = [NSString stringWithFormat:@"%.2f",[weakSelf.idealBGMaxItem.value floatValue] * 18.0];
            }
            
            if (!weakSelf.idealBGMinDidChange) {
                weakSelf.idealBGMinItem.value = [NSString stringWithFormat:@"%.2f",[weakSelf.idealBGMinItem.value floatValue] * 18.0];

            }
            weakSelf.bgUnits.text = @"mg/dL";
            weakSelf.circularSlider.maximumValue = 300.0;
            weakSelf.circularSlider.currentValue = weakSelf.circularSlider.currentValue * 18.0;
            weakSelf.bgValue.text = [NSString stringWithFormat:@"%.0f", weakSelf.circularSlider.currentValue];
            
            NSMutableArray *labelsArray = [NSMutableArray new];
            for(int i=1; i<11; i++) {
                [labelsArray addObject:[NSString stringWithFormat:@"%.0f", i*30.0]];
            }
            [weakSelf.circularSlider setInnerMarkingLabels:labelsArray];
            
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
    
    [carbsSection addItem:carbsTitle];
    [carbsSection addItem:self.carbohydrateSensitivityItem];
    
    [bgSection addItem:bgTitle];
    [bgSection addItem:self.idealBGMaxItem];
    [bgSection addItem:self.idealBGMinItem];
    
    [miscellaneousSection addItem:miscTitle];
    [miscellaneousSection addItem:self.useMoleUnitsItem];
    [miscellaneousSection addItem:self.militaryTimeItem];
    
    
    
}


- (void) saveSettings {
    NSNumberFormatter * f = [NSNumberFormatter new];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
    
    NSNumber* new_UseMoleUnits = [NSNumber numberWithBool:self.useMoleUnitsItem.value];
    NSNumber* new_insulinSensitivity = [Utilities roundNumber:[f numberFromString:self.insulinSensitivityItem.value] withNumberOfDecimalPlaces:2];
    NSNumber* new_carbSensitivity = [Utilities roundNumber:[f numberFromString:self.carbohydrateSensitivityItem.value] withNumberOfDecimalPlaces:2];
    NSNumber* new_idealBGMaxItem = [Utilities roundNumber:[f numberFromString:self.idealBGMaxItem.value] withNumberOfDecimalPlaces:2];
    NSNumber* new_idealBGMinItem = [Utilities roundNumber:[f numberFromString:self.idealBGMinItem.value] withNumberOfDecimalPlaces:2];
    
    
    [settings setValue:new_UseMoleUnits forKey:SETTING_UNITS_IN_MOLES];
    [settings setValue:new_insulinSensitivity forKey:SETTING_INSULIN_SENSITIVITY];
    [settings setValue:new_carbSensitivity forKey:SETTING_CARB_SENSITIVITY];
    [settings setValue:new_idealBGMaxItem forKey:SETTING_IDEALBG_MAX];
    [settings setValue:new_idealBGMinItem forKey:SETTING_IDEALBG_MIN];
    
    [settings setValue:@(self.insulinTypeItem.indexPath.row) forKey:SETTING_INSULIN_TYPE];
    [settings setValue:[NSNumber numberWithBool:self.militaryTimeItem.value]  forKey:SETTING_MILITARY_TIME];
    [settings synchronize];
    
}



- (void)introDidFinish:(EAIntroView *)introView {
    
}
- (void)intro:(EAIntroView *)introView pageAppeared:(EAIntroPage *)page withIndex:(NSInteger)pageIndex {
    if (pageIndex == 2) {
        NSLog(@"Saving Settings");
        [self saveSettings];
    }
}
- (void)intro:(EAIntroView *)introView pageStartScrolling:(EAIntroPage *)page withIndex:(NSInteger)pageIndex {
    
}
- (void)intro:(EAIntroView *)introView pageEndScrolling:(EAIntroPage *)page withIndex:(NSInteger)pageIndex {
    
}


- (void) completedTutorial {
    NSNumberFormatter * f = [NSNumberFormatter new];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    
    BGReading *bg = [BGReading MR_createEntity];
    bg.name = @"Blood Glucose";
    [bg setQuantity:[NSNumber numberWithFloat:self.circularSlider.currentValue] withConversion:!self.useMoleUnitsItem.value];
    bg.timeStamp = [NSDate date];
    bg.isPending = [NSNumber numberWithBool:NO];
    
    
    NSDictionary *d = @{ @"timeStamp":bg.timeStamp };
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_BGREADING_ADDED object:nil userInfo:d];
    
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError* error) {
        success ?: NSLog(@"%@", error);
    }];
    
    [[NSUserDefaults standardUserDefaults] setValue:@YES forKey:SETTING_COMPLETED_TUTORIAL];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self performSegueWithIdentifier:@"exitTutorial" sender:self];
}

@end
