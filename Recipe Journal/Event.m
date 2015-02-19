//
//  Event.m
//  Recipe Journal
//
//  Created by Robert Miller on 2/7/15.
//  Copyright (c) 2015 Robert Miller. All rights reserved.
//

#import "Event.h"


@implementation Event

@dynamic timeStamp;
@dynamic cookTimeMinutes;
@dynamic cookingProcess;
@dynamic difficulty;
@dynamic ingredients;
@dynamic notes;
@dynamic prepTimeMinutes;
@dynamic preparation;
@dynamic rating;
@dynamic recipeName;
@dynamic servingSize;
@dynamic winePairing;
@dynamic recipeIconImage;
@dynamic favorited;
@dynamic lowCalorie;
@dynamic mealType;

-(NSArray*)returnIngredientsArray {
    if (!self.ingredients) {
        return nil;
    }
    
    return [NSKeyedUnarchiver unarchiveObjectWithData:self.ingredients];
}

-(NSArray*)returnPrepartionStepsArray {
    if (!self.preparation) {
        return nil;
    }
    
    return [NSKeyedUnarchiver unarchiveObjectWithData:self.preparation];
}

-(void)setIngredientsWithArray:(NSArray *)ingredients {
    if (ingredients == nil) {
        //do nothing
    }
    else {
        NSData *ingredientsData = [NSKeyedArchiver archivedDataWithRootObject:ingredients];
        [self setValue:ingredientsData forKey:@"ingredients"];
    }
}

-(void)setPreparationWithArray:(NSArray *)preparation {
    if (preparation == nil) {
        //do nothing
    }
    else {
        NSData *preparationData = [NSKeyedArchiver archivedDataWithRootObject:preparation];
        [self setValue:preparationData forKey:@"preparation"];
    }
}

@end
