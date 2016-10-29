//
//  Reading.m
//  CompassRose
//
//  Created by Christopher Balcells on 11/19/13.
//  Copyright (c) 2013 Jose Carrillo. All rights reserved.
//

#import "Reading.h"

@implementation Reading

@dynamic name;
@dynamic timeStamp;
@dynamic isFavorite;
@dynamic isPending;

- (NSString*) itemValue {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
