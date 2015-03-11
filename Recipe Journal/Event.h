//
//  Event.h
//  Recipe Journal
//
//  Created by Robert Miller on 2/7/15.
//  Copyright (c) 2015 Robert Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CloudKit/CloudKit.h>


@interface Event : NSManagedObject

@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSNumber * cookTimeMinutes;
@property (nonatomic, retain) NSNumber * cookingProcess;
@property (nonatomic, retain) NSNumber * difficulty;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) id ingredients;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * prepTimeMinutes;
@property (nonatomic, retain) NSData * preparation;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSString * recipeName;
@property (nonatomic, retain) NSString * recordID;
@property (nonatomic, retain) NSNumber * servingSize;
@property (nonatomic, retain) NSString * winePairing;
@property (nonatomic, retain) NSData *recipeIconImage;
@property (nonatomic, retain) NSNumber * favorited;
@property (nonatomic, retain) NSNumber * lowCalorie;
@property (nonatomic, retain) NSString * mealType;

@property(nonatomic,retain) NSArray *ingredientsArray;

-(NSArray*)returnIngredientsArray;
-(NSArray*)returnPrepartionStepsArray;

-(void)setIngredientsWithArray:(NSArray *)ingredients;
-(void)setPreparationWithArray:(NSArray *)preparation;
-(void)setEventWithRecord:(CKRecord*)record;

@end

@interface Ingredients : NSValueTransformer

@end

