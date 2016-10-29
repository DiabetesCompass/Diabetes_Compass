//
//  BackgroundTaskDelegate.h
//  CompassRose
//
//  Created by Christopher Balcells on 11/11/13.
//  Copywrite (c) 2014 Clif Alferness. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BackgroundTaskDelegate : NSObject

+ (id)sharedInstance;
- (dispatch_queue_t) getPredictQueue;

- (void)start_graph;
- (void)stop_graph;
- (void)pause_graph;
- (void)resume_graph;

@end
