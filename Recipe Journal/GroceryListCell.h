//
//  GroceryListCell.h
//  Recipe Journal
//
//  Created by Robert Miller on 3/3/15.
//  Copyright (c) 2015 Robert Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroceryList.h"
#import "RecipeCloudManager.h"

@interface GroceryListCell : UITableViewCell

@property(nonatomic,retain) GroceryList *ingredient;
@property(nonatomic,retain) id parentViewController;

-(void)configureCell;

@end
