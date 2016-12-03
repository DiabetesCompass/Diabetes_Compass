//
//  TrendsViewController.m
//  CompassRose
//
//  Created by Jose Carrillo on 11/23/13.
//  Copyright (c) 2013 Clif Alferness. All rights reserved.
//

#import "TrendsContainerViewController.h"
#import "Constants.h"
#import "TrendsAlgorithmModel.h"
#import "CollapsedTrendView.h"
#import "ExpandedTrendView.h"
#import "CollapsedTrendMenu.h"
#import <FontAwesome+iOS/NSString+FontAwesome.h>

#define SCREEN_INDEX_HA1CTREND 0
#define SCREEN_INDEX_BGTREND   1
#define SCREEN_INDEX_MENU      2

@interface TrendsContainerViewController ()
@property (strong, nonatomic) CPTGraph* ha1cGraph;
@property (strong, nonatomic) CPTGraph* bgGraph;
//@property (strong, nonatomic) CPTGraph* ag15Graph;
@end

@implementation TrendsContainerViewController {
    APPaginalTableView *_paginalTableView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    _paginalTableView = [[APPaginalTableView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
    _paginalTableView.dataSource = self;
    _paginalTableView.delegate = self;
    
    [self.view addSubview:_paginalTableView];
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    /*if (UIDeviceOrientationIsPortrait(toInterfaceOrientation)) {
        self.graph.frame = self.view.bounds;
    } else {
        self.graph.frame = self.view.bounds;
    }*/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.ha1cGraph = nil;
    self.bgGraph = nil;
    //self.ag15Graph = nil;
}

#pragma mark - APPaginalTableViewDataSource

- (NSUInteger)numberOfElementsInPaginalTableView:(APPaginalTableView *)managerView
{
    NSUInteger numberOfElements = 3;
    return numberOfElements;
}

- (UIView *)paginalTableView:(APPaginalTableView *)paginalTableView collapsedViewAtIndex:(NSUInteger)index
{
    UIView *collapsedView = [self createCollapsedViewAtIndex:index];
    return collapsedView;
}

- (UIView *)paginalTableView:(APPaginalTableView *)paginalTableView expandedViewAtIndex:(NSUInteger)index
{
    UIView *expandedView = [self createExpandedViewAtIndex:index];
    return expandedView;
}

- (UIView *)createCollapsedViewAtIndex:(NSUInteger)index
{
    CollapsedTrendView *collapsedView;
    if (index == SCREEN_INDEX_MENU) {
        collapsedView = [[[NSBundle mainBundle] loadNibNamed:@"CollapsedTrendMenu" owner:self options:nil] objectAtIndex:0];
        ((CollapsedTrendMenu*)collapsedView).backButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:24];
        [((CollapsedTrendMenu*)collapsedView).backButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"icon-home"] forState:UIControlStateNormal];
        [((CollapsedTrendMenu*)collapsedView).backButton addTarget:self action:@selector(backHome) forControlEvents:UIControlEventTouchUpInside];
        collapsedView.expandable = NO;
    } else {
        collapsedView = [[[NSBundle mainBundle] loadNibNamed:@"CollapsedTrend" owner:self options:nil] objectAtIndex:0];
        collapsedView.expandable = YES;
    }
    CGRect frame = collapsedView.frame;
    collapsedView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    float screenMultiple = [[[NSUserDefaults standardUserDefaults] valueForKey:SETTING_SCREEN_CONSTANT] floatValue];
    switch (index) {
        case SCREEN_INDEX_HA1CTREND: {
            frame.size.height = 255 * screenMultiple;
            collapsedView.trendTitleLabel.text = @"HA1c";
            Ha1cReading *lastHa1cReading = [[[TrendsAlgorithmModel sharedInstance] ha1cArray] lastObject];
//            NSLog(@"last HA1c reading %@", lastHa1cReading);
            Ha1cReading *firstHa1cReading = [[[TrendsAlgorithmModel sharedInstance] ha1cArray] firstObject];
//            NSLog(@"first HA1c reading %@", firstHa1cReading);
            
/*            int total_days = [lastHa1cReading.timeStamp timeIntervalSinceDate:firstHa1cReading.timeStamp]/(SECONDS_IN_ONE_MINUTE*MINUTES_IN_ONE_HOUR*HOURS_IN_ONE_DAY);
            NSLog(@"total days = %d", total_days);
*/
            
                collapsedView.valueLabel.text = [lastHa1cReading.quantity stringValue];
            
/*            if (!firstHa1cReading) {
                // Do not display any text if no reading has been made.
                collapsedView.valueLabel.font = [UIFont systemFontOfSize:20];
                collapsedView.valueLabel.text = @"No Data";
            } else if (total_days >= 90) {
                // If there is 90 days worth of data, then the data can be displayed without any warning.
                collapsedView.valueLabel.text = [lastHa1cReading.quantity stringValue];
            } else if (total_days >= 30) {
                // Still display the last reading value, but include a warning text above the graph.
                collapsedView.valueLabel.text = [[lastHa1cReading.quantity stringValue] stringByAppendingString:@"*"];
            } else {
                // Do not display any data, only include a warning symbol; because there isn't enough past history.
                collapsedView.valueLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:40];
                collapsedView.valueLabel.text = [NSString fontAwesomeIconStringForIconIdentifier:@"icon-warning-sign"];
            }
*/
            collapsedView.backgroundColor = [UIColor colorWithRed:131.0/255.0 green:198.0/255.0 blue:242.0/255.0 alpha:1];
            break;
        }
        case SCREEN_INDEX_BGTREND: {
            frame.size.height = 255 * screenMultiple;
            collapsedView.trendTitleLabel.text = @"BG";
            BGReading *lastBGReading = [[[TrendsAlgorithmModel sharedInstance] bgArray] lastObject];
            
            if (!lastBGReading) {
                collapsedView.valueLabel.font = [UIFont systemFontOfSize:20];
                collapsedView.valueLabel.text = @"No data";
            } else {
                //collapsedView.valueLabel.text = [BGReading displayString:lastBGReading.quantity withConversion:YES];
                collapsedView.valueLabel.text = [BGReading displayString:lastBGReading.quantity withConversion:YES];
            }
            
            collapsedView.backgroundColor = [UIColor colorWithRed:85.0/255.0 green:150.0/255.0 blue:194.0/255.0 alpha:1];
            break;
        }
            /*
        case 2: {
            frame.size.height = 170 * screenMultiple;
            collapsedView.trendTitleLabel.text = @"1,5AG";
            AG15Reading *last15AGReading = [[[TrendsAlgorithmModel sharedInstance] ag15Array] lastObject];
            collapsedView.valueLabel.text = [last15AGReading.quantity stringValue];
            collapsedView.backgroundColor = [UIColor colorWithRed:55.0/255.0 green:93.0/255.0 blue:140.0/255.0 alpha:1];
            break;
        }
             */
        default:
            frame.size.height = 58 * screenMultiple;
            
            collapsedView.backgroundColor = [UIColor blackColor];
            break;
    }
    
    collapsedView.frame = frame;
    return collapsedView;
}

- (UIView *)createExpandedViewAtIndex:(NSUInteger)index
{
    ExpandedTrendView *expandedView = [[[NSBundle mainBundle] loadNibNamed:@"ExpandedTrend" owner:self options:nil] objectAtIndex:0];
    expandedView.warningLabel.text = @"";
    expandedView.noDataLabel.text = @"";
    expandedView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height );
    expandedView.trendsButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:24];
    [expandedView.trendsButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"icon-list"] forState:UIControlStateNormal];
    [expandedView.trendsButton addTarget:self action:@selector(showList) forControlEvents:UIControlEventTouchUpInside];
    
    BOOL draw_graph = true;
    
    if (index == SCREEN_INDEX_HA1CTREND) {
        expandedView.trendTitleLabel.text = @"HA1c";
        Ha1cReading *lastHa1cReading = [[[TrendsAlgorithmModel sharedInstance] ha1cArray] lastObject];
        Ha1cReading *firstHa1cReading = [[[TrendsAlgorithmModel sharedInstance] ha1cArray] firstObject];
        
        int total_days = [lastHa1cReading.timeStamp timeIntervalSinceDate:firstHa1cReading.timeStamp]/(SECONDS_IN_ONE_MINUTE*MINUTES_IN_ONE_HOUR*HOURS_IN_ONE_DAY);
//        NSLog(@"total days = %d", total_days);
        
        if (![[[TrendsAlgorithmModel sharedInstance] ha1cArray] firstObject]) {
            expandedView.noDataLabel.text = @"Estimated Ha1c requires 30 days of data";
            draw_graph = false;
        } /*else if (total_days >= 90) {
            // If there is 90 days worth of data, then the data can be displayed without any warning.
        }*/
        else if (total_days >= 30) {
            // Include a warning text above the graph.
            expandedView.warningLabel.text = [NSString stringWithFormat:@" Currently %d days of data", total_days];
        } else {
            // Do not display any data, only include a warning symbol; because there isn't enough past history.
            expandedView.noDataLabel.text = @"Estimated Ha1c requires 30 days of data";
            draw_graph = false;
        }
        
    } else if (index == SCREEN_INDEX_BGTREND) {
        expandedView.trendTitleLabel.text = @"BG";
        if (![[[TrendsAlgorithmModel sharedInstance] bgArray] firstObject]) {
            draw_graph = false;
            expandedView.noDataLabel.text = @"No blood glucose data has been input.";
        }
    } else {
        expandedView.trendTitleLabel.text = @"";
    }

    if (index==SCREEN_INDEX_MENU) {
        expandedView = nil;
    } else if (!draw_graph) {
        //do not draw the graph
    } else {
        [self createGraphForIndex:index forView:expandedView];
    }
    
    return expandedView;
}

- (void) showList {
    [_paginalTableView closeElementWithCompletion:nil animated:YES];
}

- (void) backHome {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - APPaginalTableViewDelegate

- (BOOL)paginalTableView:(APPaginalTableView *)managerView
      openElementAtIndex:(NSUInteger)index
      onChangeHeightFrom:(CGFloat)initialHeight
                toHeight:(CGFloat)finalHeight
{
    BOOL open = _paginalTableView.isExpandedState;
    APPaginalTableViewElement *element = [managerView elementAtIndex:index];
    
    if (initialHeight > finalHeight) { //open
        open = finalHeight > element.expandedHeight * 0.8f;
    }
    else if (initialHeight < finalHeight) { //close
        open = finalHeight > element.expandedHeight * 0.2f;
    }
    return open;
}

- (void)paginalTableView:(APPaginalTableView *)paginalTableView didSelectRowAtIndex:(NSUInteger)index
{
    [_paginalTableView openElementAtIndex:index completion:nil animated:YES];
}

#pragma mark CPTDataSource methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    if ([plot.identifier isEqual:PLOT_TREND_HA1C]) {
        return [[[TrendsAlgorithmModel sharedInstance] ha1cArrayCount] integerValue];
    } else if ([plot.identifier isEqual:PLOT_TREND_BG]) {
        return [[[TrendsAlgorithmModel sharedInstance] bgArrayCount] integerValue];
    }
        /*
    else if ([plot.identifier isEqual:PLOT_TREND_15AG]) {
        return [[[TrendsAlgorithmModel sharedInstance] ag15ArrayCount] integerValue];
    } */
    return 0;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    if (fieldEnum == CPTScatterPlotFieldX) {
        if ([plot.identifier isEqual:PLOT_TREND_HA1C]) {
            Ha1cReading* reading = [[TrendsAlgorithmModel sharedInstance] getFromHa1cArray:index];
            return @([reading.timeStamp timeIntervalSinceDate:[[[[TrendsAlgorithmModel sharedInstance] ha1cArray] firstObject] timeStamp]]);
        } else { //([plot.identifier isEqual:PLOT_TREND_BG]) {
            BGReading* reading = [[TrendsAlgorithmModel sharedInstance] getFromBGArray:index];
            NSNumber* result = @((int)[reading.timeStamp timeIntervalSinceDate:[[[[TrendsAlgorithmModel sharedInstance] bgArray] firstObject] timeStamp]]/60+0.5);
            return result;
        }
            /*
        } else {
            AG15Reading* reading = [[TrendsAlgorithmModel sharedInstance] getFromAg15Array:index];
            return @([reading.timeStamp timeIntervalSinceDate:[[[[TrendsAlgorithmModel sharedInstance] ag15Array] firstObject] timeStamp]]);
        }  */
    } else {
        if ([plot.identifier isEqual:PLOT_TREND_HA1C]) {
            Ha1cReading* reading = [[TrendsAlgorithmModel sharedInstance] getFromHa1cArray:index];
            return reading.quantity;
        } else { //if ([plot.identifier isEqual:PLOT_TREND_BG]) {
            BGReading* reading = [[TrendsAlgorithmModel sharedInstance] getFromBGArray:index];
            if ([BGReading isInMoles]) {
                return reading.quantity;
            }
            return @([reading.quantity floatValue]*CONVERSIONFACTOR);
        }
        
        /*else {
            AG15Reading* reading = [[TrendsAlgorithmModel sharedInstance] getFromAg15Array:index];
            return reading.quantity;
        }*/
    }
}

- (void)createGraphForIndex:(NSUInteger)index forView:(UIView*)view
{
    
    //Make the boundaries of the graph and hosting view the size of the containing view.
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CPTGraph* graph = [[CPTXYGraph alloc] initWithFrame:CGRectMake(0, 60, screenRect.size.width, screenRect.size.height -60*2)];
    CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(0, 60, screenRect.size.width, screenRect.size.height -60*2)];
    [view addSubview:hostingView];
    
    hostingView.hostedGraph = graph;
    hostingView.collapsesLayers = NO;
    
    //Pad the plot area. This ensures that the tick marks and labels
    //will show up as is appropriate.
    graph.plotAreaFrame.paddingBottom = 30.0;
    graph.plotAreaFrame.paddingLeft = 20.0;
    graph.plotAreaFrame.paddingTop = 30.0 + 50.0;
    graph.plotAreaFrame.paddingRight = 20.0;
    graph.paddingBottom = 0.0;
    graph.paddingTop = 0.0;
    graph.paddingLeft = 0.0;
    graph.paddingRight = 0.0;
    
    //This is shared by all graphs in the plotSpace.
    //It sets the coordinates of the axes
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    
    NSTimeInterval total_minutes;
    Reading* firstReading;
    Reading* lastReading;
    switch (index) {
        case 0:
            firstReading = [[[TrendsAlgorithmModel sharedInstance] ha1cArray] firstObject];
//            NSLog(@"first Reading %@", firstReading);
            lastReading = [[[TrendsAlgorithmModel sharedInstance] ha1cArray] lastObject];
//            NSLog(@"last Reading %@", lastReading);
            plotSpace.yRange = [CPTPlotRange plotRangeWithLocation: [NSNumber numberWithFloat: 0]
                                                            length: [NSNumber numberWithFloat: 10]];
            break;
        case 1:
            firstReading = [[[TrendsAlgorithmModel sharedInstance] bgArray] firstObject];
            lastReading = [[[TrendsAlgorithmModel sharedInstance] bgArray] lastObject];
            plotSpace.yRange = [CPTPlotRange plotRangeWithLocation: [NSNumber numberWithFloat: 0]
                                                            length: [NSNumber numberWithFloat: 300]];
            break;
            /*
        case 2:
            firstReading = [[[TrendsAlgorithmModel sharedInstance] ag15Array] firstObject];
            lastReading = [[[TrendsAlgorithmModel sharedInstance] ag15Array] lastObject];
            plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat(21)];
            break;
             */
            
        default:
            NSLog(@"Error! bad index");
            break;
    }
    //Minutes between the last reading and the first reading.
    total_minutes = [lastReading.timeStamp timeIntervalSinceDate:firstReading.timeStamp]/SECONDS_IN_ONE_MINUTE;
    float one_week = MINUTES_IN_ONE_HOUR*HOURS_IN_ONE_DAY*DAYS_IN_ONE_WEEK;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation: [NSNumber numberWithFloat: (total_minutes - one_week)]
                                                    length: [NSNumber numberWithFloat: one_week]];
    plotSpace.globalXRange = [CPTPlotRange plotRangeWithLocation: [NSNumber numberWithFloat:0]
                                                          length: [NSNumber numberWithFloat: total_minutes]];
    plotSpace.delegate = self;
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x = axisSet.xAxis;
    CPTXYAxis *y = axisSet.yAxis;
    x.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
    y.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
    y.axisConstraints = [CPTConstraints constraintWithLowerOffset:10.0];
    
    CPTMutableLineStyle *clearStyle = [CPTMutableLineStyle lineStyle];
    clearStyle.lineColor = [CPTColor clearColor];
    
    CPTMutableLineStyle *thinWhiteStyle = [CPTMutableLineStyle lineStyle];
    thinWhiteStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:0.4f];
    thinWhiteStyle.lineWidth = 1.0f;
    
    //x.majorIntervalLength = [[NSNumber numberWithInt:MINUTES_IN_ONE_HOUR*HOURS_IN_ONE_DAY] decimalValue];
    //x.minorTicksPerInterval = 1;
    x.majorTickLineStyle = thinWhiteStyle;
    x.minorTickLineStyle = clearStyle;
    x.axisLineStyle = thinWhiteStyle;
    //x.minorTickLength = 5.0f;
    //x.majorTickLength = 7.0f;
    //x.majorGridLineStyle = thinWhiteStyle;
    x.labelOffset = 3.0f;
    
    CPTMutableTextStyle* whiteText = [CPTMutableTextStyle textStyle];
    whiteText.color = [[CPTColor whiteColor] colorWithAlphaComponent:0.3f];
    x.labelTextStyle = whiteText;
    
    //y.majorIntervalLength = [[NSNumber numberWithFloat:plotSpace.yRange.lengthDouble/5] decimalValue];
    //y.minorTicksPerInterval = 1;
    y.majorTickLineStyle = clearStyle;
    y.minorTickLineStyle = clearStyle;
    y.axisLineStyle = clearStyle;
    //y.minorTickLength = 0.0f;
    //y.majorTickLength = 0.0f;
    //y.labelOffset = 3.0f;
    
    whiteText.color = [[CPTColor whiteColor] colorWithAlphaComponent:0.5f];
    y.labelTextStyle = whiteText;
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    if ([BGReading isInMoles]) {
        [numberFormatter setMinimumFractionDigits:1];
        [numberFormatter setMaximumFractionDigits:1];
    } else {
        [numberFormatter setMinimumFractionDigits:0];
        [numberFormatter setMaximumFractionDigits:0];
    }
    y.labelFormatter = numberFormatter;
    
    NSString *formatString;
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    formatString = [NSDateFormatter dateFormatFromTemplate:@"EE" options:0 locale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:formatString];
    
    CPTCalendarFormatter* cptFormatter = [CPTCalendarFormatter new];
    cptFormatter.dateFormatter = dateFormatter;
    cptFormatter.referenceDate = firstReading.timeStamp;
    cptFormatter.referenceCalendarUnit = NSCalendarUnitMinute;
    x.labelFormatter =  cptFormatter;
    
    CPTScatterPlot* trendDataPlot = [[CPTScatterPlot alloc] initWithFrame:graph.defaultPlotSpace.accessibilityFrame];
    switch (index) {
        case 0:
            view.backgroundColor = [UIColor colorWithRed:85.0/255.0 green:150.0/255.0 blue:194.0/255.0 alpha:1];
            trendDataPlot.identifier = PLOT_TREND_HA1C;
            break;
        case 1:
            view.backgroundColor = [UIColor colorWithRed:85.0/255.0 green:150.0/255.0 blue:194.0/255.0 alpha:1];
            trendDataPlot.identifier = PLOT_TREND_BG;
            break;
            /*
        case 2:
            view.backgroundColor = [UIColor colorWithRed:55.0/255.0 green:93.0/255.0 blue:140.0/255.0 alpha:1];
            trendDataPlot.identifier = PLOT_TREND_15AG;
            break;
             */
        default:
            NSLog(@"Error! bad index");
            break;
    }
    
    CPTPlotSymbol *circlePlotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    circlePlotSymbol.fill = [CPTFill fillWithColor:[CPTColor whiteColor]];
    circlePlotSymbol.size = CGSizeMake(5, 5);
    circlePlotSymbol.shadow = nil;
    circlePlotSymbol.lineStyle = clearStyle;
    
    trendDataPlot.plotSymbol = circlePlotSymbol;
    
    trendDataPlot.dataLineStyle = nil;
    trendDataPlot.dataSource = self;
    [graph addPlot:trendDataPlot];
    
    switch (index) {
        case 0:
            self.ha1cGraph = graph;
            break;
        case 1:
            self.bgGraph = graph;
            break;
            /*
        case 2:
            self.ag15Graph = graph;
            break;
             */
        default:
            NSLog(@"Error! bad index");
            break;
    }
    NSLog(@"setupGraph for TrendContainerViewController is finished.");
}

#pragma mark CPTPlotSpaceDelegate methods

-(CGPoint)plotSpace:(CPTPlotSpace *)space willDisplaceBy:(CGPoint)displacement
{
    return CGPointMake(displacement.x*1.5,0);
}


-(CPTPlotRange *)plotSpace:(CPTPlotSpace *)space willChangePlotRangeTo:(CPTPlotRange *)newRange forCoordinate:(CPTCoordinate)coordinate
{
    if (coordinate == CPTCoordinateY) {
        newRange = ((CPTXYPlotSpace*)space).yRange;
    } else {
        CPTXYAxisSet *axisSet = (CPTXYAxisSet *)space.graph.axisSet;
        
        NSString *formatString;
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        CPTCalendarFormatter* cptFormatter = (CPTCalendarFormatter*) axisSet.xAxis.labelFormatter;
        
        if (newRange.lengthDouble >= MINUTES_IN_ONE_HOUR*HOURS_IN_ONE_DAY*DAYS_IN_ONE_WEEK*52) {
            formatString = [NSDateFormatter dateFormatFromTemplate:@"MMM-yyyy" options:0 locale:[NSLocale currentLocale]];
        } else if (newRange.lengthDouble >= MINUTES_IN_ONE_HOUR*HOURS_IN_ONE_DAY*8) {
            formatString = [NSDateFormatter dateFormatFromTemplate:@"MMM dd" options:0 locale:[NSLocale currentLocale]];
        } else if (newRange.lengthDouble >= MINUTES_IN_ONE_HOUR*HOURS_IN_ONE_DAY*2) {
            formatString = [NSDateFormatter dateFormatFromTemplate:@"Md" options:0 locale:[NSLocale currentLocale]];
        } else {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:SETTING_MILITARY_TIME]) {
                formatString = [NSDateFormatter dateFormatFromTemplate:@"HH Md" options:0 locale:[NSLocale currentLocale]];
            } else {
                formatString = [NSDateFormatter dateFormatFromTemplate:@"hh a Md" options:0 locale:[NSLocale currentLocale]];
            }
            newRange = ((CPTXYPlotSpace*)space).xRange;
        }
        [dateFormatter setDateFormat:formatString];
        cptFormatter.dateFormatter = dateFormatter;
        axisSet.xAxis.labelFormatter = cptFormatter;
    }
    
    return newRange;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}


@end
