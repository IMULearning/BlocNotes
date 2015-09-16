//
//  NotesSplitViewController.h
//  BlocNotes
//
//  Created by Weinan Qiu on 2015-09-14.
//  Copyright (c) 2015 Kumiq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotesTableViewController.h"
#import "NotesEditViewController.h"
#import "NotesStartViewController.h"

@interface NotesSplitViewController : UISplitViewController <NotesTableViewControllerDelegate>

@property (nonatomic, strong) NotesTableViewController *masterVC;
@property (nonatomic, strong) NotesEditViewController *detailVC;
@property (nonatomic, strong) NotesStartViewController *emptyStateVC;

@property (nonatomic, strong) UINavigationController *detailNavVC;

@end
