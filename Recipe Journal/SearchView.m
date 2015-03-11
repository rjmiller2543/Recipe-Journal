//
//  SearchView.m
//  Recipe Journal
//
//  Created by Robert Miller on 3/9/15.
//  Copyright (c) 2015 Robert Miller. All rights reserved.
//

#import "SearchView.h"
#import <JVFloatLabeledTextField/JVFloatLabeledTextField.h>

@interface SearchView()

@property(nonatomic,retain) JVFloatLabeledTextField *recipeName;
@property(nonatomic,retain) JVFloatLabeledTextField *prepTime;
@property(nonatomic,retain) JVFloatLabeledTextField *cookTime;
@property(nonatomic,retain) JVFloatLabeledTextField *totalTime;
@property(nonatomic,retain) JVFloatLabeledTextField *ingredient;
@property(nonatomic,retain) JVFloatLabeledTextField *cookProcess;
@property(nonatomic,retain) JVFloatLabeledTextField *winePairing;

@end

@implementation SearchView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //do stuff
        [self configureView];
    }
    return self;
}

-(void)configureView {
    
    
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
