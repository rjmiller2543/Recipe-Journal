//
//  RecipeCloudManager.m
//  Recipe Journal
//
//  Created by Robert Miller on 2/7/15.
//  Copyright (c) 2015 Robert Miller. All rights reserved.
//

#import "RecipeCloudManager.h"
#include "Ingredient.h"
#include "AppDelegate.h"
#include "RecipeJournalHelper.h"
#include "GroceryList.h"

@implementation RecipeCloudManager

-(instancetype)init {
    self = [super init];

    if (self) {
        _container = [CKContainer defaultContainer];
        _privateDatabase = [_container privateCloudDatabase];
        _pubicDatabase = [_container publicCloudDatabase];
    }
    
    return self;
}

bool status = false;
bool notCompleted = true;
-(BOOL)isLoggedIn {
    
    [_container accountStatusWithCompletionHandler:^(CKAccountStatus accountStatus, NSError *error) {
        if (error) {
            NSLog(@"error logging in with error: %@", error);
            status = false;
        }
        else {
            if (accountStatus == CKAccountStatusAvailable) {
                status = true;
            }
            else {
                status = false;
            }
        }
        notCompleted = false;
    }];
    while (notCompleted) {
        //don't return status until status is fetched
    }
    return status;
}

#pragma mark - Recipe Sync Methods

-(void)modifyRecipeToCloud:(Event*)sender {
    [_privateDatabase fetchRecordWithID:[[CKRecordID alloc] initWithRecordName:[sender recordID]] completionHandler:^(CKRecord *record, NSError *error) {
        
        [record setValue:[NSNumber numberWithBool:true] forKey:@"Favorited"];
        
        [record setValue:[sender cookTimeMinutes] forKey:@"CookTimeMinutes"];
        [record setValue:[sender cookingProcess] forKey:@"CookingProcess"];
        [record setValue:[sender difficulty] forKey:@"Difficulty"];
        [record setValue:[sender notes] forKey:@"Notes"];
        [record setValue:[sender prepTimeMinutes] forKey:@"PrepTimeMinutes"];
        [record setValue:[sender returnPrepartionStepsArray] forKey:@"Preparation"];
        [record setValue:[sender rating] forKey:@"Rating"];
        [record setValue:[sender recipeName] forKey:@"RecipeName"];
        [record setValue:[sender servingSize] forKey:@"ServingSize"];
        [record setValue:[sender winePairing] forKey:@"WinePairing"];
        [record setValue:[sender favorited] forKey:@"Favorited"];
        [record setValue:[sender lowCalorie] forKey:@"LowCalorie"];
        [record setValue:[sender mealType] forKey:@"MealType"];
        [record setValue:[sender isPublic] forKey:@"IsPublic"];
        [record setValue:[sender publicRecordID] forKey:@"PublicRecordID"];
        
        CKAsset *photoAsset = [[CKAsset alloc] initWithFileURL:[NSURL fileURLWithPath:[sender imageURL]]];
        [record setValue:photoAsset forKey:@"RecipeIconImage"];
        
        NSString *ingPath = [NSHomeDirectory() stringByAppendingPathComponent:@"ing.plist"];
        NSArray *ingArray = [sender ingredients];
        [ingArray writeToFile:ingPath atomically:YES];
        CKAsset *ingredientAsset = [[CKAsset alloc] initWithFileURL:[NSURL fileURLWithPath:ingPath]];
        [record setValue:ingredientAsset forKey:@"IngredientsList"];
        
        CKModifyRecordsOperation *saveRecords = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:@[record] recordIDsToDelete:@[]];
        [saveRecords setSavePolicy:CKRecordSaveAllKeys];
        saveRecords.modifyRecordsCompletionBlock = ^(NSArray *savedRecords, NSArray *deletedRecordIDs, NSError *error) {
            
            if (error) {
                NSLog(@"[%@] Error pushing local data: %@", self.class, error);
            }
            
        };
        
        [_privateDatabase addOperation:saveRecords];
    }];
}

-(CKRecord*)eventToRecord:(Event*)sender {
    
    CKRecord *newRecord = [[CKRecord alloc] initWithRecordType:@"Recipe"];
    
    [newRecord setValue:[sender cookTimeMinutes] forKey:@"CookTimeMinutes"];
    [newRecord setValue:[sender cookingProcess] forKey:@"CookingProcess"];
    [newRecord setValue:[sender difficulty] forKey:@"Difficulty"];
    [newRecord setValue:[sender notes] forKey:@"Notes"];
    [newRecord setValue:[sender prepTimeMinutes] forKey:@"PrepTimeMinutes"];
    [newRecord setValue:[sender returnPrepartionStepsArray] forKey:@"Preparation"];
    [newRecord setValue:[sender rating] forKey:@"Rating"];
    [newRecord setValue:[sender recipeName] forKey:@"RecipeName"];
    [newRecord setValue:[sender servingSize] forKey:@"ServingSize"];
    [newRecord setValue:[sender winePairing] forKey:@"WinePairing"];
    [newRecord setValue:[sender favorited] forKey:@"Favorited"];
    [newRecord setValue:[sender lowCalorie] forKey:@"LowCalorie"];
    [newRecord setValue:[sender mealType] forKey:@"MealType"];
    [newRecord setValue:[sender isPublic] forKey:@"IsPublic"];
    [newRecord setValue:[sender publicRecordID] forKey:@"PublicRecordID"];
    
    if (![sender imageURL]) {
        //don't send an image
    }
    else {
        //CKAsset *photoAsset = [[CKAsset alloc] initWithFileURL:[NSURL fileURLWithPath:[sender imageURL]]];
        //[newRecord setValue:photoAsset forKey:@"RecipeIconImage"];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *ingPath = [documentsDirectory stringByAppendingPathComponent:@"ing.dat"];
    NSArray *ingArray = [sender ingredients];
    
    //[ingArray writeToFile:ingPath atomically:YES];
    //if (![ingArray writeToFile:ingPath atomically:YES]) {
    if (![NSKeyedArchiver archiveRootObject:ingArray toFile:ingPath]) {
        
        NSLog(@"didn't save properly");
    }
    
    CKAsset *ingredientAsset = [[CKAsset alloc] initWithFileURL:[NSURL fileURLWithPath:ingPath]];
    [newRecord setValue:ingredientAsset forKey:@"IngredientsList"];
    
    return newRecord;
    
}

-(void)saveRecipeToCloud:(Event*)sender {
    
    CKRecord *newRecord = [self eventToRecord:sender];
    
    [_pubicDatabase saveRecord:newRecord completionHandler:^(CKRecord *record, NSError *error) {
        if (error) {
            NSLog(@"error: %@ with record: %@", error, [record description]);
        }
        else {
            NSLog(@"Hooray!");
            //[sender setRecordID:[record recordID]];
            if (sender) {
                [sender setRecordID:[[record recordID] recordName]];
                CKAsset *photoAsset = [record objectForKey:@"RecipeIconImage"];
                
                NSURL *photoURL = photoAsset.fileURL;
                [sender setImageURL:[photoURL absoluteString]];
                
                NSManagedObjectContext *context = [[AppDelegate sharedInstance] managedObjectContext];
                
                if (![context save:&error]) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    abort();
                }
            }
        }
    }];
}

-(void)removeRecipeFromCloud:(Event*)sender complete:(void (^)(NSError *))completionHandler {
    CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:[sender recordID]];
    [_privateDatabase deleteRecordWithID:recordID completionHandler:^(CKRecordID *recordID, NSError *error) {
        if (error) {
            NSLog(@"error: %@ with record: %@", error, [recordID description]);
        }
        else {
            NSLog(@"Hooray! Deleted!");
        }
        completionHandler(error);
    }];
}

BOOL refresh = false;
-(void)fetchRecords:(void (^)(NSError*error, bool refresh))completionHandler {
    
    NSPredicate *predicate = [NSPredicate predicateWithValue:true];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Recipe" predicate:predicate];
    
    refresh = false;
    [_privateDatabase performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
        }
        else {
            NSManagedObjectContext *dataCenter = [[AppDelegate sharedInstance] managedObjectContext];
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Event"];
            
            NSError *error = nil;
            NSArray *coreDataArray = [dataCenter executeFetchRequest:fetchRequest error:&error];
            
            BOOL isSynced = false;
            for (CKRecord *record in results) {
                for (Event *event in coreDataArray) {
                    if ([[[record recordID] recordName] isEqualToString:[event recordID]]) {
                        isSynced = true;
                        break;
                    }
                    else
                        isSynced = false;
                }
                if (isSynced) {
                    //This record already exists
                    isSynced = false;
                }
                else {
                    refresh = true;
                    
                    NSManagedObjectContext *context = [[AppDelegate sharedInstance] managedObjectContext];
                    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:context];
                    
                    //NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
                    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
                    
                    Event *newEvent = (Event*)newManagedObject;
                    [newEvent setEventWithRecord:record];
                    
                    if (![context save:&error]) {
                        // Replace this implementation with code to handle the error appropriately.
                        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                        abort();
                    }
                }
            }
        }
        completionHandler(error, refresh);
    }];
}

-(void)shareRecipeToPublic:(Event *)sender complete:(void (^)(NSError *, NSString *))completionHandler {
    
    CKRecord *newRecord = [self eventToRecord:sender];
    
    [_pubicDatabase saveRecord:newRecord completionHandler:^(CKRecord *record, NSError *error) {
        if (error) {
            NSLog(@"error uploading to public database with error: %@", error);
        }
        else {
            [sender setIsPublic:[NSNumber numberWithBool:YES]];
            [sender setPublicRecordID:[[record recordID] recordName]];
        
            NSManagedObjectContext *context = [[AppDelegate sharedInstance] managedObjectContext];
            NSError *contextError;
            if (![context save:&contextError]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog(@"Unresolved error %@, %@", contextError, [contextError userInfo]);
                abort();
            }
            [self modifyRecipeToCloud:sender];
        }
        
        //[self modifyRecipeToCloud:sender];
        
        completionHandler(error, [[record recordID] recordName]);
    }];
    
}

#pragma mark - fetch records with source
-(void)fetchRecordsWithSource:(NSString *)source completionBlock:(void (^)(NSError *, BOOL))completionHandler {
    
    if ([source isEqualToString:RECIPELISTSOURCE]) {
        [self fetchRecords:^(NSError *error, bool refresh) {
            completionHandler(error, refresh);
        }];
    }
    else if ([source isEqualToString:GROCERYLISTSOURCE]) {
        [self fetchGroceryList:^(NSError *error, bool refresh) {
            completionHandler(error, refresh);
        }];
    }
    
}

#pragma mark - Grocery List Sync Methods
-(void)fetchGroceryList:(void (^)(NSError*error, bool refresh))completionHandler {
    
    NSPredicate *predicate = [NSPredicate predicateWithValue:true];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Items" predicate:predicate];
    
    refresh = false;
    [_privateDatabase performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
        if (error) {
            NSLog(@"error fetching items with error: %@", error);
        }
        else {
            NSManagedObjectContext *dataCenter = [[AppDelegate sharedInstance] managedObjectContext];
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"GroceryList"];
            
            NSError *error = nil;
            NSArray *coreDataArray = [dataCenter executeFetchRequest:fetchRequest error:&error];
            
            BOOL isSynced = false;
            for (CKRecord *record in results) {
                for (GroceryList *item in coreDataArray) {
                    if ([[[record recordID] recordName] isEqualToString:[item recordID]]) {
                        isSynced = true;
                        break;
                    }
                }
                if (isSynced) {
                    //This record already exists
                    isSynced = false;
                }
                else {
                    refresh = true;
                    
                    NSEntityDescription *entity = [NSEntityDescription entityForName:@"GroceryList" inManagedObjectContext:dataCenter];
                    
                    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:dataCenter];
                    
                    GroceryList *newEvent = (GroceryList*)newManagedObject;
                    //[newEvent setEventWithRecord:record];
                    [newEvent setName:[record objectForKey:@"name"]];
                    [newEvent setAmount:[record objectForKey:@"amount"]];
                    [newEvent setType:[record objectForKey:@"size"]];
                    
                    if (![dataCenter save:&error]) {
                        // Replace this implementation with code to handle the error appropriately.
                        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                        abort();
                    }
                }
            }
        }
    }];
    
}

-(void)saveListToItem:(GroceryList *)list {
    
    CKRecord *record = [[CKRecord alloc] initWithRecordType:@"Items"];
    
    [record setValue:[list name] forKey:@"name"];
    [record setValue:[list amount] forKey:@"amount"];
    [record setValue:[list type] forKey:@"size"];
    
    [_privateDatabase saveRecord:record completionHandler:^(CKRecord *record, NSError *error) {
        if (error) {
            NSLog(@"error saving record: %@ with error: %@", [record description], error);
        }
        else {
            NSLog(@"woot!");
            [list setRecordID:[[record recordID] recordName]];
            
            NSManagedObjectContext *context = [[AppDelegate sharedInstance] managedObjectContext];
            
            if (![context save:&error]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
    }];
    
}

-(void)removeItemFromCloud:(GroceryList *)list complete:(void (^)(NSError *error))completionHandler {
    
    CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:[list recordID]];
    [_privateDatabase deleteRecordWithID:recordID completionHandler:^(CKRecordID *recordID, NSError *error) {
        if (error) {
            NSLog(@"error: %@ with record: %@", error, [recordID description]);
        }
        else {
            NSLog(@"Hooray! Deleted!");
        }
        completionHandler(error);
    }];
    
}

@end
