//
//  InfoViewController.m
//  Recipe Journal
//
//  Created by Robert Miller on 7/9/15.
//  Copyright (c) 2015 Robert Miller. All rights reserved.
//

#import "InfoViewController.h"

@interface InfoViewController ()

@end

@implementation InfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UITextView *textView = [[UITextView alloc] init];
    [textView setTranslatesAutoresizingMaskIntoConstraints:NO];
    textView.backgroundColor = [UIColor whiteColor];
    textView.editable = NO;
    //textView.font = [UIFont flatFontOfSize:14.0f];
    textView.text =
    @"This app was developed by me, Robert Miller\nYou can contact me at RobertMiller2543 at me.com\nFeel free to email me with any bugs, suggestions, questions, or comments, I would love to hear from all of you..\nI would like to thank everyone that helped, including all of my friends and family for the suggestion of the app and for beta testing..\n\nI have to give a ton of props to CocoaPods.org and the following developers:\n\nRoman Efimov at github.com/romaonthego for the use of REMenu\nKevin at github.com/kevinzhow for the use of PNChart\nMichael Zabrowski at github.com/m1entus for the use of MZFormSheetController\nGrouper, Inc. at github.com/jflinter for the use of FlatUIKit\nCharcoal Design at github.com/nicklockwood for the use of FXBlurView\nVictor\nBaro at github.com/victorBaro for the use of VBFPopFlatButton\nMohd Iftekhar Qurashi at github.com/hackiftekhar for the use of IQDropDownTextField\nTom Konig at github.com/TomKnig for the use of TOMSMorphingLabel\nJared Verdi at github.com/jverdi for the use of JVFloatLabeledTextField\n\nEnjoy!!";
    [self.view addSubview:textView];
    
    NSDictionary *viewBindings = NSDictionaryOfVariableBindings(self.view, textView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[textView]-5-|" options:0 metrics:0 views:viewBindings]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[textView]-5-|"
                                                                      options:NSLayoutFormatAlignAllBaseline
                                                                      metrics:nil
                                                                        views:viewBindings]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:textView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.0 constant:120]];
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
