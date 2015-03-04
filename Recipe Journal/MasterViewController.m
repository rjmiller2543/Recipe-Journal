//
//  MasterViewController.m
//  Recipe Journal
//
//  Created by Robert Miller on 2/6/15.
//  Copyright (c) 2015 Robert Miller. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "NewRecipeViewController.h"
#import "RecipeTableViewCell.h"
#import "GroceryListCell.h"
#import "Event.h"
#import "GroceryList.h"
#import "Ingredient.h"
#import <AwesomeMenu/AwesomeMenu.h>
#import <SVPullToRefresh/SVPullToRefresh.h>
#import <RNFrostedSidebar/RNFrostedSidebar.h>
#import "RecipeJournalHelper.h"

#import "RecipeCloudManager.h"

@interface MasterViewController () <RNFrostedSidebarDelegate, SWTableViewCellDelegate>

@property(nonatomic,retain) RecipeCloudManager *cloudManager;
@property(nonatomic,retain) RNFrostedSidebar *callout;

@property(nonatomic,retain) NSString *tableViewSource;

@end

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"Recipes";
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.8 green:0.1 blue:0.8 alpha:1.0];
    self.navigationController.navigationBar.backgroundColor = [UIColor colorWithRed:0.2 green:0.9 blue:0.2 alpha:0.6];
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    _tableViewSource = RECIPELISTSOURCE;
    
    _cloudManager = [[RecipeCloudManager alloc] init];
    
    __weak typeof(self) weakSelf = self;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    UIEdgeInsets insets = self.tableView.contentInset;
    insets.top = self.navigationController.navigationBar.bounds.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    self.tableView.contentInset = insets;
    self.tableView.scrollIndicatorInsets = insets;
    
    [self.tableView setShowsPullToRefresh:YES];
    [self.tableView addPullToRefreshWithActionHandler:^{
        if ([weakSelf.tableViewSource isEqualToString:RECIPELISTSOURCE]) {
            if ([weakSelf.cloudManager isLoggedIn]) {
                [weakSelf.cloudManager fetchRecordsWithSource:weakSelf.tableViewSource completionBlock:^(NSError *error, BOOL refresh) {
                    if (error) {
                        NSLog(@"error: %@", error);
                    }
                    else {
                        if (refresh) {
                            [weakSelf.tableView reloadData];
                        }
                    }
                    [weakSelf.tableView.pullToRefreshView stopAnimating];
                }];
            }
        }
        else if ([weakSelf.tableViewSource isEqualToString:GROCERYLISTSOURCE]) {
            NSMutableArray *deleteIndex = [[NSMutableArray alloc] init];
            [weakSelf.fetchedResultsController.fetchedObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                GroceryList *list = (GroceryList*)obj;
                
                if ([[list marked] boolValue]) {
                    NSManagedObject *object = (NSManagedObject*)obj;
                    [weakSelf.managedObjectContext deleteObject:object];
                    
                    NSError *contextError = nil;
                    if (![weakSelf.managedObjectContext save:&contextError]) {
                        // Replace this implementation with code to handle the error appropriately.
                        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                        NSLog(@"Unresolved error %@, %@", contextError, [contextError userInfo]);
                        abort();
                    }
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
                    [deleteIndex addObject:indexPath];                }
            }];
            /*
            for (NSManagedObject *object in [weakSelf.fetchedResultsController fetchedObjects]) {
                GroceryList *list = (GroceryList*)object;
                
                if ([[list marked] boolValue]) {
                    [weakSelf.managedObjectContext deleteObject:object];
                    
                    NSError *contextError = nil;
                    if (![weakSelf.managedObjectContext save:&contextError]) {
                        // Replace this implementation with code to handle the error appropriately.
                        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                        NSLog(@"Unresolved error %@, %@", contextError, [contextError userInfo]);
                        abort();
                    }
                }
            }
             */
            
            [weakSelf.tableView.pullToRefreshView stopAnimating];
            [weakSelf.tableView reloadData];
        }
        
    }];

    [self.tableView registerClass:[RecipeTableViewCell class] forCellReuseIdentifier:@"RecipeCell"];
    [self.tableView registerClass:[GroceryListCell class] forCellReuseIdentifier:@"GroceryCell"];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    //self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showMenu:)];
    
    _callout = [[RNFrostedSidebar alloc] initWithImages:@[[UIImage imageNamed:@"cutlery-50.png"], [UIImage imageNamed:@"favorite-50.png"], [UIImage imageNamed:@"search-50.png"], [UIImage imageNamed:@"checklist-50.png"], [UIImage imageNamed:@"cross-50.png"]]];
    _callout.delegate = self;
    
    [self.tableView triggerPullToRefresh];
}

-(void)showMenu:(UIBarButtonItem*)senders {
    NSLog(@"up up");
    
    [_callout show];
}

- (void)sidebar:(RNFrostedSidebar *)sidebar didTapItemAtIndex:(NSUInteger)index {
    
    switch (index) {
        case 0: {
            //load the recipes
            NSLog(@"Load Recipes");
            _tableViewSource = RECIPELISTSOURCE;
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Event"];
            
            // Set the batch size to a suitable number.
            [fetchRequest setFetchBatchSize:10];
            
            // Edit the sort key as appropriate.
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
            NSArray *sortDescriptors = @[sortDescriptor];
            
            [fetchRequest setSortDescriptors:sortDescriptors];
            
            _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:nil cacheName:nil];
            _fetchedResultsController.delegate = self;
            
            NSError *error = nil;
            if (![self.fetchedResultsController performFetch:&error]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
            
            [self.tableView reloadData];
            
            break;
        }
        case 1:
            //predicate and load the favorites
            NSLog(@"Load Favorites");
            break;
        case 2:
            //bring up the search page
            NSLog(@"Load the Search Page");
            break;
        case 3: {
            //load the grocery list
            NSLog(@"Load Grocery List");
            _tableViewSource = GROCERYLISTSOURCE;
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;

            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"GroceryList"];
            
            // Set the batch size to a suitable number.
            [fetchRequest setFetchBatchSize:10];
            
            // Edit the sort key as appropriate.
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
            NSArray *sortDescriptors = @[sortDescriptor];
            
            [fetchRequest setSortDescriptors:sortDescriptors];
            
            _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:nil cacheName:nil];
            _fetchedResultsController.delegate = self;
            
            NSError *error = nil;
            if (![self.fetchedResultsController performFetch:&error]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
            
            [self.tableView reloadData];
            
            break;
        }
        case 4:
            //do nothing and let the sidebar dismiss from view
            NSLog(@"dismiss the sidebar");
            break;
            
        default:
            break;
    }
    
    [sidebar dismissAnimated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender {
    
    id rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    if([rootViewController isKindOfClass:[UINavigationController class]])
    {
        rootViewController = [((UINavigationController *)rootViewController).viewControllers objectAtIndex:0];
    }
    NewRecipeViewController *newView = [[NewRecipeViewController alloc] init];
    [rootViewController presentViewController:newView animated:YES completion:^{
        //up up
    }];
    
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setDetailItem:(Event*)object];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([_tableViewSource isEqualToString:RECIPELISTSOURCE]) {
        RecipeTableViewCell *recipeCell = [tableView dequeueReusableCellWithIdentifier:@"RecipeCell" forIndexPath:indexPath];
        [self configureCell:recipeCell atIndexPath:indexPath];
        return recipeCell;
    }
    else if ([_tableViewSource isEqualToString:GROCERYLISTSOURCE]) {
        GroceryListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GroceryCell" forIndexPath:indexPath];
        //[self configureCell:cell atIndexPath:indexPath];
        
        NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        GroceryList *cellList = (GroceryList*)object;
        cell.ingredient = cellList;
        [cell configureCell];
        return cell;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = @"Something's gone wrong...";
    
    return cell;
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        Event *deletedEvent = (Event*)[_fetchedResultsController objectAtIndexPath:indexPath];
        
        if ([_cloudManager isLoggedIn]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_cloudManager removeRecipeFromCloud:deletedEvent complete:^(NSError *error) {
                    
                    if (error) {
                        NSLog(@"error deleting object from cloud with error: %@, keeping object to keep everything in sync", error);
                    }
                    [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
                    
                    NSError *contextError = nil;
                    if (![context save:&contextError]) {
                        // Replace this implementation with code to handle the error appropriately.
                        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                        NSLog(@"Unresolved error %@, %@", contextError, [contextError userInfo]);
                        abort();
                    }
                }];
            });
        }
        else {
            
            [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
            
            NSError *error = nil;
            if (![context save:&error]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
        
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 48;
    if ([_tableViewSource isEqualToString:RECIPELISTSOURCE]) {
        height = 120;
    }
    return height;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    [cell setFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 120)];
    
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([_tableViewSource isEqualToString:RECIPELISTSOURCE]) {
        RecipeTableViewCell *tempCell = (RecipeTableViewCell*)cell;
        Event *cellEvent = (Event*)object;
        tempCell.event = cellEvent;
        tempCell.leftUtilityButtons = [self leftButtons];
        tempCell.rightUtilityButtons = [self rightButtons];
        tempCell.delegate = self;
        [tempCell configureCell];
    }
    else if ([_tableViewSource isEqualToString:GROCERYLISTSOURCE]) {
        //GroceryList *cellList = (GroceryList*)object;
        //NSString *cellString = [[cellList amount] stringValue];
        //cellString = [cellString stringByAppendingString:[cellList type]];
        //cellString = [cellString stringByAppendingString:[cellList name]];
        //cell.textLabel.text = cellString;
    }
    
    //cell.textLabel.text = [[object valueForKey:@"timeStamp"] description];
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([_tableViewSource isEqualToString:RECIPELISTSOURCE]) {
        Event *object = (Event*)[[self fetchedResultsController] objectAtIndexPath:indexPath];
        DetailViewController *controller = [[DetailViewController alloc] init];
        [controller setDetailItem:object];
        [self showViewController:controller sender:self];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
    
}

#pragma mark - SWTableViewDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0: {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            [self addRecipeToFavoritesWithIndexPath:indexPath];
            break;
        }
        case 1: {
            RecipeTableViewCell *tempCell = (RecipeTableViewCell*)cell;
            [self addEventToGroceryList:tempCell.event];
            break;
        }
        default:
            break;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0: {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            [self removeRecipeWithIndexPath:indexPath];
            break;
        }
        default:
            break;
    }
}

-(void)addEventToGroceryList:(Event*)event {
    
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"GroceryList" inManagedObjectContext:context];
    
    for (Ingredient *ingredient in [event returnIngredientsArray]) {
        
        NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
        GroceryList *newListing = (GroceryList*)newManagedObject;
        
        [newListing setType:[ingredient size]];
        [newListing setName:[ingredient ingredient]];
        [newListing setAmount:[ingredient amount]];
        [newListing setTimeStamp:[NSDate date]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        //Sync Grocery list to iCloud...
        if ([_cloudManager isLoggedIn]) {
            [_cloudManager saveListToItem:newListing];
        }
        
    }
    
}

-(void)addRecipeToFavoritesWithIndexPath:(NSIndexPath*)indexPath {
    
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    Event *favoritedEvent = (Event*)[_fetchedResultsController objectAtIndexPath:indexPath];
    
    [favoritedEvent setFavorited:[NSNumber numberWithBool:YES]];
    
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    if ([_cloudManager isLoggedIn]) {
        [_cloudManager modifyRecipeToCloud:favoritedEvent];
    }
    
}

-(void)removeRecipeWithIndexPath:(NSIndexPath*)indexPath {
    
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    Event *deletedEvent = (Event*)[_fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([_cloudManager isLoggedIn]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_cloudManager removeRecipeFromCloud:deletedEvent complete:^(NSError *error) {
                
                if (error) {
                    NSLog(@"error deleting object from cloud with error: %@, keeping object to keep everything in sync", error);
                }
                [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
                
                NSError *contextError = nil;
                if (![context save:&contextError]) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog(@"Unresolved error %@, %@", contextError, [contextError userInfo]);
                    abort();
                }
            }];
        });
    }
    else {
        
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                title:@"Delete"];
    
    return rightUtilityButtons;
}

- (NSArray *)leftButtons
{
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.8f green:0.231f blue:0.8f alpha:1.0]
                                                icon:[UIImage imageNamed:@"favorite.png"]];
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.15f green:0.6f blue:0.7f alpha:1.0]
                                                icon:[UIImage imageNamed:@"list.png"]];
    
    return leftUtilityButtons;
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:10];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    //NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];

    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            return;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(RecipeTableViewCell*)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

@end
