//
//  Constants.m
//  Description: This file holds any constant values which are used in more
//      than one place.
//  BG Compass
//
//  Created by macbookpro on 10/21/13.
//  Copyright (c) 2013 Clif Alferness. All rights reserved.
//

#import "Constants.h"

NSString *const NOTE_ACCEPTED = @"acceptedPendingItems";
NSString *const NOTE_REJECTED = @"rejectedPendingItems";
NSString *const NOTE_GRAPH_SHIFTED = @"graphShifted";
NSString *const NOTE_PREDICT_SHIFTED = @"predictShifted";
NSString *const NOTE_GRAPH_RECALCULATED = @"graphRecalculated";
NSString *const NOTE_PREDICT_RECALCULATED = @"predictRecalculated";
NSString *const NOTE_SETTINGS_CHANGED = @"settingsChanged";
NSString *const NOTE_BGREADING_ADDED = @"BGReadingAdded";
NSString *const NOTE_BGREADING_EDITED = @"BGReadingEdited";
NSString *const NOTE_FOODREADING_ADDED = @"foodReadingAdded";
NSString *const NOTE_FOODREADING_EDITED = @"foodReadingEdited";
NSString *const NOTE_INSULINREADING_ADDED = @"insulinReadingAdded";
NSString *const NOTE_INSULINREADING_EDITED = @"insulinReadingEdited";
NSString *const NOTE_PENDINGREADING_DELETED = @"pendingReadingEdited";

NSString *const SETTING_UNITS_IN_MOLES = @"unitsAreInMoles";
NSString *const SETTING_INSULIN_SENSITIVITY = @"insulinSensitivity";
NSString *const SETTING_INSULIN_DURATION = @"insulinDuration";
NSString *const SETTING_INSULIN_TYPE = @"insulinType";
NSString *const SETTING_CARB_SENSITIVITY = @"carbohydrateSensitivity";
NSString *const SETTING_MILITARY_TIME = @"militaryTime";
NSString *const SETTING_15AG_CONSTANT = @"15AGConstant";
NSString *const SETTING_HA1C_CONSTANT = @"HA1CConstant";
NSString *const SETTING_IDEALBG_MAX = @"idealBGMax";
NSString *const SETTING_IDEALBG_MIN = @"idealBGMin";
NSString *const SETTING_SCREEN_CONSTANT = @"screenMultiple";
NSString *const SETTING_COMPLETED_TUTORIAL = @"hasCompletedTutorial";

int const INSULINTYPE_REGULAR = 0;
int const INSULINTYPE_GLULISINE = 1;
int const INSULINTYPE_LISPRO = 2;
int const INSULINTYPE_ASPART = 3;

NSString *const INSULINTYPE_STRING_REGULAR = @"Regular";
NSString *const INSULINTYPE_STRING_GLULISINE = @"Apidra®";
NSString *const INSULINTYPE_STRING_LISPRO = @"Humalog®";
NSString *const INSULINTYPE_STRING_ASPART = @"Novolog®";

NSString *const PLOT_BGESTIMATED = @"estimatedBGPlot";
NSString *const PLOT_PREDICT = @"predictPlot";
NSString *const PLOT_TREND_HA1C = @"ha1cTrendPlot";
NSString *const PLOT_TREND_BG = @"bgTrendPlot";
NSString *const PLOT_TREND_15AG = @"15agTrendPlot";

int const SECONDS_IN_ONE_MINUTE = 60;
int const SECONDS_IN_ONE_HOUR = 3600;
int const MINUTES_IN_ONE_HOUR = 60;
int const HOURS_IN_ONE_DAY = 24;
int const DAYS_IN_ONE_WEEK = 7;

/// (milligrams/deciliter) / (millimoles/liter)
int const MG_PER_DL_PER_MMOL_PER_L = 18.0182;

int const BG_EXPIRATION_MINUTES = 720;
int const FOOD_CURVE_LENGTH_MINUTES = 120;
int const PREDICT_MINUTES = 180;

NSString *const ACTION_STRING1 = @"Settles at ";
NSString *const ACTION_STRING2 = @",\n Estimated deficit ";
NSString *const CARBS_STRING = @" carbs.";
NSString *const INSULIN_STRING = @" insulin units.";
NSString *const NO_ACTION_STRING = @",\n within range!";
