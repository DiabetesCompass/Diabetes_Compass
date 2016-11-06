//
//  GraphViewController.m
//  CompassRose
//
//  Created by Jose Carrillo and Christopher Balcells on 11/9/13.
//  Copyright (c) 2013 Clif Alferness. All rights reserved.
//

#import "GraphViewController.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "BGReading.h"
#import "CurveModel.h"
#import "BGAlgorithmModel.h"

@interface GraphViewController ()
@property (strong, nonatomic) CPTGraph* graph;
@property (strong, nonatomic) CPTPlotRange* range;
@property (strong, nonatomic) NSManagedObjectContext* dataContext;
@property (strong, nonatomic) NSMutableArray* annotations;

@end

@implementation GraphViewController {
   
    NSUInteger _graphCount;
    NSUInteger _predictCount;
    BOOL _fingerDown;
    int _fingerUpCount;
    CPTPlot* _currentAnnotatingPlot;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //custom initialization
        [self addObservers];
    }
    return self;
}

- (void)addObservers
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotifications:) name:NOTE_GRAPH_RECALCULATED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotifications:) name:NOTE_PREDICT_RECALCULATED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotifications:) name:NOTE_GRAPH_SHIFTED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotifications:) name:NOTE_PREDICT_SHIFTED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotifications:) name:NOTE_SETTINGS_CHANGED object:nil];
}

- (void)handleNotifications:(NSNotification*) note
{
    NSLog(@"Received a notification whose name was: %@", [note name]);
    if ([[note name] isEqualToString:NOTE_GRAPH_RECALCULATED]) {
        [self performSelectorOnMainThread:@selector(updateGraphData) withObject:self waitUntilDone:NO];
    } else if ([[note name] isEqualToString:NOTE_PREDICT_RECALCULATED]) {
        [self performSelectorOnMainThread:@selector(updatePredictData) withObject:self waitUntilDone:NO];
    } else if ([[note name] isEqualToString:NOTE_GRAPH_SHIFTED]) {
        [self performSelectorOnMainThread:@selector(updateGraphDataWithoutAnimation) withObject:self waitUntilDone:NO];
    } else if ([[note name] isEqualToString:NOTE_PREDICT_SHIFTED]) {
        [self performSelectorOnMainThread:@selector(updatePredictDataWithoutAnimation) withObject:self waitUntilDone:NO];
    } else if ([[note name] isEqualToString:NOTE_SETTINGS_CHANGED]) {
        [self performSelectorOnMainThread:@selector(setupGraph) withObject:self waitUntilDone:NO];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.annotations = [NSMutableArray new];
    _fingerDown = NO;
    _fingerUpCount = 0;
    
    [self setupGraph];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark CPTScatterPlotDelegate methods

-(void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)index {
    _currentAnnotatingPlot = plot;
    _fingerDown = YES;
    // Setup a style for the annotation
    CPTMutableTextStyle *hitAnnotationTextStyle = [CPTMutableTextStyle textStyle];
    //set the plot color for the finger down annotation
    hitAnnotationTextStyle.color = [CPTColor yellowColor];
    hitAnnotationTextStyle.fontSize = 16.0f;
    hitAnnotationTextStyle.fontName = @"Helvetica-Bold";
    
    // Determine point of symbol in plot coordinates
    NSNumber *x = [self numberForPlot:plot field:CPTScatterPlotFieldX recordIndex:index];
    NSNumber *y = [self numberForPlot:plot field:CPTScatterPlotFieldY recordIndex:index];
    NSArray *anchorPoint = [NSArray arrayWithObjects:x, y, nil];
    
    // Determine the screen location
    NSDecimal plotPoint[2];
    NSNumber *plotXvalue = [self numberForPlot:plot
                                         field:CPTScatterPlotFieldX
                                   recordIndex:index];
    plotPoint[CPTCoordinateX] = plotXvalue.decimalValue;
    
    NSNumber *plotYvalue = [self numberForPlot:plot
                                         field:CPTScatterPlotFieldY
                                   recordIndex:index];
    plotPoint[CPTCoordinateY] = plotYvalue.decimalValue;
    
    // Add annotation
    // First make a string for the y value
    NSString *yString = [BGReading displayString:y withConversion:NO];
    
    // Now add the annotation to the plot area
    CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:yString style:hitAnnotationTextStyle];
    CPTPlotSpaceAnnotation* annotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:(CPTXYPlotSpace *)self.graph.defaultPlotSpace  anchorPlotPoint:anchorPoint];
    annotation.contentLayer = textLayer;
    annotation.displacement = CGPointMake(0.0f, 30.0f);//dataPoint.y);
    [self.annotations addObject:annotation];
    [self.graph.plotAreaFrame.plotArea addAnnotation:annotation];
}

#pragma mark CPTPlotSpaceDelegate methods

-(BOOL) plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceDraggedEvent:(UIEvent *)event atPoint:(CGPoint)point
{
    if (_fingerDown && [self.annotations count] != 0) {
        CPTScatterPlot* plot = (CPTScatterPlot*)[self.graph plotWithIdentifier:_currentAnnotatingPlot.identifier];
        NSUInteger index = [plot indexOfVisiblePointClosestToPlotAreaPoint:point];
        
        // Setup a style for the annotation
        CPTMutableTextStyle *hitAnnotationTextStyle = [CPTMutableTextStyle textStyle];
        //set the plot color for the moving finger down annotation
        hitAnnotationTextStyle.color = [CPTColor yellowColor];
        hitAnnotationTextStyle.fontSize = 16.0f;
        hitAnnotationTextStyle.fontName = @"Helvetica-Bold";
        
        // Determine point of symbol in plot coordinates
        NSNumber *x = [self numberForPlot:_currentAnnotatingPlot field:CPTScatterPlotFieldX recordIndex:index];
        NSNumber *y = [self numberForPlot:_currentAnnotatingPlot field:CPTScatterPlotFieldY recordIndex:index];
        NSArray *anchorPoint = [NSArray arrayWithObjects:x, y, nil];
        
        // Determine the screen location
        NSDecimal plotPoint[2];
        NSNumber *plotXvalue = [self numberForPlot:plot
                                             field:CPTScatterPlotFieldX
                                       recordIndex:index];
        plotPoint[CPTCoordinateX] = plotXvalue.decimalValue;
        
        NSNumber *plotYvalue = [self numberForPlot:plot
                                             field:CPTScatterPlotFieldY
                                       recordIndex:index];
        plotPoint[CPTCoordinateY] = plotYvalue.decimalValue;
        
        // Add annotation
        // First make a string for the y value
        NSString *yString = [BGReading displayString:y withConversion:NO];
        
        // Now add the annotation to the plot area
        CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:yString style:hitAnnotationTextStyle];
        CPTPlotSpaceAnnotation* annotation = [self.annotations lastObject];
        annotation.anchorPlotPoint = anchorPoint;
        annotation.displacement = CGPointMake(0.0f, 30.0f);//dataPoint.y);
        annotation.contentLayer = textLayer;
    }
    return YES;
}

-(BOOL) plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceUpEvent:(UIEvent *)event atPoint:(CGPoint)point
{
    _fingerDown = NO;
    _currentAnnotatingPlot = nil;
    if (_fingerUpCount < [self.annotations count] && [self.annotations count] != 0) {
        CPTPlotSpaceAnnotation* annotation = [self.annotations objectAtIndex:_fingerUpCount];
        [CPTAnimation animate:annotation.contentLayer property:@"opacity" from:1.0f to:0.0f duration:0.3f withDelay:0.7f animationCurve:CPTAnimationCurveSinusoidalOut delegate:nil];
        _fingerUpCount += 1;
        
        double delayInSeconds = 1.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if ([self.annotations count] != 0) {
                CPTPlotSpaceAnnotation* annotation = [self.annotations firstObject];
                [self.graph.plotAreaFrame.plotArea removeAnnotation:annotation];
                [self.annotations removeObjectAtIndex:0];
                _fingerUpCount -= 1;
            }
        });
    }
    return YES;
}

-(CGPoint)plotSpace:(CPTPlotSpace *)space willDisplaceBy:(CGPoint)displacement
{
    return CGPointMake(displacement.x*1.5,0);
}


-(CPTPlotRange *)plotSpace:(CPTPlotSpace *)space willChangePlotRangeTo:(CPTPlotRange *)newRange forCoordinate:(CPTCoordinate)coordinate
{
    if (coordinate == CPTCoordinateY) {
        newRange = self.range;//((CPTXYPlotSpace*)space).yRange;
    } else {
        [self updateLabels];
        if ([newRange lengthDouble] < 90) {
            return [CPTPlotRange plotRangeWithLocation:[newRange location]
                                                length: [NSNumber numberWithInt:90]];
        }
    }
    return newRange;
}

#pragma mark CPTDataSource methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    if ([plot.identifier isEqual:@"estimatedBGPlot"]) {
        return _graphCount;
    }
    return _predictCount;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    if (fieldEnum == CPTScatterPlotFieldX) {
        return [NSNumber numberWithInteger:index];
    } else {
        NSNumber* value;
        if ([plot.identifier isEqual:@"estimatedBGPlot"]) {
            value = [[BGAlgorithmModel sharedInstance] getFromGraphArray:index];
        } else {
            value = [[BGAlgorithmModel sharedInstance] getFromPredictArray:index];
        }
        
        if ([value floatValue] < 1.6) {
            value = @(1.6);
        }
        if ([BGReading isInMoles]) {
            return value;
        }
        return @([value floatValue]*CONVERSIONFACTOR);
    }
}

- (void) updateGraphDataWithoutAnimation
{
    //NSLog(@"UpdateDataWithoutAnimation was called");
    [[self.graph plotWithIdentifier:@"estimatedBGPlot"] reloadData];
    [self updateLabels];
    //NSLog(@"UpdateDataWithoutAnimation completed");
}

- (void) updatePredictDataWithoutAnimation
{
    [[self.graph plotWithIdentifier:@"predictPlot"] reloadData];
    [self updateLabels];
}

- (void) updateData
{
    //NSLog(@"Started reloading graph");
    [self updateGraphData];
    [self updatePredictData];
    //NSLog(@"Completed reloading graph");
}

- (void) updateGraphData
{
    NSLog(@"UpdateGraphData was called");
    // If there is any data stored in the cache remove all of it.

    if ([[self.graph plotWithIdentifier:@"estimatedBGPlot"] cachedDataCount] != 0) {
        [[self.graph plotWithIdentifier:@"estimatedBGPlot"] deleteDataInIndexRange:NSMakeRange(0, _graphCount-1)];
    }
    if ([[BGAlgorithmModel sharedInstance] graphArrayCount].intValue != 0) {
        _graphCount = 1;
        [NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(animateGraph:) userInfo:nil repeats:YES];
    }
    [self updateLabels];
}

- (void) updatePredictData
{
    //NSLog(@"UpdatePredictData was called");
    if ([[self.graph plotWithIdentifier:@"predictPlot"] cachedDataCount] != 0) {
        [[self.graph plotWithIdentifier:@"predictPlot"] deleteDataInIndexRange:NSMakeRange(0, _predictCount-1)];
    }
    if ([[BGAlgorithmModel sharedInstance] predictArrayCount].intValue != 0) {
        _predictCount = 1;
        [NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(animatePredict:) userInfo:nil repeats:YES];
    }
    [self updateLabels];
}

- (void)animateGraph:(NSTimer *)timer
{
    if (_graphCount < [[BGAlgorithmModel sharedInstance] graphArrayCount].intValue) {
        [[self.graph plotWithIdentifier:@"estimatedBGPlot"] reloadDataInIndexRange:NSMakeRange(_graphCount-1, 1)];
        _graphCount += 1;
    } else {
        [timer invalidate];
    }
}

- (void)animatePredict:(NSTimer *)timer
{
    if (_predictCount < [[BGAlgorithmModel sharedInstance] predictArrayCount].intValue) {
        [[self.graph plotWithIdentifier:@"predictPlot"] reloadDataInIndexRange:NSMakeRange(_predictCount-1, 1)];
        _predictCount += 1;
    } else {
        [timer invalidate];
    }
}

- (void)updateLabels
//update labels called
{
    int max_range = 300;
    if ([BGReading isInMoles]) {
        max_range = 300/CONVERSIONFACTOR;
    }

    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self.graph.axisSet;
    CPTXYAxis *x = axisSet.xAxis;
    CPTXYAxis *y = axisSet.yAxis;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    y.labelingPolicy = CPTAxisLabelingPolicyNone;
    y.axisConstraints = [CPTConstraints constraintWithLowerOffset:0.0];
    
    CPTMutableLineStyle *clearStyle = [CPTMutableLineStyle lineStyle];
    clearStyle.lineColor = [CPTColor clearColor];
    
    CPTMutableLineStyle *thinWhiteStyle = [CPTMutableLineStyle lineStyle];
    
    thinWhiteStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:0.15f];
    thinWhiteStyle.lineWidth = 1.0f;
    
    x.majorIntervalLength = [[NSNumber numberWithInt:30] decimalValue];
    x.minorTicksPerInterval = 1;
    x.majorTickLineStyle = clearStyle;
    x.minorTickLineStyle = clearStyle;
    x.axisLineStyle = clearStyle;
    x.minorTickLength = 5.0f;
    x.majorTickLength = 7.0f;
    x.majorGridLineStyle = thinWhiteStyle;
    x.labelOffset = 3.0f;
    
    CPTMutableTextStyle* whiteText = [CPTMutableTextStyle textStyle];
    whiteText.color = [[CPTColor whiteColor] colorWithAlphaComponent:1.0f];
    x.labelTextStyle = whiteText;
    
    y.majorIntervalLength = [[NSNumber numberWithFloat:(max_range/3)] decimalValue];
    y.minorTicksPerInterval = 1;
    y.majorTickLineStyle = clearStyle;
    y.minorTickLineStyle = clearStyle;
    y.axisLineStyle = clearStyle;
    y.minorTickLength = 0.0f;
    y.majorTickLength = 0.0f;
    y.majorGridLineStyle = thinWhiteStyle;
    y.labelOffset = -25.0f;
    y.tickLabelDirection = CPTSignPositive;
    
    whiteText.color = [[CPTColor whiteColor] colorWithAlphaComponent:1.0f];
    y.labelTextStyle = whiteText;
    
    NSNumberFormatter *newFormatter = [[NSNumberFormatter alloc] init];
    if ([BGReading isInMoles]) {
        [newFormatter setMinimumFractionDigits:1];
        [newFormatter setMaximumFractionDigits:1];
    } else {
        [newFormatter setMinimumFractionDigits:0];
        [newFormatter setMaximumFractionDigits:0];
    }
    y.labelFormatter = newFormatter;
    
    NSString *formatString;
    NSDateFormatter *dateFormatter;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:SETTING_MILITARY_TIME]) {
        formatString = [NSDateFormatter dateFormatFromTemplate:@"HH:mm" options:0 locale:[NSLocale currentLocale]];
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:formatString];
    } else {
        formatString = [NSDateFormatter dateFormatFromTemplate:@"hh:mm a" options:0 locale:[NSLocale currentLocale]];
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:formatString];
    }
    // This section , I think, sets the x axis time labels
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *nowComponents = [gregorian components:NSMinuteCalendarUnit fromDate:[NSDate date]];
    int firstDateMinute = (int)((nowComponents.minute - (nowComponents.minute % 30)) + 30);
    int first = (int)(firstDateMinute - nowComponents.minute);
    
    int labelInterval = 60;
    // if shrunk plot space.... every other hour
    if ([((CPTXYPlotSpace *)self.graph.defaultPlotSpace).xRange lengthDouble] > 360) {
        labelInterval = 120;
    }
    NSMutableArray* xAxisLabels = [NSMutableArray new];
    NSMutableArray* labelLocations = [NSMutableArray new];
    for (int interval = 0; interval < [[CurveModel sharedInstance] getInsulinDuration]+PREDICT_MINUTES; interval += labelInterval) {
        // Is this where the label shift occurs?.. nope, I don't think so
        if (interval == 0 && first < 1) {
            //[labelLocations addObject:[NSDecimalNumber numberWithInt:first+interval]];
            [labelLocations addObject:[NSDecimalNumber numberWithInt:10]];
        } else {
            [labelLocations addObject:[NSDecimalNumber numberWithInt:first+interval]];
        }
        [xAxisLabels addObject:[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow: (first+interval)*SECONDS_IN_ONE_MINUTE]]];
    }

    NSUInteger labelLocation = 0;
    NSMutableArray *customLabels = [NSMutableArray arrayWithCapacity:[xAxisLabels count]];
    for (NSNumber *location in labelLocations) {
        CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText: [xAxisLabels objectAtIndex:labelLocation++] textStyle:x.labelTextStyle];
        newLabel.tickLocation = [location decimalValue];
        newLabel.offset = x.labelOffset + x.majorTickLength;
        

        [customLabels addObject:newLabel];
    }
    x.axisLabels = [NSSet setWithArray:customLabels];

    int tickLinesInterval = 30;
    if ([((CPTXYPlotSpace *)self.graph.defaultPlotSpace).xRange lengthDouble] > 360) {
        tickLinesInterval = 120;
    } else if ([((CPTXYPlotSpace *)self.graph.defaultPlotSpace).xRange lengthDouble] > 240) {
        tickLinesInterval = 60;
    }
    
    NSMutableArray* majorTickLocations = [NSMutableArray new];
    for (int interval = 0; interval < [[CurveModel sharedInstance] getInsulinDuration]+PREDICT_MINUTES; interval += tickLinesInterval) {
        [majorTickLocations addObject:[NSDecimalNumber numberWithInt:first+interval]];
    }
    x.majorTickLocations = [NSSet setWithArray:majorTickLocations];
    
    
    NSString* Label0 = [[NSNumber numberWithInt:max_range*1/3] stringValue];
    NSString* Label1 = [[NSNumber numberWithInt:max_range*2/3] stringValue];
    NSString* Label2 = [[NSNumber numberWithInt:max_range] stringValue];
    
    NSArray* customTickLocations = [NSArray arrayWithObjects:[NSDecimalNumber numberWithInt:max_range*1/3],
                                    [NSDecimalNumber numberWithInt:max_range*2/3],
                                    [NSDecimalNumber numberWithInt:max_range-max_range/30-0.5], nil];
    NSArray *yAxisLabels = [NSArray arrayWithObjects:Label0, Label1, Label2, nil];
    labelLocation = 0;
    customLabels = [NSMutableArray arrayWithCapacity:[yAxisLabels count]];
    for (NSNumber *tickLocation in customTickLocations) {
        CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText: [yAxisLabels objectAtIndex:labelLocation++] textStyle:y.labelTextStyle];
        newLabel.tickLocation = [tickLocation decimalValue];
        newLabel.offset = y.labelOffset + y.majorTickLength;
        [customLabels addObject:newLabel];
    }
    y.axisLabels = [NSSet setWithArray:customLabels];
}
         
- (void)setupGraph
{
    NSLog(@"setupGraph of GraphViewController is called.");
    int max_range = 300;
    if ([BGReading isInMoles]) {
        max_range = 300/CONVERSIONFACTOR;
    }
    NSLog(@"The value of max_range is: %d", max_range);
    if (self.graph) {
        CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
        self.range = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat(max_range)];
        plotSpace.yRange = self.range;
        plotSpace.globalYRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat(max_range)];
        [self updateLabels];
        return;
    }
    
    //Make the boundaries of the graph and hosting view the size of the containing view.
    
    self.graph = [[CPTXYGraph alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - 253)];
    CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - 253)];
    [self.view addSubview:hostingView];
    
    hostingView.hostedGraph = self.graph;
    hostingView.collapsesLayers = NO;
    
    //NSLog(@"The number of subviews is: %d", self.view.subviews.count);
    
    //Pad the plot area. This ensures that the tick marks and labels
    //will show up as is appropriate.
    self.graph.plotAreaFrame.paddingBottom = 30.0;
    self.graph.paddingBottom = 0.0;
    self.graph.paddingTop = 0.0;
    self.graph.paddingLeft = 0.0;
    self.graph.paddingRight = 0.0;
    
    //This is shared by all graphs in the plotSpace.
    //It sets the coordinates of the axes
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    //plotSpace.allowsMomentum = YES; //this is buggy. And doesn't even help.
    
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat(PREDICT_MINUTES)];
    self.range = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat(max_range)];
    plotSpace.yRange = self.range;
    plotSpace.delegate = self;
    
    plotSpace.globalXRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromInteger(PREDICT_MINUTES+[[CurveModel sharedInstance] getInsulinDuration])];
    plotSpace.globalYRange = self.range;

    [self updateLabels];
    
    CPTScatterPlot* estimatedBGPlot = [[CPTScatterPlot alloc] initWithFrame:self.graph.defaultPlotSpace.accessibilityFrame];
    estimatedBGPlot.identifier = @"estimatedBGPlot";
    //estimatedBGPlot.interpolation = CPTScatterPlotInterpolationCurved;
    CPTMutableLineStyle *ls1 = [CPTMutableLineStyle lineStyle];
    ls1.lineWidth = 3.0f;
   
    //main plot color (yellow or white)
    ls1.lineColor = [CPTColor yellowColor];
    
    estimatedBGPlot.dataLineStyle = ls1;
    estimatedBGPlot.plotSymbolMarginForHitDetection = (CGFloat) 10.0f;
    estimatedBGPlot.dataSource = self;
    estimatedBGPlot.delegate = self;
    [self.graph addPlot:estimatedBGPlot];
    
    CPTScatterPlot* predictPlot = [[CPTScatterPlot alloc] initWithFrame:self.graph.defaultPlotSpace.accessibilityFrame];
    predictPlot.identifier = @"predictPlot";
    //predictPlot.interpolation = CPTScatterPlotInterpolationCurved;
    CPTMutableLineStyle *ls2 = [CPTMutableLineStyle lineStyle];
    ls2.lineWidth = 3.0f;
    //predicted plot color (green)
    ls2.lineColor = [CPTColor greenColor];
    ls2.dashPattern=[NSArray arrayWithObjects:[NSDecimalNumber numberWithInt:5],[NSDecimalNumber numberWithInt:5],nil];
    predictPlot.dataLineStyle = ls2;
    estimatedBGPlot.plotSymbolMarginForHitDetection = (CGFloat) 10.0f;
    predictPlot.dataSource = self;
    predictPlot.delegate = self;
    [self.graph addPlot:predictPlot];
    NSLog(@"setupGraph of GraphViewController is finished.");
}

@end
