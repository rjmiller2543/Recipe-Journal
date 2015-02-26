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

-(void)saveRecipeToCloud:(Event*)sender {
    CKRecord *testRecord = [[CKRecord alloc] initWithRecordType:@"Items"];
    [testRecord setValue:@"up up" forKey:@"name"];
    [_privateDatabase saveRecord:testRecord completionHandler:^(CKRecord *record, NSError *error) {
        if (error) {
            NSLog(@"error: %@ with record: %@", error, [record description]);
        }
        else {
            NSLog(@"Hooray!");
            //[sender setRecordID:[record recordID]];
            if (sender) {
                [sender setRecordID:[[record recordID] recordName]];
                
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

-(void)removeRecipeFromCloud:(Event*)sender {
    CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:[sender recordID]];
    [_privateDatabase deleteRecordWithID:recordID completionHandler:^(CKRecordID *recordID, NSError *error) {
        if (error) {
            NSLog(@"error: %@ with record: %@", error, [recordID description]);
        }
        else {
            NSLog(@"Hooray! Deleted!");
        }
    }];
}

-(void)fetchRecords {
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Recipe" predicate:nil];
    
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
                    if ([[record recordID] recordName] == [event recordID]) {
                        isSynced = true;
                        break;
                    }
                }
                if (isSynced) {
                    //This record already exists
                    isSynced = false;
                }
                else {
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
    }];
}

@end
