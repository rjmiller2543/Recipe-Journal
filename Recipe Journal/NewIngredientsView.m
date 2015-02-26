//
//  NewIngredientsView.m
//  Recipe Journal
//
//  Created by Robert Miller on 2/11/15.
//  Copyright (c) 2015 Robert Miller. All rights reserved.
//

#import "NewIngredientsView.h"

@implementation NewIngredientsView 

bool isEditingIngredients = false;

- (instancetype)init
{
    self = [super init];
    //NSLog(@"init");
    if (self) {
        //_ingredients = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)willMoveToSuperview:(UIView *)newSuperview {
    //NSLog(@"will move to superview");
    //[self configureView];
}

-(void)willMoveToWindow:(UIWindow *)newWindow {
    //NSLog(@"will move to window");
    [self needsUpdateConstraints];
    [self setNeedsLayout];
    [self layoutIfNeeded];
    [self configureView];
}

-(void)configureView {
    
    //NSLog(@"%@", [self.superview description]);
    //NSLog(@"%@", [self description]);
    _tableView.scrollEnabled = NO;
    _viewHeight = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_tableView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:22.0];
    [self addConstraint:_viewHeight];
    
    self.backgroundColor = [UIColor whiteColor];
    _headerLabel = [[UILabel alloc] init];
    _headerLabel.backgroundColor = [UIColor whiteColor];
    [_headerLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    _headerLabel.font = [UIFont fontWithName:@"Copperplate" size:19.0f];
    _headerLabel.text = @"Ingredients:";
    [self addSubview:_headerLabel];
    /*[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[headerLabel]-0-|"
                                                                      options:NSLayoutFormatAlignAllBaseline
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_headerLabel)]];
    
    // Vertical
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[headerLabel(15)]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_headerLabel)]];
   */
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_headerLabel attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:0.0 constant:5.0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_headerLabel attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:0.0 constant:5.0]];
    
    [_headerLabel addConstraint:[NSLayoutConstraint constraintWithItem:_headerLabel attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:0.0 constant:15.0]];
    
    _tableView = [[UITableView alloc] init];
    [_tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview:_tableView];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual toItem:_headerLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:2.0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:0.0 constant:0.0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    
    _tableViewHeight = [NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeHeight
                                                    relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:0.0 constant:_tableView.contentSize.height + 20];
    [_tableView addConstraint:_tableViewHeight];
    [_tableView reloadData];
    
    [_tableView setNeedsLayout];
    [_tableView layoutIfNeeded];
    [self updateTableViewHeight];
}

#pragma mark - TableView Delegate Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //NSLog(@"number of rows in section: %lu", _ingredients.count);
    if (isEditingIngredients) {
        return _ingredients.count + 1;
    }
    return _ingredients.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //NSLog(@"number of sections in table");
    return 1;
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"did select row at index path");
    if (indexPath.row == 0) {
        //[self addNewIngredient];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //NSLog(@"cell for row at index path");
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    if (indexPath.row >= [_ingredients count]) {
        UIButton *newIngredient = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
        //newIngredient.backgroundColor = [UIColor blackColor];
        //[newIngredient setTitle:@"Add New Ingredient" forState:UIControlStateNormal];
        [newIngredient addTarget:self action:@selector(addNewIngredient) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:newIngredient];
        
        cell.textLabel.text = @"Add New Ingredient";
        cell.textLabel.font = [UIFont fontWithName:@"Copperplate" size:15.0f];
    }
    else {
        Ingredient *tempIng = [_ingredients objectAtIndex:(indexPath.row)];
        
        NSString *labelString = @"";
        if ([tempIng amount] != nil) {
            labelString = [labelString stringByAppendingString:[[tempIng amount] stringValue]];
            labelString = [labelString stringByAppendingString:@" "];
        }
        if ([tempIng size] != nil) {
            labelString = [labelString stringByAppendingString:[tempIng size]];
        }
        if ([tempIng ingredient] != nil) {
            labelString = [labelString stringByAppendingString:@" | "];
            labelString = [labelString stringByAppendingString:[tempIng ingredient]];
        }
        
        cell.textLabel.text = labelString;
        cell.textLabel.font = [UIFont fontWithName:@"Copperplate" size:15.0f];
    }
    
    return cell;
}

-(void)addNewIngredient {
    //NSLog(@"add new ingredient");
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"Add Ingredient" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertView addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.tag = 0x0;    //first textField
        textField.placeholder = @"Ingredient";
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
    }];
    [alertView addAction:[UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        _tempIngredient = [[Ingredient alloc] init];
        for (UITextField *textField in [alertView textFields]) {
            switch (textField.tag) {
                case 0:
                    [_tempIngredient setIngredient:[textField text]];
                    break;
                case 1:
                    [_tempIngredient setAmount:[NSNumber numberWithFloat:[[textField text] floatValue]]];
                    break;
                case 2:
                    [_tempIngredient setSize:[textField text]];
                    
                default:
                    break;
            }
        }
        
        if (_ingredients == nil) {
            _ingredients = [[NSMutableArray alloc] init];
        }
        [_ingredients addObject:_tempIngredient];
        [_tableView reloadData];
        [self updateTableViewHeight];
    }]];
    [alertView addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        //Do nothing
    }]];
    
    [_parentViewController presentViewController:alertView animated:YES completion:nil];
    
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.tag == 0x2) {
        /*UIAlertController *sizeChoices = [UIAlertController alertControllerWithTitle:@"Size portion?" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [sizeChoices addAction:[UIAlertAction actionWithTitle:@"Cup" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [_tempIngredient setSize:@"Cup"];
        }]];
        [sizeChoices addAction:[UIAlertAction actionWithTitle:@"Tsp" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [_tempIngredient setSize:@"Tsp"];
        }]];
        [sizeChoices addAction:[UIAlertAction actionWithTitle:@"Tbsp" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [_tempIngredient setSize:@"Tbsp"];
        }]];
        [sizeChoices addAction:[UIAlertAction actionWithTitle:@"Whole" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [_tempIngredient setSize:@"Whole"];
        }]];
        [sizeChoices addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            //Do nothing
        }]];
        
        id rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
        if([rootViewController isKindOfClass:[UINavigationController class]])
        {
            rootViewController = [((UINavigationController *)rootViewController).viewControllers objectAtIndex:0];
        }
        [rootViewController presentViewController:sizeChoices animated:YES completion:nil];
         */
    }
}

-(void)updateTableViewHeight {
    //[_tableView removeConstraint:_tableViewHeight];
    //NSLog(@"update table view height");
    //NSLog(@"tableview before");
    //NSLog(@"%@", [_tableView description]);
    //_tableViewHeight = [NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeHeight
    //                                                relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:0.0 constant:_tableView.contentSize.height];
    //[_tableView addConstraint:_tableViewHeight];
    [UIView animateWithDuration:0.3 animations:^{
        _tableViewHeight.constant = _tableView.contentSize.height;
        [_tableView setNeedsUpdateConstraints];
        [_tableView setNeedsLayout];
        [_tableView layoutIfNeeded];
        //NSLog(@"tableview after");
        //NSLog(@"%@", [_tableView description]);
        
        _viewHeight.constant = _tableViewHeight.constant + 22;
        [self setNeedsUpdateConstraints];
        [self setNeedsLayout];
        [self layoutIfNeeded];
        //NSLog(@"%@", [self description]);
    } completion:^(BOOL finished) {
        //NSLog(@"animation completed");
    }];
    
}

-(void)setEditBool:(BOOL)edit {
    isEditingIngredients = edit;
    [_tableView reloadData];
    [self updateTableViewHeight];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
