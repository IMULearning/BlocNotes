//
//  NotesEditViewController.h
//  BlocNotes
//
//  Created by Weinan Qiu on 2015-09-15.
//  Copyright (c) 2015 Kumiq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"

@class NotesEditViewController;

@protocol NotesEditViewControllerDelegate <NSObject>

- (void)notesEditViewController:(NotesEditViewController *)notesEditViewController
              didFinishWithNote:(Note *)note;

- (void)notesEditViewController:(NotesEditViewController *)notesEditViewController
                receivedNewNote:(Note *)newNote
               toReplaceOldNote:(Note *)oldNote;
@end

@interface NotesEditViewController : UIViewController

@property (nonatomic, weak) id<NotesEditViewControllerDelegate> delegate;
@property (nonatomic, strong) Note* note;

@end
