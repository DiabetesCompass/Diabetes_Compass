//
//  APIDelegate.m
//  CompassRose
//
//  Created by Jose Carrillo on 11/11/13.
//  Copywrite (c) 2014 Clif Alferness. All rights reserved.
//

#define NUTRITIONIXBASEURL @"http://api.nutritionix.com/v1_1"
#define NUTRITIONIXAPPID @"cdcfa8b6"
#define NUTRITIONIXAPPKEY @"d9867c57ba73adb36ad3c24128b8f8f6"
#define NUTRITIONIXSEARCHURL @"search"
#define NUTRITIONIXUPCURL @"item"


#import "APIDelegate.h"
#import <RestKit/RestKit.h>
#import "ItemSelectionTableViewController.h"
#import "NutritionixSearchFood.h"
#import "NutritionixUPCFood.h"
#import "FoodReading.h"
#import "Utilities.h"
#import "Reachability.h"

@interface APIDelegate()

@property (strong, nonatomic) RKObjectManager *queryManager;
@property (strong, nonatomic) RKObjectManager *upcManager;
@property (strong, nonatomic) NSString *lastQuery;
@property (assign, nonatomic) BOOL internetIsReachable;

@end

//TODO: Check whether or not internet is connected.
@implementation APIDelegate {
    Reachability *internetReachableFoo;
}

/* This class method implements the singleton design pattern. */
+ (id)sharedInstance
{
    static APIDelegate *sharedAPIDelegate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAPIDelegate = [[self alloc] init];
    });
    return sharedAPIDelegate;
}

+ (NSString *)getMainUrl
{
    return NUTRITIONIXBASEURL;
}

- (id)init
{
    if (self = [super init]) {
        self.internetIsReachable = NO;
        [self testInternetConnection];
    }

    return self;
}

- (void)dealloc
{
    //never will be called
}

/* Setup RestKit so we have a route for food queries. */
- (void)setupAPI
{
    RKLogConfigureByName("RestKit/Network", RKLogLevelOff);
    
    // Configure the route for querying with a UPC.
    self.upcManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:NUTRITIONIXBASEURL]];

    RKObjectMapping *requestUPCMapping = [RKObjectMapping requestMapping];
    [requestUPCMapping addAttributeMappingsFromDictionary:@{@"upc"    : @"upc",
                                                            @"appId"  : @"appId",
                                                            @"appKey" : @"appKey"}];
    
    RKRequestDescriptor *searchUPCRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:requestUPCMapping objectClass:[NutritionixUPCFood class] rootKeyPath:nil method:RKRequestMethodGET];
    [self.upcManager addRequestDescriptor:searchUPCRequestDescriptor];
    
    RKObjectMapping *responseUPCMapping = [RKObjectMapping mappingForClass:[NutritionixUPCFood class]];
    [responseUPCMapping addAttributeMappingsFromDictionary:@{@"item_id"               : @"itemID",
                                                             @"item_name"             : @"name",
                                                             @"brand_name"            : @"brand",
                                                             @"nf_total_carbohydrate" : @"carbs",
                                                             @"nf_serving_size_qty"   : @"servingUnitQuantity",
                                                             @"nf_serving_size_unit"  : @"servingUnit"}];
    
    RKResponseDescriptor *searchUPCResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseUPCMapping method:RKRequestMethodGET pathPattern:NUTRITIONIXUPCURL keyPath:nil statusCodes:[NSIndexSet indexSetWithIndex:200]];
    [self.upcManager addResponseDescriptor:searchUPCResponseDescriptor];
     
    [self.upcManager.router.routeSet addRoute:[RKRoute routeWithRelationshipName:@"foodUPC" objectClass:[NutritionixUPCFood class] pathPattern:NUTRITIONIXUPCURL method:RKRequestMethodGET]];
    
    // Configure the route for querying with a string.
    self.queryManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:NUTRITIONIXBASEURL]];
    self.queryManager.requestSerializationMIMEType = RKMIMETypeJSON;
    
    RKObjectMapping *requestMapping = [RKObjectMapping requestMapping];
    [requestMapping addAttributeMappingsFromDictionary:@{@"sort"   : @"sort",
                                                         @"filters": @"filters",
                                                         @"cal_min": @"cal_min",
                                                         @"cal_max": @"cal_max",
                                                         @"fields" : @"fields",
                                                         @"appId"  : @"appId",
                                                         @"appKey" : @"appKey",
                                                         @"query"  : @"query" }];
    
    RKRequestDescriptor *searchRequestDescriptorPost = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping objectClass:[NutritionixSearchFood class] rootKeyPath:nil method:RKRequestMethodPOST];
    [self.queryManager addRequestDescriptor:searchRequestDescriptorPost];
    
    RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[NutritionixSearchFood class]];
    [responseMapping addAttributeMappingsFromDictionary:@{@"fields.item_id": @"itemID",
                                                          @"fields.item_name": @"name",
                                                          @"fields.brand_name": @"brand",
                                                          @"fields.nf_total_carbohydrate": @"carbs",
                                                          @"fields.nf_serving_size_qty": @"servingUnitQuantity",
                                                          @"fields.nf_serving_size_unit": @"servingUnit"}];
    
    RKResponseDescriptor *searchResponseDescriptorPost = [RKResponseDescriptor responseDescriptorWithMapping:responseMapping method:RKRequestMethodPOST pathPattern:NUTRITIONIXSEARCHURL keyPath:@"hits" statusCodes:[NSIndexSet indexSetWithIndex:200]];
    [self.queryManager addResponseDescriptor:searchResponseDescriptorPost];
    
    [self.queryManager.router.routeSet addRoute:[RKRoute routeWithRelationshipName:@"foodQuery" objectClass:[NutritionixSearchFood class] pathPattern:NUTRITIONIXSEARCHURL method:RKRequestMethodPOST]];
}

/* Execute a search for a food using a query string. */
-(void)searchNutritionixWithString: (NSString*)string withController: (UIViewController*)controller
{
    ItemSelectionTableViewController *vc = (ItemSelectionTableViewController*) controller;
    
    if ([self internetConnectionDown]) {
        [vc setConnectionWasDown:YES];
        return;
    } else {
        [vc setConnectionWasDown:NO];
    }
    
    NutritionixSearchFood *search = [NutritionixSearchFood new];
    //search.sort = @{@"field" : @"item_type", @"order" : @"desc" };
    //search.filters = @{@"item_type": @"3"};
    search.results = @"0:20";
    search.cal_min = @"0";
    search.cal_max = @"50000";
    search.fields = @[@"item_name",
                      @"brand_name",
                      @"item_id",
                      @"brand_id",
                      @"nf_total_carbohydrate",
                      @"nf_serving_size_qty",
                      @"nf_serving_size_unit"];
    search.query = string;
    search.appId = NUTRITIONIXAPPID;
    search.appKey = NUTRITIONIXAPPKEY;
    
    self.lastQuery = string;
    
    [self.queryManager postObject:search path:NUTRITIONIXSEARCHURL parameters:nil success:^(RKObjectRequestOperation* operation, RKMappingResult* mappingResult) {

        // Only refresh the data if the request is the latest call. This is meant to avoid any asynchronous issues.
        if ([self.lastQuery isEqualToString:search.query]) {
            //success
            [(ItemSelectionTableViewController*)controller setSearchResults:[NSMutableArray arrayWithArray:[mappingResult array]]];
            [controller.searchDisplayController.searchResultsTableView reloadData];
            [(ItemSelectionTableViewController*)controller setSearching:NO];
        }

    } failure:^(RKObjectRequestOperation* operation, NSError* error) {
        //failure
        NSLog(@"Here is the sent URL: %@", operation.HTTPRequestOperation.request.URL);
        NSLog(@"Here is the sent methodtype: %@", operation.HTTPRequestOperation.request.HTTPMethod);
        NSLog(@"Here is the sent JSON: %@", [[NSString alloc] initWithData:operation.HTTPRequestOperation.request.HTTPBody encoding:NSUTF8StringEncoding]);
        NSLog(@"Here is the received JSON: %@", operation.HTTPRequestOperation.responseString);

        if ([self.lastQuery isEqualToString:search.query]) {
            [(ItemSelectionTableViewController*)controller setSearching:NO];
        }
    }];
    
}

/* Execute a search for a food using a UPC code. */
-(void)searchNutritionixWithUpc: (NSString*)string withController: (UIViewController*)controller
{
    ItemSelectionTableViewController *vc = (ItemSelectionTableViewController*) controller;
    if ([self internetConnectionDown]) {
        [vc setConnectionWasDown:YES];
        return;
    } else {
        [vc setConnectionWasDown:NO];
    }
    
    NutritionixUPCFood *search = [NutritionixUPCFood new];
    
    NSDictionary *params = @{@"upc"  : string,
                             @"appId"  : NUTRITIONIXAPPID,
                             @"appKey" : NUTRITIONIXAPPKEY};
    
    [self.upcManager getObject:search path:NUTRITIONIXUPCURL parameters:params success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        //success
        NSLog(@"Here is the sent URL: %@", operation.HTTPRequestOperation.request.URL);
        NSLog(@"Here is the received JSON: %@", operation.HTTPRequestOperation.responseString);
        
        NSArray* results = [mappingResult array];
        if (results) {
            NutritionixUPCFood* food = [results firstObject];
            
            NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
            FoodReading* foodReading = [FoodReading MR_createEntityInContext:context];
            foodReading.isPending = [NSNumber numberWithBool:YES];
            foodReading.name = food.name;
            foodReading.carbs = [NSNumber numberWithInt:([food.carbs floatValue] + 0.5)];
            foodReading.numberOfServings = [NSNumber numberWithInt:1];
            foodReading.servingUnitAndQuantity = [[food.servingUnitQuantity stringByAppendingString:@" "] stringByAppendingString:food.servingUnit];
            foodReading.timeStamp = [NSDate date];
            
            [(ItemSelectionTableViewController*)controller setEditingMode:NO];
            [(ItemSelectionTableViewController*)controller setSelectedItem:foodReading];
            [(ItemSelectionTableViewController*)controller performSegueWithIdentifier:@"EditItemSegue" sender:controller];
            
        } else {
// TODO: fix me Notify user the item was not in the database.
            
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        //failure
        NSLog(@"Here is the sent URL: %@", operation.HTTPRequestOperation.request.URL);
    }];

}


// Checks if we have an internet connection or not
- (void)testInternetConnection
{
    internetReachableFoo = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    // Internet is reachable
    __weak typeof(self) weakSelf = self;
    internetReachableFoo.reachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Yayyy, we have the interwebs!");
            weakSelf.internetIsReachable = YES;
        });
    };
    
    // Internet is not reachable
    internetReachableFoo.unreachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Someone broke the internet :(");
            weakSelf.internetIsReachable = NO;
        });
    };
    
    [internetReachableFoo startNotifier];
}

- (BOOL) internetConnectionDown
{
    return !self.internetIsReachable;
}


@end
