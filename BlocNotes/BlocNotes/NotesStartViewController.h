//
//  NotesStartViewController.h
//  BlocNotes
//
//  Created by Weinan Qiu on 2015-09-15.
//  Copyright (c) 2015 Kumiq. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NotesStartViewController;

@protocol NotesStartViewControllerDelegate <NSObject>

- (void) didRequestNewNoteFromNotesStartViewController:(NotesStartViewController *)notesStartViewController;

@end

@interface NotesStartViewController : UIViewController

@property (nonatomic, weak) id <NotesStartViewControllerDelegate> delegate;

@end
