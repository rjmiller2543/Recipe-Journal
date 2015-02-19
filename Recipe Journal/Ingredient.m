//
//  Ingredient.m
//  Recipe Journal
//
//  Created by Robert Miller on 2/10/15.
//  Copyright (c) 2015 Robert Miller. All rights reserved.
//

#import "Ingredient.h"

@implementation Ingredient

-(id)initWithCoder:(NSCoder*)aDecoder {
    if (self = [super init]) {
        [self setIngredient:[aDecoder decodeObjectForKey:@"ingredient"]];
        [self setAmount:[aDecoder decodeObjectForKey:@"amount"]];
        [self setSize:[aDecoder decodeObjectForKey:@"size"]];
    }
    return self;
}

-(void)setIngredient:(NSString *)ingredient {
    _ingredient = ingredient;
}

-(void)setAmount:(NSNumber *)amount {
    _amount = amount;
}

-(void)setSize:(NSString *)size {
    _size = size;
}

-(void)encodeWithCoder:(NSCoder*)aCoder {
    [aCoder encodeObject:_ingredient forKey:@"ingredient"];
    [aCoder encodeObject:_amount forKey:@"amount"];
    [aCoder encodeObject:_size forKey:@"size"];
}

@end
