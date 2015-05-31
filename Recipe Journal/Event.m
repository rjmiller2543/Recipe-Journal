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
@dynamic imageURL;
@dynamic ingredients;
@dynamic isPublic;
@dynamic notes;
@dynamic prepTimeMinutes;
@dynamic preparation;
@dynamic rating;
@dynamic recipeName;
@dynamic recordID;
@dynamic servingSize;
@dynamic winePairing;
@dynamic recipeIconImage;
@dynamic favorited;
@dynamic lowCalorie;
@dynamic mealType;
@dynamic publicRecordID;

-(instancetype)initWithRecord:(CKRecord *)record {
    self = [super init];
    if (self) {
        [self setRecipeName:[record objectForKey:@"RecipeName"]];
        [self setRating:[record objectForKey:@"Rating"]];
        [self setServingSize:[record objectForKey:@"ServingSize"]];
        [self setDifficulty:[record objectForKey:@"Difficulty"]];
        [self setPrepTimeMinutes:[record objectForKey:@"PrepTimeMinutes"]];
        [self setCookTimeMinutes:[record objectForKey:@"CookTimeMinutes"]];
        [self setPreparationWithArray:[record objectForKey:@"Preparation"]];
        [self setNotes:[record objectForKey:@"Notes"]];
        [self setRecipeIconImage:[record objectForKey:@"RecipeIconImage"]];
        [self setIsPublic:[record objectForKey:@"IsPublic"]];
        [self setTimeStamp:[record objectForKey:@"TimeStamp"]];
        [self setMealType:[record objectForKey:@"MealType"]];
        [self setLowCalorie:[record objectForKey:@"LowCalorie"]];
        //
    }
    return self;
}

-(void)setEventWithRecord:(CKRecord *)record {
    
    [self setRecipeName:[record objectForKey:@"RecipeName"]];
    [self setRating:[record objectForKey:@"Rating"]];
    [self setServingSize:[record objectForKey:@"ServingSize"]];
    [self setDifficulty:[record objectForKey:@"Difficulty"]];
    [self setPrepTimeMinutes:[record objectForKey:@"PrepTimeMinutes"]];
    [self setCookTimeMinutes:[record objectForKey:@"CookTimeMinutes"]];
    [self setCookingProcess:[record objectForKey:@"CookingProcess"]];
    [self setPreparationWithArray:[record objectForKey:@"Preparation"]];
    [self setNotes:[record objectForKey:@"Notes"]];
    [self setRecordID:[[record recordID] recordName]];
    [self setPreparationWithArray:[record objectForKey:@"Preparation"]];
    [self setWinePairing:[record objectForKey:@"WinePairing"]];
    [self setFavorited:[record objectForKey:@"Favorited"]];
    [self setLowCalorie:[record objectForKey:@"LowCalorie"]];
    [self setMealType:[record objectForKey:@"MealType"]];
    [self setIsPublic:[record objectForKey:@"IsPublic"]];
    [self setTimeStamp:[record objectForKey:@"TimeStamp"]];
    [self setPublicRecordID:[record objectForKey:@"PublicRecordID"]];
    
    CKAsset *photoAsset = [record objectForKey:@"RecipeIconImage"];
    
    NSURL *photoURL = photoAsset.fileURL;
    [self setImageURL:[photoURL absoluteString]];
    NSData *photoData = [NSData dataWithContentsOfURL:photoURL];
    [self setRecipeIconImage:photoData];
    
    CKAsset *ingAsset = [record objectForKey:@"IngredientsList"];
    
    NSURL *ingURL = ingAsset.fileURL;
    NSData *ingData = [NSData dataWithContentsOfURL:ingURL];
    NSArray *ingArray = [NSKeyedUnarchiver unarchiveObjectWithData:ingData];
    [self setIngredients:ingArray];
    
}

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

@implementation Ingredients

+ (Class)transformedValueClass
{
    return [NSArray class];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(id)value
{
    return [NSKeyedArchiver archivedDataWithRootObject:value];
}

- (NSArray*)reverseTransformedValue:(id)value
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:value];
}

@end


