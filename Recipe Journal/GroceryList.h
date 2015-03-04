//
//  GroceryList.h
//  Recipe Journal
//
//  Created by Robert Miller on 2/7/15.
//  Copyright (c) 2015 Robert Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface GroceryList : NSManagedObject

@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * amount;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * marked;
@property (nonatomic, retain) NSString * recordID;

@end
