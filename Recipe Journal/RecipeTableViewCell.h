//
//  RecipeTableViewCell.h
//  Recipe Journal
//
//  Created by Robert Miller on 2/18/15.
//  Copyright (c) 2015 Robert Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SWTableViewCell/SWTableViewCell.h>
#import "Event.h"

@interface RecipeTableViewCell : SWTableViewCell

@property(nonatomic,retain) Event *event;
@property(nonatomic,retain) UIImageView *favorited;

-(void)configureCell;

@end
