//
//  TrendsAlgorithmTests.m
//  Compass
//
//  Created by Christopher Balcells on 2/8/14.
//  Copyright (c) 2014 Clif Alferness. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BGReading.h"
#import "Ha1cReading.h"
#import "TrendsAlgorithmModel.h"
#import "Constants.h"

@interface TrendsAlgorithmTests : XCTestCase

@end

@implementation TrendsAlgorithmTests

- (void)setUp
{
    [super setUp];
    
    [MagicalRecord setDefaultModelFromClass:[self class]];
	[MagicalRecord setupCoreDataStackWithInMemoryStore];
    
}

- (void)tearDown
{
    [MagicalRecord cleanUp];

    [super tearDown];
}

- (void)testOneHundredThirtyFiveConstant {
    NSDate* origin = [NSDate new];
    
    // Create BG Readings.
    BGReading *bgReading;
    for (int i = 90 * HOURS_IN_ONE_DAY; i > 0 ; i--) {
        bgReading = [BGReading MR_createEntity];
        bgReading.name = @"BloodGlucose";
        bgReading.quantity = @(135 / MG_PER_DL_PER_MMOL_PER_L);
        bgReading.timeStamp = [NSDate dateWithTimeInterval:-i*SECONDS_IN_ONE_HOUR sinceDate:origin];
        bgReading.isPending = [NSNumber numberWithBool:NO];
    }

    [[TrendsAlgorithmModel sharedInstance] computeHA1c:bgReading.timeStamp];

    [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
    
    
    NSNumber* count = [Ha1cReading MR_numberOfEntities];
    XCTAssertEqual([count intValue], 1, @"The number of Ha1c readings was NOT one.");

    NSArray* readings = [Ha1cReading MR_findAll];
    Ha1cReading* ha1c = [readings firstObject];

    XCTAssertEqualWithAccuracy([[ha1c quantity] floatValue], 6.33, 0.01,
                               @"The result was incorrect for all readings at 135 mg/dL");
    
    [Ha1cReading MR_truncateAll];
    [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
    
}

- (void)testOneHundredSeventyConstant
{
    NSDate* origin = [NSDate new];
    
    // Create BG Readings.
    BGReading *bgReading;
    for (int i = 90*HOURS_IN_ONE_DAY; i > 0 ; i--) {
        bgReading = [BGReading MR_createEntity];
        bgReading.name = @"BloodGlucose";
        bgReading.quantity = @(170 / MG_PER_DL_PER_MMOL_PER_L);
        bgReading.timeStamp = [NSDate dateWithTimeInterval:-i*SECONDS_IN_ONE_HOUR sinceDate:origin];
        bgReading.isPending = [NSNumber numberWithBool:NO];
    }

    [[TrendsAlgorithmModel sharedInstance] computeHA1c:bgReading.timeStamp];

    [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
    
    NSNumber* count = [Ha1cReading MR_numberOfEntities];
    XCTAssertEqual([count intValue], 1, @"The number of Ha1c readings was NOT one.");
    
    NSArray* readings = [Ha1cReading MR_findAll];
    Ha1cReading* ha1c = [readings firstObject];
    
    XCTAssertEqualWithAccuracy([[ha1c quantity] floatValue], 7.55, 0.01,
                               @"The result was incorrect for all readings at 170 mg/dL");
    
    [Ha1cReading MR_truncateAll];
    [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
    
}

- (void)testOscillating170And135
{
    NSDate* origin = [NSDate new];
    
    // Create BG Readings.
    BGReading *bgReading;
    BOOL toggle = YES;
    for (int i = 90*HOURS_IN_ONE_DAY; i > 0; i -= 20) {
        bgReading = [BGReading MR_createEntity];
        bgReading.name = @"BloodGlucose";
        bgReading.timeStamp = [NSDate dateWithTimeInterval:-i*SECONDS_IN_ONE_HOUR sinceDate:origin];
        bgReading.isPending = [NSNumber numberWithBool:NO];
        if (toggle) {
            bgReading.quantity = @(170 / MG_PER_DL_PER_MMOL_PER_L);
            toggle = NO;
        } else {
            bgReading.quantity = @(135 / MG_PER_DL_PER_MMOL_PER_L);
            toggle = YES;
        }
    }
    
    [[TrendsAlgorithmModel sharedInstance] computeHA1c:bgReading.timeStamp];

    [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
    
    NSNumber* count = [Ha1cReading MR_numberOfEntities];

    // FIXME: count increases by 1 each time test is run. cleanUp isn't deleting readings?
    XCTAssertEqual([count intValue], 1, @"The number of Ha1c readings was NOT one.");
    
    Ha1cReading* ha1c = [Ha1cReading MR_findFirst];
    
    XCTAssertEqualWithAccuracy([[ha1c quantity] floatValue], 6.93, 0.01,
                               @"The result was incorrect for BG readings oscillating between 170 and 135 mg/dL");
    
    [Ha1cReading MR_truncateAll];
    [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
    
}

@end
