//
//  NewIngredientsView.m
//  Recipe Journal
//
//  Created by Robert Miller on 2/11/15.
//  Copyright (c) 2015 Robert Miller. All rights reserved.
//

#import "NewIngredientsView.h"
#import "Ingredient.h"

@implementation NewIngredientsView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self configureView];
    }
    return self;
}

-(void)configureView {
    UILabel *headerLabel = [[UILabel alloc] init];
    headerLabel.font = [UIFont fontWithName:@"Copperplate" size:19.0f];
    headerLabel.text = @"Ingredients";
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[headerLabel]-0-|"
                                                                      options:NSLayoutFormatAlignAllBaseline
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(headerLabel)]];
    
    // Vertical
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[headerLabel(15)]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(headerLabel)]];
    
    _tableView = [[UITableView alloc] init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual toItem:headerLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:2.0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:0.0 constant:0.0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    
}

#pragma mark - TableView Delegate Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _ingredients.count + 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    if (indexPath.row == 0) {
        UIButton *newIngredient = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
        [newIngredient addTarget:self action:@selector(addNewIngredient) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:newIngredient];
        
        cell.textLabel.text = @"Add New Ingredient";
        cell.textLabel.font = [UIFont fontWithName:@"Copperplate" size:15.0f];
    }
    else {
        Ingredient *tempIng = [_ingredients objectAtIndex:indexPath.row];
        
    }
    
    return [[UITableViewCell alloc] init];
}

-(void)addNewIngredient {
    
}

-(void)updateTableViewHeight {
    [_tableView removeConstraint:_tableViewHeight];
    _tableViewHeight = [NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeHeight
                                                    relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:0.9 constant:0.0];
    [_tableView addConstraint:_tableViewHeight];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
