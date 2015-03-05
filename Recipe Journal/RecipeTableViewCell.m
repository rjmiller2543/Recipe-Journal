//
//  RecipeTableViewCell.m
//  Recipe Journal
//
//  Created by Robert Miller on 2/18/15.
//  Copyright (c) 2015 Robert Miller. All rights reserved.
//

#import "RecipeTableViewCell.h"
#import <AXRatingView/AXRatingView.h>

@interface RecipeTableViewCell () <UIGestureRecognizerDelegate>

@property(nonatomic,retain) UILabel *label;
@property(nonatomic,retain) AXRatingView *rating;
@property(nonatomic,retain) UISegmentedControl *processChoice;

@end

@implementation RecipeTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
}

-(void)configureCell {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *image = [UIImage imageWithData:[_event recipeIconImage]];
        CGSize size = self.frame.size;//set the width and height
        
        //UIGraphicsBeginImageContext(size);
        
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGRect area = CGRectMake(0, 0, size.width, size.height);
        
        CGContextScaleCTM(ctx, 1, -1);
        CGContextTranslateCTM(ctx, 0, -area.size.height);
        
        CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
        
        CGContextSetAlpha(ctx, 0.4);
        
        CGContextDrawImage(ctx, area, image.CGImage);
        
        //[image drawInRect:self.frame];
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        
        //here is the scaled image which has been changed to the size specified
        UIGraphicsEndImageContext();
        
        self.backgroundColor = [UIColor colorWithPatternImage:newImage];
        //self.backgroundColor = [UIColor redColor];
        NSLog(@"background image done");
    });
    
    [self setOpaque:NO];
    [[self layer] setOpaque:NO];
    
    if (_label == nil) {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(10, 70, 0, 0)];
    }
    _label.text = [_event recipeName];
    _label.font = [UIFont fontWithName:@"Copperplate-Bold" size:20.0];
    [_label sizeToFit];
    [self addSubview:_label];
    
    if (_rating == nil) {
        _rating = [[AXRatingView alloc] initWithFrame:CGRectMake(10, 90, 120, 20)];
    }
    _rating.value = [[_event rating] floatValue];
    _rating.enabled = NO;
    [self addSubview:_rating];
    
    if (_processChoice == nil) {
        _processChoice = [[UISegmentedControl alloc]
                          initWithItems:@[[UIImage imageNamed:@"cooker-25.png"],
                                          [UIImage imageNamed:@"kitchen-25.png"]]];
    }
    [_processChoice setFrame:CGRectMake(self.frame.size.width - 75, 70, 70, 40)];
    [self addSubview:_processChoice];
    
    if (_favorited == nil) {
        _favorited = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - 120, 70, 40, 40)];
    }
    if ([[_event favorited] boolValue]) {
        _favorited.image = [UIImage imageNamed:@"favorited-50.png"];
    }
    else {
        _favorited.image = [UIImage imageNamed:@"favorite-50.png"];
    }
    [self addSubview:_favorited];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    
}

@end
