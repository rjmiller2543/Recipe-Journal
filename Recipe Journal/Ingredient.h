//
//  Ingredient.h
//  Recipe Journal
//
//  Created by Robert Miller on 2/10/15.
//  Copyright (c) 2015 Robert Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Ingredient : NSObject

@property(nonatomic,retain) NSString *ingredient;
@property(nonatomic,retain) NSNumber *amount;
@property(nonatomic,retain) NSString *size;

@end
