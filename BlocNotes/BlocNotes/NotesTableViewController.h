//
//  NotesTableViewController.h
//  BlocNotes
//
//  Created by Weinan Qiu on 2015-09-15.
//  Copyright (c) 2015 Kumiq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotesStartViewController.h"
#import "NotesEditViewController.h"

@class NotesTableViewController;
@class Note;

@protocol NotesTableViewControllerDelegate <NSObject>

- (void) notesTableViewController:(NotesTableViewController *)notesTableViewController
                   didFocusOnNote:(Note *)note;

- (void) notesTableViewController:(NotesTableViewController *)notesTableViewController
                requestToEditNote:(Note *)note;

@end

@interface NotesTableViewController : UITableViewController <NotesStartViewControllerDelegate, NotesEditViewControllerDelegate>

@property (nonatomic, weak) id <NotesTableViewControllerDelegate> delegate;

@end
