//
//  DetailViewController.m
//  Recipe Journal
//
//  Created by Robert Miller on 2/6/15.
//  Copyright (c) 2015 Robert Miller. All rights reserved.
//

#import "DetailViewController.h"
#import <UIFloatLabelTextView/UIFloatLabelTextView.h>
#import <AXRatingView/AXRatingView.h>
#import "NewIngredientsView.h"
#import "NewPreparationView.h"
#import <CSGrowingTextView/CSGrowingTextView.h>
#import <JVFloatLabeledTextField/JVFloatLabeledTextField.h>
#import "Event.h"
#import <MMProgressHUD/MMProgressHUD.h>
#import <MMProgressHUD/MMProgressHUDOverlayView.h>
#import <MMProgressHUD/MMProgressView-Protocol.h>
#import "AppDelegate.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "RecipeCloudManager.h"
#import <IQDropDownTextField/IQDropDownTextField.h>

@interface DetailViewController () <UITextViewDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate>

@property(nonatomic,retain) NSLayoutConstraint *noteViewHeight;
@property(nonatomic,retain) NSLayoutConstraint *scrollViewContentHeight;
@property(nonatomic,retain) UIScrollView *scrollView;
@property(nonatomic,retain) UIView *containerView;
@property(nonatomic,retain) JVFloatLabeledTextField *currentTextView;

@property(nonatomic,retain) JVFloatLabeledTextField *recipeTextView;
@property(nonatomic,retain) JVFloatLabeledTextField *ratingTextView;
@property(nonatomic,retain) AXRatingView *ratingView;
@property(nonatomic,retain) JVFloatLabeledTextField *servingSizeTextView;
@property(nonatomic,retain) JVFloatLabeledTextField *difficultyTextView;
@property(nonatomic,retain) AXRatingView *difficultyView;
@property(nonatomic,retain) JVFloatLabeledTextField *prepTimeTextView;
@property(nonatomic,retain) JVFloatLabeledTextField *cookTimeTextView;
@property(nonatomic,retain) NewIngredientsView *ingredientsView;
@property(nonatomic,retain) IQDropDownTextField *cookProcessTextView;
@property(nonatomic,retain) UISegmentedControl *processChoice;
@property(nonatomic,retain) JVFloatLabeledTextField *winePairingTextView;
@property(nonatomic,retain) IQDropDownTextField *mealtTypeTextView;
@property(nonatomic,retain) IQDropDownTextField *lowCalorieTextView;
@property(nonatomic,retain) NewPreparationView *preparationView;
@property(nonatomic,retain) UILabel *notesLabel;
@property(nonatomic,retain) CSGrowingTextView *notesTextView;
@property(nonatomic,retain) UIImageView *imageView;
@property(nonatomic,retain) UITapGestureRecognizer *tapGesture;
@property(nonatomic,retain) UIBarButtonItem *backButton;

@property(nonatomic,retain) RecipeCloudManager *cloudManager;

@property(nonatomic) int textHeight;

@end

@implementation DetailViewController

//#define TEXTHEIGHT          60

#define RECIPETEXTVIEW      0x1
#define RATINGTEXTVIEW      0x2
#define DIFFICULTYTEXTVIEW  0x3
#define SERVINGSIZETEXTVIEW 0x4
#define PRETIMETEXTVIEW     0x5
#define COOKTIMETEXTVIEW    0x6
#define INGREDIENTVIEW      0x7
#define COOKPROCESSTEXTVIEW 0x8
#define WINEPAIRTEXTVIEW    0x9
#define PREPARATIONTEXTVIEW 0xa
#define NOTESTEXTVIEW       0xb
#define IMAGEVIEW           0xc
#define MEALTYPEVIEW        0xd
#define LOWCALORIEVIEW      0xe
#define CONTAINERVIEW       0xff

#pragma mark - Managing the detail item

- (void)setDetailItem:(Event*)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        _textHeight = 45.0;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        
        self.title = [_detailItem recipeName];
        
        //Create toolbar to remove number pad
        UIToolbar  *numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
        numberToolbar.items = [NSArray arrayWithObjects:
                               [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                               [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad:)],
                               nil];
        
        _containerView = [[UIView alloc] init];
        //containerView.autoresizesSubviews = NO;
        [_containerView setTranslatesAutoresizingMaskIntoConstraints:NO];
        _containerView.tag = CONTAINERVIEW;
        _scrollView = [[UIScrollView alloc] init];
        [_scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
        _scrollView.backgroundColor = [UIColor whiteColor];
        _scrollView.scrollEnabled = YES;
        [self.view addSubview:_scrollView];
        [_scrollView addSubview:_containerView];
        
        
        //Setup and add Recipe Name Text View
        _recipeTextView = [[JVFloatLabeledTextField alloc] init];
        [_recipeTextView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_recipeTextView setTintColor:[UIColor blueColor]];
        //_recipeTextView.delegate = self;
        [_recipeTextView setEnabled:NO];
        _recipeTextView.tag = RECIPETEXTVIEW;
        _recipeTextView.clearsOnBeginEditing = YES;
        _recipeTextView.placeholder = @"Recipe";
        _recipeTextView.text = [_detailItem recipeName];
        _recipeTextView.font = [UIFont fontWithName:@"Copperplate" size:18.0f];
        _recipeTextView.floatingLabelFont = [UIFont fontWithName:@"Copperplate" size:12.0f];
        _recipeTextView.textAlignment = NSTextAlignmentCenter;
        _recipeTextView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
        _recipeTextView.layer.borderWidth = 2.0;
        [_containerView addSubview:_recipeTextView];
        
        
        //Setup and add Rating Text View
        _ratingTextView = [[JVFloatLabeledTextField alloc] init];
        [_ratingTextView setTranslatesAutoresizingMaskIntoConstraints:NO];
        //ratingTextView.delegate = self;
        [_ratingTextView setEnabled:NO];
        _ratingTextView.tag = RATINGTEXTVIEW;
        _ratingTextView.placeholder = @"Rating";
        _ratingTextView.text = @" ";
        _ratingTextView.clearsOnBeginEditing = YES;
        _ratingTextView.font = [UIFont fontWithName:@"Copperplate" size:18.0f];
        _ratingTextView.floatingLabelFont = [UIFont fontWithName:@"Copperplate" size:12.0f];
        _ratingTextView.textAlignment = NSTextAlignmentCenter;
        _ratingTextView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
        _ratingTextView.layer.borderWidth = 2.0;
        [_containerView addSubview:_ratingTextView];
        
        
        //Setup and add Serving Size Text View
        _servingSizeTextView = [[JVFloatLabeledTextField alloc] init];
        [_servingSizeTextView setTranslatesAutoresizingMaskIntoConstraints:NO];
        //_servingSizeTextView.delegate = self;
        [_servingSizeTextView setEnabled:NO];
        _servingSizeTextView.tag = SERVINGSIZETEXTVIEW;
        _servingSizeTextView.placeholder = @"Serving Size";
        _servingSizeTextView.font = [UIFont fontWithName:@"Copperplate" size:18.0f];
        _servingSizeTextView.floatingLabelFont = [UIFont fontWithName:@"Copperplate" size:12.0f];
        _servingSizeTextView.textAlignment = NSTextAlignmentCenter;
        _servingSizeTextView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
        _servingSizeTextView.layer.borderWidth = 2.0;
        [_containerView addSubview:_servingSizeTextView];
        
        
        //Setup and add the Difficulty Text View
        _difficultyTextView = [JVFloatLabeledTextField new];
        [_difficultyTextView setTranslatesAutoresizingMaskIntoConstraints:NO];
        //_difficultyTextView.delegate = self;
        [_difficultyTextView setEnabled:NO];
        _difficultyTextView.tag = DIFFICULTYTEXTVIEW;
        _difficultyTextView.placeholder = @"Difficulty";
        _difficultyTextView.font = [UIFont fontWithName:@"Copperplate" size:18.0f];
        _difficultyTextView.floatingLabelFont = [UIFont fontWithName:@"Copperplate" size:12.0f];
        _difficultyTextView.textAlignment = NSTextAlignmentCenter;
        _difficultyTextView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
        _difficultyTextView.layer.borderWidth = 2.0;
        [_containerView addSubview:_difficultyTextView];
        
        
        
        //Add star rating to ratingTextView
        [_ratingTextView setNeedsLayout];
        [_ratingTextView layoutIfNeeded];
        //[ratingTextView toggleFloatLabel:UIFloatLabelAnimationTypeShow];
        //ratingTextView.placeholder = @"Rating";
        //ratingTextView.floatingLabel.text = @"Rating";
        _ratingTextView.textColor = [UIColor clearColor];
        //ratingTextView.text = @"";
        _ratingView = [[AXRatingView alloc] initWithFrame:CGRectMake(5, 5, _ratingTextView.frame.size.width, _ratingTextView.frame.size.height)];
        _ratingView.enabled = NO;
        [_ratingView setTranslatesAutoresizingMaskIntoConstraints:NO];
        //[_ratingView addTarget:self action:@selector(ratingChanged) forControlEvents:UIControlEventValueChanged];
        [_ratingView setStepInterval:1.0];
        _ratingView.value = [[_detailItem rating] floatValue];
        [_ratingTextView addSubview:_ratingView];
        
        //Add plates to servingSizeTextView
        [_difficultyTextView setNeedsLayout];
        [_difficultyTextView layoutIfNeeded];
        _difficultyView = [[AXRatingView alloc] initWithFrame:CGRectMake(5, 5, _difficultyView.frame.size.width, _difficultyView.frame.size.height)];
        [_difficultyView setEnabled:NO];
        [_difficultyView setTranslatesAutoresizingMaskIntoConstraints:NO];
        //[_difficultyView addTarget: action:@se forControlEvents:ui];
        [_difficultyView setStepInterval:1.0];
        _difficultyView.value = [[_detailItem difficulty] floatValue];
        [_difficultyTextView addSubview:_difficultyView];
        
        
        
        //Setup and add the Prep Time Text View
        _prepTimeTextView = [JVFloatLabeledTextField new];
        [_prepTimeTextView setTranslatesAutoresizingMaskIntoConstraints:NO];
        //_prepTimeTextView.delegate = self;
        [_prepTimeTextView setEnabled:NO];
        _prepTimeTextView.tag = PRETIMETEXTVIEW;
        _prepTimeTextView.placeholder = @"Preparation Time";
        _prepTimeTextView.text = [[_detailItem prepTimeMinutes] stringValue];
        _prepTimeTextView.font = [UIFont fontWithName:@"Copperplate" size:18.0f];
        _prepTimeTextView.floatingLabelFont = [UIFont fontWithName:@"Copperplate" size:12.0f];
        _prepTimeTextView.textAlignment = NSTextAlignmentCenter;
        _prepTimeTextView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
        _prepTimeTextView.layer.borderWidth = 2.0;
        _prepTimeTextView.keyboardType = UIKeyboardTypeNumberPad;
        [_containerView addSubview:_prepTimeTextView];
        
        
        //Setup and add the Cook Time Text View
        _cookTimeTextView = [JVFloatLabeledTextField new];
        [_cookTimeTextView setTranslatesAutoresizingMaskIntoConstraints:NO];
        //_cookTimeTextView.delegate = self;
        [_cookTimeTextView setEnabled:NO];
        _cookTimeTextView.tag = COOKTIMETEXTVIEW;
        _cookTimeTextView.placeholder = @"Cook Time";
        _cookTimeTextView.text = [[_detailItem cookTimeMinutes] stringValue];
        _cookTimeTextView.font = [UIFont fontWithName:@"Copperplate" size:18.0f];
        _cookTimeTextView.floatingLabelFont = [UIFont fontWithName:@"Copperplate" size:12.0f];
        _cookTimeTextView.textAlignment = NSTextAlignmentCenter;
        _cookTimeTextView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
        _cookTimeTextView.layer.borderWidth = 2.0;
        _cookTimeTextView.keyboardType = UIKeyboardTypeNumberPad;
        [_containerView addSubview:_cookTimeTextView];
        
        
        //Setup and add the Ingredients View
        _ingredientsView = [NewIngredientsView new];
        _ingredientsView.parentViewController = self;
        [_ingredientsView setTranslatesAutoresizingMaskIntoConstraints:NO];
        _ingredientsView.backgroundColor = [UIColor whiteColor];
        _ingredientsView.tag = INGREDIENTVIEW;
        _ingredientsView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
        _ingredientsView.layer.borderWidth = 2.0;
        [_ingredientsView setEditBool:NO];
        [_containerView addSubview:_ingredientsView];
        //_ingredientsView.ingredients = [NSMutableArray arrayWithArray:[_detailItem returnIngredientsArray]];
        _ingredientsView.ingredients = [_detailItem ingredients];
        
        //Setup and add the Cook Process View and Segment Controller for the Cook Process Type
        _cookProcessTextView = [IQDropDownTextField new];
        [_cookProcessTextView setTranslatesAutoresizingMaskIntoConstraints:NO];
        _cookProcessTextView.isOptionalDropDown = NO;
        _cookProcessTextView.isOptionalDropDown = NO;
        [_cookProcessTextView setItemList:@[@"Stovetop", @"Baked", @"Raw", @"Mixed", @"Other"]];
        //cookProcessTextView.delegate = self;
        [_cookProcessTextView setEnabled:NO];
        _cookProcessTextView.tag = COOKPROCESSTEXTVIEW;
        _cookProcessTextView.placeholder = @"Cooking Process";
        _cookProcessTextView.text = [_detailItem cookingProcess];
        //_cookProcessTextView.floatingLabel.text = @"Cooking Process";
        //_cookProcessTextView.textColor = [UIColor clearColor];
        //[cookProcessTextView toggleFloatLabel:UIFloatLabelAnimationTypeShow];
        _cookProcessTextView.font = [UIFont fontWithName:@"Copperplate" size:18.0f];
        //_cookProcessTextView.floatingLabelFont = [UIFont fontWithName:@"Copperplate" size:12.0f];
        _cookProcessTextView.textAlignment = NSTextAlignmentCenter;
        _cookProcessTextView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
        _cookProcessTextView.layer.borderWidth = 2.0;
        _processChoice = [[UISegmentedControl alloc]
                          initWithItems:@[[UIImage imageNamed:@"cooker-25.png"],
                                          [UIImage imageNamed:@"kitchen-25.png"]]];
        [_processChoice setTranslatesAutoresizingMaskIntoConstraints:NO];
        _processChoice.tintColor = [UIColor darkGrayColor];
        [_cookProcessTextView addSubview:_processChoice];
        [_containerView addSubview:_cookProcessTextView];
        
        
        
        //Setting up the Float Label to display entire Text
        [_cookProcessTextView setNeedsLayout];
        [_cookProcessTextView layoutIfNeeded];
        //[_cookProcessTextView.floatingLabel sizeToFit];
        
        
        //Setup and add the Wine Pairing Text View
        _winePairingTextView = [JVFloatLabeledTextField new];
        [_winePairingTextView setTranslatesAutoresizingMaskIntoConstraints:NO];
        //winePairingTextView.delegate = self;
        [_winePairingTextView setEnabled:NO];
        _winePairingTextView.tag = WINEPAIRTEXTVIEW;
        _winePairingTextView.placeholder = @"Wine Pairings";
        _winePairingTextView.text = [_detailItem winePairing];
        _winePairingTextView.font = [UIFont fontWithName:@"Copperplate" size:18.0f];
        _winePairingTextView.floatingLabelFont = [UIFont fontWithName:@"Copperplate" size:12.0f];
        _winePairingTextView.textAlignment = NSTextAlignmentCenter;
        _winePairingTextView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
        _winePairingTextView.layer.borderWidth = 2.0;
        [_containerView addSubview:_winePairingTextView];
        
        //Setting up Meal Type
        _mealtTypeTextView = [IQDropDownTextField new];
        [_mealtTypeTextView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_mealtTypeTextView setEnabled:NO];
        _mealtTypeTextView.isOptionalDropDown = NO;
        [_mealtTypeTextView setItemList:@[@"Appetizer", @"Dinner", @"Side Dish", @"Dessert", @"Breakfast and Brunch", @"Lunch", @"Snack", @"Drink"]];
        _mealtTypeTextView.inputAccessoryView = numberToolbar;
        _mealtTypeTextView.tag = MEALTYPEVIEW;
        _mealtTypeTextView.text = [_detailItem mealType];
        _mealtTypeTextView.font = [UIFont fontWithName:@"Copperplate" size:18.0f];
        _mealtTypeTextView.textAlignment = NSTextAlignmentCenter;
        _mealtTypeTextView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
        _mealtTypeTextView.layer.borderWidth = 2.0;
        [_containerView addSubview:_mealtTypeTextView];
        
        //Setting up Low Cal View
        _lowCalorieTextView = [IQDropDownTextField new];
        [_lowCalorieTextView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_lowCalorieTextView setEnabled:NO];
        _lowCalorieTextView.isOptionalDropDown = NO;
        [_lowCalorieTextView setItemList:@[@"Low Calorie", @"High Calorie"]];
        _lowCalorieTextView.inputAccessoryView = numberToolbar;
        _lowCalorieTextView.tag = LOWCALORIEVIEW;
        _lowCalorieTextView.text = [_detailItem lowCalorie];
        _lowCalorieTextView.font = [UIFont fontWithName:@"Copperplate" size:18.0f];
        _lowCalorieTextView.textAlignment = NSTextAlignmentCenter;
        _lowCalorieTextView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
        _lowCalorieTextView.layer.borderWidth = 2.0;
        [_containerView addSubview:_lowCalorieTextView];
        
        
        //Setup and add the Preparation View
        _preparationView = [[NewPreparationView alloc] init];
        _preparationView.parentViewController = self;
        [_preparationView setTranslatesAutoresizingMaskIntoConstraints:NO];
        _preparationView.backgroundColor = [UIColor whiteColor];
        _preparationView.tag = PREPARATIONTEXTVIEW;
        _preparationView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
        _preparationView.layer.borderWidth = 2.0;
        [_preparationView setEditBool:NO];
        [_containerView addSubview:_preparationView];
        _preparationView.steps = [NSMutableArray arrayWithArray:[_detailItem returnPrepartionStepsArray]];
        
        
        //Setup and add the Label for the Notes
        _notesLabel = [[UILabel alloc] init];
        [_notesLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        _notesLabel.text = @"Notes:";
        _notesLabel.font = [UIFont fontWithName:@"Copperplate" size:19.0f];
        _notesLabel.textAlignment = NSTextAlignmentCenter;
        [_notesLabel sizeToFit];
        [_containerView addSubview:_notesLabel];
        
        
        //Setup and add the Notes Text View
        _notesTextView = [[CSGrowingTextView alloc] init];
        [_notesTextView setTranslatesAutoresizingMaskIntoConstraints:NO];
        _notesTextView.tag = NOTESTEXTVIEW;
        [_notesTextView.internalTextView setEditable:NO];
        _notesTextView.internalTextView.text = [_detailItem notes];
        _notesTextView.growDirection = CSGrowDirectionDown;
        [_notesTextView sizeToFit];
        [_notesTextView layoutIfNeeded];
        [_containerView addSubview:_notesTextView];
        
        
        //Setup and add the Image View
        _imageView = [[UIImageView alloc] init];
        [_imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_imageView setUserInteractionEnabled:YES];
        //[_imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addImage)]];
        _imageView.tag = IMAGEVIEW;
        _imageView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
        _imageView.layer.borderWidth = 2.0;
        //_imageView.image = [UIImage imageNamed:@"no-photo.png"];
        [_containerView addSubview:_imageView];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image = [UIImage imageWithData:[_detailItem recipeIconImage]];
            //CGSize size = _imageView.frame.size;//set the width and height
            
            //UIGraphicsBeginImageContext(size);
            
            //UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
            
            //CGContextRef ctx = UIGraphicsGetCurrentContext();
            //CGRect area = CGRectMake(0, 0, size.width, size.height);
            
            //CGContextScaleCTM(ctx, 1, -1);
            //CGContextTranslateCTM(ctx, 0, -area.size.height);
            
            //CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
            
            //CGContextSetAlpha(ctx, 1.0);
            
            //CGContextDrawImage(ctx, area, image.CGImage);
            
            //[image drawInRect:self.frame];
            //UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
            //here is the scaled image which has been changed to the size specified
            //UIGraphicsEndImageContext();
            
            //self.backgroundColor = [UIColor colorWithPatternImage:newImage];
            _imageView.image = image;
            //[_imageView sizeToFit];
            //self.backgroundColor = [UIColor redColor];
            NSLog(@"image view image done");
        });
        
        
        //Setup Share Button
        UIButton *shareButton = [[UIButton alloc] init];
        [shareButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [shareButton addTarget:self action:@selector(shareDetailItem) forControlEvents:UIControlEventTouchUpInside];
        [shareButton setTitle:@"Share" forState:UIControlStateNormal];
        shareButton.titleLabel.font = [UIFont fontWithName:@"Copperplate" size:18.0f];
        shareButton.titleLabel.textColor = [UIColor whiteColor];
        shareButton.backgroundColor = [UIColor blackColor];
        [_containerView addSubview:shareButton];
        
        //Setup Edit Button
        UIButton *editButton = [[UIButton alloc] init];
        [editButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [editButton addTarget:self action:@selector(editDetailItem) forControlEvents:UIControlEventTouchUpInside];
        [editButton setTitle:@"Edit" forState:UIControlStateNormal];
        editButton.titleLabel.font = [UIFont fontWithName:@"Copperplate" size:18.0f];
        editButton.titleLabel.textColor = [UIColor whiteColor];
        editButton.backgroundColor = [UIColor blueColor];
        [_containerView addSubview:editButton];
 
        
#pragma mark - setting layout
        
        UIView *view = self.view;
        //Add all the views to the view bindings
        NSDictionary *viewBindings = NSDictionaryOfVariableBindings(view, _scrollView, _containerView, _recipeTextView, _ratingTextView, _servingSizeTextView, _difficultyTextView, _prepTimeTextView, _cookTimeTextView, _ingredientsView, _cookProcessTextView, _winePairingTextView, _mealtTypeTextView, _lowCalorieTextView, _preparationView, _notesLabel, _notesTextView, _imageView, shareButton, editButton);
        
        //Add the scrollview to the constraints to the main view.. The content size will be set dynamically by the Container View
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_scrollView]-0-|" options:0 metrics:0 views:viewBindings]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_scrollView]|" options:0 metrics:0 views:viewBindings]];
        
        //Adding the Container view constraints to the Scrollview
        [_scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_containerView]-0-|" options:0 metrics:0 views:viewBindings]];
        [_scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_containerView]|" options:0 metrics:0 views:viewBindings]];
        
        //Setting the constraints to the container view to set the width to the view size and the height to the size of all the subviews added together
        [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_containerView(==view)]" options:0 metrics:0 views:viewBindings]];
        
        [_containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_recipeTextView]-(-2)-[_ratingTextView]-(-2)-[_prepTimeTextView]-(-2)-[_ingredientsView]-(-2)-[_cookProcessTextView]-(-2)-[_mealtTypeTextView]-(-2)-[_preparationView]-(-2)-[_notesLabel]-(-2)-[_notesTextView]-40-[_imageView]-0-[shareButton]-0-|" options:0 metrics:0 views:viewBindings]];
        
        
#pragma mark - layout for recipe text view
        [_containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_recipeTextView]-0-|"
                                                                              options:NSLayoutFormatAlignAllBaseline
                                                                              metrics:nil
                                                                                views:viewBindings]];
        
        // Vertical
        //[containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-80-[_recipeTextView(45)]"
        //                                                                      options:0
        //                                                                      metrics:nil
        //                                                                        views:viewBindings]];
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_recipeTextView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeHeight multiplier:0.0 constant:_textHeight]];
        
#pragma mark - layout for rating text view
        //[containerView addConstraint:[NSLayoutConstraint constraintWithItem:ratingTextView attribute:NSLayoutAttributeTop
        //                                                          relatedBy:NSLayoutRelationEqual toItem:_recipeTextView
        //                                                          attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-2.0]];
        
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_ratingTextView attribute:NSLayoutAttributeLeft
                                                                  relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-1.0]];
        
        [_ratingTextView addConstraint:[NSLayoutConstraint constraintWithItem:_ratingTextView attribute:NSLayoutAttributeHeight
                                                                    relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeHeight multiplier:0 constant:_textHeight]];
        
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_ratingTextView attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeWidth multiplier:0.333 constant:4.0]];
        
#pragma mark - layout for rating view within the rating text view
        [_ratingTextView addConstraint:[NSLayoutConstraint constraintWithItem:_ratingView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_ratingTextView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        
        [_ratingTextView addConstraint:[NSLayoutConstraint constraintWithItem:_ratingView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_ratingTextView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        
        [_ratingTextView addConstraint:[NSLayoutConstraint constraintWithItem:_ratingView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_ratingTextView attribute:NSLayoutAttributeWidth multiplier:0.85 constant:0.0]];
        
        [_ratingTextView addConstraint:[NSLayoutConstraint constraintWithItem:_ratingView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_ratingTextView attribute:NSLayoutAttributeHeight multiplier:0.58 constant:0.0]];
        
#pragma mark - layout for serving size text view
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_servingSizeTextView attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual toItem:_recipeTextView
                                                                  attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-2.0]];
        
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_servingSizeTextView attribute:NSLayoutAttributeLeft
                                                                  relatedBy:NSLayoutRelationEqual toItem:_ratingTextView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-2.0]];
        
        [_servingSizeTextView addConstraint:[NSLayoutConstraint
                                             constraintWithItem:_servingSizeTextView attribute:NSLayoutAttributeHeight
                                             relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeHeight multiplier:0 constant:_textHeight]];
        
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_servingSizeTextView attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeWidth multiplier:0.333 constant:4.0]];
        
#pragma mark - layout for difficulty text view
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_difficultyTextView attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual toItem:_recipeTextView
                                                                  attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-2.0]];
        
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_difficultyTextView attribute:NSLayoutAttributeLeft
                                                                  relatedBy:NSLayoutRelationEqual toItem:_servingSizeTextView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-2.0]];
        
        [_difficultyTextView addConstraint:[NSLayoutConstraint
                                            constraintWithItem:_difficultyTextView attribute:NSLayoutAttributeHeight
                                            relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeHeight multiplier:0 constant:_textHeight]];
        
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_difficultyTextView attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeWidth multiplier:0.333 constant:4.0]];
        
#pragma mark - layout for rating view within the difficult text view
        [_difficultyTextView addConstraint:[NSLayoutConstraint constraintWithItem:_difficultyView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_difficultyTextView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        
        [_difficultyTextView addConstraint:[NSLayoutConstraint constraintWithItem:_difficultyView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_difficultyTextView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        
        [_difficultyTextView addConstraint:[NSLayoutConstraint constraintWithItem:_difficultyView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_difficultyTextView attribute:NSLayoutAttributeWidth multiplier:0.85 constant:0.0]];
        
        [_difficultyTextView addConstraint:[NSLayoutConstraint constraintWithItem:_difficultyView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_difficultyTextView attribute:NSLayoutAttributeHeight multiplier:0.58 constant:0.0]];
        
        
#pragma mark - layout for Preparation Time text view
        //[containerView addConstraint:[NSLayoutConstraint constraintWithItem:prepTimeTextView attribute:NSLayoutAttributeTop
        //                                                          relatedBy:NSLayoutRelationEqual toItem:ratingTextView
        //                                                          attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-2.0]];
        
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_prepTimeTextView attribute:NSLayoutAttributeLeft
                                                                  relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-1.0]];
        
        [_prepTimeTextView addConstraint:[NSLayoutConstraint
                                          constraintWithItem:_prepTimeTextView attribute:NSLayoutAttributeHeight
                                          relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0 constant:(_textHeight)]];
        
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_prepTimeTextView attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeWidth multiplier:0.5 constant:4.0]];
        
#pragma mark - layout for Cook Time text view
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_cookTimeTextView attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual toItem:_ratingTextView
                                                                  attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-2.0]];
        
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_cookTimeTextView attribute:NSLayoutAttributeLeft
                                                                  relatedBy:NSLayoutRelationEqual toItem:_prepTimeTextView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-2.0]];
        
        [_cookTimeTextView addConstraint:[NSLayoutConstraint
                                          constraintWithItem:_cookTimeTextView attribute:NSLayoutAttributeHeight
                                          relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeHeight multiplier:0.0 constant:_textHeight]];
        
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_cookTimeTextView attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeWidth multiplier:0.5 constant:4.0]];
        
#pragma mark - layout for Ingredients view
        //[containerView addConstraint:[NSLayoutConstraint constraintWithItem:ingredientsView attribute:NSLayoutAttributeTop
        //                                                          relatedBy:NSLayoutRelationEqual toItem:cookTimeTextView
        //                                                          attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-2.0]];
        
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_ingredientsView attribute:NSLayoutAttributeLeft
                                                                  relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-1.0]];
        
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_ingredientsView attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:4.0]];
        
#pragma mark - layout for Cook Process text view
        //[containerView addConstraint:[NSLayoutConstraint constraintWithItem:cookProcessTextView attribute:NSLayoutAttributeTop
        //                                                          relatedBy:NSLayoutRelationEqual toItem:ingredientsView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-2.0]];
        
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_cookProcessTextView attribute:NSLayoutAttributeLeft
                                                                  relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-1.0]];
        
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_cookProcessTextView attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeWidth multiplier:0.5 constant:4.0]];
        
        [_cookProcessTextView addConstraint:[NSLayoutConstraint constraintWithItem:_cookProcessTextView
                                                                         attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeHeight multiplier:0.0 constant:_textHeight]];
        
#pragma mark - layout for Cook Process Segmented Control within the Cook Process Text view
        [_cookProcessTextView addConstraint:[NSLayoutConstraint constraintWithItem:_processChoice
                                                                         attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_cookProcessTextView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-1.0]];
        
        [_cookProcessTextView addConstraint:[NSLayoutConstraint constraintWithItem:_processChoice
                                                                         attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_cookProcessTextView attribute:NSLayoutAttributeWidth multiplier:0.58 constant:0.0]];
        
        [_cookProcessTextView addConstraint:[NSLayoutConstraint constraintWithItem:_processChoice
                                                                         attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_cookProcessTextView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        
        [_cookProcessTextView addConstraint:[NSLayoutConstraint constraintWithItem:_processChoice
                                                                         attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_cookProcessTextView attribute:NSLayoutAttributeHeight multiplier:0.58 constant:0.0]];
        
#pragma mark - layout for Wine Pairing text view
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_winePairingTextView attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual toItem:_ingredientsView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-2.0]];
        
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_winePairingTextView attribute:NSLayoutAttributeLeft
                                                                  relatedBy:NSLayoutRelationEqual toItem:_cookProcessTextView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-2.0]];
        
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_winePairingTextView attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeWidth multiplier:0.5 constant:4.0]];
        
        [_winePairingTextView addConstraint:[NSLayoutConstraint constraintWithItem:_winePairingTextView
                                                                         attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeHeight multiplier:0.0 constant:_textHeight]];
#pragma mark - layout for Meal Type Text View
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_mealtTypeTextView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-1.0]];
        
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_mealtTypeTextView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeWidth multiplier:0.5 constant:4.0]];
        
        [_mealtTypeTextView addConstraint:[NSLayoutConstraint constraintWithItem:_mealtTypeTextView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeHeight multiplier:0.0 constant:_textHeight]];
        
#pragma mark - layout for Calorie Text View
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_lowCalorieTextView attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual toItem:_cookProcessTextView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-2.0]];
        
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_lowCalorieTextView attribute:NSLayoutAttributeLeft
                                                                  relatedBy:NSLayoutRelationEqual toItem:_mealtTypeTextView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-2.0]];
        
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_lowCalorieTextView attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeWidth multiplier:0.5 constant:4.0]];
        
        [_lowCalorieTextView addConstraint:[NSLayoutConstraint constraintWithItem:_lowCalorieTextView
                                                                        attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeHeight multiplier:0.0 constant:_textHeight]];
    
#pragma mark - layout for preparation view
        //Note the height is set within the custom UIView (NewPreparationView)
        //[containerView addConstraint:[NSLayoutConstraint constraintWithItem:preparationView attribute:NSLayoutAttributeTop
        //                                                          relatedBy:NSLayoutRelationEqual toItem:cookProcessTextView
        //                                                          attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-2.0]];
        
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_preparationView attribute:NSLayoutAttributeLeft
                                                                  relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-1.0]];
        
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_preparationView attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:4.0]];
        
#pragma mark - layout for notes label
        //The Label Height and Width are set by the sizeToFit method
        //[containerView addConstraint:[NSLayoutConstraint constraintWithItem:notesLabel attribute:NSLayoutAttributeTop
        //                                                          relatedBy:NSLayoutRelationEqual toItem:preparationView attribute:NSLayoutAttributeBottom
        //                                                         multiplier:1.0 constant:2.0]];
        
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_notesLabel attribute:NSLayoutAttributeLeft
                                                                  relatedBy:NSLayoutRelationEqual toItem:_containerView
                                                                  attribute:NSLayoutAttributeLeft
                                                                 multiplier:1.0 constant:5.0]];
        
#pragma mark - layout for Notes text view
        //[containerView addConstraint:[NSLayoutConstraint constraintWithItem:notesTextView attribute:NSLayoutAttributeTop
        //                                                          relatedBy:NSLayoutRelationEqual toItem:notesLabel
        //                                                          attribute:NSLayoutAttributeBottom
        //                                                         multiplier:1.0 constant:1.0]];
        
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_notesTextView attribute:NSLayoutAttributeLeft
                                                                  relatedBy:NSLayoutRelationEqual toItem:_containerView
                                                                  attribute:NSLayoutAttributeLeft multiplier:1.0 constant:3.0]];
        
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_notesTextView attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual toItem:_containerView
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:1.0 constant:0.0]];
        
        //_noteViewHeight = [NSLayoutConstraint constraintWithItem:notesTextView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:notesTextView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
        //[notesTextView addConstraint:_noteViewHeight];
        
#pragma mark - layout for image view
        //[containerView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeTop
        //                                                          relatedBy:NSLayoutRelationEqual toItem:notesTextView
        //                                                          attribute:NSLayoutAttributeBottom
        //                                                         multiplier:1.0 constant:40.0]];
        
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeLeft
                                                                  relatedBy:NSLayoutRelationEqual toItem:_containerView
                                                                  attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-1.0]];
        
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual toItem:_containerView
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:1.0 constant:4.0]];
        
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual toItem:_containerView
                                                                  attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
 
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:shareButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
        
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:shareButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeWidth multiplier:0.5 constant:0.0]];
        
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:shareButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeHeight multiplier:0.0 constant:_textHeight]];
        
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:editButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_imageView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
        
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:editButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:shareButton attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
        
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:editButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeWidth multiplier:0.5 constant:0.0]];
        
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:editButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeHeight multiplier:0.0 constant:_textHeight]];
  
#pragma mark - end of layouts
        

        
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editDetailItem)];
    //[self configureView];
    
    _cloudManager = [[RecipeCloudManager alloc] init];

}

#pragma mark - Sharing
-(void)shareDetailItem {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"How do you want to share?" message:@"You can share to your friends as a PDF image, or as a recipe to add to their own Recipe Journal" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Send as PDF" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //create the PDF and open the uiactionsheet
        [self sendPDF];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Send as Recipe" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //upload to public database and open the uiactionsheet
        if ([[_detailItem isPublic] boolValue]) {
            //send the url with the public uuid
            [self sendRecipeWithUUID:[_detailItem publicRecordID]];
        }
        else {
            if ([_cloudManager isLoggedIn]) {
                [_cloudManager shareRecipeToPublic:_detailItem complete:^(NSError *error, NSString *uuid) {
                    if (error) {
                        NSLog(@"error sharing to public with error: %@",error);
                    }
                    else {
                        //send the url with the public uuid
                        [self sendRecipeWithUUID:uuid];
                    }
                }];
            }
            else {
                [self alertNoAccount];
            }
        }
    }]];
    
    [self presentViewController:alert animated:YES completion:^{
        //up up
    }];
    
}

-(NSString *)writeViewToFile {
    
    // Creates a mutable data object for updating with binary data, like a byte array
    NSMutableData *pdfData = [NSMutableData data];
    
    // Points the pdf converter to the mutable data object and to the UIView to be converted
    CGRect rect = _containerView.bounds;
    rect.size.height = _containerView.bounds.size.height - _textHeight;
    UIGraphicsBeginPDFContextToData(pdfData, rect, nil);
    UIGraphicsBeginPDFPage();
    CGContextRef pdfContext = UIGraphicsGetCurrentContext();
    
    
    // draws rect to the view and thus this is captured by UIGraphicsBeginPDFContextToData
    
    [_containerView.layer renderInContext:pdfContext];
    
    // remove PDF rendering context
    UIGraphicsEndPDFContext();
    
    // Retrieves the document directories from the iOS device
    NSArray* documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    NSString *directoryName = [[_detailItem recipeName] stringByAppendingString:@".pdf"];
    NSString *documentDirectoryFilename = [documentDirectory stringByAppendingPathComponent:directoryName];
    
    
    // instructs the mutable data object to write its context to a file on disk
    [pdfData writeToFile:documentDirectoryFilename atomically:YES];
    NSLog(@"documentDirectoryFileName: %@",documentDirectoryFilename);
    
    return documentDirectoryFilename;
    
}

-(void)sendPDF {
    
    NSString *fileName = [self writeViewToFile];
    NSData *pdfData = [NSData dataWithContentsOfFile:fileName];
    
    NSArray *activityItems = @[pdfData];
    NSArray *applicationActivities = @[];
    
    UIActivityViewController *shareSheet = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:applicationActivities];
    shareSheet.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypePostToFacebook, UIActivityTypePostToFlickr, UIActivityTypePostToTencentWeibo, UIActivityTypePostToTwitter, UIActivityTypePostToVimeo, UIActivityTypePostToWeibo];
    
    [self presentViewController:shareSheet animated:YES completion:^{
        //up up
    }];
    
}

-(void)sendRecipeWithUUID:(NSString*)uuid {
    
    NSString *url = RECIPEJOURNALURL;
    url = [url stringByAppendingString:uuid];
    NSURL *sendURL = [NSURL URLWithString:url];
    
    NSString *sendString = @"I'm sending you a recipe of mine!";
    
    NSArray *activityItems = @[sendString, sendURL];
    NSArray *applicationActivities = @[];
    
    UIActivityViewController *shareSheet = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:applicationActivities];
    shareSheet.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypePostToFacebook, UIActivityTypePostToFlickr, UIActivityTypePostToTencentWeibo, UIActivityTypePostToTwitter, UIActivityTypePostToVimeo, UIActivityTypePostToWeibo];
    
    [self presentViewController:shareSheet animated:YES completion:^{
        //up up
    }];
}

-(void)alertNoAccount {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Account Sign In Needed" message:@"To send a recipe, you must be logged into an iCloud Account..  Otherwise you can send a PDF" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //close
    }]];
    
}

#pragma mark - Edit
-(void)editDetailItem {
    NSLog(@"edit detail item");
    
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"Warning!" message:@"You're about to edit this recipe, are you sure you want to make any permanent edits?" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertView addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [_recipeTextView setEnabled:YES];
        [_ratingView setEnabled:YES];
        [_servingSizeTextView setEnabled:YES];
        [_difficultyView setEnabled:YES];
        [_prepTimeTextView setEnabled:YES];
        [_cookTimeTextView setEnabled:YES];
        [_ingredientsView setEditBool:YES];
        [_winePairingTextView setEnabled:YES];
        [_mealtTypeTextView setEnabled:YES];
        [_lowCalorieTextView setEnabled:YES];
        [_preparationView setEditBool:YES];
        [_notesTextView.internalTextView setEditable:YES];
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addImage)];
        [_imageView addGestureRecognizer:_tapGesture];
        
        _backButton = self.navigationItem.leftBarButtonItem;
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(recipeCancelled:)];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(recipeSaved:)];
        
    }]];
    
    [alertView addAction:[UIAlertAction actionWithTitle:@"Nah.." style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        //Do nothing;
        NSLog(@"action cancelled");
    }]];
    
    [self presentViewController:alertView animated:YES completion:^{
        //up up
    }];
    
    //[self updateViewConstraints];
    //[_scrollView updateConstraints];
    
}

-(void)addImage {
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    
    UIAlertController *imagePickerAlert = [UIAlertController alertControllerWithTitle:@"Choose Photo Option" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    [imagePickerAlert addAction:[UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        [self presentViewController:imagePicker animated:YES completion:^{
            NSLog(@"imgae picker controller presented");
        }];
    }]];
    [imagePickerAlert addAction:[UIAlertAction actionWithTitle:@"Choose Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self presentViewController:imagePicker animated:YES completion:^{
            NSLog(@"imgae picker controller presented");
        }];
        
    }]];
    [imagePickerAlert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        //DO Nothing
        
    }]];
    
    [self presentViewController:imagePickerAlert animated:YES completion:^{
        
        
    }];
    
}

#pragma mark - image picker delegate methods

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenPhoto = (UIImage*)info[UIImagePickerControllerOriginalImage];
    UIImageView *tempIV = (UIImageView*)[self.view viewWithTag:IMAGEVIEW];
    tempIV.image = chosenPhoto;
    [picker dismissViewControllerAnimated:YES
                               completion:^{
                                   
                               }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - Save
-(void)saveRecipe {
    
    //NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSManagedObjectContext *context = [[AppDelegate sharedInstance] managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:context];
    
    //NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    Event *newEvent = (Event*)newManagedObject;
    
    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
    
    //[SVProgressHUD showWithTitle:@"Saving Data" status:@"Up up" cancelBlock:^{
    //Canceled
    //}];
    
    [SVProgressHUD showProgress:0.0f status:@"Up"];
    //[SVProgressHUD show];
    
    UIView *containerView = [_scrollView viewWithTag:CONTAINERVIEW];
    
    NSError *error = nil;
    for (UIView *subView in [containerView subviews]) {
        
        switch (subView.tag) {
            case RECIPETEXTVIEW:
                [newManagedObject setValue:_recipeTextView.text forKey:@"recipeName"];
                if (![context save:&error]) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    abort();
                }
                [SVProgressHUD showProgress:1/12 status:@"Just Getting Starting.."];
                break;
            case RATINGTEXTVIEW:
                [newManagedObject setValue:[NSNumber numberWithFloat:_ratingView.value] forKey:@"rating"];
                if (![context save:&error]) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    abort();
                }
                [SVProgressHUD showProgress:2/12 status:@"Just Getting Starting.."];
                break;
            case SERVINGSIZETEXTVIEW:
                [newManagedObject setValue:[NSNumber numberWithFloat:[_servingSizeTextView.text floatValue]] forKey:@"servingSize"];
                if (![context save:&error]) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    abort();
                }
                [SVProgressHUD showProgress:3/12 status:@"Coals are burning.."];
                break;
            case DIFFICULTYTEXTVIEW:
                [newManagedObject setValue:[NSNumber numberWithFloat:[_difficultyView value]] forKey:@"difficulty"];
                if (![context save:&error]) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    abort();
                }
                [SVProgressHUD showProgress:4/12 status:@"Coals are burning.."];
                break;
            case PRETIMETEXTVIEW:
                [newManagedObject setValue:[NSNumber numberWithInteger:10] forKey:@"prepTimeMinutes"];
                if (![context save:&error]) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    abort();
                }
                [SVProgressHUD showProgress:5/12 status:@"I'm Seeing Some Improvement.."];
                break;
            case COOKTIMETEXTVIEW:
                [newManagedObject setValue:[NSNumber numberWithInteger:[_cookTimeTextView text].integerValue] forKey:@"cookTimeMinutes"];
                if (![context save:&error]) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    abort();
                }
                [SVProgressHUD showProgress:6/12 status:@"I'm Seeing Some Improvement.."];
                break;
            case INGREDIENTVIEW:
                [newEvent setIngredientsWithArray:_ingredientsView.ingredients];
                if (![context save:&error]) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    abort();
                }
                [SVProgressHUD showProgress:7/12 status:@"Now We're Cooking With Gas!!"];
                break;
            case COOKPROCESSTEXTVIEW:
                //[newManagedObject setValue:[NSNumber numberWithInteger:_processChoice.selectedSegmentIndex] forKey:@"cookingProcess"];
                [newManagedObject setValue:_cookProcessTextView.text forKey:@"CookingProcess"];
                if (![context save:&error]) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    abort();
                }
                [SVProgressHUD showProgress:8/12 status:@"Now We're Cooking With Gas!!"];
                break;
            case WINEPAIRTEXTVIEW:
                [newManagedObject setValue:_winePairingTextView.text forKey:@"winePairing"];
                if (![context save:&error]) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    abort();
                }
                [SVProgressHUD showProgress:9/12 status:@"Nearly There.."];
                break;
            case MEALTYPEVIEW:
                [newManagedObject setValue:_mealtTypeTextView.text forKey:@"mealType"];
                if (![context save:&error]) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    abort();
                }
                [SVProgressHUD showProgress:9/12 status:@"Nearly There.."];
                break;
            case LOWCALORIEVIEW:
                [newManagedObject setValue:_lowCalorieTextView.text forKey:@"lowCalorie"];
                if (![context save:&error]) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    abort();
                }
                [SVProgressHUD showProgress:9/12 status:@"Nearly There.."];
                break;
            case PREPARATIONTEXTVIEW:
                [newEvent setPreparationWithArray:_preparationView.steps];
                if (![context save:&error]) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    abort();
                }
                [SVProgressHUD showProgress:10/12 status:@"Nearly There.."];
                break;
            case NOTESTEXTVIEW:
                [newManagedObject setValue:_notesTextView.internalTextView.text forKey:@"notes"];
                if (![context save:&error]) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    abort();
                }
                [SVProgressHUD showProgress:11/12 status:@"Aaaaaannnnddddd.."];
                break;
            case IMAGEVIEW:
                [newManagedObject setValue:UIImagePNGRepresentation(_imageView.image) forKey:@"recipeIconImage"];
                if (![context save:&error]) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    abort();
                }
                [SVProgressHUD showProgress:12/12 status:@"AAAaaaNNNnnnDDDddd!!"];
                break;
                
            default:
                break;
        }
    }
    
    [SVProgressHUD showSuccessWithStatus:@"Woot!"];
    [SVProgressHUD dismiss];
    // Save the context.
    
    if ([_cloudManager isLoggedIn]) {
        [_cloudManager modifyRecipeToCloud:newEvent];
    }
    
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
}

-(void)recipeCancelled:(UIButton*)sender {
    //[self dismissViewControllerAnimated:YES completion:^{
        //i just like having this just in case
    //}];
    [_recipeTextView setEnabled:NO];
    [_ratingView setEnabled:NO];
    [_servingSizeTextView setEnabled:NO];
    [_difficultyView setEnabled:NO];
    [_prepTimeTextView setEnabled:NO];
    [_cookTimeTextView setEnabled:NO];
    [_ingredientsView setEditBool:NO];
    [_winePairingTextView setEnabled:NO];
    [_preparationView setEditBool:NO];
    [_notesTextView.internalTextView setEditable:NO];
    //[_imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addImage)]];
    [_imageView removeGestureRecognizer:_tapGesture];
    
    self.navigationItem.leftBarButtonItem = _backButton;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editDetailItem)];

}

-(void)recipeSaved:(UIButton*)sender {
    [self saveRecipe];
    //[self dismissViewControllerAnimated:YES completion:^{
        //up up
    //    NSLog(@"recipe saved");
    //}];
    [_recipeTextView setEnabled:NO];
    [_ratingView setEnabled:NO];
    [_servingSizeTextView setEnabled:NO];
    [_difficultyView setEnabled:NO];
    [_prepTimeTextView setEnabled:NO];
    [_cookTimeTextView setEnabled:NO];
    [_ingredientsView setEditBool:NO];
    [_winePairingTextView setEnabled:NO];
    [_preparationView setEditBool:NO];
    [_notesTextView.internalTextView setEditable:NO];
    //[_imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addImage)]];
    [_imageView removeGestureRecognizer:_tapGesture];
    
    self.navigationItem.leftBarButtonItem = _backButton;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editDetailItem)];
}

#pragma mark - UIResponder

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
