//
//  Ingredient.m
//  Recipe Journal
//
//  Created by Robert Miller on 2/10/15.
//  Copyright (c) 2015 Robert Miller. All rights reserved.
//

#import "Ingredient.h"

@implementation Ingredient

-(void)setIngredient:(NSString *)ingredient {
    _ingredient = ingredient;
}

-(void)setAmount:(NSNumber *)amount {
    _amount = amount;
}

-(void)setSize:(NSString *)size {
    _size = size;
}

@end
