//
//  Ingredients.m
//  Recipe Journal
//
//  Created by Robert Miller on 3/12/15.
//  Copyright (c) 2015 Robert Miller. All rights reserved.
//

#import "Ingredients.h"
#import "Event.h"


@implementation Ingredients

@dynamic ingredient;
@dynamic amount;
@dynamic size;
@dynamic relationshipToEvent;

-(NSArray*)arrayFromUp {
    return [[NSArray alloc] initWithObjects:[Event new], nil];
}

@end
