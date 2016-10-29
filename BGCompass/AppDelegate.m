//
//  AppDelegate.m
//  BG Compass
//
//  Created by Jose Carrillo and Christopher Balcells on 11/6/13.
//  Copyright (c) 2013 Clif Alferness. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "InsulinReading.h"
#import "BGReading.h"
#import "FoodReading.h"
#import "APIDelegate.h"
#import "Constants.h"
#import "BackgroundTaskDelegate.h"
#import "CurveModel.h"
#import "BGAlgorithmModel.h"
#import "TrendsAlgorithmModel.h"
#import "ImportExportViewController.h"


@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // check for first launch/tutorial
    float screenMultiple;
    if([UIScreen mainScreen].bounds.size.height == 568){
        // iPhone retina-4 inch
        screenMultiple = 1;
    } else{
        // iPhone retina-3.5 inch
        screenMultiple = 480.0/568.0;
    }
    
    
    NSDictionary *appDefaults = @{
                                  SETTING_COMPLETED_TUTORIAL: @NO,
                                  SETTING_INSULIN_SENSITIVITY: [NSNumber numberWithFloat:30.0],
                                  SETTING_INSULIN_TYPE: [NSNumber numberWithInt:INSULINTYPE_REGULAR],
                                  SETTING_INSULIN_DURATION: [NSNumber numberWithInt:515],
                                  SETTING_UNITS_IN_MOLES: [NSNumber numberWithBool:NO],
                                  SETTING_MILITARY_TIME: [NSNumber numberWithBool:NO],
                                  SETTING_CARB_SENSITIVITY: [NSNumber numberWithFloat:3.0],
                                  SETTING_IDEALBG_MAX: [NSNumber numberWithFloat:120],
                                  SETTING_IDEALBG_MIN: [NSNumber numberWithFloat:80],
                                  SETTING_15AG_CONSTANT: [NSNumber numberWithFloat:8.0],
                                  SETTING_HA1C_CONSTANT: [NSNumber numberWithFloat:5.0],
                                  SETTING_SCREEN_CONSTANT: [NSNumber numberWithFloat:screenMultiple]
                                  };
    
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:SETTING_COMPLETED_TUTORIAL])
    {
        // app already launched
        
    } else
    {
        
        // Override point for customization after application launch.
        
        self.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil]instantiateViewControllerWithIdentifier:@"tutorialVC"];
    }
    
    /* Segue to warning popup view */
    //[ performSegueWithIdentifier:@"warningPopup" sender:self];
    
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"CompassRose.sqlite"];
    [TrendsAlgorithmModel sharedInstance];
    [[APIDelegate sharedInstance] setupAPI];
    [[BackgroundTaskDelegate sharedInstance] start_graph];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data Stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc]
                                 initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CompassRose" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CompassRose.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

//handle csv files
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    //self.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil]instantiateViewControllerWithIdentifier:@"importExportViewController"];
    NSLog(@"Import initiated");
    //[((ImportExportViewController*)self.window.rootViewController) parseFile:url];
    return YES;
}

@end
