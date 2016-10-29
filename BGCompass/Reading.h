//
//  Reading.h
//  CompassRose
//
//  Created by Christopher Balcells on 11/19/13.
//  Copyright (c) 2013 Jose Carrillo. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface Reading : NSManagedObject

@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSDate* timeStamp;
@property (nonatomic, retain) NSNumber* isFavorite;
@property (nonatomic, retain) NSNumber* isPending;

- (NSString *) itemValue;

@end
