//
//  DetailViewController.h
//  Recipe Journal
//
//  Created by Robert Miller on 2/6/15.
//  Copyright (c) 2015 Robert Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Event.h"
#import "RecipeJournalHelper.h"

@interface DetailViewController : UIViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) Event *detailItem;

@end

