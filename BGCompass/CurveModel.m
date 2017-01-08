//
//  CurveModel.m
//  CompassRose
//
//  Created by Christopher Balcells on 11/15/13.
//  Copyright (c) 2013 Clif Alferness. All rights reserved.
//

#import "CurveModel.h"
#import "Constants.h"
#import "BGReading.h"

#define USE_DEFAULT_DURATION -1
#define USE_CURRENT_TYPE     -2

@interface CurveModel()
@property (strong, nonatomic) NSArray* insulinPoints;
@property (strong, nonatomic) NSArray* carbPoints;
@end

@implementation CurveModel {
    int _insulinDuration;
    int _insulinType;
    
}

+ (id)sharedInstance
{
    static CurveModel *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self setNewInsulinSettingsIfNecessary];
        self.carbPoints = @[
                            [NSValue valueWithCGPoint:CGPointMake(0, 0)],
                            [NSValue valueWithCGPoint:CGPointMake(30, 10)],
                            [NSValue valueWithCGPoint:CGPointMake(45, 10)],
                            [NSValue valueWithCGPoint:CGPointMake(120, 0)]
                            ];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotifications:) name:NOTE_SETTINGS_CHANGED object:nil];
    }
    return self;
}

- (void) setNewInsulinSettingsIfNecessary
{
    int new_insulinType = ((int)[[NSUserDefaults standardUserDefaults] integerForKey:SETTING_INSULIN_TYPE]);
    if (new_insulinType != _insulinType) {
        [self setInsulinPointsWithDuration:USE_DEFAULT_DURATION andInsulinType:new_insulinType];
        _insulinType = new_insulinType;
    }
    
    int new_insulinDuration = ((int)[[NSUserDefaults standardUserDefaults] integerForKey:SETTING_INSULIN_DURATION]);
    if (new_insulinDuration != _insulinDuration) {
        [self setInsulinPointsWithDuration:new_insulinDuration andInsulinType:USE_CURRENT_TYPE];
    }
}

- (void) setInsulinPointsWithDuration:(int) insulinDuration andInsulinType:(int) insulinType
{
    BOOL remember_to_change_setting = NO;
    if (insulinDuration == USE_DEFAULT_DURATION) {
        remember_to_change_setting = YES;
    }
    
    if (insulinType == USE_CURRENT_TYPE) {
        insulinType = ((int)[[NSUserDefaults standardUserDefaults] integerForKey:SETTING_INSULIN_TYPE]);
    }

    if (insulinType == INSULINTYPE_REGULAR) {
        if (insulinDuration == USE_DEFAULT_DURATION) {
            insulinDuration = 515;
        }
        // General Curve Points: (0,0), (20, 0), (90, 3.0), (290, 4.3), (390, 2.35), (515, 0)
        self.insulinPoints = @[
                               [NSValue valueWithCGPoint:CGPointMake(0, 0)],
                               [NSValue valueWithCGPoint:CGPointMake(20, 0)],
                               [NSValue valueWithCGPoint:CGPointMake(90/515*insulinDuration, 300)],
                               [NSValue valueWithCGPoint:CGPointMake(95/515*insulinDuration, 430)],
                               [NSValue valueWithCGPoint:CGPointMake(185/515*insulinDuration, 235)],
                               [NSValue valueWithCGPoint:CGPointMake(insulinDuration, 0)]
                               ];
    } else if (insulinType == INSULINTYPE_GLULISINE) {
        if (insulinDuration == USE_DEFAULT_DURATION) {
            insulinDuration = 485;
        }
        
        // Apidra Curve Points: (0,0), (20, 0), (65, 5.5), (215, 5.2), (485, 0)
        self.insulinPoints = @[
                               [NSValue valueWithCGPoint:CGPointMake(0, 0)],
                               [NSValue valueWithCGPoint:CGPointMake(20, 0)],
                               [NSValue valueWithCGPoint:CGPointMake(65/485*insulinDuration, 55)],
                               [NSValue valueWithCGPoint:CGPointMake(215/485*insulinDuration, 52)],
                               [NSValue valueWithCGPoint:CGPointMake(insulinDuration, 0)]
                               ];
    } else if (insulinType == INSULINTYPE_LISPRO || insulinType == INSULINTYPE_ASPART) {
        if (insulinDuration == USE_DEFAULT_DURATION) {
            insulinDuration = 240;
        }
        
        // Lispro/Aspart Curve Points: (0, 0), (20, 0), (75, 4.5), (185, 5.4), (240, 0)
        self.insulinPoints = @[
                               [NSValue valueWithCGPoint:CGPointMake(0, 0)],
                               [NSValue valueWithCGPoint:CGPointMake(20, 0)],
                               [NSValue valueWithCGPoint:CGPointMake(75/240*insulinDuration, 45)],
                               [NSValue valueWithCGPoint:CGPointMake(185/240*insulinDuration, 54)],
                               [NSValue valueWithCGPoint:CGPointMake(insulinDuration, 0)]
                               ];
    }
// TODO: fix me add other insulin types here. Each one with its own curve points.
    
    // Set the duration setting, if using default.
    if (remember_to_change_setting) {
        [[NSUserDefaults standardUserDefaults] setValue:@(insulinDuration) forKey:SETTING_INSULIN_DURATION];
    }
    // Set the instance variable to the variable which was used.
    _insulinDuration = insulinDuration;
}

- (void) handleNotifications:(NSNotification*) note
{
    if ([[note name] isEqualToString:NOTE_SETTINGS_CHANGED]) {
        [self setNewInsulinSettingsIfNecessary];
    }
}

// TODO: fix me Should refactor the two following methods into one method. Should just be "effectFromReading".

- (void) effectFromInsulinReading:(InsulinReading *)insulinReading toArray:(float *)insulinEffect {
    
    if ([insulinReading.insulinType integerValue] != _insulinType) {
// TODO: fix me this reveals an issue. Duration of insulin needs to be on a per reading basis if we choose to make it custom.
        [self setInsulinPointsWithDuration:USE_DEFAULT_DURATION andInsulinType:[insulinReading.insulinType intValue]];
    }
    
    NSValue* last_point;
    float array_sum = 0.0;
    for (int index = 0; index < _insulinDuration; index++) {
        
        for (NSValue* point in self.insulinPoints) {
            if (index <= point.CGPointValue.x && point.CGPointValue.x != 0) {
                // Calculating interpolated y values.
                // y = b + mx.
                // m = y2-y1/x2-x1
                // x = index - this_x
                // Final equation: y = y1 + (y2-y1)/(x2-x1)*(index - x2)
                insulinEffect[index] = last_point.CGPointValue.y + (point.CGPointValue.y - last_point.CGPointValue.y)
                                            / (point.CGPointValue.x - last_point.CGPointValue.x) * (index - last_point.CGPointValue.x);
                break;
            }
            last_point = point;
        }
        array_sum += insulinEffect[index];
    }
    
    float insulinSensitivity = [[NSUserDefaults standardUserDefaults] floatForKey:SETTING_INSULIN_SENSITIVITY];
    if (![BGReading isInMoles]) {
        insulinSensitivity = insulinSensitivity / MG_PER_DL_PER_MMOL_PER_L;
    }
// TODO: fix me The insulinSensitivity code above seems fishy. Needs a second look.
    
    // Normalize and multiply each value by insulin sensitivity
    for (int index = 0; index < _insulinDuration; index++) {
        insulinEffect[index] = insulinEffect[index] / array_sum * insulinSensitivity;
    }
    
    // Integrate
    float integrator = 0;
    for (int index = 0; index < _insulinDuration; index++) {
        integrator += insulinEffect[index];
        insulinEffect[index] = integrator;
    }
    
    // Multiply by Dosage
    for (int index = 0; index < _insulinDuration; index++) {
        insulinEffect[index] = insulinEffect[index] * insulinReading.quantity.floatValue;
    }
}

- (void) effectFromFoodReading:(FoodReading *)foodReading toArray:(float *)carbEffect {
    NSValue* last_point;
    float array_sum = 0.0;
    for (int index = 0; index < FOOD_CURVE_LENGTH_MINUTES; index++) {
        
        for (NSValue* point in self.carbPoints) {
            if  (index <= point.CGPointValue.x && point.CGPointValue.x != 0) {
                carbEffect[index] = last_point.CGPointValue.y + (point.CGPointValue.y - last_point.CGPointValue.y)
                                        / (point.CGPointValue.x - last_point.CGPointValue.x) * (index - last_point.CGPointValue.x);
                break;
            }
            last_point = point;
        }
        array_sum += carbEffect[index];
    }
    
    float carbSensitivity = [[NSUserDefaults standardUserDefaults] floatForKey:SETTING_CARB_SENSITIVITY];
    if (![BGReading isInMoles]) {
        carbSensitivity = carbSensitivity / MG_PER_DL_PER_MMOL_PER_L;
    }
    
    // Normalize and Multiply by carb sensitivity
    for (int index = 0; index < FOOD_CURVE_LENGTH_MINUTES; index++) {
        carbEffect[index] = carbEffect[index] / array_sum * carbSensitivity;
    }
    
    // Integrate
    float integrator = 0;
    for (int index = 0; index < FOOD_CURVE_LENGTH_MINUTES; index++) {
        integrator += carbEffect[index];
        carbEffect[index] = integrator;
    }
    
    // Multiply by Dosage
    for (int index = 0; index < FOOD_CURVE_LENGTH_MINUTES; index++) {
        carbEffect[index] = carbEffect[index] * foodReading.carbs.floatValue * foodReading.numberOfServings.floatValue;
    }
}

- (int) getInsulinDuration
{
    [self setNewInsulinSettingsIfNecessary];
    return _insulinDuration;
}

@end
