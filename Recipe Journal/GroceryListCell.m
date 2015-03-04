//
//  GroceryListCell.m
//  Recipe Journal
//
//  Created by Robert Miller on 3/3/15.
//  Copyright (c) 2015 Robert Miller. All rights reserved.
//

#import "GroceryListCell.h"
#import "AppDelegate.h"

@implementation GroceryListCell

-(void)configureCell {
    NSString *cellString = [[_ingredient amount] stringValue];
    cellString = [cellString stringByAppendingString:@" "];
    cellString = [cellString stringByAppendingString:[_ingredient type]];
    cellString = [cellString stringByAppendingString:@": "];
    cellString = [cellString stringByAppendingString:[_ingredient name]];
    
    self.textLabel.text = cellString;
    
    self.imageView.image = [UIImage imageNamed:@"unchecked-50.png"];
    
    UIButton *checkButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [checkButton addTarget:self action:@selector(toggleCheckButton) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:checkButton];
}

-(void)toggleCheckButton {
    
    if ([[_ingredient marked] isEqualToNumber:[NSNumber numberWithBool:true]]) {
        [_ingredient setMarked:[NSNumber numberWithBool:false]];
        
        NSManagedObjectContext *context = [[AppDelegate sharedInstance] managedObjectContext];
        
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        self.imageView.image = [UIImage imageNamed:@"unchecked-50.png"];

    }
    else {
        [_ingredient setMarked:[NSNumber numberWithBool:true]];
    
        NSManagedObjectContext *context = [[AppDelegate sharedInstance] managedObjectContext];

        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a  shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        self.imageView.image = [UIImage imageNamed:@"checked-50.png"];
    }
    
}

@end
