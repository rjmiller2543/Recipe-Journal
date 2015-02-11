//
//  NewIngredientsView.h
//  Recipe Journal
//
//  Created by Robert Miller on 2/11/15.
//  Copyright (c) 2015 Robert Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewIngredientsView : UIView <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic,retain) UITableView *tableView;
@property(nonatomic,retain) NSMutableArray *ingredients;
@property(nonatomic,retain) NSLayoutConstraint *tableViewHeight;

@end
