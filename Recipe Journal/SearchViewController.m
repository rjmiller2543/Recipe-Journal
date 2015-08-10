//
//  SearchViewController.m
//  Recipe Journal
//
//  Created by Robert Miller on 6/17/15.
//  Copyright (c) 2015 Robert Miller. All rights reserved.
//

#import "SearchViewController.h"
#import <FlatUIKit.h>
#import <IQDropDownTextField.h>
#import <JVFloatLabeledTextField.h>
#import "MasterViewController.h"

@interface SearchViewController () <UITextFieldDelegate, IQDropDownTextFieldDelegate>

@property(nonatomic,retain) JVFloatLabeledTextField *recipeNameTextField;
@property(nonatomic,retain) JVFloatLabeledTextField *ingredientTextField;
@property(nonatomic,retain) JVFloatLabeledTextField *maxPrepTimeTextField;
@property(nonatomic,retain) JVFloatLabeledTextField *maxCookTimeTextField;
@property(nonatomic,retain) JVFloatLabeledTextField *maxTotalTimeTextField;
@property(nonatomic,retain) JVFloatLabeledTextField *winePairingTextField;
@property(nonatomic,retain) IQDropDownTextField *mealTypeTextField;
@property(nonatomic,retain) IQDropDownTextField *calorieTextField;
@property(nonatomic,retain) IQDropDownTextField *cookProcessTextField;

@end

#define RECIPETEXTFIELD     0x01
#define INGREDTEXTFIELD     0x02
#define PREPTMTEXTFIELD     0x03
#define COOKTMTEXTFIELD     0x04
#define TOTLTMTEXTFIELD     0x05
#define WINEPRTEXTFIELD     0x06
#define MEALTPTEXTFIELD     0x07
#define CALORITEXTFIELD     0x08
#define COOKPRTEXTFIELD     0x09

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)doneWithNumberPad:(id)sender {
    //UITextField *textField = (UITextField*)sender;
    //[textField resignFirstResponder];
    [self.view endEditing:YES];
}

-(void)layoutSearchView {
    
    self.view.backgroundColor = [UIColor whiteColor];
    //Create toolbar to remove number pad
    UIToolbar  *numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad:)],
                           nil];
    
    UILabel *searchLabel = [[UILabel alloc] init];
    searchLabel.text = @"Search Criteria: ";
    searchLabel.font = [UIFont fontWithName:@"Copperplate" size:18.0f];
    [self.view addSubview:searchLabel];
    
    UIButton *closeButton = [[UIButton alloc] init];
    [closeButton setTitle:@"Cancel" forState:UIControlStateNormal];
    closeButton.titleLabel.font = [UIFont fontWithName:@"Copperplate" size:18.0f];
    closeButton.titleLabel.textColor = [UIColor whiteColor];
    closeButton.backgroundColor = [UIColor blackColor];
    [closeButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    
    UIButton *searchButton = [[UIButton alloc] init];
    [searchButton setTitle:@"Search" forState:UIControlStateNormal];
    searchButton.titleLabel.font = [UIFont fontWithName:@"Copperplate" size:18.0f];
    searchButton.titleLabel.textColor = [UIColor whiteColor];
    searchButton.backgroundColor = [UIColor blueColor];
    [searchButton addTarget:self action:@selector(searchButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:searchButton];
    
    _recipeNameTextField = [JVFloatLabeledTextField new];
    _ingredientTextField = [JVFloatLabeledTextField new];
    _maxPrepTimeTextField = [JVFloatLabeledTextField new];
    _maxCookTimeTextField = [JVFloatLabeledTextField new];
    _maxTotalTimeTextField = [JVFloatLabeledTextField new];
    _winePairingTextField = [JVFloatLabeledTextField new];
    _mealTypeTextField = [IQDropDownTextField new];
    _calorieTextField = [IQDropDownTextField new];
    _cookProcessTextField = [IQDropDownTextField new];
    
    [searchLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_recipeNameTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_ingredientTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_maxPrepTimeTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_maxCookTimeTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_maxTotalTimeTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_winePairingTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_mealTypeTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_calorieTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_cookProcessTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [closeButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [searchButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    _recipeNameTextField.delegate = self;
    _ingredientTextField.delegate = self;
    _maxPrepTimeTextField.delegate = self;
    _maxCookTimeTextField.delegate = self;
    _maxTotalTimeTextField.delegate = self;
    _winePairingTextField.delegate = self;
    _mealTypeTextField.delegate = self;
    _calorieTextField.delegate = self;
    _cookProcessTextField.delegate = self;
    
    _recipeNameTextField.tag = RECIPETEXTFIELD;
    _ingredientTextField.tag = INGREDTEXTFIELD;
    _maxPrepTimeTextField.tag = PREPTMTEXTFIELD;
    _maxCookTimeTextField.tag = COOKTMTEXTFIELD;
    _maxTotalTimeTextField.tag = TOTLTMTEXTFIELD;
    _winePairingTextField.tag = WINEPRTEXTFIELD;
    _mealTypeTextField.tag = MEALTPTEXTFIELD;
    _calorieTextField.tag = CALORITEXTFIELD;
    _cookProcessTextField.tag = COOKPRTEXTFIELD;
    
    _recipeNameTextField.placeholder = @"Recipe Name";
    _ingredientTextField.placeholder = @"Ingredient";
    _maxPrepTimeTextField.placeholder = @"Max Prep Time";
    _maxCookTimeTextField.placeholder = @"Max Cook Time";
    _maxTotalTimeTextField.placeholder = @"Max Total Time";
    _winePairingTextField.placeholder = @"Wine Pairing";
    _mealTypeTextField.placeholder = @"Meal Type";
    _calorieTextField.placeholder = @"Calories";
    _cookProcessTextField.placeholder = @"Cooking Process";
    
    _maxPrepTimeTextField.keyboardType = UIKeyboardTypeNumberPad;
    _maxCookTimeTextField.keyboardType = UIKeyboardTypeNumberPad;
    _maxTotalTimeTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    _recipeNameTextField.inputAccessoryView = numberToolbar;
    _ingredientTextField.inputAccessoryView = numberToolbar;
    _maxPrepTimeTextField.inputAccessoryView = numberToolbar;
    _maxCookTimeTextField.inputAccessoryView = numberToolbar;
    _maxTotalTimeTextField.inputAccessoryView = numberToolbar;
    _winePairingTextField.inputAccessoryView = numberToolbar;
    _mealTypeTextField.inputAccessoryView = numberToolbar;
    _calorieTextField.inputAccessoryView = numberToolbar;
    _cookProcessTextField.inputAccessoryView = numberToolbar;
    
    _recipeNameTextField.font = [UIFont fontWithName:@"Copperplate" size:18.0f];
    _ingredientTextField.font = [UIFont fontWithName:@"Copperplate" size:18.0f];
    _maxPrepTimeTextField.font = [UIFont fontWithName:@"Copperplate" size:18.0f];
    _maxCookTimeTextField.font = [UIFont fontWithName:@"Copperplate" size:18.0f];
    _maxTotalTimeTextField.font = [UIFont fontWithName:@"Copperplate" size:18.0f];
    _winePairingTextField.font = [UIFont fontWithName:@"Copperplate" size:18.0f];
    _mealTypeTextField.font = [UIFont fontWithName:@"Copperplate" size:18.0f];
    _calorieTextField.font = [UIFont fontWithName:@"Copperplate" size:18.0f];
    _cookProcessTextField.font = [UIFont fontWithName:@"Copperplate" size:18.0f];
    
    _recipeNameTextField.floatingLabelFont = [UIFont fontWithName:@"Copperplate" size:12.0f];
    _ingredientTextField.floatingLabelFont = [UIFont fontWithName:@"Copperplate" size:12.0f];
    _maxPrepTimeTextField.floatingLabelFont = [UIFont fontWithName:@"Copperplate" size:12.0f];
    _maxCookTimeTextField.floatingLabelFont = [UIFont fontWithName:@"Copperplate" size:12.0f];
    _maxTotalTimeTextField.floatingLabelFont = [UIFont fontWithName:@"Copperplate" size:12.0f];
    _winePairingTextField.floatingLabelFont = [UIFont fontWithName:@"Copperplate" size:12.0f];
    
    _recipeNameTextField.textAlignment = NSTextAlignmentCenter;
    _ingredientTextField.textAlignment = NSTextAlignmentCenter;
    _maxPrepTimeTextField.textAlignment = NSTextAlignmentCenter;
    _maxCookTimeTextField.textAlignment = NSTextAlignmentCenter;
    _maxTotalTimeTextField.textAlignment = NSTextAlignmentCenter;
    _winePairingTextField.textAlignment = NSTextAlignmentCenter;
    _mealTypeTextField.textAlignment = NSTextAlignmentCenter;
    _calorieTextField.textAlignment = NSTextAlignmentCenter;
    _cookProcessTextField.textAlignment = NSTextAlignmentCenter;
    
    _recipeNameTextField.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    _ingredientTextField.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    _maxPrepTimeTextField.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    _maxCookTimeTextField.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    _maxTotalTimeTextField.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    _winePairingTextField.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    _mealTypeTextField.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    _calorieTextField.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    _cookProcessTextField.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    closeButton.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    searchButton.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    
    _recipeNameTextField.layer.borderWidth = 2.0;
    _ingredientTextField.layer.borderWidth = 2.0;
    _maxPrepTimeTextField.layer.borderWidth = 2.0;
    _maxCookTimeTextField.layer.borderWidth = 2.0;
    _maxTotalTimeTextField.layer.borderWidth = 2.0;
    _winePairingTextField.layer.borderWidth = 2.0;
    _mealTypeTextField.layer.borderWidth = 2.0;
    _calorieTextField.layer.borderWidth = 2.0;
    _cookProcessTextField.layer.borderWidth = 2.0;
    closeButton.layer.borderWidth = 2.0;
    searchButton.layer.borderWidth = 2.0;
    
    [self.view addSubview:_recipeNameTextField];
    [self.view addSubview:_ingredientTextField];
    [self.view addSubview:_maxPrepTimeTextField];
    [self.view addSubview:_maxCookTimeTextField];
    [self.view addSubview:_maxTotalTimeTextField];
    [self.view addSubview:_winePairingTextField];
    [self.view addSubview:_mealTypeTextField];
    [self.view addSubview:_calorieTextField];
    [self.view addSubview:_cookProcessTextField];
    
    [_mealTypeTextField setItemList:@[@"Appetizer", @"Dinner", @"Side Dish", @"Dessert", @"Breakfast and Brunch", @"Lunch", @"Snack", @"Drink"]];
    [_calorieTextField setItemList:@[@"Low Calorie", @"High Calorie"]];
    [_cookProcessTextField setItemList:@[@"Stovetop", @"Baked", @"Raw", @"Mixed", @"Other"]];
    
    float heightM = 1.0f/12.0f;
    float heightC = 0;
    
    NSDictionary *viewBindings = NSDictionaryOfVariableBindings(self.view, searchLabel, _recipeNameTextField, _ingredientTextField, _maxPrepTimeTextField, _maxCookTimeTextField, _maxTotalTimeTextField, _winePairingTextField, _mealTypeTextField, _calorieTextField, _cookProcessTextField, closeButton, searchButton);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[searchLabel]-5-[_recipeNameTextField]-0-[_ingredientTextField]-0-[_maxPrepTimeTextField]-0-[_maxCookTimeTextField]-0-[_maxTotalTimeTextField]-0-[_winePairingTextField]-0-[_mealTypeTextField]-0-[_calorieTextField]-(0)-[_cookProcessTextField]-0-[closeButton]-0-|" options:0 metrics:0 views:viewBindings]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[searchLabel]-0-|"
                                                                          options:NSLayoutFormatAlignAllBaseline
                                                                          metrics:nil
                                                                            views:viewBindings]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:searchLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:heightM constant:heightC]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_recipeNameTextField attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    
    //up up
    [self.view addConstraint:[NSLayoutConstraint
                                         constraintWithItem:_recipeNameTextField attribute:NSLayoutAttributeHeight
                                         relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:heightM constant:heightC]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_ingredientTextField attribute:NSLayoutAttributeLeft
                                                              relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
    
    //up up
    [self.view addConstraint:[NSLayoutConstraint
                                      constraintWithItem:_ingredientTextField attribute:NSLayoutAttributeHeight
                                      relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:heightM constant:heightC]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_ingredientTextField attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_maxPrepTimeTextField attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
    
    //upup
    [self.view addConstraint:[NSLayoutConstraint
                                         constraintWithItem:_maxPrepTimeTextField attribute:NSLayoutAttributeHeight
                                         relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:heightM constant:heightC]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_maxPrepTimeTextField attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_maxCookTimeTextField attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
    
    //
    [self.view addConstraint:[NSLayoutConstraint
                                          constraintWithItem:_maxCookTimeTextField attribute:NSLayoutAttributeHeight
                                          relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:heightM constant:heightC]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_maxCookTimeTextField attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_maxTotalTimeTextField attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
    
    //up up
    [self.view addConstraint:[NSLayoutConstraint
                                          constraintWithItem:_maxTotalTimeTextField attribute:NSLayoutAttributeHeight
                                          relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:heightM constant:heightC]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_maxTotalTimeTextField attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_winePairingTextField attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
    
    //up up
    [self.view addConstraint:[NSLayoutConstraint
                                          constraintWithItem:_winePairingTextField attribute:NSLayoutAttributeHeight
                                          relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:heightM constant:heightC]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_winePairingTextField attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_calorieTextField attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
    
    //up up
    [self.view addConstraint:[NSLayoutConstraint
                                          constraintWithItem:_calorieTextField attribute:NSLayoutAttributeHeight
                                          relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:heightM constant:heightC]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_calorieTextField attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_mealTypeTextField attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
    
    //up up
    [self.view addConstraint:[NSLayoutConstraint
                                          constraintWithItem:_mealTypeTextField attribute:NSLayoutAttributeHeight
                                          relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:heightM constant:heightC]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_mealTypeTextField attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_cookProcessTextField attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
    
    //up up
    [self.view addConstraint:[NSLayoutConstraint
                                          constraintWithItem:_cookProcessTextField attribute:NSLayoutAttributeHeight
                                          relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:heightM constant:heightC]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_cookProcessTextField attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:closeButton attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
    
    //up up
    [self.view addConstraint:[NSLayoutConstraint
                                          constraintWithItem:closeButton attribute:NSLayoutAttributeHeight
                                          relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:heightM constant:heightC]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:closeButton attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.5 constant:0.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:searchButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_cookProcessTextField attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:searchButton attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual toItem:closeButton attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
    
    //up up
    [self.view addConstraint:[NSLayoutConstraint
                                          constraintWithItem:searchButton attribute:NSLayoutAttributeHeight
                                          relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:heightM constant:heightC]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:searchButton attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.5 constant:0.0]];
    
}

-(void)cancelButtonPressed {
    MasterViewController *hostController = (MasterViewController*)_hostViewController;
    [hostController cancelSearch];
}

-(void)searchButtonPressed {
    
    MasterViewController *hostController = (MasterViewController*)_hostViewController;
    
    if (![_recipeNameTextField.text isEqualToString:@""]) {
        _recipeName = _recipeNameTextField.text;
    }
    
    if (![_maxPrepTimeTextField.text isEqualToString:@""]) {
        _maxPrepTime = [NSNumber numberWithInt:[_maxPrepTimeTextField.text intValue]];
    }
    
    if (![_maxCookTimeTextField.text isEqualToString:@""]) {
        _maxCookTime = [NSNumber numberWithInt:[_maxCookTimeTextField.text intValue]];
    }
    
    if (![_maxTotalTimeTextField.text isEqualToString:@""]) {
        _maxTotalTime = [NSNumber numberWithInt:[_maxTotalTimeTextField.text intValue]];
    }
    
    if (![_winePairingTextField.text isEqualToString:@""]) {
        _winePairing = _winePairingTextField.text;
    }
    
    if (![_mealTypeTextField.text isEqualToString:@""]) {
        _mealType = _mealTypeTextField.text;
    }
    
    if (![_calorieTextField.text isEqualToString:@""]) {
        _lowCalorie = _calorieTextField.text;
    }
    
    if (![_ingredientTextField.text isEqualToString:@""]) {
        _ingredient = _ingredientTextField.text;
    }
    
    [hostController doSearch:self];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
