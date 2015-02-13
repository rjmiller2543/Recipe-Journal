//
//  NewRecipeViewController.m
//  Recipe Journal
//
//  Created by Robert Miller on 2/9/15.
//  Copyright (c) 2015 Robert Miller. All rights reserved.
//

#import "NewRecipeViewController.h"
#import <UIFloatLabelTextView/UIFloatLabelTextView.h>
#import <AXRatingView/AXRatingView.h>
#import "NewIngredientsView.h"
#import "NewPreparationView.h"
#import <CSGrowingTextView/CSGrowingTextView.h>

@interface NewRecipeViewController () <UITextViewDelegate>

@property(nonatomic,retain) NSLayoutConstraint *noteViewHeight;

@end

@implementation NewRecipeViewController

//#define TEXTHEIGHT          60
const float textHeight = 45.0f;

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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = CGRectMake(0, 0, 320, 640);
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self configureView];
}

-(void)configureView {
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    scrollView.backgroundColor = [UIColor whiteColor];
    //[self.view addSubview:scrollView];
    
    UIFloatLabelTextView *recipeTextView = [UIFloatLabelTextView new];
    [recipeTextView setTranslatesAutoresizingMaskIntoConstraints:NO];
    recipeTextView.delegate = self;
    recipeTextView.tag = RECIPETEXTVIEW;
    recipeTextView.placeholder = @"Recipe";
    recipeTextView.font = [UIFont fontWithName:@"Copperplate" size:18.0f];
    recipeTextView.floatLabel.font = [UIFont fontWithName:@"Copperplate" size:12.0f];
    recipeTextView.textAlignment = NSTextAlignmentNatural;
    recipeTextView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    recipeTextView.layer.borderWidth = 2.0;
    [self.view addSubview:recipeTextView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[recipeTextView]-0-|"
                                                                      options:NSLayoutFormatAlignAllBaseline
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(recipeTextView)]];
    
    // Vertical
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-80-[recipeTextView(45)]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(recipeTextView)]];
    
    UIFloatLabelTextView *ratingTextView = [UIFloatLabelTextView new];
    [ratingTextView setTranslatesAutoresizingMaskIntoConstraints:NO];
    ratingTextView.delegate = self;
    ratingTextView.tag = RATINGTEXTVIEW;
    ratingTextView.font = [UIFont fontWithName:@"Copperplate" size:18.0f];
    ratingTextView.floatLabel.font = [UIFont fontWithName:@"Copperplate" size:12.0f];
    ratingTextView.textAlignment = NSTextAlignmentLeft;
    ratingTextView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    ratingTextView.layer.borderWidth = 2.0;
    [self.view addSubview:ratingTextView];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:ratingTextView attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual toItem:recipeTextView
                                                          attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-2.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:ratingTextView attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:0.0 constant:-2.0]];
    
    [ratingTextView addConstraint:[NSLayoutConstraint constraintWithItem:ratingTextView attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0 constant:textHeight]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:ratingTextView attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.333 constant:4.0]];
    
    UIFloatLabelTextView *servingSizeTextView = [UIFloatLabelTextView new];
    [servingSizeTextView setTranslatesAutoresizingMaskIntoConstraints:NO];
    servingSizeTextView.delegate = self;
    servingSizeTextView.tag = SERVINGSIZETEXTVIEW;
    servingSizeTextView.placeholder = @"Serving Size";
    servingSizeTextView.font = [UIFont fontWithName:@"Copperplate" size:18.0f];
    servingSizeTextView.floatLabel.font = [UIFont fontWithName:@"Copperplate" size:12.0f];
    servingSizeTextView.textAlignment = NSTextAlignmentLeft;
    servingSizeTextView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    servingSizeTextView.layer.borderWidth = 2.0;
    [self.view addSubview:servingSizeTextView];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:servingSizeTextView attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual toItem:recipeTextView
                                                          attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-2.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:servingSizeTextView attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual toItem:ratingTextView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-2.0]];
    
    [servingSizeTextView addConstraint:[NSLayoutConstraint
                                        constraintWithItem:servingSizeTextView attribute:NSLayoutAttributeHeight
                                        relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0 constant:textHeight]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:servingSizeTextView attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.333 constant:4.0]];
    
    UIFloatLabelTextView *difficultyTextView = [UIFloatLabelTextView new];
    [difficultyTextView setTranslatesAutoresizingMaskIntoConstraints:NO];
    difficultyTextView.delegate = self;
    difficultyTextView.tag = DIFFICULTYTEXTVIEW;
    difficultyTextView.placeholder = @"Difficulty";
    difficultyTextView.font = [UIFont fontWithName:@"Copperplate" size:18.0f];
    difficultyTextView.floatLabel.font = [UIFont fontWithName:@"Copperplate" size:12.0f];
    difficultyTextView.textAlignment = NSTextAlignmentLeft;
    difficultyTextView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    difficultyTextView.layer.borderWidth = 2.0;
    [self.view addSubview:difficultyTextView];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:difficultyTextView attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual toItem:recipeTextView
                                                          attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-2.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:difficultyTextView attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual toItem:servingSizeTextView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-2.0]];
    
    [difficultyTextView addConstraint:[NSLayoutConstraint
                                       constraintWithItem:difficultyTextView attribute:NSLayoutAttributeHeight
                                       relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0 constant:textHeight]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:difficultyTextView attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.333 constant:4.0]];
    
    //Add star rating to ratingTextView
    [ratingTextView setNeedsLayout];
    [ratingTextView layoutIfNeeded];
    [ratingTextView toggleFloatLabel:UIFloatLabelAnimationTypeShow];
    ratingTextView.placeholder = @"Rating";
    ratingTextView.floatLabel.text = @"Rating";
    ratingTextView.textColor = [UIColor clearColor];
    //ratingTextView.text = @"";
    AXRatingView *ratingView = [[AXRatingView alloc] initWithFrame:CGRectMake(5, 5, ratingTextView.frame.size.width, ratingTextView.frame.size.height)];
    [ratingView addTarget:self action:@selector(ratingChanged) forControlEvents:UIControlEventValueChanged];
    [ratingView setStepInterval:1.0];
    ratingView.value = 0.0;
    [ratingTextView addSubview:ratingView];
    
    //Add plates to servingSizeTextView
    
    
    UIFloatLabelTextView *prepTimeTextView = [UIFloatLabelTextView new];
    [prepTimeTextView setTranslatesAutoresizingMaskIntoConstraints:NO];
    prepTimeTextView.delegate = self;
    prepTimeTextView.tag = PREPARATIONTEXTVIEW;
    prepTimeTextView.placeholder = @"Preparation Time";
    prepTimeTextView.font = [UIFont fontWithName:@"Copperplate" size:18.0f];
    prepTimeTextView.floatLabel.font = [UIFont fontWithName:@"Copperplate" size:12.0f];
    prepTimeTextView.textAlignment = NSTextAlignmentLeft;
    prepTimeTextView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    prepTimeTextView.layer.borderWidth = 2.0;
    [self.view addSubview:prepTimeTextView];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:prepTimeTextView attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual toItem:ratingTextView
                                                          attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-2.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:prepTimeTextView attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:0.0 constant:-2.0]];
    
    [prepTimeTextView addConstraint:[NSLayoutConstraint
                                     constraintWithItem:prepTimeTextView attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0 constant:textHeight]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:prepTimeTextView attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.5 constant:4.0]];
    
    UIFloatLabelTextView *cookTimeTextView = [UIFloatLabelTextView new];
    [cookTimeTextView setTranslatesAutoresizingMaskIntoConstraints:NO];
    cookTimeTextView.delegate = self;
    cookTimeTextView.tag = COOKTIMETEXTVIEW;
    cookTimeTextView.placeholder = @"Cook Time";
    cookTimeTextView.font = [UIFont fontWithName:@"Copperplate" size:18.0f];
    cookTimeTextView.floatLabel.font = [UIFont fontWithName:@"Copperplate" size:12.0f];
    cookTimeTextView.textAlignment = NSTextAlignmentLeft;
    cookTimeTextView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    cookTimeTextView.layer.borderWidth = 2.0;
    [self.view addSubview:cookTimeTextView];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:cookTimeTextView attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual toItem:ratingTextView
                                                          attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-2.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:cookTimeTextView attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual toItem:prepTimeTextView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-2.0]];
    
    [cookTimeTextView addConstraint:[NSLayoutConstraint
                                     constraintWithItem:cookTimeTextView attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.0 constant:textHeight]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:cookTimeTextView attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.5 constant:4.0]];
    
    NewIngredientsView *ingredientsView = [NewIngredientsView new];
    [ingredientsView setTranslatesAutoresizingMaskIntoConstraints:NO];
    ingredientsView.backgroundColor = [UIColor whiteColor];
    ingredientsView.tag = INGREDIENTVIEW;
    ingredientsView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    ingredientsView.layer.borderWidth = 2.0;
    [self.view addSubview:ingredientsView];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:ingredientsView attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual toItem:cookTimeTextView
                                                          attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-2.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:ingredientsView attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:0.0 constant:-2.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:ingredientsView attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:4.0]];
    
    UIFloatLabelTextView *cookProcessTextView = [UIFloatLabelTextView new];
    [cookProcessTextView setTranslatesAutoresizingMaskIntoConstraints:NO];
    cookProcessTextView.delegate = self;
    cookProcessTextView.tag = COOKPROCESSTEXTVIEW;
    cookProcessTextView.placeholder = @"Cooking Process";
    cookProcessTextView.floatLabel.text = @"Cooking Process";
    cookProcessTextView.textColor = [UIColor clearColor];
    [cookProcessTextView toggleFloatLabel:UIFloatLabelAnimationTypeShow];
    cookProcessTextView.font = [UIFont fontWithName:@"Copperplate" size:18.0f];
    cookProcessTextView.floatLabel.font = [UIFont fontWithName:@"Copperplate" size:12.0f];
    cookProcessTextView.textAlignment = NSTextAlignmentLeft;
    cookProcessTextView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    cookProcessTextView.layer.borderWidth = 2.0;
    UISegmentedControl *processChoice = [[UISegmentedControl alloc]
                                         initWithItems:@[[UIImage imageNamed:@"cooker-25.png"],
                                                         [UIImage imageNamed:@"kitchen-25.png"]]];
    [processChoice setTranslatesAutoresizingMaskIntoConstraints:NO];
    processChoice.tintColor = [UIColor darkGrayColor];
    [cookProcessTextView addSubview:processChoice];
    [self.view addSubview:cookProcessTextView];
    
    //Layout Constraints for the CookProcessTextView
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:cookProcessTextView attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual toItem:ingredientsView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-2.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:cookProcessTextView attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:0.0 constant:-2.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:cookProcessTextView attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.5 constant:4.0]];
    
    [cookProcessTextView addConstraint:[NSLayoutConstraint constraintWithItem:cookProcessTextView
                                                                    attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.0 constant:textHeight]];
    
    //Layout Constraints for the UISegmented Control
    [cookProcessTextView setNeedsLayout];
    [cookProcessTextView layoutIfNeeded];
    [cookProcessTextView.floatLabel sizeToFit];
    [cookProcessTextView addConstraint:[NSLayoutConstraint constraintWithItem:processChoice
                                                                    attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cookProcessTextView.floatLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-1.0]];
    
    [cookProcessTextView addConstraint:[NSLayoutConstraint constraintWithItem:processChoice
                                                                    attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:cookProcessTextView attribute:NSLayoutAttributeWidth multiplier:0.58 constant:0.0]];
    
    [cookProcessTextView addConstraint:[NSLayoutConstraint constraintWithItem:processChoice
                                                                    attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:cookProcessTextView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    
    [cookProcessTextView addConstraint:[NSLayoutConstraint constraintWithItem:processChoice
                                                                    attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:cookProcessTextView attribute:NSLayoutAttributeHeight multiplier:0.58 constant:0.0]];
    
    UIFloatLabelTextView *winePairingTextView = [UIFloatLabelTextView new];
    [winePairingTextView setTranslatesAutoresizingMaskIntoConstraints:NO];
    winePairingTextView.delegate = self;
    winePairingTextView.tag = WINEPAIRTEXTVIEW;
    winePairingTextView.placeholder = @"Wine Pairings";
    winePairingTextView.font = [UIFont fontWithName:@"Copperplate" size:18.0f];
    winePairingTextView.floatLabel.font = [UIFont fontWithName:@"Copperplate" size:12.0f];
    winePairingTextView.textAlignment = NSTextAlignmentLeft;
    winePairingTextView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    winePairingTextView.layer.borderWidth = 2.0;
    [self.view addSubview:winePairingTextView];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:winePairingTextView attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual toItem:ingredientsView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-2.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:winePairingTextView attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual toItem:cookProcessTextView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-2.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:winePairingTextView attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.5 constant:4.0]];
    
    [winePairingTextView addConstraint:[NSLayoutConstraint constraintWithItem:winePairingTextView
                                                                    attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.0 constant:textHeight]];
    
    NewPreparationView *preparationView = [[NewPreparationView alloc] init];
    [preparationView setTranslatesAutoresizingMaskIntoConstraints:NO];
    preparationView.backgroundColor = [UIColor whiteColor];
    preparationView.tag = PREPARATIONTEXTVIEW;
    preparationView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    preparationView.layer.borderWidth = 2.0;
    [self.view addSubview:preparationView];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:preparationView attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual toItem:cookProcessTextView
                                                          attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-2.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:preparationView attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:0.0 constant:-2.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:preparationView attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:4.0]];
    
    UILabel *notesLabel = [[UILabel alloc] init];
    [notesLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    notesLabel.text = @"Notes:";
    notesLabel.font = [UIFont fontWithName:@"Copperplate" size:19.0f];
    notesLabel.textAlignment = NSTextAlignmentLeft;
    [notesLabel sizeToFit];
    [self.view addSubview:notesLabel];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:notesLabel attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual toItem:preparationView attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0 constant:2.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:notesLabel attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:0.0 constant:5.0]];
    
    CSGrowingTextView *notesTextView = [[CSGrowingTextView alloc] init];
    [notesTextView setTranslatesAutoresizingMaskIntoConstraints:NO];
    notesTextView.tag = NOTESTEXTVIEW;
    notesTextView.internalTextView.text = @"Write Down Notes Here:";
    notesTextView.growDirection = CSGrowDirectionDown;
    [self.view addSubview:notesTextView];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:notesTextView attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual toItem:notesLabel
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0 constant:1.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:notesTextView attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual toItem:self.view
                                                          attribute:NSLayoutAttributeLeft multiplier:0.0 constant:3.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:notesTextView attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1.0 constant:0.0]];
    
    _noteViewHeight = [NSLayoutConstraint constraintWithItem:notesTextView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:notesTextView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
    [notesTextView addConstraint:_noteViewHeight];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    imageView.tag = IMAGEVIEW;
    imageView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    imageView.layer.borderWidth = 2.0;
    //imageView.image = [UIImage imageNamed:@"no-photo.png"];
    [self.view addSubview:imageView];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual toItem:notesTextView
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0 constant:10.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual toItem:self.view
                                                          attribute:NSLayoutAttributeLeft multiplier:0.0 constant:-2.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1.0 constant:4.0]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIResponder
-(void)textViewDidBeginEditing:(UITextView *)textView {
    UIFloatLabelTextView *tempView = (UIFloatLabelTextView*)textView;
    [tempView toggleFloatLabel:UIFloatLabelAnimationTypeShow];
    textView.text = @"";
    [tempView.floatLabel sizeToFit];
    textView.textColor = [UIColor blackColor];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if(![touch.view isKindOfClass:[UITextView class]]) {
        [touch.view endEditing:YES];
    }
}

#pragma mark - Help Methods
-(void)ratingChanged {
    NSLog(@"rating changed");
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
