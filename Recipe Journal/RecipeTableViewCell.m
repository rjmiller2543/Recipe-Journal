//
//  RecipeTableViewCell.m
//  Recipe Journal
//
//  Created by Robert Miller on 2/18/15.
//  Copyright (c) 2015 Robert Miller. All rights reserved.
//

#import "RecipeTableViewCell.h"
#import <AXRatingView/AXRatingView.h>

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
        //CGRect area = self.frame;
        
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
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 70, 0, 0)];
    label.text = [_event recipeName];
    label.font = [UIFont fontWithName:@"Copperplate-Bold" size:20.0];
    [label sizeToFit];
    [self addSubview:label];
    
    AXRatingView *rating = [[AXRatingView alloc] initWithFrame:CGRectMake(10, 90, 120, 20)];
    rating.value = [[_event rating] floatValue];
    rating.enabled = NO;
    [self addSubview:rating];
    
    UISegmentedControl *processChoice = [[UISegmentedControl alloc]
                                         initWithItems:@[[UIImage imageNamed:@"cooker-25.png"],
                                                         [UIImage imageNamed:@"kitchen-25.png"]]];
    [processChoice setFrame:CGRectMake(self.frame.size.width - 60, 90, 40, 20)];
    [self addSubview:processChoice];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    
}

@end
