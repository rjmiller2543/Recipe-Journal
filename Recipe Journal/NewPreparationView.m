//
//  NewPreparationView.m
//  Recipe Journal
//
//  Created by Robert Miller on 2/12/15.
//  Copyright (c) 2015 Robert Miller. All rights reserved.
//

#import "NewPreparationView.h"

@implementation NewPreparationView

BOOL isEditingSteps = false;

- (instancetype)init
{
    self = [super init];
    if (self) {
        //_steps = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)willMoveToSuperview:(UIView *)newSuperview {
    
}

-(void)willMoveToWindow:(UIWindow *)newWindow {
    [self needsUpdateConstraints];
    [self setNeedsLayout];
    [self layoutIfNeeded];
    [self configureView];
}

-(void)configureView {
    
    _tableView.scrollEnabled = NO;
    _viewHeight = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_tableView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:22.0];
    [self addConstraint:_viewHeight];
    
    self.backgroundColor = [UIColor whiteColor];
    _headerLabel = [[UILabel alloc] init];
    _headerLabel.backgroundColor = [UIColor whiteColor];
    [_headerLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    _headerLabel.font = [UIFont fontWithName:@"Copperplate" size:19.0f];
    _headerLabel.text = @"Preparation:";
    [self addSubview:_headerLabel];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_headerLabel attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:5.0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_headerLabel attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:5.0]];
    
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
                                                     relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
    
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
    if (isEditingSteps) {
        return _steps.count + 1;
    }
    return _steps.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    if (indexPath.row >= [_steps count]) {
        UIButton *newStep = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
        [newStep addTarget:self action:@selector(addNewStepWithIndexPath:) forControlEvents:UIControlEventTouchUpInside];
        newStep.tag = indexPath.row;
        [cell addSubview:newStep];
        
        cell.textLabel.text = @"Add New Step";
        cell.textLabel.font = [UIFont fontWithName:@"Copperplate" size:15.0f];
    }
    else {
        NSString *tempStep = @"Step ";
        NSNumber *stepNum = [NSNumber numberWithInteger:(indexPath.row + 1)];
        tempStep = [tempStep stringByAppendingString:[stepNum stringValue]];
        tempStep = [tempStep stringByAppendingString:@": "];
        NSString *prepText = (NSString*)[_steps objectAtIndex:indexPath.row];
        tempStep = [tempStep stringByAppendingString:prepText];
        
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 0;
        [cell sizeToFit];
        cell.textLabel.text = tempStep;
        cell.textLabel.font = [UIFont fontWithName:@"Copperplate" size:15.0f];
    }
    
    return cell;
}

-(void)addNewStepWithIndexPath:(id)sender {
    //NSLog(@"add new ingredient");
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"Add Ingredient" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertView addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        
        textField.tag = 0x0;    //first textField
        textField.delegate = self;
        
        UIButton *senderButton = (UIButton*)sender;
        NSString *placeholderText = @"Step ";
        NSNumber *tempNumber = [NSNumber numberWithInteger:senderButton.tag];
        placeholderText = [placeholderText stringByAppendingString:[tempNumber stringValue]];
        
        textField.placeholder = placeholderText;
        
    }];
    [alertView addAction:[UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        UITextField *tempField = [[alertView textFields] objectAtIndex:0];
        NSString *tempStep = [[NSString alloc] initWithString:[tempField text]];
        if (_steps == nil) {
            _steps = [[NSMutableArray alloc] init];
        }
        [_steps addObject:tempStep];
        
        [_tableView reloadData];
        [self updateTableViewHeight];
    }]];
    [alertView addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        //Do nothing
    }]];
    
    [_parentViewController presentViewController:alertView animated:YES completion:nil];
    
}

-(void)updateTableViewHeight {
    
    CGFloat height = 0;
    for (int i = 0; i < [_tableView numberOfRowsInSection:0]; i++) {
        UITableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        height += cell.frame.size.height;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        
        CGFloat finalHeight = 0;
        if (height < _tableView.contentSize.height) {
            finalHeight = _tableView.contentSize.height;
        }
        else {
            finalHeight = height;
        }
        _tableViewHeight.constant = finalHeight;
        [_tableView setNeedsUpdateConstraints];
        [_tableView setNeedsLayout];
        [_tableView layoutIfNeeded];
        
        _viewHeight.constant = _tableViewHeight.constant + 22;
        [self setNeedsUpdateConstraints];
        [self setNeedsLayout];
        [self layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        //NSLog(@"animation completed");
    }];
    
}

-(void)setEditBool:(BOOL)edit {
    isEditingSteps = edit;
    [_tableView reloadData];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end

