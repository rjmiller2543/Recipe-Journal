//
//  Ingredients.h
//  Recipe Journal
//
//  Created by Robert Miller on 3/12/15.
//  Copyright (c) 2015 Robert Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

@interface Ingredients : NSManagedObject

@property (nonatomic, retain) NSString * ingredient;
@property (nonatomic, retain) NSNumber * amount;
@property (nonatomic, retain) NSString * size;
@property (nonatomic, retain) Event *relationshipToEvent;

-(NSArray*)arrayFromUp;

@end
