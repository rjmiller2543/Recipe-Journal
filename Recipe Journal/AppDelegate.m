//
//  AppDelegate.m
//  Recipe Journal
//
//  Created by Robert Miller on 2/6/15.
//  Copyright (c) 2015 Robert Miller. All rights reserved.
//

#import "AppDelegate.h"
#import "DetailViewController.h"
#import "MasterViewController.h"
#import "RecipeCloudManager.h"
#import "NewRecipeViewController.h"
#import <FlatUIKit.h>

@interface AppDelegate () <UISplitViewControllerDelegate, NSFetchedResultsControllerDelegate>

@property(nonatomic,retain) RecipeCloudManager *cloudManager;

@end

@implementation AppDelegate

+(id)sharedInstance
{
    return [[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
    navigationController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem;
    splitViewController.delegate = self;
    
    UINavigationController *masterNavigationController = splitViewController.viewControllers[0];
    MasterViewController *controller = (MasterViewController *)masterNavigationController.topViewController;
    controller.managedObjectContext = self.managedObjectContext;
    
    _cloudManager = [[RecipeCloudManager alloc] init];
    
    //[application registerUserNotificationSettings];
    [application registerForRemoteNotifications];
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];

    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:@"firstRun"]) {
        [self initSubscriptionsWithCompletionHandler:^(NSError *error) {
            if (error) {
                NSLog(@"error initializing subscriptions: %@", error);
            }
            else {
                [defaults setObject:[NSDate date] forKey:@"firstRun"];
            }
        }];
    }
    
    return YES;
}

/*
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    CKNotification *notifications = [CKNotification notificationFromRemoteNotificationDictionary:userInfo];
    NSLog(@"notification is: %@", notifications);
}
 */

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    CKQueryNotification *notifications = [CKQueryNotification notificationFromRemoteNotificationDictionary:userInfo];
    NSLog(@"notification is: %@", notifications);
    
    if ([[notifications alertActionLocalizationKey] isEqualToString:@"CREATE_ITEM_NOTIFICATION"]) {
        [_cloudManager fetchRecordsWithSource:GROCERYLISTSOURCE completionBlock:^(NSError *error, BOOL refresh) {
            //up up
        }];
    }
    else if ([[notifications alertActionLocalizationKey] isEqualToString:@"CREATE_RECIPE_NOTIFICATION"]) {
        [_cloudManager fetchRecordsWithSource:RECIPELISTSOURCE completionBlock:^(NSError *error, BOOL refresh) {
            //up up
        }];
    }
    else if ([[notifications alertActionLocalizationKey] isEqualToString:@"DELETE_ITEM_NOTIFICATION"]) {
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"GroceryList"];
        
        // Set the batch size to a suitable number.
        [fetchRequest setFetchBatchSize:10];
        
        // Edit the sort key as appropriate.
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
        NSArray *sortDescriptors = @[sortDescriptor];
        
        NSPredicate *prepPredicate = [NSPredicate predicateWithFormat:@"recordID = %@", [[notifications recordID] recordName]];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setPredicate:prepPredicate];
        
        NSFetchedResultsController *_fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        _fetchedResultsController.delegate = self;
        
        NSError *error = nil;
        if (![_fetchedResultsController performFetch:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        if ([_fetchedResultsController fetchedObjects].count == 1) {
            NSManagedObject *object = [[_fetchedResultsController fetchedObjects] firstObject];
            
            [self.managedObjectContext deleteObject:object];
            
            NSError *contextError = nil;
            if (![self.managedObjectContext save:&contextError]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog(@"Unresolved error %@, %@", contextError, [contextError userInfo]);
                abort();
            }
        }
        else if ( [_fetchedResultsController fetchedObjects].count > 1 ) {
            NSLog(@"error, there are multiple records with the same ID");
        }
        else if ( [_fetchedResultsController fetchedObjects].count < 1) {
            NSLog(@"error, there are no records that match this ID");
        }
    }
    else if ([[notifications alertActionLocalizationKey] isEqualToString:@"DELETE_RECIPE_NOTIFICATION"]) {
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Event"];
        
        // Set the batch size to a suitable number.
        [fetchRequest setFetchBatchSize:10];
        
        // Edit the sort key as appropriate.
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
        NSArray *sortDescriptors = @[sortDescriptor];
        
        NSPredicate *prepPredicate = [NSPredicate predicateWithFormat:@"recordID = %@", [[notifications recordID] recordName]];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setPredicate:prepPredicate];
        
        NSFetchedResultsController *_fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        _fetchedResultsController.delegate = self;
        
        NSError *error = nil;
        if (![_fetchedResultsController performFetch:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        if ([_fetchedResultsController fetchedObjects].count == 1) {
            NSManagedObject *object = [[_fetchedResultsController fetchedObjects] firstObject];
            
            [self.managedObjectContext deleteObject:object];
            
            NSError *contextError = nil;
            if (![self.managedObjectContext save:&contextError]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog(@"Unresolved error %@, %@", contextError, [contextError userInfo]);
                abort();
            }
        }
        else if ( [_fetchedResultsController fetchedObjects].count > 1 ) {
            NSLog(@"error, there are multiple records with the same ID");
        }
        else if ( [_fetchedResultsController fetchedObjects].count < 1) {
            NSLog(@"error, there are no records that match this ID");
        }
    }
    
    completionHandler(UIBackgroundFetchResultNewData);
}

-(void)initSubscriptionsWithCompletionHandler:(void (^)(NSError *error))completionHandler
{
    /* creating the subscriptions.. possible Apple bug, but I need to let the cloud manager complete the save subscription before i can save a new prescription.. this is why they are nested
     
        save create item {
            save delete item {
                save create recipe {
                    save delete recipe {
     
                    }
                }
            }
        }
     */
    
    NSPredicate *predicate = [NSPredicate predicateWithValue:true];
    
    CKSubscription *createItemSubscription = [[CKSubscription alloc] initWithRecordType:@"Items" predicate:predicate options:CKSubscriptionOptionsFiresOnRecordCreation];
    
    CKNotificationInfo *createNotificationInfo = [CKNotificationInfo new];
    createNotificationInfo.alertActionLocalizationKey = @"CREATE_ITEM_NOTIFICATION";
    //notificationInfo.soundName = nil;
    createNotificationInfo.shouldBadge = NO;
    createItemSubscription.notificationInfo = createNotificationInfo;
    
    [_cloudManager.privateDatabase saveSubscription:createItemSubscription completionHandler:^(CKSubscription *subscription, NSError *error) {
        if (error) {
            NSLog(@"error saving create item subscription: %@", error);
            completionHandler(error);
            return;
        }
        else {
            NSLog(@"create item subscription saved");
        }
        CKSubscription *deleteItemSubscription = [[CKSubscription alloc] initWithRecordType:@"Items" predicate:predicate options:CKSubscriptionOptionsFiresOnRecordDeletion];
        
        CKNotificationInfo *deleteNotificationInfo = [CKNotificationInfo new];
        deleteNotificationInfo.alertActionLocalizationKey = @"DELETE_ITEM_NOTIFICATION";
        //notificationInfo.soundName = nil;
        deleteNotificationInfo.shouldBadge = NO;
        deleteItemSubscription.notificationInfo = deleteNotificationInfo;
        
        [_cloudManager.privateDatabase saveSubscription:deleteItemSubscription completionHandler:^(CKSubscription *subscription, NSError *error) {
            if (error) {
                NSLog(@"error saving delete item subscription: %@", error);
                completionHandler(error);
                return;
            }
            else {
                NSLog(@"delete item subscriptions saved");
            }
            CKSubscription *createRecipeSubscription = [[CKSubscription alloc] initWithRecordType:@"Recipe" predicate:predicate options:CKSubscriptionOptionsFiresOnRecordCreation];
            
            CKNotificationInfo *createRecipeNotificationInfo = [CKNotificationInfo new];
            createRecipeNotificationInfo.alertActionLocalizationKey = @"CREATE_RECIPE_NOTIFICATION";
            //notificationInfo.soundName = nil;
            createRecipeNotificationInfo.shouldBadge = NO;
            createRecipeSubscription.notificationInfo = createRecipeNotificationInfo;
            
            [_cloudManager.privateDatabase saveSubscription:createRecipeSubscription completionHandler:^(CKSubscription *subscription, NSError *error) {
                if (error) {
                    NSLog(@"error saving create recipe subscription: %@", error);
                    completionHandler(error);
                    return;
                }
                else {
                    NSLog(@"create recipe subscriptions saved");
                }
                CKSubscription *deleteRecipeSubscription = [[CKSubscription alloc] initWithRecordType:@"Recipe" predicate:predicate options:CKSubscriptionOptionsFiresOnRecordDeletion];
                
                CKNotificationInfo *deleteRecipeNotificationInfo = [CKNotificationInfo new];
                deleteRecipeNotificationInfo.alertActionLocalizationKey = @"DELETE_RECIPE_NOTIFICATION";
                //notificationInfo.soundName = nil;
                deleteRecipeNotificationInfo.shouldBadge = NO;
                deleteRecipeSubscription.notificationInfo = deleteRecipeNotificationInfo;
                
                [_cloudManager.privateDatabase saveSubscription:deleteRecipeSubscription completionHandler:^(CKSubscription *subscription, NSError *error) {
                    if (error) {
                        NSLog(@"error saving delete recipe subscription: %@", error);
                        completionHandler(error);
                    }
                    else {
                        NSLog(@"delete reipe subscriptions saved");
                        completionHandler(error);
                    }
                }];
            }];
        }];
    }];
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    NSLog(@"Source Application: %@", sourceApplication);
    NSLog(@"url scheme: %@", [url scheme]);
    NSLog(@"url query: %@", [url query]);
    
    //RecipeCloudManager *cloudManager = [[RecipeCloudManager alloc] init];
    
    [_cloudManager fetchRecipeFromPublic:[url query] complete:^(NSError *error, CKRecord *record) {
        NewRecipeViewController *newRecipe = [[NewRecipeViewController alloc] init];
        //[newRecipe newRecipeFromRecord:record];
        [self.window.rootViewController presentViewController:newRecipe animated:YES completion:^{
            //up up
            [newRecipe newRecipeFromRecord:record];
        }];
    }];
    
    return YES;
}

#pragma mark - Split view

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
    if ([secondaryViewController isKindOfClass:[UINavigationController class]] && [[(UINavigationController *)secondaryViewController topViewController] isKindOfClass:[DetailViewController class]] && ([(DetailViewController *)[(UINavigationController *)secondaryViewController topViewController] detailItem] == nil)) {
        // Return YES to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.robertmiller.Recipe_Journal" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Recipe_Journal" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Recipe_Journal.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
