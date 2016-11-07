//
//  BackgroundTaskDelegate.m
//  CompassRose
//
//  Created by Christopher Balcells on 11/11/13.
//  Copywrite (c) 2014 Clif Alferness. All rights reserved.
//

#import "BackgroundTaskDelegate.h"
#import "BGAlgorithmModel.h"
#import "Constants.h"
#import "GraphViewController.h"
#import "HomeViewController.h"
#import "AppDelegate.h"

@interface BackgroundTaskDelegate()
@property (strong, nonatomic) dispatch_source_t predictBG;
@property (strong, nonatomic) dispatch_queue_t predict_queue;

@end

@implementation BackgroundTaskDelegate

+ (id)sharedInstance
{
    static BackgroundTaskDelegate *sharedDelegate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDelegate = [[self alloc] init];
    });
    return sharedDelegate;
}

- (UIViewController*) getCurrentViewController
{
    AppDelegate* delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UINavigationController *navigationController = (UINavigationController *)delegate.window.rootViewController;
    return navigationController.topViewController;
}

- (dispatch_queue_t) getPredictQueue {
    return self.predict_queue;
}

- (void) start_graph
{
    self.predict_queue = dispatch_queue_create("predict_queue", 0);
    dispatch_async(self.predict_queue, ^{[[BGAlgorithmModel sharedInstance] calculateGraphArray];});
    
    self.predictBG =  dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.predict_queue);
    dispatch_source_set_event_handler(self.predictBG, ^{
        [[BGAlgorithmModel sharedInstance] shiftGraphArray];
        [[BGAlgorithmModel sharedInstance] calculatePredictArray];
    });
    
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    NSDateComponents *nowComponents = [gregorian components:NSSecondCalendarUnit fromDate:[NSDate date]];
    int SecondsToNextMinute = (int) (60 - nowComponents.second);
    
    dispatch_source_set_timer(self.predictBG,
                              // Dispatch at the top of the next minute.
                              dispatch_walltime(DISPATCH_TIME_NOW, SecondsToNextMinute * NSEC_PER_SEC),
                              60ull * NSEC_PER_SEC, //interval = 1 minute
                              1ull * NSEC_PER_SEC); //leeway = 1 second
    dispatch_resume(self.predictBG);
}

- (void) stop_graph
{
    dispatch_source_cancel(self.predictBG);
}

- (void) pause_graph
{
    dispatch_suspend(self.predictBG);
}

- (void) resume_graph
{
    dispatch_resume(self.predictBG);
}

@end
