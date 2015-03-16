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
#import "AppDelegate.h"

@interface MasterViewController () <RNFrostedSidebarDelegate, SWTableViewCellDelegate>

@property(nonatomic,retain) RecipeCloudManager *cloudManager;
@property(nonatomic,retain) RNFrostedSidebar *callout;
@property(nonatomic,retain) UIView *searchPage;

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
    
    _callout = [[RNFrostedSidebar alloc] initWithImages:@[[UIImage imageNamed:@"cutlery-50.png"], [UIImage imageNamed:@"favorite-50.png"], [UIImage imageNamed:@"sort-50.png"], [UIImage imageNamed:@"search-50.png"], [UIImage imageNamed:@"checklist-50.png"], [UIImage imageNamed:@"cross-50.png"]]];
    _callout.delegate = self;
    
    _tableViewDataSource = [self.fetchedResultsController fetchedObjects];
    
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
            
            //Change the title and source
            self.title = @"Recipes";
            _tableViewSource = RECIPELISTSOURCE;
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

            //Change the add button to add a new recipe
            UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
            self.navigationItem.rightBarButtonItem = addButton;
            
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
            
            _tableViewDataSource = [_fetchedResultsController fetchedObjects];
            
            [self.tableView reloadData];
            
            break;
        }
        case 1: {
            //predicate and load the favorites
            NSLog(@"Load Favorites");
            
            //Change the title to match
            self.title = @"Favorites";
            _tableViewSource = FAVORITELISTSOURCE;
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            
            //release the add button so we don't just add favorite.. kinda confusing..
            self.navigationItem.rightBarButtonItem = nil;
            
            //set the predicate and reload the data
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Event"];
            
            [fetchRequest setFetchBatchSize:10];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"favorited = 1"];
            
            [fetchRequest setPredicate:predicate];
            
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
            NSArray *sortDescriptors = @[sortDescriptor];
            
            [fetchRequest setSortDescriptors:sortDescriptors];
            
            _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
            _fetchedResultsController.delegate = self;
            
            NSError *error = nil;
            if (![self.fetchedResultsController performFetch:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
            
            _tableViewDataSource = [_fetchedResultsController fetchedObjects];
            
            [self.tableView reloadData];
            
            break;
        }
        case 2: {
            //bring up the load options alert and sort
            NSLog(@"Load the Sort Options");
            
            //Give a popup alert to give options
            UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"Sort Recipes" message:@"Sort by: " preferredStyle:UIAlertControllerStyleAlert];
            
            /* Sort by earliest to latest date */
            [alertView addAction:[UIAlertAction actionWithTitle:@"Date: New-Old" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
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
                
                _tableViewDataSource = [_fetchedResultsController fetchedObjects];
                
                NSLog(@"Done with date: earliest - latest");
                
                [self.tableView reloadData];
            }]];
            
            /* Sort by latest to earliest date */
            [alertView addAction:[UIAlertAction actionWithTitle:@"Date: Old-New" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Event"];
                
                // Set the batch size to a suitable number.
                [fetchRequest setFetchBatchSize:10];
                
                // Edit the sort key as appropriate.
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:YES];
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
                
                _tableViewDataSource = [_fetchedResultsController fetchedObjects];
                
                NSLog(@"Done with date latest - earliest");
                
                [self.tableView reloadData];
            }]];
            
            /* Sort by A to Z */
            [alertView addAction:[UIAlertAction actionWithTitle:@"Alphabetical: A-Z" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Event"];
                
                // Set the batch size to a suitable number.
                [fetchRequest setFetchBatchSize:10];
                
                // Edit the sort key as appropriate.
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"recipeName" ascending:YES];
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
                
                _tableViewDataSource = [_fetchedResultsController fetchedObjects];
                
                NSLog(@"Done with alphabetical a - z");
                
                [self.tableView reloadData];
            }]];
            
            /* Sort by Z to A */
            [alertView addAction:[UIAlertAction actionWithTitle:@"Alphabetical: Z-A" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Event"];
                
                // Set the batch size to a suitable number.
                [fetchRequest setFetchBatchSize:10];
                
                // Edit the sort key as appropriate.
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"recipeName" ascending:NO];
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
                
                _tableViewDataSource = [_fetchedResultsController fetchedObjects];
                
                NSLog(@"Done with alphabetical z - a");
                
                [self.tableView reloadData];
            }]];
            
            [alertView addAction:[UIAlertAction actionWithTitle:@"Rating" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Event"];
                
                // Set the batch size to a suitable number.
                [fetchRequest setFetchBatchSize:10];
                
                // Edit the sort key as appropriate.
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"rating" ascending:NO];
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
                
                _tableViewDataSource = [_fetchedResultsController fetchedObjects];
                
                NSLog(@"Done with alphabetical z - a");
                
                [self.tableView reloadData];
            }]];
            
            /* Sort by Z to A */
            [alertView addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                //Do Nothing
            }]];
            
            [self.navigationController presentViewController:alertView animated:YES completion:nil];
            
            break;
        }
        case 3: {
            //bring up the search page
            NSLog(@"Load The Search Page");
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Search:" message:@"Enter any or all of the search criteria:" preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.placeholder = @"Recipe Name";
            }];
            [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.placeholder = @"Contains Ingredient";
            }];
            [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.placeholder = @"Max Prep Time";
            }];
            [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.placeholder = @"Max Cook Time";
            }];
            [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.placeholder = @"Max Total Time";
            }];
            [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.placeholder = @"Wine Pairing";
            }];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"Search!" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                //Do the Search
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Event"];
                
                // Set the batch size to a suitable number.
                [fetchRequest setFetchBatchSize:10];
                
                NSMutableArray *predicateArray = [[NSMutableArray alloc] init];
                
                NSPredicate *predicate = [NSPredicate predicateWithValue:true];
                [predicateArray addObject:predicate];
                NSString *predicateString = @"";
                
                UITextField *textField = [[alert textFields] objectAtIndex:0];
                if (![textField.text isEqualToString:@""]) {
                    predicateString = textField.text;
                    NSPredicate *namePredicate = [NSPredicate predicateWithFormat:@"recipeName CONTAINS[c] %@", predicateString];
                    [predicateArray addObject:namePredicate];
                }
                
                /*textField = [[alert textFields] objectAtIndex:1];
                if (![textField.text isEqualToString:@""]) {
                    predicateString = textField.text;
                    //Figure out a way to go through ingredients
                    
                    NSPredicate *ingredientPredicate = [NSPredicate predicateWithFormat:@"ANY SELF.ingredients.ingredient like[c] %@", predicateString];
                    //[predicateArray addObject:ingredientPredicate];
                }*/
                
                textField = [[alert textFields] objectAtIndex:2];
                if (![textField.text isEqualToString:@""]) {
                    predicateString = textField.text;
                    NSPredicate *prepPredicate = [NSPredicate predicateWithFormat:@"prepTimeMinutes = %@", [NSNumber numberWithInteger:[predicateString integerValue]]];
                    [predicateArray addObject:prepPredicate];
                }
                
                textField = [[alert textFields] objectAtIndex:3];
                if (![textField.text isEqualToString:@""]) {
                    predicateString = textField.text;
                    NSPredicate *cookPredicate = [NSPredicate predicateWithFormat:@"cookTimeMinutes = %@", [predicateString integerValue]];
                    [predicateArray addObject:cookPredicate];
                }
                
                textField = [[alert textFields] objectAtIndex:4];
                if (![textField.text isEqualToString:@""]) {
                    predicateString = textField.text;
                    NSPredicate *totalPredicate = [NSPredicate predicateWithFormat:@"cookTimeMinutes + prepTimeMinutes = %@", [NSNumber numberWithInteger:[predicateString integerValue]]];
                    [predicateArray addObject:totalPredicate];
                }
                
                textField = [[alert textFields] objectAtIndex:5];
                if (![textField.text isEqualToString:@""]) {
                    predicateString = textField.text;
                    NSPredicate *winePredicate = [NSPredicate predicateWithFormat:@"winePairing CONTAINS[c] %@", predicateString];
                    [predicateArray addObject:winePredicate];
                }
                
                NSPredicate *fetchPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicateArray];
                
                [fetchRequest setPredicate:fetchPredicate];
                
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
                
                _tableViewDataSource = [_fetchedResultsController fetchedObjects];
                
                textField = [[alert textFields] objectAtIndex:1];
                if (![textField.text isEqualToString:@""]) {
                    predicateString = textField.text;
                    //Figure out a way to go through ingredients
                    
                    NSPredicate *ingredientPredicate = [NSPredicate predicateWithFormat:@"ANY SELF.ingredients.ingredient like[c] %@", predicateString];
                    _tableViewDataSource = [_tableViewDataSource filteredArrayUsingPredicate:ingredientPredicate];
                    //[predicateArray addObject:ingredientPredicate];
                }
                
                NSLog(@"Done with search");
                
                [self.tableView reloadData];
                
                
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                //Do nothing
            }]];
            [self presentViewController:alert animated:YES completion:^{
                //Up up
            }];
            break;
        }
        case 4: {
            
            //load the grocery list
            NSLog(@"Load Grocery List");
            
            //Change the title to match the criteria
            self.title = @"Grocery List";
            _tableViewSource = GROCERYLISTSOURCE;
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;

            //Change the add button to add a grocery item
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewGrocery:)];
            
            //Fetch the Grocery List and reload the table view
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
            
            _tableViewDataSource = [_fetchedResultsController fetchedObjects];
            
            [self.tableView reloadData];
            
            break;
        }
        case 5: {
            //do nothing and let the sidebar dismiss from view
            NSLog(@"dismiss the sidebar");
            
            //doing this as a test.. to be deleted..
            Ingredient *num1 = [[Ingredient alloc] init];
            [num1 setIngredient:@"yarg"];
            Ingredient *num2 = [[Ingredient alloc] init];
            [num2 setIngredient:@"Up"];
            Ingredient *num3 = [[Ingredient alloc] init];
            [num3 setIngredient:@"test"];
            
            NSArray *array = [[NSArray alloc] initWithObjects:num1, num2, num3, nil];
            
            Ingredient *num4 = [[Ingredient alloc] init];
            [num4 setIngredient:@"blarg"];
            NSArray *secArray = [[NSArray alloc] initWithObjects:num4, nil];
            
            NSManagedObjectContext *context = [[AppDelegate sharedInstance] managedObjectContext];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:context];
            
            //NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
            NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
            
            Event *event1 = (Event*)newManagedObject;
            [event1 setRecipeName:@"one"];
            [event1 setIngredients:array];
            
            NSManagedObject *secManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
            Event *event2 = (Event*)secManagedObject;
            [event2 setRecipeName:@"two"];
            [event2 setIngredients:secArray];
            
            NSArray *eventArray = [[NSArray alloc] initWithObjects:event1, event2, nil];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY SELF.ingredients.ingredient like[c] 'up'"];
            NSArray *filteredArray = [eventArray filteredArrayUsingPredicate:predicate];
            NSLog(@"count of filtered array: %lu", (unsigned long)[filteredArray count]);
                                      
            break;
        }
            
        default:
            break;
    }
    
    [sidebar dismissAnimated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)insertNewGrocery:(id)sender {
    
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"New Grocery Item" message:@"Add a new item, amount, and size" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertView addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.tag = 0x0;    //first textField
        textField.placeholder = @"Ingredient";
        textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    }];
    [alertView addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.tag = 0x1;    //second textField
        textField.placeholder = @"Amount";
        textField.keyboardType = UIKeyboardTypeDecimalPad;
    }];
    [alertView addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.tag = 0x2;
        //textField.delegate = self;
        textField.placeholder = @"Cup/Tsp/Tbsp/Whole?";
        textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    }];
    [alertView addAction:[UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"GroceryList" inManagedObjectContext:self.managedObjectContext];
        
        //NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:self.managedObjectContext];
        GroceryList *_tempIngredient = (GroceryList*)newManagedObject;
        for (UITextField *textField in [alertView textFields]) {
            switch (textField.tag) {
                case 0:
                    [_tempIngredient setName:[textField text]];
                    break;
                case 1:
                    [_tempIngredient setAmount:[NSNumber numberWithFloat:[[textField text] floatValue]]];
                    break;
                case 2:
                    [_tempIngredient setType:[textField text]];
                    
                default:
                    break;
            }
        }
        
        [_tempIngredient setTimeStamp:[NSDate date]];
        
        NSError *contextError = nil;
        if (![self.managedObjectContext save:&contextError]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", contextError, [contextError userInfo]);
            abort();
        }
        
        [self.tableView reloadData];
        
        if ([_cloudManager isLoggedIn]) {
            [_cloudManager saveListToItem:_tempIngredient];
        }
    }]];
    [alertView addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        //Do nothing
    }]];
    
    [self.navigationController presentViewController:alertView animated:YES completion:nil];
    
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
        //DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        //[controller setDetailItem:(Event*)object];
        //controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        //controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //return [[self.fetchedResultsController sections] count];
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    //return [sectionInfo numberOfObjects];
    return [_tableViewDataSource count];
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
        
        //NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        GroceryList *cellList = (GroceryList*)[_tableViewDataSource objectAtIndex:indexPath.row];
        
        cell.ingredient = cellList;
        cell.parentViewController = self;
        [cell configureCell];
        return cell;
    }
    else if ([_tableViewSource isEqualToString:FAVORITELISTSOURCE]) {
        RecipeTableViewCell *recipeCell = [tableView dequeueReusableCellWithIdentifier:@"RecipeCell" forIndexPath:indexPath];
        [self configureCell:recipeCell atIndexPath:indexPath];
        return recipeCell;
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
    CGFloat height = 60;
    if ([_tableViewSource isEqualToString:RECIPELISTSOURCE]) {
        height = 120;
    }
    else if ([_tableViewSource isEqualToString:FAVORITELISTSOURCE]) {
        height = 120;
    }
    return height;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    [cell setFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 120)];
    
    //NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([_tableViewSource isEqualToString:RECIPELISTSOURCE]) {
        RecipeTableViewCell *tempCell = (RecipeTableViewCell*)cell;
        Event *cellEvent = (Event*)[_tableViewDataSource objectAtIndex:indexPath.row];
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
    else if ([_tableViewSource isEqualToString:FAVORITELISTSOURCE]) {
        RecipeTableViewCell *tempCell = (RecipeTableViewCell*)cell;
        Event *cellEvent = (Event*)[_tableViewDataSource objectAtIndex:indexPath.row];
        tempCell.event = cellEvent;
        tempCell.leftUtilityButtons = [self leftButtons];
        tempCell.rightUtilityButtons = [self rightButtons];
        tempCell.delegate = self;
        [tempCell configureCell];
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
    
    for (Ingredient *ingredient in [event ingredients]) {
        
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
    
    if ([[favoritedEvent favorited] boolValue]) {
        [favoritedEvent setFavorited:[NSNumber numberWithBool:NO]];
    }
    else {
        [favoritedEvent setFavorited:[NSNumber numberWithBool:YES]];
    }
    
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    if ([_cloudManager isLoggedIn]) {
        [_cloudManager modifyRecipeToCloud:favoritedEvent];
    }
    
    [self.tableView reloadData];
    
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
    
    _tableViewDataSource = [_fetchedResultsController fetchedObjects];
    
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
