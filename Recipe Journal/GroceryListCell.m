//
//  GroceryListCell.m
//  Recipe Journal
//
//  Created by Robert Miller on 3/3/15.
//  Copyright (c) 2015 Robert Miller. All rights reserved.
//

#import "GroceryListCell.h"
#import "AppDelegate.h"

@interface GroceryListCell ()

@property(nonatomic,retain) NSTimer *timer;
@property(nonatomic) float counter;
@property(nonatomic,retain) RecipeCloudManager *cloudManager;

@end

@implementation GroceryListCell

-(void)awakeFromNib {
    
}

-(void)configureCell {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressDone:)];
    longPress.minimumPressDuration = 0.2;
    longPress.delegate = self;
    [self addGestureRecognizer:longPress];
    _counter = 1.0;
    
    NSString *cellString = [[_ingredient amount] stringValue];
    cellString = [cellString stringByAppendingString:@" "];
    cellString = [cellString stringByAppendingString:[_ingredient type]];
    cellString = [cellString stringByAppendingString:@" | "];
    cellString = [cellString stringByAppendingString:[_ingredient name]];
    
    self.textLabel.text = cellString;
    
    if ([[_ingredient marked] boolValue]) {
        self.imageView.image = [UIImage imageNamed:@"checked-50.png"];
        self.imageView.userInteractionEnabled = YES;
    }
    else {
        self.imageView.image = [UIImage imageNamed:@"unchecked-50.png"];
        self.imageView.userInteractionEnabled = YES;
    }
    
    UIButton *checkButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [checkButton addTarget:self action:@selector(toggleCheckButton) forControlEvents:UIControlEventTouchUpInside];
    [self.imageView addSubview:checkButton];
}

-(void)toggleCheckButton {
    
    if ([[_ingredient marked] boolValue]) {
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

-(void)updateCellBackground {
    
    _counter -= 0.01;
    
    self.backgroundColor = [UIColor colorWithRed:0.8 green:0.1 blue:(1.0 - _counter) alpha:1.0];
    
    if (_counter <= 0.0) {
        [_timer invalidate];
        _counter = 1.0;
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Edit Item" message:@"Options:" preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction:[UIAlertAction actionWithTitle:@"Edit Item" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UIAlertController *stringPopup = [UIAlertController alertControllerWithTitle:@"Edit Item" message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            [stringPopup addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.tag = 0x0;    //first textField
                textField.text = [_ingredient name];
                textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
            }];
            [stringPopup addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.tag = 0x1;    //second textField
                textField.text = [[_ingredient amount] stringValue];
                textField.keyboardType = UIKeyboardTypeDecimalPad;
            }];
            [stringPopup addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.tag = 0x2;
                //textField.delegate = self;
                textField.text = [_ingredient type];
                textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
            }];
            [stringPopup addAction:[UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                //_ingredient = [[Ingredient alloc] init];
                for (UITextField *textField in [stringPopup textFields]) {
                    switch (textField.tag) {
                        case 0:
                            [_ingredient setName:[textField text]];
                            break;
                        case 1:
                            [_ingredient setAmount:[NSNumber numberWithFloat:[[textField text] floatValue]]];
                            break;
                        case 2:
                            [_ingredient setType:[textField text]];
                            
                        default:
                            break;
                    }
                }
                
                NSManagedObjectContext *context = [[AppDelegate sharedInstance] managedObjectContext];
                
                NSError *error = nil;
                if (![context save:&error]) {
                    NSLog(@"error saving list with error: %@", error);
                    abort();
                }
                
                [self configureCell];
            }]];
            
            [stringPopup addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                //Do nothing
            }]];
            
            [_parentViewController presentViewController:stringPopup animated:YES completion:nil];
            
        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            
            UIAlertController *stringPopup = [UIAlertController alertControllerWithTitle:@"Are you sure?" message:@"This action will permanantly delete the item from iCloud" preferredStyle:UIAlertControllerStyleAlert];
            [stringPopup addAction:[UIAlertAction actionWithTitle:@"Yeah I'm Sure" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                NSManagedObjectContext *context = [[AppDelegate sharedInstance] managedObjectContext];
                
                if (_cloudManager == nil) {
                    _cloudManager = [[RecipeCloudManager alloc] init];
                }
                
                if ([_cloudManager isLoggedIn]) {
                    [_cloudManager removeItemFromCloud:_ingredient complete:^(NSError *error) {
                        if (error) {
                            NSLog(@"error removing item from cloud with error: %@", error);
                        }
                        else {
                            [context deleteObject:_ingredient];
                            
                            NSError *error = nil;
                            if (![context save:&error]) {
                                NSLog(@"error with deleting grocery item with error: %@", error);
                                abort();
                            }
                        }
                    }];
                }
                
            }]];
            [stringPopup addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                //do nothing
            }]];
            
            [_parentViewController presentViewController:stringPopup animated:YES completion:nil];
            
        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            //Do nothing
        }]];
        
        [_parentViewController presentViewController:alert animated:YES completion:^{
            //oops..
        }];
        
    }
    
    /*
     stringPopup.addAction(UIAlertAction(title: "YES", style: .Destructive, handler: { Void in
     
     let context = self.fetchedResultsController.managedObjectContext
     let cell: UITableViewCell = self.SelectedCell!
     let indexPath = self.tableView.indexPathForCell(cell)
     let managedObject: NSManagedObject = self.fetchedResultsController.objectAtIndexPath(indexPath!) as NSManagedObject
     context.deleteObject(managedObject)
     
     // Save the context.
     var error: NSError? = nil
     if !context.save(&error) {
     // Replace this implementation with code to handle the error appropriately.
     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
     //println("Unresolved error \(error), \(error.userInfo)")
     abort()
     }
     }));
     stringPopup.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { Void in
     //Cancel
     }))
     self.presentViewController(stringPopup, animated: true, completion: nil)
     
     }))
     alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { Void in
     //Cancel
     }))
     self.presentViewController(alert, animated: true, completion: nil)
     }
     */
}

-(void)longPressDone:(UILongPressGestureRecognizer*)sender {
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateCellBackground) userInfo:nil repeats:true];
    }
    else if (sender.state == UIGestureRecognizerStateCancelled) {
        [_timer invalidate];
        self.backgroundColor = [UIColor whiteColor];
        _counter = 1.0;
    }
    else if (sender.state == UIGestureRecognizerStateEnded) {
        [_timer invalidate];
        if (_counter > 0.0) {
            [self toggleCheckButton];
        }
        _counter = 1.0;
        self.backgroundColor = [UIColor whiteColor];
    }
    NSLog(@"counter: %f", _counter);
}

@end
