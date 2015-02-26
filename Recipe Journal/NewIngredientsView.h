//
//  NewIngredientsView.h
//  Recipe Journal
//
//  Created by Robert Miller on 2/11/15.
//  Copyright (c) 2015 Robert Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Ingredient.h"


@interface NewIngredientsView : UIView <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property(nonatomic,retain) UITableView *tableView;
@property(nonatomic,retain) UILabel *headerLabel;
@property(nonatomic,retain) NSMutableArray *ingredients;
@property(nonatomic,retain) NSLayoutConstraint *tableViewHeight;
@property(nonatomic,retain) NSLayoutConstraint *viewHeight;
@property(nonatomic,retain) Ingredient *tempIngredient;

@property(nonatomic) id parentViewController;

-(void)setEditBool:(BOOL)edit;

@end
