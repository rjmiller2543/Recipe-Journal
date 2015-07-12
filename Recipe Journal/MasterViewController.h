//
//  MasterViewController.h
//  Recipe Journal
//
//  Created by Robert Miller on 2/6/15.
//  Copyright (c) 2015 Robert Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "RecipeJournalHelper.h"

@class DetailViewController;

@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property(nonatomic,retain) NSArray *tableViewDataSource;

-(void)doSearch:(id)searchController;
-(void)cancelSearch;
-(void)closeNewRecipeView;

@end

