//
//  NotesDetailViewController.h
//  BlocNotes
//
//  Created by Weinan Qiu on 2015-09-14.
//  Copyright (c) 2015 Kumiq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"

@class NotesDetailViewController;

@protocol NotesDetailViewControllerDelegate <NSObject>

- (void)notesDetailViewController:(NotesDetailViewController *)detailViewController didFinishWithNote:(Note *)note;

@end

@interface NotesDetailViewController : UIViewController

@property (nonatomic, strong, readonly) Note *note;
@property (nonatomic, weak) id <NotesDetailViewControllerDelegate> delegate;

- (instancetype)initWithNote:(Note *)note;

@end
