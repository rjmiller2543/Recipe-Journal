//
//  SearchViewController.h
//  Recipe Journal
//
//  Created by Robert Miller on 6/17/15.
//  Copyright (c) 2015 Robert Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UIViewController

@property(nonatomic,retain) NSString *recipeName;
@property(nonatomic,retain) NSString *ingredient;
@property(nonatomic,retain) NSNumber *maxPrepTime;
@property(nonatomic,retain) NSNumber *maxCookTime;
@property(nonatomic,retain) NSNumber *maxTotalTime;
@property(nonatomic,retain) NSString *winePairing;
@property(nonatomic,retain) NSString *mealType;
@property(nonatomic,retain) NSString *lowCalorie;
@property(nonatomic) id hostViewController;

-(void)layoutSearchView;

@end
