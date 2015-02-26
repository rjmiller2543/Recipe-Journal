//
//  NewPreparationView.h
//  Recipe Journal
//
//  Created by Robert Miller on 2/12/15.
//  Copyright (c) 2015 Robert Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CSGrowingTextView/CSGrowingTextView.h>

@interface NewPreparationView : UIView <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate, CSGrowingTextViewDelegate>

@property(nonatomic,retain) UITableView *tableView;
@property(nonatomic,retain) UILabel *headerLabel;
@property(nonatomic,retain) NSMutableArray *steps;
@property(nonatomic,retain) NSLayoutConstraint *tableViewHeight;
@property(nonatomic,retain) NSLayoutConstraint *viewHeight;

@property(nonatomic) id parentViewController;

-(void)setEditBool:(BOOL)edit;

@end
