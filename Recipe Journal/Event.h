//
//  Event.h
//  Recipe Journal
//
//  Created by Robert Miller on 2/7/15.
//  Copyright (c) 2015 Robert Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Event : NSManagedObject

@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSNumber * cookTimeMinutes;
@property (nonatomic, retain) NSNumber * cookingProcess;
@property (nonatomic, retain) NSNumber * difficulty;
@property (nonatomic, retain) NSData * ingredients;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * prepTimeMinutes;
@property (nonatomic, retain) NSData * preparation;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSString * recipeName;
@property (nonatomic, retain) NSNumber * servingSize;
@property (nonatomic, retain) NSString * winePairing;
@property (nonatomic, retain) id recipeIconImage;
@property (nonatomic, retain) NSNumber * favorited;
@property (nonatomic, retain) NSNumber * lowCalorie;
@property (nonatomic, retain) NSString * mealType;

@end