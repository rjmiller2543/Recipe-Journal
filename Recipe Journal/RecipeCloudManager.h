//
//  RecipeCloudManager.h
//  Recipe Journal
//
//  Created by Robert Miller on 2/7/15.
//  Copyright (c) 2015 Robert Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"
#import "GroceryList.h"
#import <CloudKit/CloudKit.h>

@interface RecipeCloudManager : NSObject

@property(nonatomic,retain) CKContainer *container;
@property(nonatomic,retain) CKDatabase *privateDatabase;
@property(nonatomic,retain) CKDatabase *pubicDatabase;

-(BOOL)isLoggedIn;
-(void)saveRecipeToCloud:(Event*)sender;
-(void)removeRecipeFromCloud:(Event*)sender complete:(void (^)(NSError*error))completionHandler;
-(void)fetchRecordsWithSource:(NSString*)source completionBlock:(void (^)(NSError*error, BOOL refresh))completionHandler;
-(void)modifyRecipeToCloud:(Event*)sender;

-(void)saveListToItem:(GroceryList*)list;
-(void)removeItemFromCloud:(GroceryList*)list complete:(void (^)(NSError *error))completionHandler;

@end
