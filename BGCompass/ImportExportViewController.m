//
//  ImportExportViewController.m
//  Compass
//
//  Created by Jose Carrillo on 3/3/14.
//  Copyright (c) 2014 Clif Alferness. All rights reserved.
//
//This file is for import and export of csv files with historical data

#import "ImportExportViewController.h"
#import "Reading.h"
#import "BGReading.h"
#import "InsulinReading.h"
#import "FoodReading.h"
#import "Constants.h"

@interface ImportExportViewController ()

@property (strong, nonatomic) CHCSVParser* parser;

@property (strong, nonatomic) NSString* fileType;
@property (strong, nonatomic) NSMutableArray* valueLocations;
@property (nonatomic) BOOL setup;
@property (nonatomic) int lineCount;
@property (strong, nonatomic) NSMutableArray* addedItems;
@property (strong, nonatomic) NSDateFormatter* dateFormatter;

@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSDate* timestamp;
@property (strong, nonatomic) NSNumber* favorite;
@property (strong, nonatomic) NSNumber* quantity;
@property (strong, nonatomic) NSNumber* servings;
@property (strong, nonatomic) NSNumber* carbs;
@property (strong, nonatomic) NSString* units;
@property (strong, nonatomic) NSString* type;


@end

@implementation ImportExportViewController

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
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)parseFile:(NSURL*)url {
    self.url = url;
    self.parser = [[CHCSVParser alloc] initWithContentsOfCSVFile:[url relativePath]];
    [self.parser setDelegate:self];
    self.parser.sanitizesFields = YES;
    self.setup = YES;
    self.lineCount = 0;
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"MMMM d, yyyy h:mm a"];
    self.valueLocations = [NSMutableArray new];
    self.addedItems = [NSMutableArray new];
    [self.parser parse];
}


- (void)parserDidBeginDocument:(CHCSVParser *)parser {
    NSLog(@"Starting csv parsing...");
    
}

- (void)parserDidEndDocument:(CHCSVParser *)parser {
    if (self.fileType == nil) {
        NSLog(@"Incorrect File Format");
    } else {
        NSLog(@"Finished csv parsing!");
    }
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    [self performSegueWithIdentifier:@"exitImportExportSegue" sender:self];
    
}

- (void)parser:(CHCSVParser *)parser didBeginLine:(NSUInteger)recordNumber {
    
}

- (void)parser:(CHCSVParser *)parser didEndLine:(NSUInteger)recordNumber {
    self.lineCount++;
    if (self.type != nil) {
        if ([self.type caseInsensitiveCompare:@"Food"]) {
            
            FoodReading *foodReading = [FoodReading MR_createInContext:[NSManagedObjectContext MR_defaultContext]];
            foodReading.name = self.name;
            foodReading.carbs = self.carbs;
            foodReading.servingUnitAndQuantity = self.units;
            foodReading.numberOfServings = self.servings;
            foodReading.timeStamp = self.timestamp;
            foodReading.isPending = [NSNumber numberWithBool:NO];
            foodReading.isFavorite = self.favorite;
            NSDictionary *d = @{ @"timeStamp":foodReading.timeStamp };
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_FOODREADING_ADDED object:nil userInfo:d];
        } else if ([self.type caseInsensitiveCompare:@"Blood Glucose"]) {
            BGReading *bgReading = [BGReading MR_createInContext:[NSManagedObjectContext MR_defaultContext]];
            bgReading.name = self.name;
            bgReading.quantity = self.quantity;
            bgReading.timeStamp = self.timestamp;
            bgReading.isPending = [NSNumber numberWithBool:NO];
            bgReading.isFavorite = self.favorite;
            NSDictionary *d = @{ @"timeStamp":bgReading.timeStamp };
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_BGREADING_ADDED object:nil userInfo:d];
        } else if ([self.type caseInsensitiveCompare:@"Insulin"]) {
            InsulinReading *insulinReading = [InsulinReading MR_createInContext:[NSManagedObjectContext MR_defaultContext]];
            insulinReading.name = self.name;
            insulinReading.quantity = self.quantity;
            insulinReading.timeStamp = self.timestamp;
            insulinReading.isPending = [NSNumber numberWithBool:NO];
            insulinReading.isFavorite = self.favorite;
            NSDictionary *d = @{ @"timeStamp":insulinReading.timeStamp };
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_INSULINREADING_ADDED object:nil userInfo:d];
        } else {
           
        }
        
        self.type = nil;
        self.name = nil;
        self.timestamp = nil;
        self.favorite = nil;
        self.quantity = nil;
        self.carbs = nil;
        self.servings = nil;
        self.units = nil;
    }
}

- (void)parser:(CHCSVParser *)parser didReadField:(NSString *)field atIndex:(NSInteger)fieldIndex {
    if (self.lineCount > 1) {
        self.setup = NO;
    } else {
        
    }
    if (self.setup) {
        if (self.fileType == nil && [field hasPrefix:@"BG Compass"]) {
            NSLog(@"BG Compass data file identified");
            self.fileType = field;
        } else if( self.lineCount == 1) {
            [self.valueLocations addObject:field];
        }
    } else {
        NSString* valueType = [self.valueLocations objectAtIndex:fieldIndex];
        if (![field isEqualToString:@""]) {
            if ([valueType  caseInsensitiveCompare: @"Reading Type"]) {
                self.type = field;
            } else if ([valueType  caseInsensitiveCompare: @"Name"]) {
                self.name = field;
            } else if ([valueType  caseInsensitiveCompare: @"Timestamp"]) {
                self.timestamp = [self.dateFormatter dateFromString:field];
            } else if ([valueType  caseInsensitiveCompare: @"Favorite"]) {
                self.favorite = [NSNumber numberWithBool:[field boolValue]];
            } else if ([valueType  caseInsensitiveCompare: @"Quantity"]) {
                self.quantity = [NSNumber numberWithFloat:[field floatValue]];
            } else if ([valueType  caseInsensitiveCompare: @"Carbohydrates"]) {
                self.carbs = [NSNumber numberWithFloat:[field floatValue]];
            } else if ([valueType  caseInsensitiveCompare: @"Servings"]) {
                self.servings = [NSNumber numberWithFloat:[field floatValue]];
            } else if ([valueType  caseInsensitiveCompare: @"Serving Unit"]) {
                self.units= field;
            } else if ([valueType  caseInsensitiveCompare: @"Units In Mols"]) {
                if ([field caseInsensitiveCompare:@"NO"]) {
                    self.quantity = [NSNumber numberWithFloat:[self.quantity floatValue]/18.0];
                }
            }
        }
    }
    
}

- (void)parser:(CHCSVParser *)parser didReadComment:(NSString *)comment {
    
}

- (void)parser:(CHCSVParser *)parser didFailWithError:(NSError *)error {
    NSLog(@"ERROR: %@", error);
    
}

@end
